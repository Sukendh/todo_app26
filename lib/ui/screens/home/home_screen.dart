import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/models/task_model.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/task/task_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../task/add_edit_task_screen.dart';
import '../../widgets/task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Tasks', style: Theme.of(context).textTheme.displayLarge),
                      Text(DateFormat('EEEE, MMM d').format(DateTime.now()), 
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showLogoutDialog(context),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'), 
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Summary Cards (Responsive Layout)
              LayoutBuilder(
                builder: (context, constraints) {
                  return _buildSummaryCards(context);
                },
              ),
              const SizedBox(height: 32),

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.white54,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                ],
              ),
              const SizedBox(height: 24),

              // Task List
              Expanded(
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TasksLoaded) {
                      final activeTasks = state.tasks.where((t) => !t.isCompleted).toList();
                      final completedTasks = state.tasks.where((t) => t.isCompleted).toList();
                      
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTaskList(activeTasks, 'Active'),
                          _buildTaskList(completedTasks, 'Completed'),
                        ],
                      );
                    } else if (state is TaskOperationError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const Center(child: Text('No tasks yet.'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        int completed = 0;
        int total = 0;
        if (state is TasksLoaded) {
          total = state.tasks.length;
          completed = state.tasks.where((t) => t.isCompleted).length;
        }
        
        return Row(
          children: [
            _buildSummaryCard(
              'COMPLETED',
              '$completed/$total',
              Icons.check_box_outlined,
              borderColor: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(width: 16),
            _buildSummaryCard(
              'REMAINING',
              '${total - completed}',
              Icons.timer_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, {Color? borderColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(count, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, String type) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks found.'));
    }

    final highPriority = tasks.where((t) => t.priority == 'High').toList();
    final others = tasks.where((t) => t.priority != 'High').toList();

    return ListView(
      children: [
        if (highPriority.isNotEmpty) _buildSectionHeader('HIGH PRIORITY'),
        ...highPriority.map((task) => TaskItem(task: task)),
        const SizedBox(height: 24),
        if (others.isNotEmpty) _buildSectionHeader('UPCOMING'),
        ...others.map((task) => TaskItem(task: task)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.pop(dialogContext);
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

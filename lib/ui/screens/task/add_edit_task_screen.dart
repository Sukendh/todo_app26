import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/models/task_model.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/task/task_bloc.dart';
import '../../../core/theme/app_theme.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _priority;
  late String _category;
  late DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? 'Medium';
    _category = widget.task?.category ?? 'Work';
    _dueDate = widget.task?.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.task != null;
    final authState = context.read<AuthBloc>().state as Authenticated;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEdit ? 'Edit Task' : 'Add New Task', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
              onPressed: () => _confirmDelete(context, authState),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('TASK TITLE'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'What needs to be done?'),
            ),
            const SizedBox(height: 32),

            _buildLabel('DESCRIPTION'),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Add more details about this task...'),
            ),
            const SizedBox(height: 32),

            _buildLabel('DUE DATE'),
            _buildDatePicker(context),
            const SizedBox(height: 32),

            Row(
                children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                _buildLabel('PRIORITY'),
                                Row(
                                    children: [
                                        _buildPriorityOption('Low', Icons.arrow_downward, AppColors.lowPriority),
                                        const SizedBox(width: 8),
                                        _buildPriorityOption('Medium', Icons.drag_handle, AppColors.midPriority),
                                        const SizedBox(width: 8),
                                        _buildPriorityOption('High', Icons.arrow_upward, AppColors.highPriority),
                                    ],
                                ),
                            ],
                        ),
                    ),
                ],
            ),
            const SizedBox(height: 32),

            _buildLabel('CATEGORY'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('Work', Icons.work_outline),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Personal', Icons.person_outline),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Shopping', Icons.shopping_cart_outlined),
                  const SizedBox(width: 12),
                  _buildCategoryChip('New', Icons.add, isNew: true),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  final task = Task(
                    id: widget.task?.id,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    isCompleted: widget.task?.isCompleted ?? false,
                    dueDate: _dueDate,
                    priority: _priority,
                    category: _category,
                    timestamp: DateTime.now(),
                  );

                  if (isEdit) {
                    context.read<TaskBloc>().add(
                          UpdateTaskRequested(authState.user.id, authState.user.token, task),
                        );
                  } else {
                    context.read<TaskBloc>().add(
                          AddTaskRequested(authState.user.id, authState.user.token, task),
                        );
                  }
                  Navigator.pop(context);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isEdit ? Icons.check : Icons.add_circle_outline, size: 24),
                  const SizedBox(width: 12),
                  Text(isEdit ? 'Save Changes' : 'Create Task'),
                ],
              ),
            ),
            if (isEdit) 
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OutlinedButton(
                  onPressed: () => _confirmDelete(context, authState),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.highPriority, width: 1.5),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    foregroundColor: AppColors.highPriority,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline),
                      const SizedBox(width: 8),
                      const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => _dueDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dueDate != null ? DateFormat('MMMM d, y').format(_dueDate!) : 'Set Due Date',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                if (_dueDate != null)
                  Text(
                    DateFormat('EEEE, h:mm a').format(_dueDate!),
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String type, IconData icon, Color color) {
    bool isSelected = _priority == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected 
                ? Border.all(color: AppColors.primary, width: 2) 
                : Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String type, IconData icon, {bool isNew = false}) {
    bool isSelected = _category == type;
    return GestureDetector(
      onTap: isNew ? () {} : () => setState(() => _category = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: isNew ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.white60, size: 18),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white60,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Authenticated auth) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(
                    DeleteTaskRequested(auth.user.id, auth.user.token, widget.task!.id!),
                  );
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close screen
            },
               child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

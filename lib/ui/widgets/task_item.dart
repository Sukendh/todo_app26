import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app26/ui/screens/task/add_edit_task_screen.dart';
import '../../../data/models/task_model.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/task/task_bloc.dart';
import '../../core/theme/app_theme.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // We expect the state to be Authenticated here because TaskItem is only shown in HomeScreen
    final authState = context.read<AuthBloc>().state as Authenticated;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditTaskScreen(task: task),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Checkbox Circle
            GestureDetector(
              onTap: () {
                context.read<TaskBloc>().add(
                  UpdateTaskRequested(
                    authState.user.id,
                    authState.user.token,
                    task.copyWith(isCompleted: !task.isCompleted),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.primary
                        : Colors.white38,
                    width: 2,
                  ),
                  color: task.isCompleted
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted ? Colors.white38 : Colors.white,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        task.dueDate != null
                            ? Icons.calendar_today_outlined
                            : Icons.timer_outlined,
                        size: 14,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task.dueDate != null
                            ? DateFormat('EEEE, MMM d').format(task.dueDate!)
                            : 'No due date',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Reorder/Dots
            const Icon(Icons.drag_indicator_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

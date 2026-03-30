import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/task_service.dart';

// Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String userId;
  final String token;
  const LoadTasks({required this.userId, required this.token});
  @override
  List<Object?> get props => [userId, token];
}

class AddTaskRequested extends TaskEvent {
  final String userId;
  final String token;
  final Task task;
  const AddTaskRequested(this.userId, this.token, this.task);
  @override
  List<Object?> get props => [userId, token, task];
}

class UpdateTaskRequested extends TaskEvent {
  final String userId;
  final String token;
  final Task task;
  const UpdateTaskRequested(this.userId, this.token, this.task);
  @override
  List<Object?> get props => [userId, token, task];
}

class DeleteTaskRequested extends TaskEvent {
  final String userId;
  final String token;
  final String taskId;
  const DeleteTaskRequested(this.userId, this.token, this.taskId);
  @override
  List<Object?> get props => [userId, token, taskId];
}

// States
abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  const TasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TaskOperationError extends TaskState {
  final String message;
  const TaskOperationError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService taskService;

  TaskBloc({required this.taskService}) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await taskService.getTasks(event.userId, event.token);
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TaskOperationError(e.toString()));
      }
    });

    on<AddTaskRequested>((event, emit) async {
      try {
        await taskService.addTask(event.userId, event.token, event.task);
        add(LoadTasks(userId: event.userId, token: event.token));
      } catch (e) {
        emit(TaskOperationError(e.toString()));
      }
    });

    on<UpdateTaskRequested>((event, emit) async {
      try {
        await taskService.updateTask(event.userId, event.token, event.task);
        add(LoadTasks(userId: event.userId, token: event.token));
      } catch (e) {
        emit(TaskOperationError(e.toString()));
      }
    });

    on<DeleteTaskRequested>((event, emit) async {
      try {
        await taskService.deleteTask(event.userId, event.token, event.taskId);
        add(LoadTasks(userId: event.userId, token: event.token));
      } catch (e) {
        emit(TaskOperationError(e.toString()));
      }
    });
  }
}

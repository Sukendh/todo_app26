import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/task_model.dart';

class TaskService {
  final http.Client _client = http.Client();

  // GET: Fetch all tasks
  Future<List<Task>> getTasks(String userId, String token) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.dbBaseUrl}tasks/$userId.json?auth=$token'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = jsonDecode(response.body);
      if (data == null) return [];
      
      return data.entries.map((e) => Task.fromJson(e.value, e.key)).toList();
    } else {
      throw Exception('Failed to fetch tasks: ${response.statusCode}');
    }
  }

  // POST: Add a new task
  Future<Task> addTask(String userId, String token, Task task) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.dbBaseUrl}tasks/$userId.json?auth=$token'),
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final taskId = data['name']; // Firebase returns ID in 'name' field for POST
      return task.copyWith(id: taskId);
    } else {
      throw Exception('Failed to add task: ${response.statusCode}');
    }
  }

  // PATCH: Edit/Update a task
  Future<void> updateTask(String userId, String token, Task task) async {
    if (task.id == null) throw Exception('Task ID cannot be null for update');
    
    final response = await _client.patch(
      Uri.parse('${ApiConstants.dbBaseUrl}tasks/$userId/${task.id}.json?auth=$token'),
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${response.statusCode}');
    }
  }

  // DELETE: Delete a task
  Future<void> deleteTask(String userId, String token, String taskId) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.dbBaseUrl}tasks/$userId/$taskId.json?auth=$token'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task: ${response.statusCode}');
    }
  }
}

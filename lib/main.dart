import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/task_service.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/task/task_bloc.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final taskService = TaskService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authService: authService),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(taskService: taskService),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter To-Do REST',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Trigger task loading when authenticated
          context.read<TaskBloc>().add(
                LoadTasks(userId: state.user.id, token: state.user.token),
              );
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomeScreen();
        } else if (state is AuthInitial || state is Unauthenticated || state is AuthError) {
          return const LoginScreen();
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return const LoginScreen();
      },
    );
  }
}

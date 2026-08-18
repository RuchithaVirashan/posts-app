import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_event.dart';
import 'presentation/auth/bloc/auth_state.dart';
import 'presentation/auth/view/login_page.dart';
import 'presentation/dashboard/bloc/posts_bloc.dart';
import 'presentation/dashboard/bloc/posts_event.dart';
import 'presentation/main/view/main_shell.dart';

class PostsApp extends StatelessWidget {
  const PostsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: BlocProvider(
        create: (_) =>
            sl<AuthBloc>()..add(const AuthSessionRestoreRequested()),
        child: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!_splashDone &&
            (state is AuthAuthenticated || state is AuthUnauthenticated)) {
          setState(() => _splashDone = true);
        }
      },
      builder: (context, state) {
        if (!_splashDone) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          return BlocProvider(
            create: (_) => sl<PostsBloc>()..add(const PostsStarted()),
            child: const MainShell(),
          );
        }
        return const LoginPage();
      },
    );
  }
}

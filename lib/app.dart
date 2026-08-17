import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/user.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_event.dart';
import 'presentation/auth/bloc/auth_state.dart';
import 'presentation/auth/view/login_page.dart';

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
          return _PlaceholderHomePage(user: state.user);
        }
        return const LoginPage();
      },
    );
  }
}

class _PlaceholderHomePage extends StatelessWidget {
  const _PlaceholderHomePage({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts App')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome, ${user.displayName}', style: AppTextStyles.title),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthLogoutRequested()),
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}

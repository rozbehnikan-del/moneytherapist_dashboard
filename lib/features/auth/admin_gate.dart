import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'admin_access_model.dart';
import 'admin_access_service.dart';
import '../home/main_shell_page.dart';



class AdminGate extends StatefulWidget {
  const AdminGate({super.key});

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  late final AdminAccessService _service;
  late Future<AdminAccessModel> _futureAccess;

  @override
  void initState() {
    super.initState();
    _service = AdminAccessService(Dio());
    _futureAccess = _service.checkAccess();
  }

  Future<void> _retry() async {
    setState(() {
      _futureAccess = _service.checkAccess();
    });

    await _futureAccess;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminAccessModel>(
      future: _futureAccess,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AdminLoadingScreen();
        }

        if (snapshot.hasError) {
          return _AdminErrorScreen(
            error: snapshot.error.toString(),
            onRetry: _retry,
          );
        }

        final access = snapshot.data;

        if (access == null || !access.allowed) {
          return _AccessDeniedScreen(onRetry: _retry);
        }

        return MainShellPage(
          adminUsername: access.telegramUsername,
          adminRole: access.role,
        );
      },
    );
  }
}

class _AdminLoadingScreen extends StatelessWidget {
  const _AdminLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F8FB),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _AdminErrorScreen extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;

  const _AdminErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFF991B1B),
                  size: 44,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin check failed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessDeniedScreen extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _AccessDeniedScreen({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF991B1B),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This control panel is only available for approved Telegram admins.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Check again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../features/landing/presentation/widgets/app_header.dart';

/// Global shell widget that wraps all pages with consistent AppHeader
class AppShell extends StatelessWidget {
  final Widget child;
  final bool showHeader;

  const AppShell({
    super.key,
    required this.child,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showHeader) {
      return child;
    }

    return Scaffold(
      appBar: const AppHeader(),
      body: child,
    );
  }
}

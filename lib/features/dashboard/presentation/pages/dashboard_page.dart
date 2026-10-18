import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../widgets/admin_dashboard.dart';
import '../widgets/agency_dashboard.dart';
import '../widgets/brand_dashboard.dart';
import '../widgets/media_owner_dashboard.dart';

/// Kontrolna tabla prema ulozi prijavljenog korisnika.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: state is AuthAuthenticated
              ? _forRole(state)
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _forRole(AuthAuthenticated state) {
    // Ključ po korisniku: nova prijava dobija sveže podatke.
    final key = ValueKey('dashboard-${state.user.id}-${state.user.role}');
    switch (state.user.role) {
      case Role.admin:
        return AdminDashboard(key: key, user: state.user);
      case Role.mediaOwner:
        return MediaOwnerDashboard(key: key, user: state.user);
      case Role.brand:
        return BrandDashboard(key: key, user: state.user);
      case Role.agency:
        return AgencyDashboard(key: key, user: state.user);
    }
  }
}

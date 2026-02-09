import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../widgets/admin_dashboard.dart';
import '../widgets/agency_dashboard.dart';
import '../widgets/brand_dashboard.dart';
import '../widgets/media_owner_dashboard.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: _buildDashboardForRole(context, state, l10n),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      },
    );
  }

  Widget _buildDashboardForRole(
    BuildContext context,
    AuthAuthenticated state,
    AppLocalizations l10n,
  ) {
    switch (state.user.role) {
      case Role.admin:
        return AdminDashboard(user: state.user);
      case Role.mediaOwner:
        return MediaOwnerDashboard(user: state.user);
      case Role.brand:
        return BrandDashboard(user: state.user);
      case Role.agency:
        return AgencyDashboard(user: state.user);
    }
  }
}

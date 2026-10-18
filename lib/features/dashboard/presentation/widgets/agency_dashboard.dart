import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../data/repository/analytics_repository.dart';
import '../blocs/analytics_bloc.dart';
import 'client_dashboard.dart';

/// Kontrolna tabla agencije (kao brend, uz brendove i upite po brendu).
class AgencyDashboard extends StatelessWidget {
  final User user;

  const AgencyDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(context.read<AnalyticsRepository>())
        ..add(LoadAgencyAnalytics()),
      child: ClientDashboard(user: user, agency: true),
    );
  }
}

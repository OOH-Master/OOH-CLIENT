import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../data/repository/analytics_repository.dart';
import '../blocs/analytics_bloc.dart';
import 'client_dashboard.dart';

/// Kontrolna tabla brenda.
class BrandDashboard extends StatelessWidget {
  final User user;

  const BrandDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(context.read<AnalyticsRepository>())
        ..add(LoadBrandAnalytics()),
      child: ClientDashboard(user: user, agency: false),
    );
  }
}

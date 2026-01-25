import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            l10n.comingSoon,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          const Text('Google Maps Integration'),
        ],
      ),
    );
  }
}

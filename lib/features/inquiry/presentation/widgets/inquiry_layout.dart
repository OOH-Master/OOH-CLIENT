import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../utils/inquiry_errors.dart';

/// Raspored stranica upita, usklađen sa AppFrame-om: od 900 px prozor ima
/// bočni meni, pa stranica počinje svojim PageHeader-om; na užem prozoru
/// stranica ima tanak AppBar sa naslovom.
class InquiryLayout {
  InquiryLayout._();

  static const double wideWindow = 900;
  static const double maxContentWidth = 1240;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideWindow;

  /// Bočni razmak: 32 na širokom ekranu, 16 na telefonu, a na vrlo širokom
  /// prostoru toliko da sadržaj ne bude širi od [maxContentWidth].
  static double gutter(double available, {required bool wide}) {
    final base = wide ? 32.0 : 16.0;
    final extra = (available - maxContentWidth - 2 * base) / 2;
    return extra > 0 ? base + extra : base;
  }
}

/// Scaffold stranice upita: AppBar samo na uskom prozoru (na širokom naslov
/// nosi [InquiryHeader]).
class InquiryScaffold extends StatelessWidget {
  final String title;
  final List<Widget> appBarActions;
  final Widget body;
  final Widget? bottomBar;

  const InquiryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.appBarActions = const [],
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    final wide = InquiryLayout.isWide(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide
          ? null
          : AppBar(
              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: [...appBarActions, const SizedBox(width: 4)],
            ),
      body: body,
      bottomNavigationBar: bottomBar,
    );
  }
}

/// Zaglavlje u toku sadržaja: na širokom ekranu PageHeader (naslov, opis,
/// akcije), na telefonu samo opis i akcije, jer naslov već stoji u AppBar-u.
class InquiryHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;

  const InquiryHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    if (InquiryLayout.isWide(context)) {
      // PageHeader slaže akcije u jedan red; kada je sadržaj uzan (meni je
      // otvoren), akcije prelaze ispod naslova da red ne bi bio prepun.
      return LayoutBuilder(builder: (context, constraints) {
        final inline = actions.length < 2 || constraints.maxWidth >= 1000;
        final header = PageHeader(
          title: title,
          subtitle: subtitle,
          actions: inline ? actions : const [],
          showBack: showBack,
          padding: EdgeInsets.fromLTRB(0, 28, 0, inline ? 22 : 14),
        );
        if (inline) return header;
        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Padding(
                // poravnato sa naslovom, desno od dugmeta za povratak
                padding: EdgeInsets.only(left: showBack ? 50 : 0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: actions,
                ),
              ),
            ],
          ),
        );
      });
    }
    if ((subtitle == null || subtitle!.isEmpty) && actions.isEmpty) {
      return const SizedBox(height: 16);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null && subtitle!.isNotEmpty)
            Text(
              subtitle!,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.mutedForeground),
            ),
          if (actions.isNotEmpty) ...[
            if (subtitle != null && subtitle!.isNotEmpty)
              const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}

/// Kartice u jednoj ili dve kolone (dve od prozora širine 1100 px, ako sadržaj
/// ima bar 700 px); u redu sa dve kartice obe su iste visine.
class InquiryCardGrid extends StatelessWidget {
  final int itemCount;

  /// [fill] je `true` kada kartica treba da popuni visinu reda.
  final Widget Function(BuildContext context, int index, bool fill) itemBuilder;

  /// Najmanja širina prozora za dve kolone.
  final double twoColumnWindow;

  /// Najmanja širina sadržaja za dve kolone (meni zauzima deo prozora).
  final double twoColumnWidth;
  final double spacing;

  const InquiryCardGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.twoColumnWindow = 1100,
    this.twoColumnWidth = 700,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final window = MediaQuery.sizeOf(context).width;
    return LayoutBuilder(builder: (context, constraints) {
      final twoColumns =
          window >= twoColumnWindow && constraints.maxWidth >= twoColumnWidth;
      if (!twoColumns) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < itemCount; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              itemBuilder(context, i, false),
            ],
          ],
        );
      }
      final rows = <Widget>[];
      for (var i = 0; i < itemCount; i += 2) {
        if (i > 0) rows.add(SizedBox(height: spacing));
        rows.add(IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: itemBuilder(context, i, true)),
              SizedBox(width: spacing),
              Expanded(
                child: i + 1 < itemCount
                    ? itemBuilder(context, i + 1, true)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ));
      }
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
    });
  }
}

/// Učitavanje celog ekrana.
class InquiryLoadingView extends StatelessWidget {
  const InquiryLoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Greška pri učitavanju: kratko objašnjenje na srpskom i ponovni pokušaj.
class InquiryErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;
  final String title;

  const InquiryErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.title = 'Podaci nisu učitani',
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_outlined,
      title: title,
      message: InquiryErrors.describe(error),
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Pokušaj ponovo'),
      ),
    );
  }
}

/// Kratka poruka na dnu ekrana; greške na crvenoj podlozi.
void showInquirySnack(BuildContext context, String message,
    {bool error = false, bool success = false}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error
          ? AppColors.destructive
          : success
              ? AppColors.success
              : null,
    ));
}

/// Tanka traka napretka dok se podaci osvežavaju, a stari prikaz ostaje.
class InquiryRefreshBar extends StatelessWidget {
  final bool visible;

  const InquiryRefreshBar({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: visible
          ? const LinearProgressIndicator(minHeight: 2)
          : const SizedBox.shrink(),
    );
  }
}

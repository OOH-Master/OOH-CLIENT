import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/domain/entities/user.dart';

/// Okvir kontrolne table: naslov sa nazivom firme ispod, glavne akcije desno,
/// sadržaj do 1240 px širine, povlačenje za osvežavanje (telefon) i dugme za
/// osvežavanje (široki ekran, gde povlačenja nema).
class DashboardScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Future<void> Function() onRefresh;
  final List<Widget> children;

  const DashboardScaffold({
    super.key,
    this.title = 'Kontrolna tabla',
    this.subtitle,
    this.actions = const [],
    required this.onRefresh,
    required this.children,
  });

  static const double maxContentWidth = 1240;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final side = compact ? 16.0 : 32.0;
    final gap = compact ? 16.0 : 20.0;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth + side * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: title,
                  subtitle: subtitle,
                  actions: [
                    ...actions,
                    if (!compact) _RefreshButton(onPressed: onRefresh),
                  ],
                ),
                Padding(
                  padding:
                      EdgeInsets.fromLTRB(side, 0, side, compact ? 28 : 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        if (i > 0) SizedBox(height: gap),
                        children[i],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Osvežavanje podataka table; poslednja akcija u zaglavlju.
class _RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RefreshButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Osveži',
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(46, 46),
          padding: EdgeInsets.zero,
        ),
        child: const Icon(Icons.refresh_rounded, size: 18),
      ),
    );
  }
}

/// Podnaslov table: naziv firme; stručnjak za lokacije radi u ime platforme,
/// pa za njega stoji ime (ili ništa).
String? dashboardSubtitle(User user) {
  String? pick(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
  if (user.role == Role.admin) return pick(user.firstName);
  return pick(user.companyName) ?? pick(user.firstName);
}

/// Dve kolone na širokom ekranu (levo šire), jedna ispod druge na užem.
class DashboardColumns extends StatelessWidget {
  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;

  const DashboardColumns({
    super.key,
    required this.left,
    required this.right,
    this.leftFlex = 3,
    this.rightFlex = 2,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final gap = compact ? 16.0 : 20.0;
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 860) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, SizedBox(height: gap), right],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: leftFlex, child: left),
          SizedBox(width: gap),
          Expanded(flex: rightFlex, child: right),
        ],
      );
    });
  }
}

/// Sekcija koja se učitava: sivi redovi umesto sadržaja.
class SectionSkeleton extends StatelessWidget {
  final int rows;

  const SectionSkeleton({super.key, this.rows = 3});

  @override
  Widget build(BuildContext context) {
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widthFactor,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            bar(0.4, 12),
            const SizedBox(height: 8),
            bar(0.75, 10),
          ],
        ],
      ),
    );
  }
}

/// Sekcija čiji podaci nisu stigli: naslov i ponovni pokušaj.
class SectionFailure extends StatelessWidget {
  final VoidCallback onRetry;
  final String title;

  const SectionFailure(
      {super.key, required this.onRetry, this.title = 'Podaci nisu učitani'});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      compact: true,
      icon: Icons.cloud_off_rounded,
      title: title,
      action: TextButton(
        onPressed: onRetry,
        child: const Text('Pokušaj ponovo'),
      ),
    );
  }
}

/// Veza u zaglavlju sekcije ("Svi upiti"): obojen tekst.
class SectionLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SectionLink({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 34),
        textStyle:
            AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

/// Tanka linija između redova u kartici.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColors.borderSoft);
}

/// Kartica sa listom redova: zaglavlje kao u [SectionCard] (naslov, podatak
/// desno od naslova, veza), a pozadina reda pri prelazu mišem izlazi malo van
/// poravnanja sadržaja.
class ListSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  /// `true` kada je [child] lista redova sa sopstvenim unutrašnjim razmakom.
  final bool rows;

  const ListSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.rows = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 10,
                      children: [
                        Text(title,
                            style: AppTypography.labelLarge.copyWith(
                                fontSize: 15.5, color: AppColors.foreground)),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.mutedForeground),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            rows
                ? child
                : Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: child,
                  ),
          ],
        ),
      ),
    );
  }
}

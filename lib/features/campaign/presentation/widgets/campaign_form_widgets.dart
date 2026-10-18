import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';

/// Okvir forme kampanje: zaglavlje (na telefonu AppBar), sadržaj u karticama i
/// traka za čuvanje zalepljena za dno.
class CampaignFormScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget Function(BuildContext context, double width) builder;
  final bool loading;
  final String saveLabel;
  final VoidCallback onSave;

  const CampaignFormScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.builder,
    required this.loading,
    required this.saveLabel,
    required this.onSave,
  });

  void _cancel(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/app/campaigns');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide ? null : AppBar(title: Text(title)),
      bottomNavigationBar: _ActionBar(
        wide: wide,
        loading: loading,
        saveLabel: saveLabel,
        onCancel: () => _cancel(context),
        onSave: onSave,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = wide ? 32.0 : 16.0;
          final gutter = math.max(side, (constraints.maxWidth - 1240) / 2);
          final width = constraints.maxWidth - 2 * gutter;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(gutter, wide ? 0 : 16, gutter, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wide)
                  PageHeader(
                    title: title,
                    subtitle: subtitle,
                    showBack: true,
                    padding: const EdgeInsets.only(top: 28, bottom: 22),
                  ),
                builder(context, width),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool wide;
  final bool loading;
  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _ActionBar({
    required this.wide,
    required this.loading,
    required this.saveLabel,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final save = FilledButton.icon(
      onPressed: loading ? null : onSave,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.subtle),
            )
          : const Icon(Icons.check_rounded, size: 20),
      label: Text(saveLabel),
    );
    final cancel = OutlinedButton(
      onPressed: loading ? null : onCancel,
      child: const Text('Otkaži'),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = wide ? 32.0 : 16.0;
            final gutter = math.max(side, (constraints.maxWidth - 1240) / 2);
            return Padding(
              padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 12),
              child: wide
                  ? Row(
                      children: [
                        const Spacer(),
                        cancel,
                        const SizedBox(width: 12),
                        save,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: cancel),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: save),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// Dve kartice jedna pored druge na širokom ekranu, inače jedna ispod druge.
class CampaignFormColumns extends StatelessWidget {
  final double width;
  final List<Widget> left;
  final List<Widget> right;

  const CampaignFormColumns({
    super.key,
    required this.width,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> spaced(List<Widget> items) => [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            items[i],
          ],
        ];

    if (width >= 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Column(children: spaced(left))),
          const SizedBox(width: 20),
          Expanded(flex: 2, child: Column(children: spaced(right))),
        ],
      );
    }
    return Column(children: spaced([...left, ...right]));
  }
}

/// Polje datuma: prikazuje "16.11.2026.", a bira se iz kalendara.
class CampaignDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const CampaignDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined, size: 20),
          suffixIcon: const Icon(Icons.expand_more_rounded, size: 20),
        ),
        child: Text(
          value == null ? '' : SrFormat.date(value),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
        ),
      ),
    );
  }
}

/// Trajanje izabranog perioda, ili upozorenje kada je kraj pre početka.
/// Dok oba datuma nisu izabrana, ne prikazuje ništa.
class CampaignPeriodHint extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;

  const CampaignPeriodHint({super.key, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    if (start == null || end == null) return const SizedBox.shrink();
    if (end!.isBefore(start!)) {
      return Text(
        'Kraj zakupa je pre početka.',
        style: AppTypography.caption.copyWith(color: AppColors.destructive),
      );
    }
    final days = end!.difference(start!).inDays + 1;
    return Text(
      'Trajanje: ${SrFormat.daysLabel(days)}',
      style: AppTypography.caption.copyWith(color: AppColors.text2),
    );
  }
}

/// ISO datum za API ("2026-11-16").
String campaignIsoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Iznos budžeta iz polja ("1200", "1200,50").
double? campaignBudget(String text) {
  final t = text.trim().replaceAll(' ', '').replaceAll(',', '.');
  return t.isEmpty ? null : double.tryParse(t);
}

/// Zajednički izgled kartice forme kampanje.
class CampaignFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const CampaignFormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            children[i],
          ],
        ],
      ),
    );
  }
}

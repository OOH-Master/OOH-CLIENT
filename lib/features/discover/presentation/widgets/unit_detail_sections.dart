import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../domain/entities/ooh_unit.dart';
import 'inventory_map.dart';
import 'unit_card_parts.dart';
import 'unit_labels.dart';

/// Trajanje jednog ciklusa zakupa i primeri trajanja kampanje (u danima).
class _CycleInfo {
  final int days;

  /// "4 nedelje"
  final String span;
  final List<int> examples;

  const _CycleInfo(this.days, this.span, this.examples);

  static _CycleInfo of(CycleType type) {
    switch (type) {
      case CycleType.oneDay:
        return const _CycleInfo(1, '1 dan', [7, 14, 30]);
      case CycleType.oneWeek:
        return const _CycleInfo(7, '1 nedelja', [7, 14, 28, 56]);
      case CycleType.twoWeek:
        return const _CycleInfo(14, '2 nedelje', [14, 28, 56]);
      case CycleType.fourWeek:
        return const _CycleInfo(28, '4 nedelje', [14, 28, 56, 84]);
      case CycleType.oneMonth:
        return const _CycleInfo(30, '1 mesec', [30, 60, 90]);
    }
  }

  /// Trajanje kampanje rečima: "8 nedelja", "2 meseca", "14 dana".
  String durationLabel(int d) {
    if (days == 30) {
      return SrFormat.count(d ~/ 30, 'mesec', 'meseca', 'meseci');
    }
    if (days >= 7 && d % 7 == 0) {
      return SrFormat.count(d ~/ 7, 'nedelja', 'nedelje', 'nedelja');
    }
    return SrFormat.daysLabel(d);
  }

  int cyclesFor(int d) => (d / days).ceil();
}

/// Kartica sa cenom desno od fotografije: cena za period zakupa, dostupnost,
/// vlasnik, kratki podaci i dugmad "Dodaj u upit" i "Pošalji upit".
class UnitPriceCard extends StatelessWidget {
  final OohUnit unit;
  final bool inBasket;
  final VoidCallback onToggleInquiry;
  final VoidCallback onSendInquiry;

  const UnitPriceCard({
    super.key,
    required this.unit,
    required this.inBasket,
    required this.onToggleInquiry,
    required this.onSendInquiry,
  });

  @override
  Widget build(BuildContext context) {
    final owner = unit.mediaOwnerName;
    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cena za period zakupa',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 4),
            _BigPrice(unit: unit),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusPill(label: unit.statusLabel, tone: unit.statusTone),
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            if (owner != null && owner.isNotEmpty) ...[
              const SizedBox(height: 16),
              UnitOwnerRow(owner: owner),
            ],
            const SizedBox(height: 12),
            _FactLine(label: 'Grad', value: unit.cityAndCountry),
            _FactLine(label: 'Tip', value: unit.typeLabel),
            _FactLine(label: 'Format', value: unit.formatLabel),
            if (unit.dimensionsLabel.isNotEmpty)
              _FactLine(label: 'Dimenzije', value: unit.dimensionsLabel),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onToggleInquiry,
              icon: Icon(
                inBasket ? Icons.check_rounded : Icons.shopping_basket_outlined,
                size: 19,
              ),
              label: Text(inBasket ? 'Dodato u upit' : 'Dodaj u upit'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    inBasket ? AppColors.primaryStrong : AppColors.foreground,
                backgroundColor:
                    inBasket ? AppColors.primarySoft : AppColors.surface,
                side: BorderSide(
                    color: inBasket ? AppColors.primaryTint : AppColors.input),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onSendInquiry,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Pošalji upit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigPrice extends StatelessWidget {
  final OohUnit unit;

  const _BigPrice({required this.unit});

  @override
  Widget build(BuildContext context) {
    if (!unit.hasPrice) {
      return Text('Cena na upit', style: AppTypography.h4);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: unit.priceAmount,
            style: AppTypography.money.copyWith(fontSize: 32, height: 1.15),
          ),
          TextSpan(
            text: '  / ${unit.cycleText}',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.mutedForeground),
          ),
        ]),
        maxLines: 1,
      ),
    );
  }
}

class _FactLine extends StatelessWidget {
  final String label;
  final String value;

  const _FactLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(label,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.mutedForeground)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vlasnik medija: inicijali i naziv.
class UnitOwnerRow extends StatelessWidget {
  final String owner;

  const UnitOwnerRow({super.key, required this.owner});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(name: owner, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(owner,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(fontSize: 15)),
              Text('Vlasnik medija',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.mutedForeground)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Generalni upit: kampanja se opiše, a stručnjak predloži površine.
class GeneralInquiryBox extends StatelessWidget {
  final VoidCallback onPressed;

  const GeneralInquiryBox({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Generalni upit',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Opišite kampanju, a stručnjak za lokacije predložiće površine.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onPressed,
            child: const Text('Pošalji generalni upit'),
          ),
        ],
      ),
    );
  }
}

/// Pregled: naziv, vlasnik medija, tip i format, okruženje, osvetljenje,
/// dimenzije i opis (kada ga vlasnik unese).
class UnitOverviewTab extends StatelessWidget {
  final OohUnit unit;

  const UnitOverviewTab({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final owner = unit.mediaOwnerName;
    String or(String v) => v.isEmpty ? 'Nije navedeno' : v;
    final typeAndFormat = [unit.typeLabel, unit.formatLabel]
        .where((s) => s.isNotEmpty)
        .join(', ');
    final facts = <(String, String)>[
      ('Tip i format', or(typeAndFormat)),
      ('Okruženje', or(unit.venueLabel)),
      ('Osvetljenje', or(unit.illuminationLabel)),
      ('Dimenzije', or(unit.dimensionsLabel)),
      if (unit.resolutionLabel.isNotEmpty) ('Rezolucija', unit.resolutionLabel),
      if ((unit.impressions ?? 0) > 0)
        ('Impresije', SrFormat.money(unit.impressions, null, decimals: false)),
    ];
    final description = unit.description?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        UnitTitleRow(
          unit: unit,
          style: AppTypography.h4.copyWith(color: AppColors.foreground),
        ),
        const SizedBox(height: 6),
        UnitPlaceLine(text: unit.placeLine),
        if (owner != null && owner.isNotEmpty) ...[
          const SizedBox(height: 18),
          UnitOwnerRow(owner: owner),
        ],
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 620
                ? 3
                : (constraints.maxWidth >= 380 ? 2 : 1);
            const gap = 14.0;
            final itemWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: 16,
              children: [
                for (final (label, value) in facts)
                  SizedBox(
                    width: itemWidth,
                    child: MetaItem(label: label, value: value),
                  ),
              ],
            );
          },
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text('Opis', style: AppTypography.labelLarge.copyWith(fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.text2, height: 1.6),
          ),
        ],
      ],
    );
  }
}

/// Lokacija: mapa sa oznakom i adresa.
class UnitLocationTab extends StatelessWidget {
  final OohUnit unit;
  final bool wide;

  const UnitLocationTab({super.key, required this.unit, this.wide = true});

  @override
  Widget build(BuildContext context) {
    final hasCoords = unit.latitude != 0 || unit.longitude != 0;
    final point = LatLng(unit.latitude, unit.longitude);
    String or(String v) => v.isEmpty ? 'Nije navedeno' : v;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasCoords)
          Container(
            height: wide ? 320 : 240,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: point,
                      initialZoom: 15.0,
                      backgroundColor: const Color(0xFFE9ECF3),
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.drag |
                            InteractiveFlag.pinchZoom |
                            InteractiveFlag.doubleTapZoom,
                      ),
                    ),
                    children: [
                      const DiscoverTileLayer(),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: point,
                            width: 64,
                            height: 64,
                            child: const _DetailPin(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Positioned(
                      left: 10, bottom: 10, child: MapAttributionLabel()),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: AppDecorations.sunken(),
            child: const EmptyState(
              compact: true,
              icon: Icons.location_off_outlined,
              title: 'Lokacija na mapi nije uneta',
            ),
          ),
        const SizedBox(height: 18),
        SpecTable(
          columns: wide ? 2 : 1,
          rows: [
            ('Adresa', or(unit.address.trim())),
            ('Grad', or(unit.cityLabel)),
            ('Država', or(unit.countryLabel)),
            if (hasCoords)
              (
                'Koordinate',
                '${unit.latitude.toStringAsFixed(5)}, '
                    '${unit.longitude.toStringAsFixed(5)}'
              ),
          ],
        ),
      ],
    );
  }
}

class _DetailPin extends StatelessWidget {
  const _DetailPin();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: const Icon(Icons.place_rounded, size: 20, color: Colors.white),
      ),
    );
  }
}

/// Specifikacije površine u tabeli naziv–vrednost.
class UnitSpecsTab extends StatelessWidget {
  final OohUnit unit;
  final bool wide;

  const UnitSpecsTab({super.key, required this.unit, this.wide = true});

  @override
  Widget build(BuildContext context) {
    String or(String v) => v.isEmpty ? 'Nije navedeno' : v;
    final owner = unit.mediaOwnerName ?? '';
    final rows = <(String, String)>[
      ('Šifra', or(unit.code ?? '')),
      ('Tip površine', or(unit.typeLabel)),
      ('Format', or(unit.formatLabel)),
      if (unit.vendorFormatLabel.isNotEmpty &&
          unit.vendorFormatLabel != unit.formatLabel)
        ('Format vlasnika', unit.vendorFormatLabel),
      ('Okruženje', or(unit.venueLabel)),
      ('Osvetljenje', or(unit.illuminationLabel)),
      ('Dimenzije', or(unit.dimensionsLabel)),
      if (unit.resolutionLabel.isNotEmpty) ('Rezolucija', unit.resolutionLabel),
      if ((unit.impressions ?? 0) > 0)
        ('Impresije', SrFormat.money(unit.impressions, null, decimals: false)),
      ('Ciklus zakupa', _CycleInfo.of(unit.cycleType).span),
      if (owner.isNotEmpty) ('Vlasnik medija', owner),
      ('Lokacija', or(unit.cityAndCountry)),
    ];
    return SpecTable(rows: rows, columns: wide ? 2 : 1);
  }
}

/// Tabela naziv–vrednost; na širokom ekranu u dve kolone.
class SpecTable extends StatelessWidget {
  final List<(String, String)> rows;
  final int columns;

  const SpecTable({super.key, required this.rows, this.columns = 1});

  @override
  Widget build(BuildContext context) {
    if (columns < 2 || rows.length < 4) return _column(rows);
    final half = (rows.length / 2).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _column(rows.sublist(0, half))),
        const SizedBox(width: 28),
        Expanded(child: _column(rows.sublist(half))),
      ],
    );
  }

  Widget _column(List<(String, String)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (label, value) in items)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    label,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.mutedForeground),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Cena: cena ciklusa i primeri za uobičajena trajanja kampanje.
class UnitPricingTab extends StatelessWidget {
  final OohUnit unit;

  const UnitPricingTab({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    if (!unit.hasPrice) {
      return Container(
        decoration: AppDecorations.sunken(),
        child: const EmptyState(
          compact: true,
          icon: Icons.payments_outlined,
          title: 'Cena na upit',
        ),
      );
    }
    final info = _CycleInfo.of(unit.cycleType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Cena jednog ciklusa zakupa',
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.mutedForeground)),
        const SizedBox(height: 4),
        UnitPriceText(unit: unit, fontSize: 28),
        const SizedBox(height: 20),
        Text('Primeri', style: AppTypography.labelLarge.copyWith(fontSize: 15)),
        const SizedBox(height: 8),
        _ExamplesTable(unit: unit, info: info),
      ],
    );
  }
}

class _ExamplesTable extends StatelessWidget {
  final OohUnit unit;
  final _CycleInfo info;

  const _ExamplesTable({required this.unit, required this.info});

  @override
  Widget build(BuildContext context) {
    final head = AppTypography.labelSmall.copyWith(
      color: AppColors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    Widget row(List<Widget> cells, {bool header = false}) => Container(
          padding:
              EdgeInsets.symmetric(horizontal: 12, vertical: header ? 9 : 11),
          decoration: BoxDecoration(
            color: header ? AppColors.surfaceSunken : null,
            border: header
                ? null
                : const Border(top: BorderSide(color: AppColors.borderSoft)),
          ),
          child: Row(children: [
            Expanded(flex: 3, child: cells[0]),
            Expanded(flex: 2, child: cells[1]),
            Expanded(
                flex: 3,
                child:
                    Align(alignment: Alignment.centerRight, child: cells[2])),
          ]),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row([
            Text('Trajanje kampanje', style: head),
            Text('Ciklusa', style: head),
            Text('Ukupno', style: head),
          ], header: true),
          for (final d in info.examples)
            row([
              Text(info.durationLabel(d), style: AppTypography.bodyMedium),
              Text(
                SrFormat.count(
                    info.cyclesFor(d), 'ciklus', 'ciklusa', 'ciklusa'),
                style:
                    AppTypography.bodyMedium.copyWith(color: AppColors.text2),
              ),
              Text(
                SrFormat.money(unit.price * info.cyclesFor(d), unit.currency,
                    decimals: false),
                style: AppTypography.money.copyWith(fontSize: 15),
              ),
            ]),
        ],
      ),
    );
  }
}

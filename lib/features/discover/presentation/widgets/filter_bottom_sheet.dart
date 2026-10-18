import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../data/api/inventory_api_service.dart';
import '../../data/dto/dto.dart';
import '../../domain/entities/ooh_unit.dart';
import 'unit_labels.dart';

/// Ostali filteri pretrage, redom kojim ih korisnik bira: tip površine, format,
/// tip lokacije, unutra ili spolja, osvetljenje i raspon cena.
///
/// Na telefonu je list koji se izvlači odozdo, na širokom ekranu bočni panel.
/// Vrednosti koje idu u filter ostaju iste kao u API-ju; prevode se samo nazivi.
class FilterBottomSheet extends StatefulWidget {
  final List<DictionaryRefDto> unitTypes;
  final List<DictionaryRefDto> mediaFormats;
  final List<DictionaryRefDto> venueTypes;
  final InventoryFilterParams currentFilters;
  final void Function(InventoryFilterParams filters) onApply;
  final VoidCallback onReset;

  /// Površine iz trenutnih rezultata: pomažu da se od dve istoznačne stavke
  /// rečnika ("Mall" i "Malls") ponudi ona koja ima površine.
  final List<OohUnit> units;

  /// Bočni panel (širok ekran) umesto lista odozdo.
  final bool asPanel;

  const FilterBottomSheet({
    super.key,
    required this.unitTypes,
    required this.mediaFormats,
    required this.venueTypes,
    required this.currentFilters,
    required this.onApply,
    required this.onReset,
    this.units = const [],
    this.asPanel = false,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  static const double _priceMax = 10000;

  late int? _unitTypeId;
  late int? _mediaFormatId;
  late int? _venueTypeId;
  late String? _environment;
  late String? _illumination;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  RangeValues _priceRange = const RangeValues(0, _priceMax);
  bool _usePriceSlider = true;

  // "Unutra ili spolja"; OUTDOOR server ne poznaje i tada ne suzi rezultate.
  static const _environmentOptions = ['INDOOR', 'OUTDOOR'];

  static const _illuminationOptions = [
    'ILLUMINATED',
    'FRONTLIT',
    'BACKLIT',
    'AMBIENT_ARTIFICIAL',
    'NOT_ILLUMINATED',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.currentFilters;
    _unitTypeId = f.unitTypeId;
    _mediaFormatId = f.mediaFormatId;
    _venueTypeId = f.venueTypeId;
    _environment = f.environment;
    _illumination = f.illumination;
    _minPriceController =
        TextEditingController(text: f.minPrice?.toStringAsFixed(0) ?? '');
    _maxPriceController =
        TextEditingController(text: f.maxPrice?.toStringAsFixed(0) ?? '');
    final minP = f.minPrice ?? 0;
    final maxP = f.maxPrice ?? _priceMax;
    _priceRange = RangeValues(
      minP.clamp(0, _priceMax).toDouble(),
      maxP.clamp(0, _priceMax).toDouble(),
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  double? _parsePrice(String text) {
    final cleaned = text.trim().replaceAll('.', '').replaceAll(',', '.');
    return cleaned.isEmpty ? null : double.tryParse(cleaned);
  }

  void _handleApply() {
    double? minPrice;
    double? maxPrice;

    if (_usePriceSlider) {
      if (_priceRange.start > 0) minPrice = _priceRange.start;
      if (_priceRange.end < _priceMax) maxPrice = _priceRange.end;
    } else {
      minPrice = _parsePrice(_minPriceController.text);
      maxPrice = _parsePrice(_maxPriceController.text);
    }

    // Pretraga po nazivu ostaje ona iz polja na vrhu stranice.
    final keyword = widget.currentFilters.keyword;

    final filters = InventoryFilterParams(
      unitTypeId: _unitTypeId,
      mediaFormatId: _mediaFormatId,
      venueTypeId: _venueTypeId,
      environment: _environment,
      illumination: _illumination,
      minPrice: minPrice,
      maxPrice: maxPrice,
      keyword: (keyword != null && keyword.isNotEmpty) ? keyword : null,
    );

    widget.onApply(filters);
    Navigator.pop(context);
  }

  void _handleReset() {
    setState(() {
      _unitTypeId = null;
      _mediaFormatId = null;
      _venueTypeId = null;
      _environment = null;
      _illumination = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _priceRange = const RangeValues(0, _priceMax);
      _usePriceSlider = true;
    });
  }

  int get _localFilterCount {
    int count = 0;
    if (_unitTypeId != null) count++;
    if (_mediaFormatId != null) count++;
    if (_venueTypeId != null) count++;
    if (_environment != null) count++;
    if (_illumination != null) count++;
    if (_usePriceSlider) {
      if (_priceRange.start > 0 || _priceRange.end < _priceMax) count++;
    } else if (_minPriceController.text.isNotEmpty ||
        _maxPriceController.text.isNotEmpty) {
      count++;
    }
    return count;
  }

  Set<String> _present(String? Function(OohUnit u) pick) => {
        for (final u in widget.units)
          if (pick(u) != null) pick(u)!.toLowerCase(),
      };

  @override
  Widget build(BuildContext context) {
    if (widget.asPanel) {
      return Material(
        color: AppColors.surface,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Divider(height: 1),
              Expanded(child: _buildSections(null)),
              _buildActionButtons(),
            ],
          ),
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ColoredBox(
          color: AppColors.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.input,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _buildHeader(),
              const Divider(height: 1),
              Expanded(child: _buildSections(scrollController)),
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSections(ScrollController? controller) {
    final unitTypeOptions = DiscoverLabels.options(
      widget.unitTypes,
      DiscoverLabels.unitType,
      present: _present((u) => u.unitTypeName),
      selectedId: _unitTypeId,
    );
    final formatOptions = DiscoverLabels.options(
      widget.mediaFormats,
      DiscoverLabels.format,
      present: _present((u) => u.mediaFormatName),
      selectedId: _mediaFormatId,
    );
    final venueOptions = DiscoverLabels.options(
      widget.venueTypes,
      DiscoverLabels.venue,
      present: _present((u) => u.venueTypeName),
      selectedId: _venueTypeId,
    );
    final environments = [
      ..._environmentOptions,
      if (_environment != null && !_environmentOptions.contains(_environment))
        _environment!,
    ];

    final sections = <Widget>[
      if (unitTypeOptions.isNotEmpty)
        _FilterSection(
          title: 'Tip površine',
          child: _idChips(unitTypeOptions, _unitTypeId,
              (v) => setState(() => _unitTypeId = v)),
        ),
      if (formatOptions.isNotEmpty)
        _FilterSection(
          title: 'Format',
          child: _idChips(formatOptions, _mediaFormatId,
              (v) => setState(() => _mediaFormatId = v)),
        ),
      if (venueOptions.isNotEmpty)
        _FilterSection(
          title: 'Tip lokacije',
          child: _idChips(venueOptions, _venueTypeId,
              (v) => setState(() => _venueTypeId = v)),
        ),
      _FilterSection(
        title: 'Unutra ili spolja',
        child: _valueChips(
            environments,
            _environment,
            DiscoverLabels.environment,
            (v) => setState(() => _environment = v)),
      ),
      _FilterSection(
        title: 'Osvetljenje',
        child: _valueChips(
            _illuminationOptions,
            _illumination,
            DiscoverLabels.illumination,
            (v) => setState(() => _illumination = v)),
      ),
      _FilterSection(
        title: 'Raspon cena',
        child: _buildPriceRange(),
      ),
    ];

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Divider(height: 1, color: AppColors.borderSoft),
      ),
      itemBuilder: (_, i) => sections[i],
    );
  }

  Widget _buildHeader() {
    final count = _localFilterCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 10, 12),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text('Filteri', style: AppTypography.h4),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '$count',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Zatvori',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Opcije iz rečnika: "Sve" i po jedna oznaka za svaku stavku.
  Widget _idChips(List<DictionaryOption> options, int? selected,
      ValueChanged<int?> onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _OptionChip(
          label: 'Sve',
          selected: selected == null,
          onTap: () => onChanged(null),
        ),
        for (final o in options)
          _OptionChip(
            label: o.label,
            selected: selected == o.id,
            onTap: () => onChanged(selected == o.id ? null : o.id),
          ),
      ],
    );
  }

  /// Opcije sa vrednostima enuma: "Sve" i srpski naziv za svaku vrednost.
  Widget _valueChips(List<String> values, String? selected,
      String Function(String) labelOf, ValueChanged<String?> onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _OptionChip(
          label: 'Sve',
          selected: selected == null,
          onTap: () => onChanged(null),
        ),
        for (final v in values)
          _OptionChip(
            label: labelOf(v),
            selected: selected == v,
            onTap: () => onChanged(selected == v ? null : v),
          ),
      ],
    );
  }

  Widget _buildPriceRange() {
    String fmt(double v) => SrFormat.money(v.roundToDouble(), null);
    final atMax = _priceRange.end >= _priceMax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(fmt(_priceRange.start),
                style: AppTypography.money.copyWith(fontSize: 15)),
            const Spacer(),
            Text(atMax ? '${fmt(_priceMax)}+' : fmt(_priceRange.end),
                style: AppTypography.money.copyWith(fontSize: 15)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primarySoft,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
            trackHeight: 4,
            showValueIndicator: ShowValueIndicator.onDrag,
            valueIndicatorColor: AppColors.ink,
            valueIndicatorTextStyle:
                AppTypography.labelSmall.copyWith(color: Colors.white),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: 0,
            max: _priceMax,
            divisions: 100,
            labels: RangeLabels(fmt(_priceRange.start), fmt(_priceRange.end)),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
                _minPriceController.text = values.start.round().toString();
                _maxPriceController.text = values.end.round().toString();
                _usePriceSlider = true;
              });
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _priceField(_minPriceController, 'Od')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('–',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.mutedForeground)),
            ),
            Expanded(child: _priceField(_maxPriceController, 'Do')),
          ],
        ),
      ],
    );
  }

  Widget _priceField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      style: AppTypography.bodyMedium,
      onChanged: (_) => setState(() => _usePriceSlider = false),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _handleReset,
                child: const Text('Poništi'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _handleApply,
                child: const Text('Prikaži rezultate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTypography.labelLarge.copyWith(fontSize: 15)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: selected ? AppColors.primaryStrong : AppColors.text2,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primarySoft,
      side: BorderSide(
        color: selected ? AppColors.primaryTint : AppColors.border,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/api/inventory_api_service.dart';
import '../../data/dto/dto.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<DictionaryRefDto> unitTypes;
  final List<DictionaryRefDto> mediaFormats;
  final List<DictionaryRefDto> venueTypes;
  final InventoryFilterParams currentFilters;
  final void Function(InventoryFilterParams filters) onApply;
  final VoidCallback onReset;

  const FilterBottomSheet({
    super.key,
    required this.unitTypes,
    required this.mediaFormats,
    required this.venueTypes,
    required this.currentFilters,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late int? _unitTypeId;
  late int? _mediaFormatId;
  late int? _venueTypeId;
  late String? _environment;
  late String? _illumination;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _keywordController;
  RangeValues _priceRange = const RangeValues(0, 10000);
  bool _usePriceSlider = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  static const _environmentOptions = [
    'INDOOR',
    'OUTDOOR',
    'ROADSIDE',
    'MALL',
    'AIRPORT',
    'TRANSIT',
  ];

  static const _illuminationOptions = [
    'ILLUMINATED',
    'FRONTLIT',
    'BACKLIT',
    'NOT_ILLUMINATED',
  ];

  @override
  void initState() {
    super.initState();
    _unitTypeId = widget.currentFilters.unitTypeId;
    _mediaFormatId = widget.currentFilters.mediaFormatId;
    _venueTypeId = widget.currentFilters.venueTypeId;
    _environment = widget.currentFilters.environment;
    _illumination = widget.currentFilters.illumination;
    _minPriceController = TextEditingController(
      text: widget.currentFilters.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.currentFilters.maxPrice?.toStringAsFixed(0) ?? '',
    );
    _keywordController = TextEditingController(
      text: widget.currentFilters.keyword ?? '',
    );

    // Initialize price range from current filters
    final minP = widget.currentFilters.minPrice ?? 0;
    final maxP = widget.currentFilters.maxPrice ?? 10000;
    _priceRange = RangeValues(minP.clamp(0, 10000), maxP.clamp(0, 10000));
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  String _environmentLabel(String value) {
    switch (value) {
      case 'INDOOR':
        return l10n.indoor;
      case 'OUTDOOR':
        return l10n.outdoor;
      case 'ROADSIDE':
        return l10n.roadside;
      case 'MALL':
        return l10n.mall;
      case 'AIRPORT':
        return l10n.airport;
      case 'TRANSIT':
        return l10n.transitEnv;
      default:
        return value;
    }
  }

  String _illuminationLabel(String value) {
    switch (value) {
      case 'ILLUMINATED':
        return l10n.illuminated;
      case 'FRONTLIT':
        return l10n.frontlit;
      case 'BACKLIT':
        return l10n.backlit;
      case 'NOT_ILLUMINATED':
        return l10n.notIlluminated;
      default:
        return value;
    }
  }

  void _handleApply() {
    double? minPrice;
    double? maxPrice;

    if (_usePriceSlider) {
      if (_priceRange.start > 0) minPrice = _priceRange.start;
      if (_priceRange.end < 10000) maxPrice = _priceRange.end;
    } else {
      minPrice = double.tryParse(_minPriceController.text);
      maxPrice = double.tryParse(_maxPriceController.text);
    }

    final keyword = _keywordController.text.trim();

    final filters = InventoryFilterParams(
      unitTypeId: _unitTypeId,
      mediaFormatId: _mediaFormatId,
      venueTypeId: _venueTypeId,
      environment: _environment,
      illumination: _illumination,
      minPrice: minPrice,
      maxPrice: maxPrice,
      keyword: keyword.isNotEmpty ? keyword : null,
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
      _keywordController.clear();
      _priceRange = const RangeValues(0, 10000);
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
      if (_priceRange.start > 0 || _priceRange.end < 10000) count++;
    } else {
      if (_minPriceController.text.isNotEmpty || _maxPriceController.text.isNotEmpty) count++;
    }
    if (_keywordController.text.trim().isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              _buildHeader(),
              Divider(height: 1, color: AppColors.border),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // --- Section: Pretraga ---
                    _buildSectionHeader(Icons.search, l10n.filterKeyword),
                    const SizedBox(height: 8),
                    _buildKeywordField(),
                    const SizedBox(height: 24),

                    // --- Section: Tip inventara ---
                    if (widget.unitTypes.isNotEmpty) ...[
                      _buildSectionHeader(Icons.category, l10n.filterUnitType),
                      const SizedBox(height: 8),
                      _buildDropdown<int>(
                        value: _unitTypeId,
                        items: widget.unitTypes,
                        onChanged: (v) => setState(() => _unitTypeId = v),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- Section: Media format ---
                    if (widget.mediaFormats.isNotEmpty) ...[
                      _buildSectionHeader(Icons.tv, l10n.filterMediaFormat),
                      const SizedBox(height: 8),
                      _buildDropdown<int>(
                        value: _mediaFormatId,
                        items: widget.mediaFormats,
                        onChanged: (v) => setState(() => _mediaFormatId = v),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- Section: Tip lokacije ---
                    if (widget.venueTypes.isNotEmpty) ...[
                      _buildSectionHeader(Icons.place, l10n.filterVenueType),
                      const SizedBox(height: 8),
                      _buildDropdown<int>(
                        value: _venueTypeId,
                        items: widget.venueTypes,
                        onChanged: (v) => setState(() => _venueTypeId = v),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- Section: Okruzenje ---
                    _buildSectionHeader(Icons.nature_people, l10n.filterEnvironment),
                    const SizedBox(height: 8),
                    _buildChipGroup(
                      options: _environmentOptions,
                      selected: _environment,
                      labelBuilder: _environmentLabel,
                      onSelected: (v) => setState(() {
                        _environment = _environment == v ? null : v;
                      }),
                    ),
                    const SizedBox(height: 24),

                    // --- Section: Osvetljenje ---
                    _buildSectionHeader(Icons.lightbulb_outline, l10n.illuminated),
                    const SizedBox(height: 8),
                    _buildChipGroup(
                      options: _illuminationOptions,
                      selected: _illumination,
                      labelBuilder: _illuminationLabel,
                      onSelected: (v) => setState(() {
                        _illumination = _illumination == v ? null : v;
                      }),
                    ),
                    const SizedBox(height: 24),

                    // --- Section: Raspon cena ---
                    _buildSectionHeader(Icons.euro, l10n.filterPriceRange),
                    const SizedBox(height: 8),
                    _buildPriceRangeSlider(),
                    const SizedBox(height: 8),
                    _buildPriceRange(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              // Bottom action buttons
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      child: Row(
        children: [
          Text(
            l10n.filters,
            style: AppTypography.h2.copyWith(
              color: AppColors.foreground,
            ),
          ),
          if (_localFilterCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '$_localFilterCount',
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.foreground),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildKeywordField() {
    return TextField(
      controller: _keywordController,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
      decoration: InputDecoration(
        hintText: l10n.searchPlaceholder,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
        prefixIcon: Icon(Icons.search, color: AppColors.mutedForeground, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DictionaryRefDto> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value as int?,
          dropdownColor: Colors.white,
          isExpanded: true,
          hint: Text(
            l10n.selectAll,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
          ),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text(
                l10n.selectAll,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
              ),
            ),
            ...items.map((item) => DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(
                    item.name,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
                  ),
                )),
          ],
          onChanged: (v) => onChanged(v as T?),
        ),
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required String? selected,
    required String Function(String) labelBuilder,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return ChoiceChip(
          label: Text(labelBuilder(option)),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          backgroundColor: AppColors.muted,
          labelStyle: AppTypography.bodySmall.copyWith(
            color: isSelected ? AppColors.primary : AppColors.foreground,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 10000,
          divisions: 100,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          labels: RangeLabels(
            '\u20AC${_priceRange.start.round()}',
            '\u20AC${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
              _minPriceController.text = values.start.round().toString();
              _maxPriceController.text = values.end.round().toString();
              _usePriceSlider = true;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\u20AC${_priceRange.start.round()}',
              style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
            ),
            Text(
              '\u20AC${_priceRange.end.round()}',
              style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRange() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
            onChanged: (_) => setState(() => _usePriceSlider = false),
            decoration: InputDecoration(
              hintText: l10n.filterMinPrice,
              hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              prefixText: '\u20AC ',
              prefixStyle: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('\u2013', style: AppTypography.bodyLarge.copyWith(color: AppColors.mutedForeground)),
        ),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
            onChanged: (_) => setState(() => _usePriceSlider = false),
            decoration: InputDecoration(
              hintText: l10n.filterMaxPrice,
              hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              prefixText: '\u20AC ',
              prefixStyle: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _handleReset,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                side: BorderSide(color: AppColors.border),
              ),
              child: Text(
                l10n.resetFilters,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _handleApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Text(
                l10n.applyFilters,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/ooh_unit.dart';
import '../blocs/discover_bloc.dart';
import 'sort_dropdown.dart';
import 'unit_labels.dart';
import 'view_toggle.dart';

/// Gornja traka pretrage, redom: država, grad, pretraga po nazivu ili lokaciji
/// i dugme "Filteri" sa brojem aktivnih filtera.
class DiscoverToolbar extends StatelessWidget {
  final DiscoverLoaded state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenFilters;

  /// Polje za pretragu je u traci (na telefonu je u listi rezultata).
  final bool showSearch;

  /// Uža traka za telefon i tablet.
  final bool compact;

  const DiscoverToolbar({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onOpenFilters,
    this.showSearch = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final country = _CountrySelect(state: state);
    final city = _CitySelect(state: state);
    final filters = FiltersButton(
      count: state.activeFilterCount,
      onPressed: onOpenFilters,
      compact: compact && !showSearch,
    );
    final search = DiscoverSearchField(
      controller: searchController,
      onChanged: onSearchChanged,
      onClear: onClearSearch,
    );

    if (compact && !showSearch) {
      return Row(
        children: [
          Expanded(child: country),
          const SizedBox(width: 8),
          Expanded(child: city),
          const SizedBox(width: 8),
          filters,
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: compact ? 168 : 196, child: country),
        const SizedBox(width: 10),
        SizedBox(width: compact ? 176 : 216, child: city),
        const SizedBox(width: 10),
        if (showSearch) Expanded(child: search) else const Spacer(),
        const SizedBox(width: 10),
        filters,
      ],
    );
  }
}

/// Polje za pretragu po nazivu ili lokaciji.
class DiscoverSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const DiscoverSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTypography.bodyMedium,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Pretraži po nazivu ili lokaciji',
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 42, minHeight: 40),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Obriši pretragu',
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: onClear,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(34, 34),
                      fixedSize: const Size(34, 34),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Dugme "Filteri"; kada su filteri aktivni, dobija indigo podlogu i broj.
class FiltersButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;
  final bool compact;

  const FiltersButton({
    super.key,
    required this.count,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
        foregroundColor:
            active ? AppColors.primaryStrong : AppColors.foreground,
        backgroundColor: active ? AppColors.primarySoft : AppColors.surface,
        side:
            BorderSide(color: active ? AppColors.primaryTint : AppColors.input),
        textStyle: AppTypography.labelLarge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune_rounded, size: 18),
          const SizedBox(width: 8),
          const Text('Filteri'),
          if (active) ...[
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 20),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Polje izbora u traci: vrednost i strelica.
class _SelectBox<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final List<String> selectedLabels;
  final ValueChanged<T?> onChanged;
  final String hint;

  const _SelectBox({
    super.key,
    required this.value,
    required this.items,
    required this.selectedLabels,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.input),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                isDense: true,
                menuMaxHeight: 420,
                borderRadius: BorderRadius.circular(AppRadius.md),
                dropdownColor: AppColors.surface,
                icon: const Icon(Icons.expand_more_rounded,
                    size: 20, color: AppColors.mutedForeground),
                hint: Text(hint,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.subtle)),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w500,
                ),
                selectedItemBuilder: (context) => [
                  for (final l in selectedLabels)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(l,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                ],
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountrySelect extends StatelessWidget {
  final DiscoverLoaded state;

  const _CountrySelect({required this.state});

  @override
  Widget build(BuildContext context) {
    final countries = state.countries;
    final selected = state.selectedCountry == null
        ? null
        : countries.where((c) => c.id == state.selectedCountry!.id).firstOrNull;
    final labels = [
      'Sve države',
      for (final c in countries) SrLabels.country(c.name),
    ];
    return _SelectBox<Country?>(
      hint: 'Izaberi državu',
      value: selected,
      selectedLabels: labels,
      items: [
        DropdownMenuItem<Country?>(
          value: null,
          child: Text(labels.first,
              style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        for (final c in countries)
          DropdownMenuItem<Country?>(
            value: c,
            child:
                Text(SrLabels.country(c.name), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (country) =>
          context.read<DiscoverBloc>().add(SelectCountry(country)),
    );
  }
}

class _CitySelect extends StatelessWidget {
  final DiscoverLoaded state;

  const _CitySelect({required this.state});

  @override
  Widget build(BuildContext context) {
    final cities = state.cities;
    final selected = state.selectedCity == null
        ? null
        : cities.where((c) => c.id == state.selectedCity!.id).firstOrNull;
    final withCountry = state.selectedCountry == null;
    String label(City c) =>
        withCountry ? SrLabels.place(c.name, c.country) : SrLabels.city(c.name);
    final labels = ['Svi gradovi', for (final c in cities) label(c)];
    return _SelectBox<City?>(
      hint: 'Izaberi grad',
      value: selected,
      selectedLabels: labels,
      items: [
        DropdownMenuItem<City?>(
          value: null,
          child: Text(labels.first,
              style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        for (final c in cities)
          DropdownMenuItem<City?>(
            value: c,
            child: Text(label(c), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (city) => context.read<DiscoverBloc>().add(SelectCity(city)),
    );
  }
}

/// Red iznad rezultata: broj površina, generalni upit, redosled i prikaz.
class DiscoverResultsBar extends StatelessWidget {
  final DiscoverLoaded state;
  final VoidCallback onGeneralInquiry;

  const DiscoverResultsBar({
    super.key,
    required this.state,
    required this.onGeneralInquiry,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DiscoverBloc>();
    return Row(
      children: [
        Expanded(child: DiscoverCountText(state: state)),
        const SizedBox(width: 12),
        GeneralInquiryButton(onPressed: onGeneralInquiry),
        const SizedBox(width: 8),
        SortDropdown(
          currentSort: state.sortOption,
          onChanged: (sort) => bloc.add(ChangeSort(sort)),
        ),
        const SizedBox(width: 8),
        ViewToggle(
          currentMode: state.viewMode,
          onChanged: (mode) => bloc.add(ChangeViewMode(mode)),
        ),
      ],
    );
  }
}

/// "57 površina u gradu Beograd"
class DiscoverCountText extends StatelessWidget {
  final DiscoverLoaded state;
  final bool stacked;

  const DiscoverCountText(
      {super.key, required this.state, this.stacked = false});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingUnits) {
      return Text(
        'Učitavanje površina…',
        style:
            AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
      );
    }
    final count = DiscoverLabels.unitCount(state.units.length);
    final scope = DiscoverLabels.scope(
      city: state.selectedCity?.name,
      country: state.selectedCountry?.name,
    );
    final countStyle = (stacked ? AppTypography.h5 : AppTypography.labelLarge)
        .copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
            fontSize: stacked ? 18 : 15);
    final scopeStyle =
        (stacked ? AppTypography.caption : AppTypography.bodyMedium)
            .copyWith(color: AppColors.mutedForeground);

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count, style: countStyle),
          Text(scope,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: scopeStyle),
        ],
      );
    }
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: count, style: countStyle),
        TextSpan(text: ' $scope', style: scopeStyle),
      ]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// "Generalni upit": kampanja se opiše, a stručnjak predloži lokacije.
class GeneralInquiryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool iconOnly;

  const GeneralInquiryButton(
      {super.key, required this.onPressed, this.iconOnly = false});

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return IconButton(
        tooltip: 'Generalni upit',
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primarySoft,
          foregroundColor: AppColors.primaryStrong,
          fixedSize: const Size(40, 40),
        ),
        icon: const Icon(Icons.support_agent_rounded, size: 20),
      );
    }
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: AppTypography.labelLarge,
      ),
      child: const Text('Generalni upit'),
    );
  }
}

/// Traka izbora na vrhu rezultata: broj izabranih površina, njihove sličice,
/// "Poništi" i "Pošalji upit".
class DiscoverSelectionBar extends StatelessWidget {
  final int count;
  final List<OohUnit> units;
  final VoidCallback onClear;
  final VoidCallback onSend;
  final bool compact;

  const DiscoverSelectionBar({
    super.key,
    required this.count,
    required this.units,
    required this.onClear,
    required this.onSend,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 12, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(compact ? 0 : AppRadius.card),
      ),
      child: Row(
        children: [
          if (!compact && units.isNotEmpty) ...[
            _ThumbRow(units: units, total: count),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              DiscoverLabels.selectedCount(count),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelLarge
                  .copyWith(color: Colors.white, fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.inkText,
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Poništi'),
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            onPressed: onSend,
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Pošalji upit'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sličice izabranih površina jedna do druge, najviše četiri i "+N".
class _ThumbRow extends StatelessWidget {
  final List<OohUnit> units;
  final int total;

  const _ThumbRow({required this.units, required this.total});

  @override
  Widget build(BuildContext context) {
    const w = 40.0;
    const h = 30.0;
    final shown = units.take(4).toList();
    final extra = total - shown.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          UnitThumb(
            imageUrl: shown[i].imageUrl,
            width: w,
            height: h,
            radius: 5,
            digital: shown[i].isDigitalUnit,
          ),
        ],
        if (extra > 0) ...[
          const SizedBox(width: 8),
          Text(
            '+$extra',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.inkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

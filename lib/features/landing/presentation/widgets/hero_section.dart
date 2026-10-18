import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../discover/domain/entities/city.dart';
import '../../../discover/domain/entities/country.dart';
import '../../../discover/presentation/blocs/discover_bloc.dart';
import 'landing_shared.dart';

/// Uvodni deo početne strane: tamna pozadina, naslov, pretraga (država, grad,
/// pojam), kategorije i obim ponude; desno (na telefonu ispod) tri ilustracije
/// površina u ravnoj mreži.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  static const List<String> _categories = [
    'Autobuska stanica',
    'Tržni centar',
    'Metro',
    'Aerodrom',
    'Digitalni bilbord',
    'Anamorfik',
    'Brendiranje',
    'Elektronski',
  ];

  /// Kolona sa ilustracijama na širokom ekranu i razmak do teksta. Dve kolone
  /// tek od 1280 px: tada kolona teksta ima najmanje 716 px, pa pretraga staje
  /// u jedan red (traži 680 px).
  static const double _gridWidth = 420;
  static const double _columnGap = 48;
  static const double _twoColumnsFrom = 1280;

  final TextEditingController _keyword = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DiscoverBloc>().add(LoadCountries());
    });
  }

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  /// Država, grad i pojam idu pretrazi kao parametri adrese
  /// (`countryId`, `cityId`, `keyword`).
  void _search() {
    final state = context.read<DiscoverBloc>().state;
    final params = <String, String>{};
    if (state is DiscoverLoaded) {
      if (state.selectedCountry != null) {
        params['countryId'] = state.selectedCountry!.id.toString();
      }
      if (state.selectedCity != null) {
        params['cityId'] = state.selectedCity!.id.toString();
      }
    }
    final typed = _keyword.text.trim();
    final keyword = typed.isNotEmpty ? typed : _selectedCategory;
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
    final uri = Uri(
        path: '/discover', queryParameters: params.isNotEmpty ? params : null);
    context.go(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final twoColumns = width >= _twoColumnsFrom;
    final phone = width < 600;
    final side = landingGutter(context);

    final copy = _HeroCopy(
      keyword: _keyword,
      categories: _categories,
      selectedCategory: _selectedCategory,
      onCategory: (c) =>
          setState(() => _selectedCategory = _selectedCategory == c ? null : c),
      onSearch: _search,
    );

    return ColoredBox(
      color: AppColors.ink,
      child: Padding(
        padding:
            EdgeInsets.fromLTRB(side, phone ? 36 : 72, side, phone ? 48 : 92),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: twoColumns
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: _columnGap),
                      const SizedBox(width: _gridWidth, child: _HeroGrid()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      copy,
                      SizedBox(height: phone ? 36 : 48),
                      const _HeroGrid(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Tekst, pretraga, kategorije, obim ponude ─────────────────────────────

class _HeroCopy extends StatelessWidget {
  final TextEditingController keyword;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategory;
  final VoidCallback onSearch;

  const _HeroCopy({
    required this.keyword,
    required this.categories,
    required this.selectedCategory,
    required this.onCategory,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final phone = width < 600;
    final muted = AppColors.inkText.withValues(alpha: 0.78);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Headline(),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Pronađite bilborde, city light vitrine i digitalne ekrane u Srbiji, Hrvatskoj i Bosni i Hercegovini, uporedite cene za period zakupa i pošaljite jedan upit svim vlasnicima medija.',
            style: (phone ? AppTypography.bodyMedium : AppTypography.bodyLarge)
                .copyWith(color: muted),
          ),
        ),
        SizedBox(height: phone ? 24 : 32),
        _SearchPanel(keyword: keyword, onSearch: onSearch),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in categories)
              _HeroChip(
                label: c,
                selected: c == selectedCategory,
                onTap: () => onCategory(c),
              ),
          ],
        ),
        SizedBox(height: phone ? 24 : 32),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Više od 500 površina u 70 gradova Srbije, Hrvatske i Bosne i Hercegovine.',
              style: AppTypography.bodyMedium.copyWith(color: muted),
            ),
            TextButton(
              onPressed: onSearch,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryTint,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Pogledaj mapu'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Naslov u jednoj boji; kada ima mesta, prelama se posle zareza.
class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = (constraints.maxWidth / 13.4).clamp(30.0, 52.0).toDouble();
      final breakAfterComma = constraints.maxWidth >= size * 13;
      return Text(
        breakAfterComma
            ? 'Oglasni prostor u tri države,\nna jednom mestu'
            : 'Oglasni prostor u tri države, na jednom mestu',
        style: AppTypography.displayMedium.copyWith(
          color: Colors.white,
          fontSize: size,
          height: 1.08,
          letterSpacing: -size * 0.022,
        ),
      );
    });
  }
}

/// Bela traka pretrage: država, grad, pojam i dugme.
class _SearchPanel extends StatelessWidget {
  final TextEditingController keyword;
  final VoidCallback onSearch;

  const _SearchPanel({required this.keyword, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        final loaded = state is DiscoverLoaded ? state : null;
        final countries = loaded?.countries ?? const <Country>[];
        final cities = loaded?.cities ?? const <City>[];
        final loading = state is DiscoverLoading || state is DiscoverInitial;

        final country = _SearchField(
          label: 'Država',
          child: _CountryDropdown(
            countries: countries,
            selected: loaded?.selectedCountry,
            loading: loading && countries.isEmpty,
          ),
        );
        final city = _SearchField(
          label: 'Grad',
          child: _CityDropdown(
            cities: cities,
            selected: loaded?.selectedCity,
            loading: loading && countries.isEmpty,
          ),
        );
        Widget term(String hint) => _SearchField(
              label: 'Pretraga',
              child: TextField(
                controller: keyword,
                onSubmitted: (_) => onSearch(),
                textInputAction: TextInputAction.search,
                style: AppTypography.labelLarge.copyWith(
                    color: AppColors.foreground, fontWeight: FontWeight.w500),
                // Bez okvira iz teme: polje je deo bele trake.
                decoration: InputDecoration(
                  isCollapsed: true,
                  isDense: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: hint,
                  hintMaxLines: 1,
                  hintStyle: AppTypography.labelLarge.copyWith(
                      color: AppColors.subtle, fontWeight: FontWeight.w400),
                ),
              ),
            );
        final button = FilledButton.icon(
          onPressed: onSearch,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 54),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
          icon: const Icon(Icons.search_rounded, size: 20),
          label: const Text('Pretraži'),
        );

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth >= 680) {
              return Row(
                children: [
                  SizedBox(width: 190, child: country),
                  const _VerticalRule(),
                  SizedBox(width: 170, child: city),
                  const _VerticalRule(),
                  Expanded(child: term('Naziv ili lokacija')),
                  const SizedBox(width: 8),
                  button,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: country),
                    const _VerticalRule(),
                    Expanded(child: city),
                  ],
                ),
                const Divider(height: 1, color: AppColors.borderSoft),
                term('Naziv ili lokacija, npr. Knez Mihailova'),
                const SizedBox(height: 6),
                button,
              ],
            );
          }),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final String label;
  final Widget child;

  const _SearchField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.caption
                .copyWith(color: AppColors.subtle, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}

class _VerticalRule extends StatelessWidget {
  const _VerticalRule();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 34, color: AppColors.border);
}

TextStyle get _valueStyle => AppTypography.labelLarge
    .copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600);

class _LoadingValue extends StatelessWidget {
  const _LoadingValue();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.6),
        ),
        const SizedBox(width: 8),
        Text('Učitavanje…',
            style: AppTypography.labelMedium.copyWith(color: AppColors.subtle)),
      ],
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  final List<Country> countries;
  final Country? selected;
  final bool loading;

  const _CountryDropdown(
      {required this.countries, required this.selected, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LoadingValue();
    final value =
        selected != null && countries.contains(selected) ? selected : null;
    return DropdownButtonHideUnderline(
      child: DropdownButton<Country?>(
        value: value,
        disabledHint: Text('Sve države', style: _valueStyle),
        isDense: true,
        isExpanded: true,
        borderRadius: BorderRadius.circular(AppRadius.md),
        dropdownColor: AppColors.surface,
        icon: const Icon(Icons.expand_more_rounded,
            size: 18, color: AppColors.mutedForeground),
        style: _valueStyle,
        items: [
          DropdownMenuItem<Country?>(
            value: null,
            child: Text('Sve države',
                overflow: TextOverflow.ellipsis, style: _valueStyle),
          ),
          for (final c in countries)
            DropdownMenuItem<Country?>(
              value: c,
              child: Text(SrLabels.country(c.name),
                  overflow: TextOverflow.ellipsis, style: _valueStyle),
            ),
        ],
        onChanged: countries.isEmpty
            ? null
            : (c) => context.read<DiscoverBloc>().add(SelectCountry(c)),
      ),
    );
  }
}

class _CityDropdown extends StatelessWidget {
  final List<City> cities;
  final City? selected;
  final bool loading;

  const _CityDropdown(
      {required this.cities, required this.selected, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) return const _LoadingValue();
    final value =
        selected != null && cities.contains(selected) ? selected : null;
    return DropdownButtonHideUnderline(
      child: DropdownButton<City?>(
        value: value,
        disabledHint: Text('Svi gradovi', style: _valueStyle),
        isDense: true,
        isExpanded: true,
        borderRadius: BorderRadius.circular(AppRadius.md),
        dropdownColor: AppColors.surface,
        menuMaxHeight: 360,
        icon: const Icon(Icons.expand_more_rounded,
            size: 18, color: AppColors.mutedForeground),
        style: _valueStyle,
        selectedItemBuilder: (context) => [
          Text('Svi gradovi',
              overflow: TextOverflow.ellipsis, style: _valueStyle),
          for (final c in cities)
            Text(SrLabels.city(c.name),
                overflow: TextOverflow.ellipsis, style: _valueStyle),
        ],
        items: [
          DropdownMenuItem<City?>(
            value: null,
            child: Text('Svi gradovi',
                overflow: TextOverflow.ellipsis, style: _valueStyle),
          ),
          for (final c in cities)
            DropdownMenuItem<City?>(
              value: c,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: SrLabels.city(c.name)),
                  TextSpan(
                    text: '  ${SrLabels.country(c.country)}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.mutedForeground),
                  ),
                ]),
                overflow: TextOverflow.ellipsis,
                style: _valueStyle,
              ),
            ),
        ],
        onChanged: cities.isEmpty
            ? null
            : (c) => context.read<DiscoverBloc>().add(SelectCity(c)),
      ),
    );
  }
}

class _HeroChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HeroChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  State<_HeroChip> createState() => _HeroChipState();
}

class _HeroChipState extends State<_HeroChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: _hovered ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: _hovered ? 0.24 : 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 15, color: Colors.white),
                const SizedBox(width: 5),
              ],
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: selected ? Colors.white : AppColors.inkText,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Ilustracije ──────────────────────────────────────────────────────────

/// Tri ilustracije površina u ravnoj mreži, bez senki i preklapanja: u širokom
/// prostoru jedna pored druge, u užoj koloni jedna velika i dve manje ispod.
class _HeroGrid extends StatelessWidget {
  const _HeroGrid();

  static const double _gap = 16;

  static const _slavija = _HeroShot(
    asset: LandingAssets.ledSlavija,
    place: 'Slavija, Beograd',
    format: 'Digitalni ekran',
  );
  static const _knez = _HeroShot(
    asset: LandingAssets.cityLightKnez,
    place: 'Knez Mihailova, Beograd',
    format: 'City light',
  );
  static const _brankov = _HeroShot(
    asset: LandingAssets.bilbordBrankov,
    place: 'Brankov most, Beograd',
    format: 'Bilbord',
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 640) {
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _slavija),
            SizedBox(width: _gap),
            Expanded(child: _knez),
            SizedBox(width: _gap),
            Expanded(child: _brankov),
          ],
        );
      }
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _slavija,
          SizedBox(height: _gap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _knez),
              SizedBox(width: _gap),
              Expanded(child: _brankov),
            ],
          ),
        ],
      );
    });
  }
}

/// Ilustracija sa natpisom ispod: mesto, pa vrsta površine.
class _HeroShot extends StatelessWidget {
  final String asset;
  final String place;
  final String format;

  const _HeroShot(
      {required this.asset, required this.place, required this.format});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LandingShot(asset: asset),
        const SizedBox(height: 8),
        Text(
          place,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.inkText.withValues(alpha: 0.86)),
        ),
        Text(
          format,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}

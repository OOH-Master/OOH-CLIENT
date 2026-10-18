import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../discover/data/dto/dto.dart';
import '../../data/repository/inventory_management_repository.dart';
import '../blocs/inventory_images_cubit.dart';
import '../blocs/inventory_management_bloc.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/inventory_list_items.dart';
import '../widgets/map_location_picker.dart';

class InventoryFormPage extends StatelessWidget {
  final String? inventoryId;

  const InventoryFormPage({super.key, this.inventoryId});

  bool get isEditing => inventoryId != null;

  /// Podaci površine koje lista prosleđuje pri otvaranju izmene, da forma ne
  /// bude prazna. Posle osvežavanja stranice ih nema i forma počinje prazna.
  static InventoryItemDto? _initialFromRoute(BuildContext context, int? id) {
    try {
      final extra = GoRouterState.of(context).extra;
      InventoryItemDto? item;
      if (extra is InventoryItemDto) {
        item = extra;
      } else if (extra is Map) {
        item = InventoryItemDto.fromJson(Map<String, dynamic>.from(extra));
      }
      if (item != null && (id == null || item.id == id)) return item;
    } catch (_) {
      // Bez podataka iz liste forma ostaje prazna, kao i ranije.
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<InventoryManagementRepository>();
    final parsedId = inventoryId != null ? int.tryParse(inventoryId!) : null;
    final initial = isEditing ? _initialFromRoute(context, parsedId) : null;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => InventoryManagementBloc(repo)),
        if (parsedId != null)
          BlocProvider(
            create: (_) => InventoryImagesCubit(repo, parsedId)..load(),
          ),
      ],
      child: _InventoryFormView(
        inventoryId: inventoryId,
        isEditing: isEditing,
        initial: initial,
      ),
    );
  }
}

class _InventoryFormView extends StatefulWidget {
  final String? inventoryId;
  final bool isEditing;
  final InventoryItemDto? initial;

  const _InventoryFormView({
    this.inventoryId,
    required this.isEditing,
    this.initial,
  });

  @override
  State<_InventoryFormView> createState() => _InventoryFormViewState();
}

class _InventoryFormViewState extends State<_InventoryFormView> {
  static const _environments = [
    'ROADSIDE',
    'INDOOR',
    'MALL',
    'AIRPORT',
    'TRANSIT',
    'OTHER',
  ];
  static const _illuminations = [
    'ILLUMINATED',
    'BACKLIT',
    'FRONTLIT',
    'AMBIENT_ARTIFICIAL',
    'NOT_ILLUMINATED',
  ];
  static const _cycles = [
    'ONE_DAY',
    'ONE_WEEK',
    'TWO_WEEK',
    'FOUR_WEEK',
    'ONE_MONTH',
  ];

  final _formKey = GlobalKey<FormState>();
  final _siteNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _formatController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _pixelWidthController = TextEditingController();
  final _pixelHeightController = TextEditingController();
  String? _currency = 'EUR';
  String? _cycleType = 'ONE_MONTH';
  String? _environment;
  String? _illumination;
  String _sizeUnit = 'M';
  double? _lat;
  double? _lng;
  bool _showPreview = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  /// Fotografije postoje samo za sačuvanu površinu sa ispravnim brojem u putanji.
  bool get _hasImages =>
      widget.isEditing && int.tryParse(widget.inventoryId ?? '') != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) _seed(initial);
    _priceController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _priceController.removeListener(_refresh);
    _siteNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _formatController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _pixelWidthController.dispose();
    _pixelHeightController.dispose();
    super.dispose();
  }

  // ── Popunjavanje iz postojeće površine ───────────────────────────────────

  static String _plain(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// API vraća ciklus kao "4-week", a prima ime enuma ("FOUR_WEEK").
  static String? _cycleEnum(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return null;
    if (_cycles.contains(v.toUpperCase())) return v.toUpperCase();
    switch (v.toLowerCase()) {
      case '1-day':
        return 'ONE_DAY';
      case '1-week':
        return 'ONE_WEEK';
      case '2-week':
        return 'TWO_WEEK';
      case '4-week':
        return 'FOUR_WEEK';
      case '1-month':
        return 'ONE_MONTH';
    }
    return null;
  }

  /// API vraća osvetljenje kao "Not illuminated", a prima "NOT_ILLUMINATED".
  static String? _illuminationEnum(String? raw) {
    final v = (raw ?? '').trim().toUpperCase().replaceAll(' ', '_');
    if (v.isEmpty || v == 'UNKNOWN') return null;
    return v;
  }

  void _seed(InventoryItemDto i) {
    _siteNameController.text = i.siteName ?? '';
    _descriptionController.text = i.description ?? '';
    _addressController.text = i.fullAddress ?? '';
    if (i.pricePerCycle != null) {
      _priceController.text = _plain(i.pricePerCycle!);
    }
    if (i.currency != null && i.currency!.trim().isNotEmpty) {
      _currency = i.currency!.trim().toUpperCase();
    }
    _cycleType = _cycleEnum(i.cycleType) ?? _cycleType;
    final env = i.environment?.trim().toUpperCase();
    _environment = (env == null || env.isEmpty) ? null : env;
    _illumination = _illuminationEnum(i.illumination);
    _lat = i.lat;
    _lng = i.lng;
    _formatController.text = i.vendorMediaFormatName ?? '';
    if (i.physicalWidth != null) {
      _widthController.text = _plain(i.physicalWidth!);
    }
    if (i.physicalHeight != null) {
      _heightController.text = _plain(i.physicalHeight!);
    }
    final unit = i.sizeUnit?.trim().toUpperCase();
    if (unit != null && unit.isNotEmpty) _sizeUnit = unit;
    if (i.pixelWidth != null) _pixelWidthController.text = '${i.pixelWidth}';
    if (i.pixelHeight != null) _pixelHeightController.text = '${i.pixelHeight}';
  }

  static double? _number(String text) {
    final t = text.trim().replaceAll(' ', '').replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  // ── Akcije ───────────────────────────────────────────────────────────────

  void _togglePreview() {
    if (_showPreview) {
      setState(() => _showPreview = false);
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _showPreview = true);
    }
  }

  void _cancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/app/my-inventory');
    }
  }

  void _handleSubmit() {
    // U pregledu forma nije u stablu; polja su već provereni pri ulasku u pregled.
    final form = _formKey.currentState;
    if (form != null && !form.validate()) return;

    final data = <String, dynamic>{
      'siteName': _siteNameController.text,
      'fullAddress': _addressController.text,
      'pricePerCycle': _number(_priceController.text),
      'currency': _currency,
      'cycleType': _cycleType,
    };

    if (_descriptionController.text.isNotEmpty) {
      data['description'] = _descriptionController.text;
    }
    if (_environment != null) data['environment'] = _environment;
    if (_illumination != null) data['illumination'] = _illumination;
    if (_lat != null) data['lat'] = _lat;
    if (_lng != null) data['lng'] = _lng;

    // Format i dimenzije šalju se samo kada su uneti.
    final format = _formatController.text.trim();
    if (format.isNotEmpty) data['vendorMediaFormatName'] = format;
    final width = _number(_widthController.text);
    final height = _number(_heightController.text);
    if (width != null) data['physicalWidth'] = width;
    if (height != null) data['physicalHeight'] = height;
    if (width != null || height != null) data['sizeUnit'] = _sizeUnit;
    final pw = int.tryParse(_pixelWidthController.text.trim());
    final ph = int.tryParse(_pixelHeightController.text.trim());
    if (pw != null) data['pixelWidth'] = pw;
    if (ph != null) data['pixelHeight'] = ph;

    final bloc = context.read<InventoryManagementBloc>();
    if (widget.isEditing) {
      final id = int.tryParse(widget.inventoryId!);
      if (id != null) bloc.add(UpdateInventoryItem(id, data));
    } else {
      bloc.add(CreateInventoryItem(data));
    }
  }

  // ── Izgled ───────────────────────────────────────────────────────────────

  String get _title => widget.isEditing ? 'Izmena površine' : 'Nova površina';

  /// Šifra i mesto površine koja se menja; za novu površinu nema podnaslova.
  String? get _subtitle {
    final i = widget.initial;
    if (!widget.isEditing || i == null) return null;
    final view = InventoryView(i);
    final text = [view.code, view.place]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(', ');
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide
          ? null
          : AppBar(
              title: Text(_title),
              actions: [
                TextButton.icon(
                  onPressed: _togglePreview,
                  icon: Icon(
                    _showPreview
                        ? Icons.edit_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  label: Text(_showPreview ? 'Izmeni' : 'Pregled'),
                ),
                const SizedBox(width: 4),
              ],
            ),
      bottomNavigationBar:
          BlocBuilder<InventoryManagementBloc, InventoryManagementState>(
        builder: (context, state) => _FormActionBar(
          wide: wide,
          loading: state is InventoryManagementLoading,
          saveLabel: widget.isEditing ? 'Sačuvaj izmene' : 'Sačuvaj površinu',
          onCancel: _cancel,
          onSave: _handleSubmit,
        ),
      ),
      body: BlocListener<InventoryManagementBloc, InventoryManagementState>(
        listener: (context, state) {
          if (state is InventoryFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          }
          if (state is InventoryManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = wide ? 32.0 : 16.0;
            final gutter = math.max(side, (constraints.maxWidth - 1240) / 2);
            final contentWidth = constraints.maxWidth - 2 * gutter;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(gutter, wide ? 0 : 16, gutter, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wide)
                    PageHeader(
                      title: _title,
                      subtitle: _subtitle,
                      showBack: true,
                      padding: const EdgeInsets.only(top: 28, bottom: 22),
                      actions: [
                        OutlinedButton.icon(
                          onPressed: _togglePreview,
                          icon: Icon(
                            _showPreview
                                ? Icons.edit_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                          ),
                          label: Text(_showPreview
                              ? 'Nastavi izmenu'
                              : 'Pregled pre čuvanja'),
                        ),
                      ],
                    ),
                  if (_showPreview)
                    _buildPreview(contentWidth)
                  else
                    Form(key: _formKey, child: _buildSections(contentWidth)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSections(double width) {
    final basic = _basicSection();
    final location = _locationSection();
    final format = _formatSection();
    final price = _priceSection();
    final photos = _photosSection();
    const gap = SizedBox(height: 16);

    if (width >= 980) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(children: [basic, gap, location]),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: Column(children: [format, gap, price, gap, photos]),
          ),
        ],
      );
    }
    return Column(
      children: [basic, gap, location, gap, format, gap, price, gap, photos],
    );
  }

  String? _required(String? v) =>
      (v == null || v.isEmpty) ? l10n.validatorRequired : null;

  /// "EUR (€)", "BAM (KM)"; kada je oznaka ista kao šifra, samo "RSD".
  static String _currencyOption(String code) {
    final label = SrFormat.currencyLabel(code);
    return (label.isEmpty || label == code) ? code : '$code ($label)';
  }

  Widget _basicSection() {
    return SectionCard(
      title: 'Osnovno',
      child: Column(
        children: [
          TextFormField(
            controller: _siteNameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '${l10n.siteName} *',
              hintText: 'npr. LED ekran Slavija',
            ),
            validator: _required,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration(
              labelText: l10n.description,
              hintText: 'Vidljivost, saobraćaj, okolina, posebne pogodnosti',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationSection() {
    return SectionCard(
      title: 'Lokacija',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _addressController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '${l10n.address} *',
              hintText: 'Ulica i broj, grad',
              prefixIcon: const Icon(Icons.place_outlined, size: 20),
            ),
            validator: _required,
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Tip lokacije'),
          _choiceChips(
            options: _environments,
            selected: _environment,
            label: SrLabels.venue,
            onChanged: (v) => setState(() => _environment = v),
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Tačka na mapi'),
          MapLocationPicker(
            initialLat: _lat,
            initialLng: _lng,
            hasLocation: _lat != null && _lng != null,
            onLocationSelected: (LatLng location) {
              setState(() {
                _lat = location.latitude;
                _lng = location.longitude;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _formatSection() {
    final decimal = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    final digits = [FilteringTextInputFormatter.digitsOnly];
    final units = {'M', 'CM', _sizeUnit}.toList();

    return SectionCard(
      title: 'Format i dimenzije',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _formatController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Format',
              hintText: 'npr. Billboard 4x3, City light, LED ekran',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _widthController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimal,
                  decoration: const InputDecoration(labelText: 'Širina'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('×'),
              ),
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimal,
                  decoration: const InputDecoration(labelText: 'Visina'),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                child: DropdownButtonFormField<String>(
                  initialValue: _sizeUnit,
                  decoration: const InputDecoration(labelText: 'Jedinica'),
                  items: [
                    for (final u in units)
                      DropdownMenuItem(value: u, child: Text(u.toLowerCase())),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _sizeUnit = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pixelWidthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: digits,
                  decoration: const InputDecoration(
                    labelText: 'Rezolucija, širina (px)',
                    helperText: 'Samo za digitalne površine',
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 22),
                child: Text('×'),
              ),
              Expanded(
                child: TextFormField(
                  controller: _pixelHeightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: digits,
                  decoration: const InputDecoration(
                    labelText: 'Visina (px)',
                    helperText: ' ',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FieldLabel(l10n.illumination),
          _choiceChips(
            options: _illuminations,
            selected: _illumination,
            label: SrLabels.illumination,
            onChanged: (v) => setState(() => _illumination = v),
          ),
        ],
      ),
    );
  }

  Widget _priceSection() {
    final currencies = {
      'EUR',
      'RSD',
      'BAM',
      'USD',
      if (_currency != null) _currency!
    }.toList();
    final parsed = _number(_priceController.text);

    return SectionCard(
      title: 'Cena i ciklus',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  style: AppTypography.money.copyWith(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: '${l10n.price} *',
                    hintText: 'npr. 180',
                    suffixText: SrFormat.currencyLabel(_currency),
                  ),
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: InputDecoration(labelText: l10n.currency),
                  items: [
                    for (final c in currencies)
                      DropdownMenuItem(
                        value: c,
                        child: Text(_currencyOption(c)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _currency = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _FieldLabel(l10n.cycleType),
          _choiceChips(
            options: _cycles,
            selected: _cycleType,
            allowNone: false,
            label: (c) {
              final s = SrFormat.cycleLabel(c);
              return s.isEmpty ? c ?? '' : s[0].toUpperCase() + s.substring(1);
            },
            onChanged: (v) => setState(() => _cycleType = v),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: AppDecorations.sunken(),
            child: Row(
              children: [
                Text('U pretrazi: ',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.mutedForeground)),
                Flexible(
                  child: Text(
                    parsed == null
                        ? 'cena još nije uneta'
                        : SrFormat.priceWithCycle(
                            parsed, _currency, _cycleType),
                    style: parsed == null
                        ? AppTypography.bodySmall
                            .copyWith(color: AppColors.subtle)
                        : AppTypography.money.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photosSection() {
    if (!_hasImages) {
      return SectionCard(
        title: 'Fotografije',
        child: Text(
          'Dodaju se posle čuvanja površine.',
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.mutedForeground),
        ),
      );
    }

    return SectionCard(
      title: 'Fotografije',
      child: BlocConsumer<InventoryImagesCubit, InventoryImagesState>(
        listener: (ctx, imgState) {
          if (imgState.error != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text('Greška sa fotografijama: ${imgState.error}'),
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        },
        builder: (ctx, imgState) {
          final cubit = ctx.read<InventoryImagesCubit>();
          if (imgState.isLoading && imgState.images.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return ImageUploadWidget(
            existingImages: imgState.images.map((img) {
              final path =
                  img.imageUrl ?? '/api/v1/public/files/${img.fileName}';
              return ApiConfig.absoluteUrl(path);
            }).toList(),
            isUploading: imgState.isUploading,
            onImagesAdded: (List<XFile> files) {
              cubit.uploadImages(files);
            },
            onImageRemoved: (int index) {
              if (index < imgState.images.length) {
                cubit.deleteImage(imgState.images[index].id);
              }
            },
          );
        },
      ),
    );
  }

  Widget _choiceChips({
    required List<String> options,
    required String? selected,
    required String Function(String?) label,
    required ValueChanged<String?> onChanged,
    bool allowNone = true,
  }) {
    final all = [...options];
    if (selected != null && !all.contains(selected)) all.add(selected);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in all)
          ChoiceChip(
            label: Text(label(option).isEmpty ? option : label(option)),
            selected: selected == option,
            showCheckmark: false,
            onSelected: (_) {
              final isSelected = selected == option;
              if (isSelected && !allowNone) return;
              onChanged(isSelected ? null : option);
            },
            selectedColor: AppColors.primarySoft,
            side: BorderSide(
              color: selected == option ? AppColors.primary : AppColors.border,
            ),
            labelStyle: AppTypography.labelMedium.copyWith(
              color: selected == option
                  ? AppColors.primaryStrong
                  : AppColors.text2,
              fontWeight:
                  selected == option ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
      ],
    );
  }

  // ── Pregled pre čuvanja ──────────────────────────────────────────────────

  Widget _buildPreview(double width) {
    final initial = widget.initial;
    final price = _number(_priceController.text);
    final place = initial == null
        ? ''
        : SrLabels.place(initial.city?.name, initial.country?.name);
    final dims = SrLabels.dimensions(_number(_widthController.text),
        _number(_heightController.text), _sizeUnit.toLowerCase());
    final pw = int.tryParse(_pixelWidthController.text.trim());
    final ph = int.tryParse(_pixelHeightController.text.trim());
    final resolution = (pw != null && ph != null) ? '$pw × $ph px' : '';
    final format = SrLabels.format(_formatController.text.trim());
    final digital = initial != null && InventoryView(initial).digital;

    String? imageUrl = initial?.assetUrl;
    if (_hasImages) {
      final images = context.read<InventoryImagesCubit>().state.images;
      if (images.isNotEmpty) {
        imageUrl = images.first.imageUrl ??
            '/api/v1/public/files/${images.first.fileName}';
      }
    }

    final specs = [
      if (_environment != null) SrLabels.venue(_environment),
      if (format.isNotEmpty) format,
      if (dims.isNotEmpty) dims,
      if (resolution.isNotEmpty) resolution,
      if (_illumination != null) SrLabels.illumination(_illumination),
    ].where((s) => s.isNotEmpty).toList();

    final thumb = UnitThumb(
      imageUrl: imageUrl,
      width: width >= 720 ? 320 : width - 40,
      height: width >= 720 ? 210 : (width - 40) * 0.62,
      radius: AppRadius.md,
      digital: digital,
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (initial != null && InventoryView(initial).code != null) ...[
          InventoryCodeTag(InventoryView(initial).code!),
          const SizedBox(height: 6),
        ],
        Text(_siteNameController.text, style: AppTypography.h4),
        const SizedBox(height: 4),
        Text(
          [_addressController.text, place]
              .where((s) => s.isNotEmpty)
              .join(', '),
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.mutedForeground),
        ),
        if (specs.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final s in specs) SpecChip(label: s)],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          price == null
              ? 'Cena nije uneta'
              : SrFormat.priceWithCycle(price, _currency, _cycleType),
          style: AppTypography.money.copyWith(fontSize: 22),
        ),
        if (_descriptionController.text.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            _descriptionController.text,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.text2),
          ),
        ],
        const SizedBox(height: 14),
        Text(
          _lat != null && _lng != null
              ? 'Tačka na mapi: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}'
              : 'Tačka na mapi nije postavljena',
          style:
              AppTypography.caption.copyWith(color: AppColors.mutedForeground),
        ),
      ],
    );

    return SectionCard(
      title: 'Pregled pre čuvanja',
      child: width >= 720
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                thumb,
                const SizedBox(width: 24),
                Expanded(child: info)
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [thumb, const SizedBox(height: 16), info],
            ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Traka za čuvanje, zalepljena za dno ekrana.
class _FormActionBar extends StatelessWidget {
  final bool wide;
  final bool loading;
  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _FormActionBar({
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

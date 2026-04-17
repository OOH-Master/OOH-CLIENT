import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../discover/data/repository/discover_repository.dart';
import '../../../discover/domain/entities/ooh_unit.dart';
import '../../data/repository/inquiry_repository.dart';

/// Admin-only page for attaching inventory units to a BRIEF inquiry.
/// Opens the full public inventory list with checkbox selection; on submit
/// posts to `POST /api/v1/admin/inquiries/{id}/assign-units`.
class AdminAssignUnitsPage extends StatelessWidget {
  final int inquiryId;

  const AdminAssignUnitsPage({super.key, required this.inquiryId});

  @override
  Widget build(BuildContext context) {
    return _AssignUnitsView(inquiryId: inquiryId);
  }
}

class _AssignUnitsView extends StatefulWidget {
  final int inquiryId;

  const _AssignUnitsView({required this.inquiryId});

  @override
  State<_AssignUnitsView> createState() => _AssignUnitsViewState();
}

class _AssignUnitsViewState extends State<_AssignUnitsView> {
  late final DiscoverRepository _discover;
  late final InquiryRepository _inquiry;
  List<OohUnit> _units = [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _discover = context.read<DiscoverRepository>();
    _inquiry = context.read<InquiryRepository>();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _discover.getUnits();
    if (!mounted) return;
    if (result is Success<List<OohUnit>>) {
      setState(() {
        _units = result.data;
        _loading = false;
      });
    } else if (result is Error<List<OohUnit>>) {
      setState(() {
        _error = result.failure.message;
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) return;
    setState(() => _submitting = true);
    final ids = _selected.map(int.parse).toList();
    try {
      await _inquiry.assignUnits(widget.inquiryId, ids);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.unitsAssignedSuccess(ids.length))),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.error}: $e'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  List<OohUnit> get _filtered {
    if (_search.isEmpty) return _units;
    final q = _search.toLowerCase();
    return _units.where((u) {
      return u.address.toLowerCase().contains(q) ||
          u.cityName.toLowerCase().contains(q) ||
          (u.mediaOwnerName?.toLowerCase().contains(q) ?? false) ||
          u.type.name.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)!.assignUnits} — #${widget.inquiryId}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
            const SizedBox(height: AppSpacing.sm),
            Text(_error!),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(onPressed: _load, child: Text(AppLocalizations.of(context)!.retry)),
          ],
        ),
      );
    }

    final filtered = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.assignUnitsSearchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noUnitsFound,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final unit = filtered[i];
                    final selected = _selected.contains(unit.id);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(unit.id);
                          } else {
                            _selected.remove(unit.id);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        unit.address,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${unit.cityName} • ${unit.type.name.toUpperCase()}'),
                          if (unit.mediaOwnerName != null)
                            Text(
                              unit.mediaOwnerName!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                        ],
                      ),
                      secondary: Text(
                        unit.priceDisplay,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.selectedCount(_selected.length),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: (_selected.isEmpty || _submitting) ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(AppLocalizations.of(context)!.assignLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

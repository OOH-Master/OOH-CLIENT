import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repository/agency_repository.dart';
import '../blocs/agency_bloc.dart';

class AgencyBrandsPage extends StatelessWidget {
  const AgencyBrandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AgencyBloc(context.read<AgencyRepository>())..add(LoadBrands()),
      child: const _AgencyBrandsView(),
    );
  }
}

class _AgencyBrandsView extends StatelessWidget {
  const _AgencyBrandsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.brands),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        icon: const Icon(Icons.add),
        label: Text(l10n.addBrand),
      ),
      body: BlocConsumer<AgencyBloc, AgencyState>(
        listener: (context, state) {
          if (state is BrandCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.brandCreated)),
            );
          }
        },
        builder: (context, state) {
          if (state is AgencyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AgencyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AgencyBloc>().add(LoadBrands()),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is BrandsLoaded) {
            if (state.brands.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_outlined,
                        size: 64, color: AppColors.mutedForeground),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.noBrands,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AgencyBloc>().add(LoadBrands());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.brands.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final brand = state.brands[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          radius: 20,
                          child: Text(
                            brand.name.isNotEmpty
                                ? brand.name[0].toUpperCase()
                                : '?',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            brand.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                        Text(
                          '#${brand.id}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.addBrand),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.brandName,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                context.read<AgencyBloc>().add(CreateBrand(name));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
              ),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}

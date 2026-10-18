import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/role.dart';

/// Izbor uloge pri registraciji: naziv, kratko objašnjenje i oznaka izbora.
/// Izabrana kartica dobija indigo ivicu i blagu indigo podlogu.
class RoleSelectorCard extends StatefulWidget {
  final Role role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectorCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<RoleSelectorCard> createState() => _RoleSelectorCardState();
}

class _RoleSelectorCardState extends State<RoleSelectorCard> {
  bool _hover = false;

  String get _title {
    switch (widget.role) {
      case Role.brand:
        return 'Brend';
      case Role.agency:
        return 'Agencija';
      case Role.mediaOwner:
        return 'Vlasnik medija';
      case Role.admin:
        return 'Stručnjak za lokacije';
    }
  }

  String get _description {
    switch (widget.role) {
      case Role.brand:
        return 'Oglašivač koji traži površine za svoje kampanje.';
      case Role.agency:
        return 'Planira i zakupljuje kampanje za više brendova.';
      case Role.mediaOwner:
        return 'Nudi bilborde, city light panele i digitalne ekrane.';
      case Role.admin:
        return 'Predlaže lokacije i vodi upite klijenata.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    final borderColor = selected
        ? AppColors.primary
        : (_hover ? AppColors.input : AppColors.border);

    return Semantics(
      button: true,
      selected: selected,
      label: _title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: selected ? 1.6 : 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 15,
                          color: selected
                              ? AppColors.primaryStrong
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _description,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _SelectionDot(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  final bool selected;

  const _SelectionDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.input,
          width: 1.6,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

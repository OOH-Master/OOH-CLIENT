import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../data/dto/notification_dto.dart';

/// Tekst obaveštenja sa servera, pripremljen za prikaz.
class NotificationText {
  NotificationText._();

  /// Statusi dobijaju srpske nazive ("SUBMITTED" postaje "Podnet"), a crta
  /// između delova naslova postaje zarez: "Zahtev za cenu — Upit #4" postaje
  /// "Zahtev za cenu, upit #4".
  static String clean(String raw) {
    final labeled = raw.replaceAllMapped(RegExp(r'\b[A-Z][A-Z_]{2,}\b'), (m) {
      final token = m[0]!;
      final label = SrLabels.inquiryStatus(token);
      return label.isEmpty ? token : label;
    });
    return labeled
        .replaceAllMapped(RegExp(r'\s+—\s+(\p{Lu})(?=\p{Ll})', unicode: true),
            (m) => ', ${m[1]!.toLowerCase()}')
        .replaceAll(RegExp(r'\s+—\s+'), ', ');
  }
}

/// Jedno obaveštenje: naslov, vreme, poruka, veza ka upitu i tačka za
/// nepročitano. Koristi se na stranici obaveštenja i u padajućem meniju zvonca.
class NotificationTile extends StatefulWidget {
  final NotificationDto notification;
  final VoidCallback? onTap;

  /// Opciona veza ka upitu ili zahtevu na koji se obaveštenje odnosi.
  final VoidCallback? onOpen;
  final String? openLabel;

  /// Vreme za prikaz; podrazumevano relativno ("pre 5 min").
  final String? timeLabel;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onOpen,
    this.openLabel,
    this.timeLabel,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool _hovered = false;

  static final Color _unreadBackground = Color.alphaBlend(
      AppColors.primary.withValues(alpha: 0.045), AppColors.surface);

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final unread = !n.read;
    final title = NotificationText.clean(
        (n.title ?? '').trim().isEmpty ? 'Obaveštenje' : n.title!.trim());
    final message = n.message == null || n.message!.trim().isEmpty
        ? null
        : NotificationText.clean(n.message!.trim());
    final time = widget.timeLabel ?? n.timeAgo;

    final background = unread
        ? _unreadBackground
        : (_hovered
            ? AppColors.surfaceSunken.withValues(alpha: 0.6)
            : AppColors.surface);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.foreground,
                                  fontWeight: unread
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (time.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text(
                                  time,
                                  style: AppTypography.caption.copyWith(
                                    color: unread
                                        ? AppColors.primaryStrong
                                        : AppColors.subtle,
                                    fontWeight: unread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (message != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.mutedForeground),
                          ),
                        ],
                        if (widget.onOpen != null) ...[
                          const SizedBox(height: 8),
                          _OpenLink(
                            label: widget.openLabel ?? 'Otvori',
                            onTap: widget.onOpen!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (unread)
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 6),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Veza ka upitu: obojen tekst.
class _OpenLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OpenLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

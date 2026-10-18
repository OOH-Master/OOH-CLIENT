import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../domain/entities/inquiry.dart';

enum _StepState { done, current, upcoming, failed }

class _StepData {
  final String label;
  final String? caption;
  final _StepState state;
  final bool success;

  const _StepData(this.label, this.state, {this.caption, this.success = false});
}

/// Tok upita kao vodoravni niz koraka, izveden iz statusa:
/// Podnet → (Dodela površina, samo brif) → Cene vlasnika → Ponuda → Odluka.
class InquiryProgress extends StatelessWidget {
  final InquiryStatus status;
  final bool brief;
  final String? createdAt;

  const InquiryProgress({
    super.key,
    required this.status,
    required this.brief,
    this.createdAt,
  });

  List<_StepData> _steps() {
    final labels = [
      'Podnet',
      if (brief) 'Dodela površina',
      'Cene vlasnika',
      'Ponuda',
      'Odluka',
    ];
    final last = labels.length - 1;
    final pricesStep = brief ? 2 : 1;

    // Indeks koraka koji je u toku; svi pre njega su završeni.
    final int current;
    switch (status) {
      case InquiryStatus.submitted:
      case InquiryStatus.inProgress:
        current = 1;
        break;
      case InquiryStatus.quotesRequested:
        current = pricesStep;
        break;
      case InquiryStatus.pricingReady:
        current = pricesStep + 1;
        break;
      case InquiryStatus.offerSent:
      case InquiryStatus.rejectedByClient:
        current = last;
        break;
      case InquiryStatus.acceptedByClient:
      case InquiryStatus.realized:
      case InquiryStatus.closed:
        current = labels.length;
        break;
    }

    String? finalCaption;
    switch (status) {
      case InquiryStatus.acceptedByClient:
        finalCaption = 'Prihvaćeno';
        break;
      case InquiryStatus.realized:
        finalCaption = 'Realizovano';
        break;
      case InquiryStatus.closed:
        finalCaption = 'Zatvoreno';
        break;
      case InquiryStatus.rejectedByClient:
        finalCaption = 'Odbijeno';
        break;
      default:
        finalCaption = null;
    }

    final submitted = SrFormat.parseDate(createdAt);
    return [
      for (var i = 0; i < labels.length; i++)
        if (i == last && status == InquiryStatus.rejectedByClient)
          _StepData(labels[i], _StepState.failed, caption: finalCaption)
        else if (i < current)
          _StepData(
            labels[i],
            _StepState.done,
            caption: i == 0 && submitted != null
                ? SrFormat.date(submitted)
                : (i == last ? finalCaption : null),
            success: i == last &&
                (status == InquiryStatus.acceptedByClient ||
                    status == InquiryStatus.realized),
          )
        else if (i == current)
          _StepData(labels[i], _StepState.current,
              caption: i == last ? 'čeka odluku' : 'u toku')
        else
          _StepData(labels[i], _StepState.upcoming),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: _StepView(
              index: i,
              step: steps[i],
              leftLine: i == 0 ? null : steps[i].state != _StepState.upcoming,
              rightLine: i == steps.length - 1
                  ? null
                  : (steps[i].state == _StepState.done &&
                      steps[i + 1].state != _StepState.upcoming),
            ),
          ),
      ],
    );
  }
}

class _StepView extends StatelessWidget {
  final int index;
  final _StepData step;

  /// null = nema linije (prvi ili poslednji korak); true = pređeni deo toka.
  final bool? leftLine;
  final bool? rightLine;

  const _StepView({
    required this.index,
    required this.step,
    required this.leftLine,
    required this.rightLine,
  });

  Widget _line(bool? active) {
    if (active == null) return const Expanded(child: SizedBox());
    return Expanded(
      child: Container(
        height: 2,
        color: active ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _dot() {
    switch (step.state) {
      case _StepState.done:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: step.success ? AppColors.success : AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
        );
      case _StepState.current:
        return Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
          ),
        );
      case _StepState.failed:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              color: AppColors.destructive, shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
        );
      case _StepState.upcoming:
        return Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceSunken,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '${index + 1}',
            style: AppTypography.labelSmall
                .copyWith(color: AppColors.subtle, fontWeight: FontWeight.w600),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reached = step.state != _StepState.upcoming;
    final captionColor = step.state == _StepState.failed
        ? AppColors.destructive
        : step.state == _StepState.current
            ? AppColors.primary
            : AppColors.mutedForeground;
    return Column(
      children: [
        SizedBox(
          height: 32,
          child: Row(
            children: [_line(leftLine), _dot(), _line(rightLine)],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            step.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: reached ? AppColors.foreground : AppColors.mutedForeground,
            ),
          ),
        ),
        if (step.caption != null) ...[
          const SizedBox(height: 2),
          Text(
            step.caption!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: captionColor),
          ),
        ],
      ],
    );
  }
}

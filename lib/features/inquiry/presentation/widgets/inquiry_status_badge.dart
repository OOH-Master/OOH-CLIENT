import 'package:flutter/material.dart';

import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../domain/entities/inquiry.dart';

/// Status upita na srpskom, sa bojom faze: plava dok je upit kod platforme,
/// ljubičasta dok vlasnici određuju cene, indigo kada je ponuda poslata,
/// zelena za prihvaćeno, crvena za odbijeno.
class InquiryStatusBadge extends StatelessWidget {
  final InquiryStatus status;
  final bool dense;

  const InquiryStatusBadge(
      {super.key, required this.status, this.dense = false});

  static PillTone toneFor(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.submitted:
        return PillTone.info;
      case InquiryStatus.inProgress:
        return PillTone.warning;
      case InquiryStatus.quotesRequested:
        return PillTone.violet;
      case InquiryStatus.pricingReady:
        return PillTone.primary;
      case InquiryStatus.offerSent:
        return PillTone.primary;
      case InquiryStatus.acceptedByClient:
        return PillTone.success;
      case InquiryStatus.rejectedByClient:
        return PillTone.danger;
      case InquiryStatus.realized:
        return PillTone.success;
      case InquiryStatus.closed:
        return PillTone.neutral;
    }
  }

  static String labelFor(InquiryStatus status) =>
      SrLabels.inquiryStatus(status.apiValue);

  @override
  Widget build(BuildContext context) {
    return StatusPill(
        label: labelFor(status), tone: toneFor(status), dense: dense);
  }
}

import 'package:flutter/material.dart';

import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';

/// Status zahteva za ponudu (vlasnik medija): novi plavo, u izradi ćilibarno,
/// cene poslate zeleno, odbijeno crveno.
class QuoteStatusPill extends StatelessWidget {
  final String status;
  final bool dense;

  const QuoteStatusPill({super.key, required this.status, this.dense = false});

  static PillTone toneFor(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
        return PillTone.info;
      case 'IN_PROGRESS':
        return PillTone.warning;
      case 'SUBMITTED':
        return PillTone.success;
      case 'DECLINED':
        return PillTone.danger;
      default:
        return PillTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) => StatusPill(
      label: SrLabels.quoteStatus(status), tone: toneFor(status), dense: dense);
}

/// Status objedinjene ponude: čeka odluku (indigo), prihvaćena, odbijena.
class OfferStatusPill extends StatelessWidget {
  final String? status;
  final bool dense;

  const OfferStatusPill({super.key, required this.status, this.dense = false});

  static PillTone toneFor(String? status) {
    switch ((status ?? 'SENT').toUpperCase()) {
      case 'SENT':
        return PillTone.primary;
      case 'ACCEPTED':
        return PillTone.success;
      case 'REJECTED':
        return PillTone.danger;
      default:
        return PillTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) => StatusPill(
      label: SrLabels.offerStatus(status ?? 'SENT'),
      tone: toneFor(status),
      dense: dense);
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/role.dart';
import '../../data/repository/inquiry_repository.dart';
import '../utils/inquiry_errors.dart';
import '../utils/pdf_opener.dart';
import 'inquiry_layout.dart';

/// "Preuzmi PDF": preuzima PDF upita ili objedinjene ponude sa adrese koja
/// pripada ulozi (brend, agencija, stručnjak) i otvara ga.
class PdfDownloadButton extends StatefulWidget {
  final int inquiryId;
  final Role role;
  final String label;
  final bool iconOnly;
  final bool expand;

  const PdfDownloadButton({
    super.key,
    required this.inquiryId,
    required this.role,
    this.label = 'Preuzmi PDF',
    this.iconOnly = false,
    this.expand = false,
  });

  @override
  State<PdfDownloadButton> createState() => _PdfDownloadButtonState();
}

class _PdfDownloadButtonState extends State<PdfDownloadButton> {
  bool _busy = false;

  Future<void> _download() async {
    if (_busy) return;
    final repository = context.read<InquiryRepository>();
    setState(() => _busy = true);
    try {
      final bytes =
          await repository.downloadPdf(widget.inquiryId, role: widget.role);
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        showInquirySnack(context, 'PDF još nije spreman. Pokušajte ponovo.',
            error: true);
        return;
      }
      final opened =
          await openPdfBytes(bytes, 'ponuda-upit-${widget.inquiryId}.pdf');
      if (!mounted) return;
      if (!opened) {
        showInquirySnack(
            context, 'Otvaranje PDF-a nije podržano na ovom uređaju.',
            error: true);
      }
    } catch (e) {
      if (mounted) {
        showInquirySnack(context, InquiryErrors.describe(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _busy
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.picture_as_pdf_outlined, size: 19);
    if (widget.iconOnly) {
      return IconButton(
        tooltip: widget.label,
        onPressed: _busy ? null : _download,
        icon: icon,
      );
    }
    final button = OutlinedButton.icon(
      onPressed: _busy ? null : _download,
      icon: icon,
      label: Text(widget.label),
    );
    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

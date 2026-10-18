import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

/// Android i iOS: PDF se predaje spoljnoj aplikaciji kao data URI.
Future<bool> openPdfBytes(List<int> bytes, String fileName) async {
  final uri = Uri.parse('data:application/pdf;base64,${base64Encode(bytes)}');
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

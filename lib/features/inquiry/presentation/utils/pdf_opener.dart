import 'pdf_opener_stub.dart' if (dart.library.js_interop) 'pdf_opener_web.dart'
    as platform;

/// Otvara PDF koji je stigao sa servera kao niz bajtova.
///
/// Na vebu pravi Blob i otvara ga u novoj kartici (ili ga preuzima kao datoteku
/// [fileName] kada pregledač blokira novi prozor). Na telefonu ga predaje
/// spoljnoj aplikaciji. Vraća `false` kada uređaj ne može da otvori PDF.
Future<bool> openPdfBytes(List<int> bytes, String fileName) =>
    platform.openPdfBytes(bytes, fileName);

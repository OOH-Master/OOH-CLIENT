import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

// Pregledač ne dozvoljava otvaranje data: adresa u novom prozoru, pa se PDF
// pretvara u Blob sa privremenom adresom (URL.createObjectURL).

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSAny> parts, _BlobOptions options);
}

extension type _BlobOptions._(JSObject _) implements JSObject {
  external factory _BlobOptions({String type});
}

@JS('URL')
extension type _ObjectUrl._(JSObject _) implements JSObject {
  external static String createObjectURL(JSObject blob);
  external static void revokeObjectURL(String url);
}

@JS('open')
external JSObject? _openWindow(String url, String target);

@JS('document')
external _Document get _document;

extension type _Document._(JSObject _) implements JSObject {
  external _Anchor createElement(String tag);
}

extension type _Anchor._(JSObject _) implements JSObject {
  external set href(String value);
  external set download(String value);
  external void click();
}

Future<bool> openPdfBytes(List<int> bytes, String fileName) async {
  final data = Uint8List.fromList(bytes).toJS;
  final blob = _Blob(<JSAny>[data].toJS, _BlobOptions(type: 'application/pdf'));
  final url = _ObjectUrl.createObjectURL(blob);

  // Nova kartica sa pregledom PDF-a; ako je pregledač blokira (zahtev je trajao
  // duže od dozvoljenog posle klika), PDF se preuzima kao datoteka.
  final opened = _openWindow(url, '_blank');
  if (opened == null) {
    final anchor = _document.createElement('a')
      ..href = url
      ..download = fileName;
    anchor.click();
  }

  // Adresa mora da živi dok se PDF ne učita u novoj kartici.
  Timer(const Duration(minutes: 2), () => _ObjectUrl.revokeObjectURL(url));
  return true;
}

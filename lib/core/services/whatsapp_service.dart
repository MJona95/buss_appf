import 'package:url_launcher/url_launcher.dart';

class WhatsAppException implements Exception {
  final String phoneNumber;

  const WhatsAppException(this.phoneNumber);

  @override
  String toString() => 'No se pudo abrir WhatsApp. Teléfono: $phoneNumber';
}

class WhatsAppService {
  Future<void> contactUnit({
    required String phoneNumber,
    required String unitNumber,
  }) async {
    final rawNumber = phoneNumber.replaceAll(RegExp(r'\+'), '');
    final uri = Uri.parse(
      'https://wa.me/$rawNumber?text=Hola%20Unidad%20$unitNumber,%20me%20gustaria%20obtener%20informacion.',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    throw WhatsAppException(phoneNumber);
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const _cloudName = 'dbbivsnc9';
  static const _uploadPreset = 'wander_public';

  static Future<String?> subirImagen(Uint8List bytes, String nombreArchivo) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['public_id'] = nombreArchivo
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: nombreArchivo));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(respStr);
        return data['secure_url'];
      } else {
        print('Error Cloudinary: ${response.statusCode}');
        print(respStr);
        return null;
      }
    } catch (e) {
      print('Error al subir a Cloudinary: $e');
      return null;
    }
  }
}

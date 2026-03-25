import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your PC LAN IP
  static const String baseUrl = "http://10.184.189.238:8000";

  static Future<Map<String, dynamic>?> detectPest(File image) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detect-pest'));
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        return jsonDecode(respStr);
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}

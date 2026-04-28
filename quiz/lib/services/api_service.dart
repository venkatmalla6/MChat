import 'dart:convert';
import 'package:http/http.dart' as http;
import 'file_service.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  Future<String> extractText(SelectedFileResult file) async {
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/extract-text');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.fileBytes,
          filename: file.fileName,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseData);
        if (decoded['success'] == true) {
          return decoded['extracted_text'] ?? '';
        }
        throw Exception('Backend returned unsuccessful response');
      }
      throw Exception('Server error ${response.statusCode}');
    });
  }

  Future<List<Map<String, dynamic>>> generateMcqs(String extractedText) async {
    return _retry(() async {
      final uri = Uri.parse('$_baseUrl/generate-mcqs');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'extracted_text': extractedText}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['mcqs'] != null) {
          return List<Map<String, dynamic>>.from(decoded['mcqs']);
        }
        throw Exception('Invalid response format');
      }
      throw Exception('Server error ${response.statusCode}');
    }, retries: 2);
  }
  Future<dynamic> translate(dynamic text, String targetLang) async {
    final uri = Uri.parse('$_baseUrl/translate');
    
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'target_language': targetLang,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return decoded['translated_text'];
        } else {
          throw Exception('Failed to translate: Invalid response');
        }
      } else {
         throw Exception('Failed to translate. Server error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during translation: $e');
    }
  }

  Future<T> _retry<T>(Future<T> Function() action, {int retries = 3}) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await action();
      } catch (e) {
        if (attempts >= retries) {
          throw Exception('Error after $attempts attempts: $e');
        }
        print('Retrying API call (Attempt $attempts)... Error: $e');
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }
}

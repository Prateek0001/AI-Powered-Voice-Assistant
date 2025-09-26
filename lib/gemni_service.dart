import 'dart:convert';
import 'package:voice_assistance/secrets.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$geminiAPIKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text":
                      "Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no."
                }
              ]
            }
          ]
        }),
      );

      print(res.body);
      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['candidates'][0]['content']
            ['parts'][0]['text'];
        content = content.trim();

        switch (content.toLowerCase()) {
          case 'yes':
          case 'yes.':
            final res = await geminiImageAPI(prompt); 
            return res;
          default:
            final res = await geminiChatAPI(prompt);
            return res;
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> geminiChatAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });

    try {
      final res = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$geminiAPIKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['candidates'][0]['content']
            ['parts'][0]['text'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> geminiImageAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-generate-001:?key=$geminiAPIKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (res.statusCode == 200) {
        String bytesBase64Encoded = jsonDecode(res.body)['predictions'][0]['bytesBase64Encoded'];
        bytesBase64Encoded = bytesBase64Encoded.trim();
        bytesBase64Encoded = 'data:image/png;base64,$bytesBase64Encoded';

        return bytesBase64Encoded;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chat_response.dart';

abstract class ChatRepo {
  Future<Either<String, ChatResponse>> sendMessage(String query);
}

class ChatRepoImpl implements ChatRepo {
  final String _baseUrl = 'http://10.0.2.2:8000/';

  @override
  Future<Either<String, ChatResponse>> sendMessage(String query) async {
    try {
      print('Chat API: Sending request to ${_baseUrl}chat');
      print('Chat API: Request body: ${json.encode({'query': query})}');

      final response = await http
          .post(
            Uri.parse('${_baseUrl}chat'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'query': query,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Chat API: Response status: ${response.statusCode}');
      print('Chat API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final chatResponse = ChatResponse.fromJson(responseData);

        if (chatResponse.status == 'success') {
          // Format the response for better mobile display
          final formattedResponse = _formatResponse(chatResponse.data.response);
          final formattedChatResponse = ChatResponse(
            status: chatResponse.status,
            message: chatResponse.message,
            data: ChatResponseData(
              response: formattedResponse,
              facilitiesFound: chatResponse.data.facilitiesFound,
            ),
          );
          return Right(formattedChatResponse);
        } else {
          return Left(chatResponse.message);
        }
      } else {
        return Left('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Chat API: Error occurred: $e');
      return Left('Network error: ${e.toString()}');
    }
  }

  String _formatResponse(String rawResponse) {
    // Clean and simplify the response for mobile display
    String formatted = rawResponse
        // Replace \n with actual line breaks
        .replaceAll('\\n', '\n')
        // Remove all markdown formatting
        .replaceAll('**', '')
        .replaceAll('*', '')
        // Clean up extra spaces and formatting
        .replaceAll('    ', '')
        .replaceAll('   ', ' ')
        // Remove excessive line breaks
        .replaceAll('\n\n\n', '\n\n')
        .replaceAll('\n\n\n\n', '\n\n');

    // Parse and restructure the response
    List<String> lines = formatted.split('\n');
    StringBuffer result = StringBuffer();

    String currentFacility = '';
    bool isNewFacility = false;

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Check if this is a facility name (usually longer and doesn't contain ':' with details)
      if (line.contains('Sports') ||
          line.contains('Club') ||
          line.contains('Complex') ||
          line.contains('Hall') ||
          line.contains('Dome') ||
          line.contains('Center')) {
        if (!line.contains('Address:') &&
            !line.contains('Price:') &&
            !line.contains('Operating')) {
          // This is a facility name
          if (currentFacility.isNotEmpty) {
            result.write('\n\n'); // Add spacing between facilities
          }
          currentFacility = line;
          result.write('🏟️ $line\n');
          isNewFacility = true;
          continue;
        }
      }

      // Process facility details
      if (line.contains('Address:')) {
        String address = line.replaceAll('Address:', '').trim();
        result.write('📍 $address\n');
      } else if (line.contains('Price:')) {
        String price = line.replaceAll('Price:', '').trim();
        result.write('💰 $price\n');
      } else if (line.contains('Capacity:')) {
        String capacity = line.replaceAll('Capacity:', '').trim();
        result.write('👥 $capacity\n');
      } else if (line.contains('Operating Hours:')) {
        String hours = line.replaceAll('Operating Hours:', '').trim();
        result.write('🕐 $hours\n');
      } else if (line.contains('Includes:')) {
        String includes = line.replaceAll('Includes:', '').trim();
        result.write('⚽ $includes\n');
      } else if (line.toLowerCase().contains('court') &&
          !currentFacility.isEmpty) {
        // Handle court information
        if (!line.contains('Address:') &&
            !line.contains('Price:') &&
            !line.contains('Operating')) {
          result.write('⚽ $line\n');
        }
      }
    }

    // Add summary
    result.write('\n✅ Multiple facilities found in your area!');

    return result.toString().trim();
  }
}

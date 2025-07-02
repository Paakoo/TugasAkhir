import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_keluar/screen/home_screen.dart';
import 'package:mobile_keluar/screen/result.dart';
import 'PresenceProvider.dart';

class VerificationHandler {
  static Future<void> handleResponse(
    BuildContext context, 
    Map<String, dynamic> response,
    Uint8List imageBytes
  ) async {
    final bool isSuccess = response['status'] == 'success';
    final bool isError = response['status'] == 'error';
    final errorCode = response['data']?['error_code'];

    if (!isSuccess || isError) {
      String errorMessage = 'Verification failed';
      if (errorCode == 'no_face_detected') {    
        errorMessage = 'No face detected. Please try again.';
      } else if (errorCode == 'spoof_detected') {
        errorMessage = 'Spoof detected. Please use a real face.';
      } else if (errorCode == 'face_not_found') {
        errorMessage = 'Face not found in database. Please register first.';
      } else if (errorCode == 'face_mismatch') {
        final matchedName = response['data']?['matched_name'] ?? 'Unknown';
        final confidence = (response['data']?['confidence'] ?? 0.0) * 100;
        errorMessage = 'Face matched with different user: $matchedName (${confidence.toStringAsFixed(2)}%)';
      } else {
        errorMessage = response['message'] ?? 'Verification failed.';
      }

      presenceProvider.setError(errorMessage);
      
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Verification Failed'),
              content: Text(
                errorMessage,
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  child: const Text('Try Again'),
                  onPressed: () {
                    presenceProvider.reset();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // Success case
      presenceProvider.setVerified(true);
    }
  }
}

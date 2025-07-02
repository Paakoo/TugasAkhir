import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Tambahkan ini
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final Uint8List imageBytes;
  final storage = FlutterSecureStorage();

  ResultScreen({
    Key? key,
    required this.result,
    required this.imageBytes,
  }) : super(key: key);

  Future<void> _sendPresenceData(BuildContext context) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final response = await http.post(
        Uri.parse('http://192.168.100.22:5000/api/presence'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(result),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/cob');
      } else {
        throw Exception('Failed to save presence data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(result);
    final bool isSuccess = result['status'] == 'success';
    
    if (isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendPresenceData(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Verification Result'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.memory(
              imageBytes,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      result['message'] ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isSuccess ? null : Colors.red,
                            fontWeight: isSuccess ? null : FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Status: ${result['status']?.toUpperCase() ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isSuccess ? Colors.green : Colors.red,
                          ),
                    ),
                    SizedBox(height: 10),
                    Text(
                        'Face Name: ${result['data']['matched_name'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Account Name: ${result['data']['database_name'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Location: ${result['location'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Confidence: ${(result['data']['confidence'] * 100).toStringAsFixed(2)}%',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Spoof Confidence: ${(result['data']['spoof_confidence'] * 100).toStringAsFixed(2)}%',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Is Real: ${(result['data']['is_real'] ?? 'Unknown')}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                
                    SizedBox(height: 20),
                    Text(
                      'Processing Times:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 10),
                    if (result['timing'] != null) ...[
                      _buildTimingRow('Detection', result['timing']['detection']),
                      _buildTimingRow('Embedding', result['timing']['embedding']),
                      _buildTimingRow('Matching', result['timing']['matching']),
                      _buildTimingRow('Processing', result['timing']['processing']),
                      Divider(),
                      _buildTimingRow('Total Time', result['timing']['total'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingRow(String label, String? value, {TextStyle? style}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value ?? '-', style: style),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    const storage = FlutterSecureStorage();

    try {
      // Hapus token dari penyimpanan
      await storage.delete(key: 'jwt_token');

      // Navigasi ke halaman login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      // Tampilkan pesan kesalahan jika logout gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout. Please try again.'),
        ),
      );
    }
  }
}

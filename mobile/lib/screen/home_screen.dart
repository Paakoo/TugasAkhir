import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http_parser/http_parser.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'nav_bar.dart';
import 'package:http/http.dart' as http;
import 'PresenceProvider.dart';
import 'package:flutter/services.dart';
import 'show_error.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _manualLocations = [
    {
      'name': 'Office Pertama',
      'location': LatLng(-7.770163593429085, 111.48197507858067),
    },
    {
      'name': 'PENS',
      'location': LatLng(-7.276847076758826, 112.79304403165791),
    },
    {
      'name': 'Office Kedua',
      'location': LatLng(-7.289130911117342, 112.79867119645702),
    },
  ];
  
  int _selectedOfficeIndex = 0;
  String? selectedLocation;
  bool isLocationSelected = false;
  final Location _location = Location();
  LatLng? _userLocation;
  double _radius = 30.0;
  bool _isUserWithinRadius = false;
  bool _isLocationServiceEnabled = false;
  String _currentTime = '';
  String _userName = '';
  Timer? _timer;
  bool _hasAttendanceToday = false;
  bool _hasClockedOut = false;
  final _storage = FlutterSecureStorage();
  
  @override
  void initState() {
    super.initState();
    if (!presenceProvider.isProcessing) {
      presenceProvider.reset();
    }
    _checkLocationService();
    _loadUserName();
    _updateTime();
    _checkPresenceStatus();
    _fetchTodayAttendance(); 
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _updateTime());
    initializeDateFormatting('id_ID');
    _location.onLocationChanged.listen((LocationData locationData) {
      if (mounted) {
        setState(() {
          _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
          _checkIfUserWithinRadius();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationService() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        _showLocationDialog();
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _showLocationDialog();
        return;
      }
    }

    setState(() => _isLocationServiceEnabled = true);
    _fetchLocation();
  }

  Future<void> _fetchTodayAttendance() async {
    final storage = FlutterSecureStorage();
    try {
      final token = await storage.read(key: 'jwt_token');
      final decodedToken = JwtDecoder.decode(token!);
      final userName = decodedToken['sub'];

      final response = await http.get(
        Uri.parse('http://20.189.117.63:8080/api/history?nama_karyawan=$userName'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final historyData = List<Map<String, dynamic>>.from(data['data']);
        
        // Check if there's attendance for today
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final hasTodayAttendance = historyData.any((item) {
          final date = DateTime.parse(item['tanggal']);
          return DateFormat('yyyy-MM-dd').format(date) == today;
        });

        if (mounted) {
          setState(() {
            _hasAttendanceToday = hasTodayAttendance;
          });
        }
      }
    } catch (e) {
      print('Error fetching attendance history: $e');
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Required'),
          content: Text('Please enable GPS and grant location permission to use this app.'),
          actions: [
            TextButton(
              child: Text('Settings'),
              onPressed: () async {
                Navigator.pop(context);
                await _location.requestService();
                await _checkLocationService();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchLocation() async {
    final locationData = await _location.getLocation();
    if (mounted) {
      setState(() {
        _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _checkIfUserWithinRadius();
      });
    }
  }

  double? _distanceToOffice;

  void _checkIfUserWithinRadius() {
    if (_userLocation != null) {
      final selectedOffice = _manualLocations[_selectedOfficeIndex]['location'];
      final distance = Distance().as(
        LengthUnit.Meter,
        selectedOffice,
        _userLocation!,
      );

      setState(() {
        _distanceToOffice = distance; // Simpan jarak untuk ditampilkan
        _isUserWithinRadius = distance <= _radius;
        
        // Debug prints
        print('Current location: ${_userLocation!.latitude}, ${_userLocation!.longitude}');
        print('Office location: ${selectedOffice.latitude}, ${selectedOffice.longitude}');
        print('Distance to office: $distance meters');
        print('Radius limit: $_radius meters');
        print('Is within radius: $_isUserWithinRadius');
      });
    }
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  Future<void> _loadUserName() async {
    final storage = FlutterSecureStorage();
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print('Decoded token: $decodedToken');
        final String name = decodedToken['sub'].toString();
        setState(() {
          _userName = name;
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
      setState(() {
        _userName = 'User';
      });
    }
  }

  Future<void> _restartGPS() async {
    setState(() => _isLocationServiceEnabled = false);
    await _location.requestService();
    await _checkLocationService();
  }

  Future<void> _checkPresenceStatus() async {
    final storage = FlutterSecureStorage();
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        final responseIn = await http.get(
          Uri.parse('http://20.189.117.63:8080/api/checkclockIn?nama_karyawan=$_userName'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (mounted) {
          setState(() {
            _hasAttendanceToday = responseIn.statusCode == 200;
            print('Attendance status updated - Clock in: $_hasAttendanceToday, Clock out: $_hasClockedOut');
          });
        }
      }
    } catch (e) {
      print('Error checking presence status: $e');
    }
  }

  void _showSuccessNotification(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Success',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }

  Widget _buildAttendanceButton() {
    return AnimatedBuilder(
      animation: presenceProvider,
      builder: (context, child) {
        if (_hasAttendanceToday) {
          return ElevatedButton.icon(
            onPressed: null,
            icon: Icon(Icons.check_circle, color: Colors.white),
            label: Text('Absensi Hari Ini Selesai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 20, 158, 91),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        return ElevatedButton.icon(
          onPressed: presenceProvider.isProcessing
            ? null 
            : _canStartRecognition()
              ? () async {
                  final result = await Navigator.pushNamed(context, '/liveness');
                  if (result != null && result is Map) {
                    if (result.containsKey('photoData')) {
                      await _verifyAndUpload(
                        result['photoData'],
                        selectedLocation!,
                        _userLocation?.latitude,
                        _userLocation?.longitude,
                      );
                    } else if (result.containsKey('error')) {
                      _showErrorDialog(result['error']);
                    }
                  }
                }
              : null,
          icon: presenceProvider.isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.login, color: Colors.white),
          label: Text(presenceProvider.isProcessing ? 'Processing...' : 'Mulai Absensi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  Future<void> _verifyAndUpload(Uint8List photoData,String locationType, double? latitude, double? longitude) async {
    presenceProvider.startProcessing();

    try {
      final token = await _storage.read(key: 'jwt_token');
      final uri = Uri.parse("http://20.189.117.63:8080/api/present");
      final request = http.MultipartRequest('POST', uri);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'upload_$timestamp.jpg';
      final String officeName = locationType == 'WFO' 
          ? _manualLocations[_selectedOfficeIndex]['name']
          : 'Work From Anywhere';

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      // Add photo file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          photoData,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Add latitude and longitude as form fields
      request.fields.addAll({
        'location_type': locationType,
        'office_name': officeName,
        'latitude': latitude?.toString() ?? '',
        'longitude': longitude?.toString() ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      });;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        await VerificationHandler.handleResponse(context, result, photoData);

        // Send attendance data after successful verification
        final presenceUri = Uri.parse("http://20.189.117.63:8080/api/presence");
        final presenceResponse = await http.post(
          presenceUri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(result),
        );

        if (presenceResponse.statusCode == 201) {
          setState(() {
            _hasAttendanceToday = true;
          });
          presenceProvider.setVerified(true);
          _showSuccessNotification('Absensi berhasil dilakukan');
          await Future.delayed(Duration(seconds: 1));
          presenceProvider.stopProcessing();
        } else {
          throw Exception('Failed to record attendance: ${presenceResponse.statusCode}');
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          errorData = {
            'status': 'error',
            'message': 'Request failed with status: ${response.statusCode}',
            'error': {
              'code': response.statusCode,
              'details': response.body,
            },
          };
        }
        await VerificationHandler.handleResponse(
          context,
          {
            'status': 'error',
            'message': errorData['message'] ?? 'Request failed',
            'data': {
              'error_code': response.statusCode,
              'error_details': errorData['error'] ?? 'Unknown error',
            },
          },
          photoData,
        );
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        presenceProvider.setError(e.toString());
        await VerificationHandler.handleResponse(
          context,
          {
            'status': 'error',
            'message': e.toString(),
            'data': {
              'error_code': 0,
              'error_details': 'Connection error',
            },
          },
          photoData,
        );
      }
    } finally {
      if (mounted && !presenceProvider.isVerified) {
        presenceProvider.stopProcessing();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[500],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[500]!, Colors.blue[50]!],
            stops: [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome,',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            _userName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(DateTime.now()),
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            _currentTime,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Work Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildLocationOption('WFO', Icons.business, selectedLocation == 'WFO'),
                          ),
                          Expanded(
                            child: _buildLocationOption('WFA', Icons.home, selectedLocation == 'WFA'),
                          ),
                        ],
                      ),
                      if (selectedLocation == 'WFO') ...[
                        SizedBox(height: 16),
                        Text(
                          'Select Office Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildOfficeSelector(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _userLocation == null
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                          ),
                        )
                      : _buildMap(),
                ),
              ),
              if (!_hasAttendanceToday)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _getStatusColor()),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getStatusIcon(), color: _getStatusColor()),
                      SizedBox(width: 8),
                      Text(
                        _getStatusMessage(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              _buildAttendanceButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
      ),
    );
  }

  Widget _buildLocationOption(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLocation = title;
          isLocationSelected = true;
        });
      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (!_isLocationServiceEnabled) return Colors.red;
    if (!isLocationSelected) return Colors.orange;
    if (selectedLocation == 'WFA') return Colors.green;
    return _isUserWithinRadius ? Colors.green : Colors.red;
  }

  IconData _getStatusIcon() {
    if (!_isLocationServiceEnabled) return Icons.location_off;
    if (!isLocationSelected) return Icons.warning;
    if (selectedLocation == 'WFA') return Icons.check_circle;
    return _isUserWithinRadius ? Icons.check_circle : Icons.cancel;
  }

  String _getStatusMessage() {
    if (!_isLocationServiceEnabled) return 'Tolong hidupkan location services';
    if (!isLocationSelected) return 'Pilih work mode';
    if (selectedLocation == 'WFA') return 'WFA Mode';

    if (_distanceToOffice != null) {
    return _isUserWithinRadius
        ? 'Kamu berada dalam radius (${_distanceToOffice!.toStringAsFixed(1)}m)'
        : 'Kamu berada di luar radius (${_distanceToOffice!.toStringAsFixed(1)}m)';
    }

    return _isUserWithinRadius
        ? 'Kamu berada di dalam radius'
        : 'Kamu berada di luar radius';
  }

  bool _canStartRecognition() {
    if (_hasAttendanceToday) return false;
    if (!_isLocationServiceEnabled) return false;
    if (!isLocationSelected) return false;
    if (_userLocation == null) return false;

    if (selectedLocation == 'WFO') {
      return _isUserWithinRadius;
    }
    
    return true;
  }

  Future<void> _sendLocationData(String locationType, double? latitude, double? longitude, {required bool isClockOut}) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not available')),
      );
      return;
    }

    final String officeName = locationType == 'WFO'
        ? _manualLocations[_selectedOfficeIndex]['name']
        : 'Work From Anywhere';

    final locationData = {
      'location_data': {
        'location_type': locationType,
        'office_name': officeName,
        'timestamp': DateTime.now().toIso8601String(),
        'latitude': _userLocation!.latitude.toString(),
        'longitude': _userLocation!.longitude.toString(),
        'is_clock_out': isClockOut,
      },
    };

    try {
      final response = await http.post(
        Uri.parse('http://20.189.117.63:8080/api/getlocation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(locationData),
      );

      if (response.statusCode == 200) {
        await _checkPresenceStatus();
      } else {
        throw Exception('Failed to send location data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  double metersToPixels(double meters, double latitude, double zoom) {
    final earthCircumference = 40075016.686;
    final metersPerPixel = earthCircumference * math.cos(latitude * math.pi/180) / math.pow(2, zoom + 8);
    return meters / metersPerPixel;
  }

  Widget _buildMap() {
    if (_userLocation == null) {
      return Center(child: CircularProgressIndicator());
    }

    final officeLocation = _manualLocations[_selectedOfficeIndex]['location'];
    final bounds = LatLngBounds.fromPoints([
      _userLocation!,
      officeLocation,
    ]);

    if (selectedLocation == 'WFA') {
      return FlutterMap(
        options: MapOptions(
          initialCenter: _userLocation ?? _manualLocations[_selectedOfficeIndex]['location'],
          initialZoom: 20.0,
          minZoom: 20.0,
          maxZoom: 20.0,
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          Stack(
            children: [
              MarkerLayer(
                markers: [
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      child: Icon(Icons.person_pin_circle, color: Colors.blue),
                    ),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.refresh, color: Colors.blue[700]),
                    onPressed: _restartGPS,
                    tooltip: 'Restart GPS',
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: _userLocation ?? _manualLocations[_selectedOfficeIndex]['location'],
        initialZoom: 18.5,
        minZoom: 18.5,
        maxZoom: 18.5,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        Stack(
          children: [
            CircleLayer(
              circles: [
                CircleMarker(
                  point: _manualLocations[_selectedOfficeIndex]['location'],
                  radius: metersToPixels(
                    _radius,
                    _manualLocations[_selectedOfficeIndex]['location'].latitude,
                    18.5 // sesuaikan dengan zoom level peta
                  ),
                  color: Colors.blue.withOpacity(0.3),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _manualLocations[_selectedOfficeIndex]['location'],
                  child: Icon(Icons.location_on, color: Colors.red),
                ),
                if (_userLocation != null)
                  Marker(
                    point: _userLocation!,
                    child: Icon(Icons.person_pin_circle, color: Colors.blue),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue[700]),
                  onPressed: _restartGPS,
                  tooltip: 'Restart GPS',
                ),
              ),
            ),
          ],
        ),
        if (_distanceToOffice != null)
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              'Jarak: ${_distanceToOffice!.toStringAsFixed(1)}m',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isUserWithinRadius ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _logout(BuildContext context) async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildOfficeSelector() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _selectedOfficeIndex,
          items: List.generate(_manualLocations.length, (index) {
            return DropdownMenuItem(
              value: index,
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue[700]),
                  SizedBox(width: 12),
                  Text(
                    _manualLocations[index]['name'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),
          onChanged: (index) {
            if (index != null) {
              setState(() {
                _selectedOfficeIndex = index;
                _checkIfUserWithinRadius();
              });
            }
          },
        ),
      ),
    );
  }
}

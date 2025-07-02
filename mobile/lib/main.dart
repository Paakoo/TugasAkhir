import 'package:flutter/material.dart';
// import 'package:tes/screen/home_screen.dart';
import 'package:mobile_keluar/screen/screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_keluar/screen/PresenceProvider.dart';
void main() {
  runApp(ChangeNotifierProvider(
      create: (_) => presenceProvider,
      child: MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liveness',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => SplashScreen(),
        // "/coba":(context) => LoginSScreen(),
        "/login": (context) => LoginScreen(),
        // "/home": (context) => HomeScreen(),
        "/liveness": (context) => const LivenessScreen(),
        // "/map": (context) => MapScreen(),
        "/cob": (context) => HomeScreen(),
        "/history": (context) => HistoryScreen(),
      },
    );
  }
}

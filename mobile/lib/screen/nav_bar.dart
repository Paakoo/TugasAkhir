import 'package:flutter/material.dart';
import 'package:mobile_keluar/screen/home_screen.dart';
import 'package:mobile_keluar/screen/screen.dart';
import 'PresenceProvider.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;

  const NavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        // Jangan pindah halaman jika sedang dalam proses
        if (presenceProvider.isProcessing && index != currentIndex) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Mohon tunggu sampai proses selesai'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        switch (index) {
          case 0:
            if (currentIndex != 0) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => HomeScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
            break;
          case 1:
            if (currentIndex != 1) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => HistoryScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
            break;
        }
      },
      selectedItemColor: Colors.blue[700],
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
      ],
    );
  }
}
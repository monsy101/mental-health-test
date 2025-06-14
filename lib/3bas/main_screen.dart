import 'package:flutter/material.dart';
import 'package:monsy_weird_package/3bas/home_page.dart';
import 'package:monsy_weird_package/3bas/settings_page.dart';
import 'package:monsy_weird_package/3bas/therapist_contacts_page.dart';
import 'package:monsy_weird_package/pages/contacts_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Track active tab index
  final List<Widget> _screens = [HomePage(), TherapistContactsPage(), ContactsPage(), SettingsPage()]; // Page list

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green, // Highlight selected icon
        unselectedItemColor: Colors.grey, // Darker color for unselected
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // ✅ Show a Snackbar when page changes
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to ${_screens[index].runtimeType}'),
              backgroundColor: Colors.blueAccent,
              duration: Duration(seconds: 2),
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_alt), label: 'Therapy'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'settings'),
        ],
      ),
    );
  }
}
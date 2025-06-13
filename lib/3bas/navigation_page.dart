// int _selectedIndex = 0; // Track active tab index
// final List<Widget> _screens = [HomePage(), TherapyPage(), ChatPage()]; // Define screens
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: _screens[_selectedIndex], // Display active screen
//     bottomNavigationBar: BottomNavigationBar(
//       backgroundColor: Colors.white,
//       selectedItemColor: primaryGreen,
//       unselectedItemColor: secondaryText,
//       currentIndex: _selectedIndex,
//       onTap: (index) {
//         setState(() {
//           _selectedIndex = index; // ✅ Dynamically change active tab
//         });
//       },
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//         BottomNavigationBarItem(icon: Icon(Icons.psychology_alt), label: 'Therapy'),
//         BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
//       ],
//     ),
//   );
// }
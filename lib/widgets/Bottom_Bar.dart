// Yeh widget bottom navigation state ko manage karega
import 'package:e/Messages/messageList.dart';
import 'package:e/screens/buyer/Shops/all_shops.dart';
import 'package:e/screens/buyer/home_screen.dart';
import 'package:e/screens/buyer/wishlist.dart';
import 'package:e/test.dart' hide kTextColorSecondary;
import 'package:e/testk.dart';
import 'package:e/utils/constants.dart';

import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  // Selected tab index
  int _selectedIndex = 0;

  // Pages ki list (Aap yahan apne asli screens daal sakte hain)
  final List<Widget> _pages = <Widget>[
    HomeScreen(),
    AllShopsScreen(),
    // OrdersDemoScreen
    //(),
    ChatListScreen(),
    // WishlistScreen(),
    AdminImageUploadScreen()
  ];

  // Tab change hone par yeh function call hoga
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Jo bhi page select hoga, woh yahan dikhega
      body: Center(child: _pages.elementAt(_selectedIndex)),
      // Bottom Navigation Bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            // Thoda sa shadow dene ke liye

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              topLeft: Radius.circular(25), // 👈 Rounded corners
              topRight: Radius.circular(25),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,

              onTap: _onItemTapped,

              backgroundColor: kTextColorSecondary,

              type:
                  BottomNavigationBarType.fixed, // Saare items hamesha dikhenge
              selectedItemColor: Colors.white, // Selected item ka color
              unselectedItemColor: Colors.white60, // Unselected item ka color
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 11),

              items: const <BottomNavigationBarItem>[
                // 1. Home
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                // 2. Categories
                BottomNavigationBarItem(
                  icon: Icon(Icons.storefront),
                  label: 'Shops',
                ),
                // 3. Cart

                // 4. Messages (Aapki request ke mutabik)
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'Messages',
                ),
                // 5. Profile
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Favorite',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

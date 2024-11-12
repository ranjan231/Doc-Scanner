

import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
              image:
                  Image.asset('assets/images/home.png', width: 35, height: 30),
              0),
          _buildNavItem(
              image: Image.asset('assets/images/docs.png',
                  width: 35, height: 30),
              1),
          SizedBox(width: 30),
          
          _buildNavItem(
              image: Image.asset('assets/images/tools.png',
                  width: 35, height: 30),
              3),
          _buildNavItem(
              image:
                  Image.asset('assets/images/user.png', width: 35, height: 30),
              4),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, {required Image image}) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          image,
        ],
      ),
    );
  }
}

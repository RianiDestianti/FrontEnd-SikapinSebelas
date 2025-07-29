import 'package:flutter/material.dart';

class KaprogNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const KaprogNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<KaprogNavigation> createState() => _KaprogNavigationState();
}

class _KaprogNavigationState extends State<KaprogNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups,
            label: 'Siswa',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = widget.currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: Container(
          height: 70,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 0,
                left: isActive ? 20 : 35,
                right: isActive ? 20 : 35,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: isActive ? 3 : 0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Content
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Icon(
                          isActive ? activeIcon : icon,
                          color: isActive ? Colors.blue : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: isActive ? Colors.blue : Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        ),
                        child: Text(label),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
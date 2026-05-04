import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// Bottom navigation bar con indicatore a scorrimento orizzontale.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcoliamo la larghezza esatta di ciascun elemento dividendo lo spazio per 4
            final double itemWidth = constraints.maxWidth / 4;
            
            return Stack(
              children: [
                // 1. Lo sfondo verde che scivola a destra e sinistra
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: currentIndex * itemWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: itemWidth,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                
                // 2. Le icone e il testo sopra lo sfondo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_filled, 'HOME', itemWidth),
                    _buildNavItem(1, Icons.account_balance_wallet, 'FINANZE', itemWidth),
                    _buildNavItem(2, Icons.calendar_month, 'ORGANIZZA', itemWidth),
                    _buildNavItem(3, Icons.people, 'COINQUILINI', itemWidth),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, double width) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (currentIndex != index) {
          onTap(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 56, // Altezza fissa per mantenere stabilità
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

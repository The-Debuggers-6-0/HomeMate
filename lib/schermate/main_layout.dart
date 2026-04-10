import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'finanze_screen.dart';
import 'profile_page.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pages = [
      const HomeScreen(),
      const FinanzeScreen(),
      // Mettiamo un segnaposto per la pagina organizzazione che non esiste ancora
      const Scaffold(body: Center(child: Text("Organizzazione", style: TextStyle(fontSize: 24)))),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // TRANSIZIONE MORBIDA TRA LE SCHERMATE MAIN
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: ColoredBox(
                key: ValueKey<int>(_currentIndex), // Forza l'animazione di switcher
                color: AppColors.background,
                child: _pages[_currentIndex],
              ),
            ),
          ),
          
          // NUOVA BOTTOM NAVIGATION BAR ANIMATA FLOTTANTE
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuint,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_filled, 'HOME'),
                  _buildNavItem(1, Icons.account_balance_wallet, 'FINANZE'),
                  _buildNavItem(2, Icons.calendar_month, 'ORGANIZZA'),
                  _buildNavItem(3, Icons.person, 'PROFILO'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        // Allarga il padding se selezionato, lo riduce se non selezionato
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.0 : 6.0,
          vertical: isSelected ? 10.0 : 4.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        // Adatta dinamicamente le dimensioni al contenuto che sfuma
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isSelected
                ? Row(
                    key: const ValueKey("selected"),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                : Column(
                    key: const ValueKey("unselected"),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: AppColors.textSecondary, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

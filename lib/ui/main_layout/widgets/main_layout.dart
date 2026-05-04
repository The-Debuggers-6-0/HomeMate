import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/custom_bottom_nav_bar.dart';
import '../../home/widgets/home_screen.dart';
import '../../finanze/widgets/finanze_screen.dart';
import '../../coinquilini/widgets/coinquilini_screen.dart';

/// Layout principale con bottom navigation bar animata.
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
      // Segnaposto per la pagina organizzazione
      const Scaffold(
          body: Center(
              child:
                  Text("Organizzazione", style: TextStyle(fontSize: 24)))),
      const CoinquiliniScreen(),
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
                key: ValueKey<int>(_currentIndex),
                color: AppColors.background,
                child: _pages[_currentIndex],
              ),
            ),
          ),

          // BOTTOM NAVIGATION BAR CONDIVISA DA CORE/UI
          CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}

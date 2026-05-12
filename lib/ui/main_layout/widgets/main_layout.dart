import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/custom_bottom_nav_bar.dart';
import '../../home/widgets/home_screen.dart';
import '../../finanze/widgets/finanze_screen.dart';
import '../../coinquilini/widgets/coinquilini_screen.dart';
import '../../organizza/widgets/organizza_screen.dart';

/// Notifier per comunicare il cambio di tab
class TabChangeNotifier extends ChangeNotifier {
  int _currentTab = 0;
  
  int get currentTab => _currentTab;
  
  void selectTab(int index) {
    _currentTab = index;
    notifyListeners();
  }
}

/// Layout principale con bottom navigation bar animata.
class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  late final TabChangeNotifier _tabNotifier;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabNotifier = TabChangeNotifier();
    // Se il notifier viene chiamato dalle pagine, aggiorniamo anche _currentIndex
    _tabNotifier.addListener(_onTabSelectedFromNotifier);
    _pages = [
      HomeScreen(tabNotifier: _tabNotifier, tabIndex: 0),
      FinanzeScreen(tabNotifier: _tabNotifier, tabIndex: 1),
      OrganizzaScreen(tabNotifier: _tabNotifier, tabIndex: 2),
      CoinquiliniScreen(tabNotifier: _tabNotifier, tabIndex: 3),
    ];
  }

  void _onTabSelectedFromNotifier() {
    final idx = _tabNotifier.currentTab;
    if (mounted && idx != _currentIndex) {
      setState(() {
        _currentIndex = idx;
      });
    }
  }

  @override
  void dispose() {
    _tabNotifier.removeListener(_onTabSelectedFromNotifier);
    _tabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Manteniamo vive le pagine per evitare dispose/rebuild aggressivi con i Provider.
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.background,
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ),

          // BOTTOM NAVIGATION BAR CONDIVISA DA CORE/UI
          CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _tabNotifier.selectTab(index);
              });
            },
          ),
        ],
      ),
    );
  }
}

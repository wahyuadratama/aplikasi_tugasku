import 'package:flutter/material.dart';

import '../main.dart';
import '../screens/completed_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/app_router.dart';
import 'add_task_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    CompletedScreen(),
    SettingsScreen(),
  ];

  Future<void> _openEditor() async {
    await Navigator.push(
      context,
      slideRoute(const AddTaskScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['TugasKu', 'Tugas Selesai', 'Pengaturan'];
    final appBar = _currentIndex == 0
        ? AppBar(
            title: const Text('TugasKu', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              _ThemeToggleButton(),
              IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Urutkan',
                onPressed: () {
                  final homeState = context.findAncestorStateOfType<_HomeTabState>();
                  homeState?._showSortMenu();
                },
              ),
            ],
          )
        : AppBar(
            title: Text(titles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
          );

    return Scaffold(
      appBar: appBar,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        onPressed: _openEditor,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Beranda',
                  selected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.check_circle_outline,
                  activeIcon: Icons.check_circle,
                  label: 'Selesai',
                  selected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Pengaturan',
                  selected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  void _showSortMenu() {
    (_homeKey.currentState as dynamic)?._showSortMenu();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(key: _homeKey, showAppBar: false);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: selected ? FontWeight.w600 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = TugasKuApp.of(context);
    if (app == null) {
      return const IconButton(onPressed: null, icon: Icon(Icons.light_mode));
    }
    final mode = app.themeMode;
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return PopupMenuButton<ThemeMode>(
      icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
      tooltip: 'Tema',
      onSelected: app.setThemeMode,
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(Icons.light_mode),
              SizedBox(width: 8),
              Text('Terang'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(Icons.dark_mode),
              SizedBox(width: 8),
              Text('Gelap'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(Icons.brightness_auto),
              SizedBox(width: 8),
              Text('Ikut sistem'),
            ],
          ),
        ),
      ],
    );
  }
}

// Layar Beranda: daftar tugas aktif + filter kategori + tombol tambah (FAB).
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/task_storage.dart';
import '../utils/app_router.dart';
import '../widgets/empty_state.dart';
import '../widgets/staggered_item.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'completed_screen.dart';
import 'settings_screen.dart';

const String _allCategoriesKey = '__all__';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;
  const HomeScreen({super.key, this.showAppBar = true});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  String _filter = _allCategoriesKey;
  TaskSort _sort = TaskSort.manual;
  String _searchQuery = '';
  bool _isSearching = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      TaskStorage.loadTasks(),
      TaskStorage.loadSort(),
    ]);
    if (!mounted) return;
    setState(() {
      _tasks = results[0] as List<Task>;
      _sort = results[1] as TaskSort;
      _normalizeFilter();
    });
  }

  Future<void> _save() => TaskStorage.saveTasks(_tasks);

  List<Task> get _active => _tasks.where((t) => !t.isDone).toList();

  List<Task> get _visible {
    var filtered = _filter == _allCategoriesKey
        ? _active
        : _active.where((t) => t.categoryKey == _filter).toList();
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((t) =>
              t.title.toLowerCase().contains(query) ||
              t.description.toLowerCase().contains(query))
          .toList();
    }
    
    return sortTasks(filtered, _sort);
  }

  /// Chip filter kategori. Kategori dibandingkan case-insensitive supaya
  /// "Kuliah" dan "kuliah" tidak jadi dua chip berbeda.
  List<({String key, String label})> get _categories {
    final map = <String, String>{};
    for (final t in _active) {
      map.putIfAbsent(t.categoryKey, () => t.category);
    }
    return [
      (key: _allCategoriesKey, label: 'Semua'),
      ...map.entries.map((e) => (key: e.key, label: e.value)),
    ];
  }

  /// Kalau kategori yang difilter sudah tidak ada (mis. tugasnya dihapus),
  /// kembalikan filter ke "Semua" supaya layar tidak terlihat kosong melompong.
  void _normalizeFilter() {
    if (_filter == _allCategoriesKey) return;
    final stillExists = _active.any((t) => t.categoryKey == _filter);
    if (!stillExists) _filter = _allCategoriesKey;
  }

  void _toggle(Task task, bool? value) {
    setState(() {
      final i = _tasks.indexWhere((t) => t.id == task.id);
      if (i >= 0) _tasks[i] = task.copyWith(isDone: value ?? false);
      _normalizeFilter();
    });
    // Batalkan reminder kalau tugas diselesaikan
    if (value == true) NotificationService.cancelReminder(task.id);
    _save();
  }

  void _delete(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
      _normalizeFilter();
    });
    NotificationService.cancelReminder(task.id);
    _save();
    
    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tugas dihapus'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () {
            setState(() {
              _tasks.add(task);
              _normalizeFilter();
            });
            _save();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Buka layar tambah/edit; kalau kembali dengan hasil, simpan.
  Future<void> _openEditor([Task? task]) async {
    final result = await Navigator.push<Task?>(
      context,
      slideRoute(AddTaskScreen(task: task)),
    );
    if (result == null || !mounted) return;
    setState(() {
      final i = _tasks.indexWhere((t) => t.id == result.id);
      if (i >= 0) {
        _tasks[i] = result; // edit
      } else {
        _tasks.add(result); // tambah baru
      }
      _normalizeFilter();
    });
    _save();
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Urutkan Tugas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ...TaskSort.values.map((s) {
              final selected = s == _sort;
              return ListTile(
                title: Text(s.label),
                trailing: selected
                    ? const Icon(Icons.check, color: Color(0xFF6C63FF))
                    : null,
                onTap: () {
                  setState(() => _sort = s);
                  TaskStorage.saveSort(s);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_active.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _ProgressCard(
              total: _active.length,
              done: _tasks.where((t) => t.isDone).length,
            ),
          ),
        if (widget.showAppBar)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Daftar tugasmu',
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (ctx, i) {
              final c = _categories[i];
              final selected = c.key == _filter;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(c.label),
                  selected: selected,
                  selectedColor: const Color(0xFF6C63FF),
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  onSelected: (_) =>
                      setState(() => _filter = c.key),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _visible.isEmpty
              ? EmptyState(
                  type: _active.isEmpty
                      ? EmptyStateType.noTasks
                      : EmptyStateType.noFiltered,
                )
              : ListView.builder(
                  itemCount: _visible.length,
                  itemBuilder: (ctx, i) {
                    final t = _visible[i];
                    return StaggeredItem(
                      index: i,
                      child: TaskCard(
                        task: t,
                        onToggle: (v) => _toggle(t, v),
                        onTap: () => _openEditor(t),
                        onDelete: (task) => _delete(task),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    if (!widget.showAppBar) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari tugas...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari tugas...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('TugasKu',
                style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              }),
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Cari',
              onPressed: () => setState(() => _isSearching = true),
            ),
          _ThemeToggleButton(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu',
            onSelected: (value) async {
              if (value == 'sort') {
                _showSortMenu();
              } else if (value == 'completed') {
                await Navigator.push(
                  context,
                  slideRoute(const CompletedScreen()),
                );
                if (!mounted) return;
                _load();
              } else if (value == 'settings') {
                await Navigator.push(
                  context,
                  slideRoute(const SettingsScreen()),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort),
                    SizedBox(width: 8),
                    Text('Urutkan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 8),
                    Text('Tugas Selesai'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Pengaturan'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: body,
      floatingActionButton: widget.showAppBar
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Tugas'),
            )
          : null,
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int total;
  final int done;

  const _ProgressCard({required this.total, required this.done});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final percent = (progress * 100).round();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$done dari $total tugas selesai',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE0E0E0),
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                );
              },
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
      return const Icon(Icons.light_mode); // fallback untuk test
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

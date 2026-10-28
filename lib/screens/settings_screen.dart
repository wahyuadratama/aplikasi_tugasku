import 'package:flutter/material.dart';

import '../main.dart';
import '../services/backup_service.dart';
import '../services/task_storage.dart';

class SettingsScreen extends StatefulWidget {
  final bool showAppBar;
  const SettingsScreen({super.key, this.showAppBar = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await TaskStorage.getPreferences();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await TaskStorage.getPreferences();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      children: [
        // Notifikasi Section
        _buildSectionHeader('Notifikasi'),
        _buildSwitchTile(
          title: 'Aktifkan Notifikasi',
          subtitle: 'Terima notifikasi dari aplikasi',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _savePreference('notifications_enabled', value);
          },
        ),
        _buildSwitchTile(
          title: 'Reminder Deadline',
          subtitle: 'Ingatkan H-1 dan hari-H pukul 08:00',
          value: _remindersEnabled,
          enabled: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _remindersEnabled = value);
            _savePreference('reminders_enabled', value);
          },
        ),
        const Divider(),

        // Tema Section
        _buildSectionHeader('Tampilan'),
        _buildThemeSelector(),
        const Divider(),

        // Data Section
        _buildSectionHeader('Data'),
        _buildDataManagement(),
        const Divider(),

        // Tentang Section
        _buildSectionHeader('Tentang'),
        _buildAboutTile(),
      ],
    );
    if (!widget.showAppBar) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: body,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6C63FF),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeThumbColor: const Color(0xFF6C63FF),
    );
  }

  Widget _buildThemeSelector() {
    final app = TugasKuApp.of(context);
    if (app == null) return const SizedBox.shrink();

    final mode = app.themeMode;
    return Column(
      children: [
        _buildThemeOption(
          icon: Icons.light_mode,
          label: 'Terang',
          value: ThemeMode.light,
          selected: mode == ThemeMode.light,
          onTap: () => app.setThemeMode(ThemeMode.light),
        ),
        _buildThemeOption(
          icon: Icons.dark_mode,
          label: 'Gelap',
          value: ThemeMode.dark,
          selected: mode == ThemeMode.dark,
          onTap: () => app.setThemeMode(ThemeMode.dark),
        ),
        _buildThemeOption(
          icon: Icons.brightness_auto,
          label: 'Ikut Sistem',
          value: ThemeMode.system,
          selected: mode == ThemeMode.system,
          onTap: () => app.setThemeMode(ThemeMode.system),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required ThemeMode value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: selected ? const Color(0xFF6C63FF) : null),
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check, color: Color(0xFF6C63FF))
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDataManagement() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Backup Data'),
          subtitle: const Text('Export semua tugas ke file'),
          onTap: () => _showBackupDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Restore Data'),
          subtitle: const Text('Import tugas dari backup'),
          onTap: () => _showRestoreDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('Hapus Semua Data',
              style: TextStyle(color: Colors.red)),
          subtitle: const Text('Hapus semua tugas (tidak bisa dibatalkan)'),
          onTap: () => _showDeleteAllDialog(),
        ),
      ],
    );
  }

  Widget _buildAboutTile() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Versi'),
          subtitle: const Text('TugasKu v1.1.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Lisensi'),
          subtitle: const Text('MIT License'),
        ),
      ],
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('Ekspor semua tugas ke file JSON?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final path = await BackupService.exportTasks();
              if (!mounted) return;
              if (path != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Backup tersimpan: $path')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal membuat backup')),
                );
              }
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
            'Fitur restore akan segera tersedia dengan file picker yang lebih baik.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text(
            'Ini akan menghapus semua tugas Anda. Tindakan ini tidak bisa dibatalkan!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await TaskStorage.saveTasks([]);
              if (!mounted) return;
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua data telah dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

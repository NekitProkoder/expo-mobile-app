import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'admin_exhibitor_form_screen.dart';

class AdminExhibitorsScreen extends StatefulWidget {
  const AdminExhibitorsScreen({super.key});

  @override
  State<AdminExhibitorsScreen> createState() => _AdminExhibitorsScreenState();
}

class _AdminExhibitorsScreenState extends State<AdminExhibitorsScreen> {
  List exhibitors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExhibitors();
  }

  Future<void> loadExhibitors() async {
    try {
      final data = await ApiService.getExhibitors();

      if (!mounted) return;

      setState(() {
        exhibitors = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  Future<void> deleteItem(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить участника?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteExhibitor(id);
      await loadExhibitors();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления: $e')),
      );
    }
  }

  Future<void> openAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminExhibitorFormScreen(),
      ),
    );

    await loadExhibitors();
  }

  Future<void> openEditScreen(Map item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminExhibitorFormScreen(
          exhibitor: item,
        ),
      ),
    );

    await loadExhibitors();
  }

  Widget card(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => openEditScreen(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.store, size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('Категория: ${item['category'] ?? '-'}'),
                      Text('Стенд: ${item['stand_number'] ?? '-'}'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => openEditScreen(item),
                  icon: const Icon(Icons.edit, color: Colors.black54),
                ),
                IconButton(
                  onPressed: () => deleteItem(item['id']),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Управление участниками'),
        backgroundColor: const Color(0xFFFACA2C),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFACA2C),
        onPressed: openAddScreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadExhibitors,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: exhibitors.map((e) => card(e)).toList(),
              ),
            ),
    );
  }
}
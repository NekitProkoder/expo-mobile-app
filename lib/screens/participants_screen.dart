import 'dart:convert';
import '../config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exhibitor.dart';
import 'participant_detail_screen.dart';

class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  List<Exhibitor> exhibitors = [];
  List<Exhibitor> filteredExhibitors = [];

  Set<int> favoriteIds = {};

  bool isLoading = true;
  bool showOnlyFavorites = false;
  bool isFromCache = false;

  String searchText = '';
  String selectedCategory = 'Все';

  final String apiUrl =
    '${ApiConfig.baseUrl}/api/exhibitors';
  final String cacheKey = 'cached_exhibitors';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await loadFavorites();
    await loadExhibitors();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorite_exhibitors') ?? [];

    favoriteIds =
        saved.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'favorite_exhibitors',
      favoriteIds.map((e) => e.toString()).toList(),
    );
  }

  Future<void> saveExhibitorsCache(String rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, rawJson);
  }

  Future<bool> loadExhibitorsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(cacheKey);

    if (cachedJson == null || cachedJson.isEmpty) {
      return false;
    }

    try {
      final List data = jsonDecode(cachedJson);

      if (!mounted) return false;

      setState(() {
        exhibitors = data.map((e) => Exhibitor.fromJson(e)).toList();
        filteredExhibitors = exhibitors;
        isLoading = false;
        isFromCache = true;
      });

      applyFilters();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleFavorite(int id) async {
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    });

    await saveFavorites();
    applyFilters();
  }

  Future<void> loadExhibitors() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      await saveExhibitorsCache(response.body);

      final List data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        exhibitors = data.map((e) => Exhibitor.fromJson(e)).toList();
        filteredExhibitors = exhibitors;
        isLoading = false;
        isFromCache = false;
      });

      applyFilters();
    } catch (e) {
      final hasCache = await loadExhibitorsFromCache();

      if (!mounted) return;

      if (!hasCache) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки участников: $e')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Нет соединения. Показан сохранённый список.'),
          ),
        );
      }
    }
  }

  List<String> getCategories() {
    final categories = exhibitors
        .map((e) => e.category ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    categories.sort();

    return ['Все', ...categories];
  }

  void applyFilters() {
    List<Exhibitor> result = exhibitors;

    if (showOnlyFavorites) {
      result = result.where((e) => favoriteIds.contains(e.id)).toList();
    }

    if (selectedCategory != 'Все') {
      result = result.where((e) => e.category == selectedCategory).toList();
    }

    if (searchText.trim().isNotEmpty) {
      final query = searchText.toLowerCase();

      result = result.where((e) {
        return e.name.toLowerCase().contains(query) ||
            (e.category ?? '').toLowerCase().contains(query) ||
            (e.standNumber ?? '').toLowerCase().contains(query) ||
            (e.description ?? '').toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      filteredExhibitors = result;
    });
  }

  Widget logoBox(Exhibitor exhibitor) {
    final logoUrl = exhibitor.logoUrl;

    if (logoUrl == null || logoUrl.isEmpty) {
      return const Icon(Icons.store, size: 30);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.store, size: 30);
        },
      ),
    );
  }

  Widget cacheNotice() {
    if (!isFromCache) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Показан сохранённый список участников',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget exhibitorCard(Exhibitor exhibitor) {
    final isFavorite = favoriteIds.contains(exhibitor.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ParticipantDetailScreen(
                  exhibitor: exhibitor,
                  isFavorite: isFavorite,
                  onFavoriteChanged: () => toggleFavorite(exhibitor.id),
                ),
              ),
            );

            await loadFavorites();
            applyFilters();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: logoBox(exhibitor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exhibitor.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if ((exhibitor.category ?? '').isNotEmpty)
                        Text(
                          exhibitor.category!,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        'Стенд: ${exhibitor.standNumber ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => toggleFavorite(exhibitor.id),
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? const Color(0xFFFACA2C) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBlock() {
    final categories = getCategories();

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Поиск компании, категории или стенда',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            searchText = value;
            applyFilters();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilterChip(
              label: const Text('Избранные'),
              selected: showOnlyFavorites,
              selectedColor: const Color(0xFFFACA2C),
              backgroundColor: Colors.white,
              avatar: Icon(
                showOnlyFavorites ? Icons.star : Icons.star_border,
                size: 18,
              ),
              onSelected: (value) {
                setState(() {
                  showOnlyFavorites = value;
                });
                applyFilters();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = category == selectedCategory;

              return ChoiceChip(
                label: Text(category),
                selected: selected,
                selectedColor: const Color(0xFFFACA2C),
                backgroundColor: Colors.white,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = category;
                  });
                  applyFilters();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget emptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 180),
      child: Center(
        child: Text('Участники не найдены'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Участники'),
        backgroundColor: const Color(0xFFFACA2C),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFACA2C),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadExhibitors,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  cacheNotice(),
                  searchBlock(),
                  const SizedBox(height: 16),
                  Text(
                    'Найдено: ${filteredExhibitors.length}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filteredExhibitors.isEmpty)
                    emptyState()
                  else
                    ...filteredExhibitors.map((e) => exhibitorCard(e)),
                ],
              ),
            ),
    );
  }
}
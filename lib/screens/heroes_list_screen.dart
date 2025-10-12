// lib/screens/heroes_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/hero_models.dart';
import '../providers/hero_provider.dart';
import 'hero_detail_screen.dart';

class HeroesListScreen extends StatefulWidget {
  const HeroesListScreen({super.key});

  @override
  State<HeroesListScreen> createState() => _HeroesListScreenState();
}

class _HeroesListScreenState extends State<HeroesListScreen> {
  static const _pageSize = 20;
  final PagingController<int, SuperHero> _pagingController = 
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final provider = context.read<HeroProvider>();
      final newHeroes = await provider.getHeroesPaginated(pageKey, _pageSize);
      
      final isLastPage = newHeroes.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newHeroes);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newHeroes, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Heróis'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: PagedListView<int, SuperHero>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<SuperHero>(
          itemBuilder: (context, hero, index) => _buildHeroCard(hero),
          firstPageErrorIndicatorBuilder: (context) => _buildErrorWidget(),
          newPageErrorIndicatorBuilder: (context) => _buildErrorWidget(),
          firstPageProgressIndicatorBuilder: (context) => 
              const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (context) => 
              const Center(child: CircularProgressIndicator()),
          noItemsFoundIndicatorBuilder: (context) => 
              const Center(child: Text('Nenhum herói encontrado')),
        ),
      ),
    );
  }

  Widget _buildHeroCard(SuperHero hero) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: hero.images.sm,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            httpHeaders: const {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
            placeholder: (context, url) => Container(
              width: 50,
              height: 50,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              print('[IMAGE ERROR] URL: $url');
              print('[IMAGE ERROR] Error: $error');
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: Icon(
                  Icons.person, 
                  color: Colors.grey[600],
                  size: 30,
                ),
              );
            },
            fadeInDuration: const Duration(milliseconds: 300),
            maxWidthDiskCache: 200,
            maxHeightDiskCache: 200,
          ),
        ),
        title: Text(
          hero.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hero.biography.fullName.isNotEmpty 
                ? hero.biography.fullName 
                : 'Nome completo não disponível'),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatChip('INT', hero.powerStats.intelligence, Colors.blue),
                const SizedBox(width: 4),
                _buildStatChip('STR', hero.powerStats.strength, Colors.red),
                const SizedBox(width: 4),
                _buildStatChip('SPD', hero.powerStats.speed, Colors.green),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _navigateToDetail(hero),
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Erro ao carregar heróis'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _pagingController.refresh(),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(SuperHero hero) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HeroDetailScreen(hero: hero),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/hero_domain.dart';
import '../repository/hero_repository.dart';
import '../repository/database_repository.dart';

class HeroProvider extends ChangeNotifier {
  final HeroService _heroService = HeroService();
  final DatabaseService _databaseService = DatabaseService.instance;

  List<SuperHero> _allHeroes = [];
  List<SuperHero> _myCards = [];
  bool _isLoading = false;
  String? _error;
  SuperHero? _dailyCard;
  String? _lastDailyCardDate;
  bool _isOffline = false;

  List<SuperHero> get allHeroes => _allHeroes;
  List<SuperHero> get myCards => _myCards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SuperHero? get dailyCard => _dailyCard;
  bool get canGetDailyCard => _lastDailyCardDate != _getTodayString();
  bool get isOffline => _isOffline;

  static const int maxCards = 15;

  // com cache + offline
  Future<void> loadAllHeroes() async {
    _setLoading(true);
    try {
      // primeiro, tenta carregar da API
      try {
        print('[CACHE] Tentando carregar da API...');
        _allHeroes = await _heroService.getAllHeroes();

        // Sucesso da API - salva no cache
        await _databaseService.clearCache();
        await _databaseService.cacheHeroes(_allHeroes);
        _isOffline = false;
        print(
            '[CACHE] ✅ Carregado da API e salvo no cache: ${_allHeroes.length} heróis');
      } catch (apiError) {
        print('[CACHE] ❌ Erro na API: $apiError');

        // Falha da API - tenta carregar do cache
        final hasCache = await _databaseService.hasCache();
        if (hasCache) {
          print('[CACHE] 💾 Carregando do cache local...');
          _allHeroes = await _databaseService.getCachedHeroes();
          _isOffline = true;
          print('[CACHE] ✅ Carregado do cache: ${_allHeroes.length} heróis');
        } else {
          throw Exception('Sem conexão e sem cache disponível');
        }
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      _allHeroes = [];
      print('[CACHE] ❌ Erro final: $e');
    } finally {
      _setLoading(false);
    }
  }

  // com cache + offline
  Future<List<SuperHero>> getHeroesPaginated(int page, int limit) async {
    try {
      print('[CACHE] 📄 Solicitando página $page (limite: $limit)');

      // Primeiro, tenta carregar da API com _start/_limit
      try {
        final apiHeroes =
            await _heroService.getHeroesPaginated(page: page, limit: limit);

        // API funcionando - salva no cache
        await _databaseService.cacheHeroes(apiHeroes);
        _isOffline = false;
        print(
            '[CACHE] ✅ Página $page carregada da API: ${apiHeroes.length} heróis');

        return apiHeroes;
      } catch (apiError) {
        print('[CACHE] ❌ Erro na API: $apiError');

        // Falha da API - carrega do cache
        final offset = (page - 1) * limit;
        final cachedHeroes = await _databaseService.getCachedHeroes(
          limit: limit,
          offset: offset,
        );

        _isOffline = true;
        print(
            '[CACHE] 💾 Página $page carregada do cache: ${cachedHeroes.length} heróis');

        return cachedHeroes;
      }
    } catch (e) {
      print('[CACHE] ❌ Erro geral: $e');
      throw Exception('Erro ao carregar heróis paginados: $e');
    }
  }

  Future<void> getDailyCard() async {
    if (!canGetDailyCard) {
      throw Exception('Você já pegou sua carta diária hoje!');
    }

    _setLoading(true);
    try {
      if (_allHeroes.isEmpty) {
        await loadAllHeroes();
      }

      if (_allHeroes.isEmpty) {
        throw Exception('Nenhum herói disponível');
      }

      final randomIndex = DateTime.now().millisecond % _allHeroes.length;
      _dailyCard = _allHeroes[randomIndex];
      _lastDailyCardDate = _getTodayString();
      await _saveDailyCardDate();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _dailyCard = null;
    } finally {
      _setLoading(false);
    }
  }

  void clearDailyCard() {
    _dailyCard = null;
    notifyListeners();
  }

  Future<SuperHero?> getHeroById(int id) async {
    try {
      // primeiro, tenta carregar da API
      try {
        final apiHero = await _heroService.getHeroById(id);
        _isOffline = false;
        return apiHero;
      } catch (apiError) {
        print('[CACHE] ❌ Erro na API para herói $id: $apiError');

        // falha da API - tenta carregar do cache
        final cachedHero = await _databaseService.getCachedHeroById(id);
        _isOffline = true;

        return cachedHero;
      }
    } catch (e) {
      print('[CACHE] ❌ Erro ao buscar herói $id: $e');
      return null;
    }
  }

  Future<void> addToMyCards(SuperHero hero) async {
    if (_myCards.length >= maxCards) {
      throw Exception('Você já tem o máximo de $maxCards cartas!');
    }

    if (_myCards.any((card) => card.id == hero.id)) {
      throw Exception('Você já possui esta carta!');
    }

    _myCards.add(hero);
    await _saveMyCards();
    notifyListeners();
  }

  Future<void> removeFromMyCards(SuperHero hero) async {
    _myCards.removeWhere((card) => card.id == hero.id);
    await _saveMyCards();
    notifyListeners();
  }

  bool hasCard(SuperHero hero) {
    return _myCards.any((card) => card.id == hero.id);
  }

  Future<void> loadLocalData() async {
    await _loadMyCards();
    await _loadDailyCardDate();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveMyCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardIds = _myCards.map((card) => card.id.toString()).toList();
    await prefs.setStringList('my_cards', cardIds);
  }

  Future<void> _loadMyCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardIds = prefs.getStringList('my_cards') ?? [];

    _myCards.clear();
    for (final idString in cardIds) {
      final id = int.tryParse(idString);
      if (id != null) {
        try {
          final hero = await getHeroById(id); // Agora usa cache também
          if (hero != null) {
            _myCards.add(hero);
          }
        } catch (e) {
          debugPrint('Erro ao carregar carta $id: $e');
        }
      }
    }
  }

  Future<void> _saveDailyCardDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_daily_card_date', _lastDailyCardDate ?? '');
  }

  Future<void> _loadDailyCardDate() async {
    final prefs = await SharedPreferences.getInstance();
    _lastDailyCardDate = prefs.getString('last_daily_card_date');
  }
}

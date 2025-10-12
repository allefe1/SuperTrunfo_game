import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hero_models.dart';
import '../services/hero_service.dart';

class HeroProvider extends ChangeNotifier {
  final HeroService _heroService = HeroService();
  
  List<SuperHero> _allHeroes = [];
  List<SuperHero> _myCards = [];
  bool _isLoading = false;
  String? _error;
  SuperHero? _dailyCard;
  String? _lastDailyCardDate;

  List<SuperHero> get allHeroes => _allHeroes;
  List<SuperHero> get myCards => _myCards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SuperHero? get dailyCard => _dailyCard;
  bool get canGetDailyCard => _lastDailyCardDate != _getTodayString();

  static const int maxCards = 15;

  Future<void> loadAllHeroes() async {
    _setLoading(true);
    try {
      _allHeroes = await _heroService.getAllHeroes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _allHeroes = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<SuperHero>> getHeroesPaginated(int page, int limit) async {
    try {
      return await _heroService.getHeroesPaginated(page: page, limit: limit);
    } catch (e) {
      throw Exception('Erro ao carregar heróis paginados: $e');
    }
  }

  Future<void> getDailyCard() async {
    if (!canGetDailyCard) {
      throw Exception('Você já pegou sua carta diária hoje!');
    }

    _setLoading(true);
    try {
      _dailyCard = await _heroService.getRandomHero();
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
          final hero = await _heroService.getHeroById(id);
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

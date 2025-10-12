import '../database/app_database.dart';
import '../database/entities/hero_entity.dart';
import '../models/hero_models.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<AppDatabase> get database async {
    _database ??= await AppDatabase.getInstance();
    return _database!;
  }

  
  Future<void> cacheHeroes(List<SuperHero> heroes) async {
  final db = await database;
  
  
  for (final hero in heroes) {
    final entity = HeroEntity.fromSuperHero(hero);
    try {
      await db.heroDao.insertHero(entity);
    } catch (e) {
      // Se der erro de duplicata, atualiza
      await db.heroDao.updateHero(entity);
    }
  }
  
  print('[DATABASE] 💾 Cached ${heroes.length} heroes');
}

  // buscar heróis do cache
  Future<List<SuperHero>> getCachedHeroes({int? limit, int? offset}) async {
    final db = await database;
    List<HeroEntity> entities;
    
    if (limit != null && offset != null) {
      entities = await db.heroDao.getHeroesPaginated(limit, offset);
    } else {
      entities = await db.heroDao.getAllHeroes();
    }
    
    return entities.map((entity) => entity.toSuperHero()).toList();
  }

  
  Future<SuperHero?> getCachedHeroById(int id) async {
    final db = await database;
    final entity = await db.heroDao.getHeroById(id);
    return entity?.toSuperHero();
  }

  // verificar se tem cache
  Future<bool> hasCache() async {
    final db = await database;
    final count = await db.heroDao.getHeroesCount();
    return (count ?? 0) > 0;
  }

  // limpar cache antigo
  Future<void> clearCache() async {
    final db = await database;
    await db.heroDao.deleteAllHeroes();
  }
}

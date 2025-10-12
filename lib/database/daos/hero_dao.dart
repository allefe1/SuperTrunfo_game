import 'package:floor/floor.dart';
import '../entities/hero_entity.dart';

@dao
abstract class HeroDao {
  @Query('SELECT * FROM heroes')
  Future<List<HeroEntity>> getAllHeroes();

  @Query('SELECT * FROM heroes WHERE id = :id')
  Future<HeroEntity?> getHeroById(int id);

  @Query('SELECT * FROM heroes LIMIT :limit OFFSET :offset')
  Future<List<HeroEntity>> getHeroesPaginated(int limit, int offset);

  @Query('SELECT COUNT(*) FROM heroes')
  Future<int?> getHeroesCount();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertHero(HeroEntity hero);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertHeroes(List<HeroEntity> heroes);

  @update
  Future<void> updateHero(HeroEntity hero);

  @delete
  Future<void> deleteHero(HeroEntity hero);

  @Query('DELETE FROM heroes')
  Future<void> deleteAllHeroes();

  @Query('SELECT * FROM heroes WHERE cachedAt > :timestamp')
  Future<List<HeroEntity>> getHeroesCachedAfter(int timestamp);

  @Query('SELECT * FROM heroes WHERE name LIKE :query OR slug LIKE :query')
  Future<List<HeroEntity>> searchHeroes(String query);
}

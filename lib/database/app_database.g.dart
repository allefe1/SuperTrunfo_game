// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  HeroDao? _heroDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `heroes` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `slug` TEXT NOT NULL, `powerStatsJson` TEXT NOT NULL, `appearanceJson` TEXT NOT NULL, `biographyJson` TEXT NOT NULL, `workJson` TEXT NOT NULL, `connectionsJson` TEXT NOT NULL, `imagesJson` TEXT NOT NULL, `cachedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  HeroDao get heroDao {
    return _heroDaoInstance ??= _$HeroDao(database, changeListener);
  }
}

class _$HeroDao extends HeroDao {
  _$HeroDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _heroEntityInsertionAdapter = InsertionAdapter(
            database,
            'heroes',
            (HeroEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'slug': item.slug,
                  'powerStatsJson': item.powerStatsJson,
                  'appearanceJson': item.appearanceJson,
                  'biographyJson': item.biographyJson,
                  'workJson': item.workJson,
                  'connectionsJson': item.connectionsJson,
                  'imagesJson': item.imagesJson,
                  'cachedAt': item.cachedAt
                }),
        _heroEntityUpdateAdapter = UpdateAdapter(
            database,
            'heroes',
            ['id'],
            (HeroEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'slug': item.slug,
                  'powerStatsJson': item.powerStatsJson,
                  'appearanceJson': item.appearanceJson,
                  'biographyJson': item.biographyJson,
                  'workJson': item.workJson,
                  'connectionsJson': item.connectionsJson,
                  'imagesJson': item.imagesJson,
                  'cachedAt': item.cachedAt
                }),
        _heroEntityDeletionAdapter = DeletionAdapter(
            database,
            'heroes',
            ['id'],
            (HeroEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'slug': item.slug,
                  'powerStatsJson': item.powerStatsJson,
                  'appearanceJson': item.appearanceJson,
                  'biographyJson': item.biographyJson,
                  'workJson': item.workJson,
                  'connectionsJson': item.connectionsJson,
                  'imagesJson': item.imagesJson,
                  'cachedAt': item.cachedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<HeroEntity> _heroEntityInsertionAdapter;

  final UpdateAdapter<HeroEntity> _heroEntityUpdateAdapter;

  final DeletionAdapter<HeroEntity> _heroEntityDeletionAdapter;

  @override
  Future<List<HeroEntity>> getAllHeroes() async {
    return _queryAdapter.queryList('SELECT * FROM heroes',
        mapper: (Map<String, Object?> row) => HeroEntity(
            id: row['id'] as int,
            name: row['name'] as String,
            slug: row['slug'] as String,
            powerStatsJson: row['powerStatsJson'] as String,
            appearanceJson: row['appearanceJson'] as String,
            biographyJson: row['biographyJson'] as String,
            workJson: row['workJson'] as String,
            connectionsJson: row['connectionsJson'] as String,
            imagesJson: row['imagesJson'] as String,
            cachedAt: row['cachedAt'] as int));
  }

  @override
  Future<HeroEntity?> getHeroById(int id) async {
    return _queryAdapter.query('SELECT * FROM heroes WHERE id = ?1',
        mapper: (Map<String, Object?> row) => HeroEntity(
            id: row['id'] as int,
            name: row['name'] as String,
            slug: row['slug'] as String,
            powerStatsJson: row['powerStatsJson'] as String,
            appearanceJson: row['appearanceJson'] as String,
            biographyJson: row['biographyJson'] as String,
            workJson: row['workJson'] as String,
            connectionsJson: row['connectionsJson'] as String,
            imagesJson: row['imagesJson'] as String,
            cachedAt: row['cachedAt'] as int),
        arguments: [id]);
  }

  @override
  Future<List<HeroEntity>> getHeroesPaginated(
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList('SELECT * FROM heroes LIMIT ?1 OFFSET ?2',
        mapper: (Map<String, Object?> row) => HeroEntity(
            id: row['id'] as int,
            name: row['name'] as String,
            slug: row['slug'] as String,
            powerStatsJson: row['powerStatsJson'] as String,
            appearanceJson: row['appearanceJson'] as String,
            biographyJson: row['biographyJson'] as String,
            workJson: row['workJson'] as String,
            connectionsJson: row['connectionsJson'] as String,
            imagesJson: row['imagesJson'] as String,
            cachedAt: row['cachedAt'] as int),
        arguments: [limit, offset]);
  }

  @override
  Future<int?> getHeroesCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM heroes',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> deleteAllHeroes() async {
    await _queryAdapter.queryNoReturn('DELETE FROM heroes');
  }

  @override
  Future<List<HeroEntity>> getHeroesCachedAfter(int timestamp) async {
    return _queryAdapter.queryList('SELECT * FROM heroes WHERE cachedAt > ?1',
        mapper: (Map<String, Object?> row) => HeroEntity(
            id: row['id'] as int,
            name: row['name'] as String,
            slug: row['slug'] as String,
            powerStatsJson: row['powerStatsJson'] as String,
            appearanceJson: row['appearanceJson'] as String,
            biographyJson: row['biographyJson'] as String,
            workJson: row['workJson'] as String,
            connectionsJson: row['connectionsJson'] as String,
            imagesJson: row['imagesJson'] as String,
            cachedAt: row['cachedAt'] as int),
        arguments: [timestamp]);
  }

  @override
  Future<List<HeroEntity>> searchHeroes(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM heroes WHERE name LIKE ?1 OR slug LIKE ?1',
        mapper: (Map<String, Object?> row) => HeroEntity(
            id: row['id'] as int,
            name: row['name'] as String,
            slug: row['slug'] as String,
            powerStatsJson: row['powerStatsJson'] as String,
            appearanceJson: row['appearanceJson'] as String,
            biographyJson: row['biographyJson'] as String,
            workJson: row['workJson'] as String,
            connectionsJson: row['connectionsJson'] as String,
            imagesJson: row['imagesJson'] as String,
            cachedAt: row['cachedAt'] as int),
        arguments: [query]);
  }

  @override
  Future<void> insertHero(HeroEntity hero) async {
    await _heroEntityInsertionAdapter.insert(hero, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertHeroes(List<HeroEntity> heroes) async {
    await _heroEntityInsertionAdapter.insertList(
        heroes, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateHero(HeroEntity hero) async {
    await _heroEntityUpdateAdapter.update(hero, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteHero(HeroEntity hero) async {
    await _heroEntityDeletionAdapter.delete(hero);
  }
}

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

import 'entities/hero_entity.dart';
import 'daos/hero_dao.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [HeroEntity])
abstract class AppDatabase extends FloorDatabase {
  HeroDao get heroDao;

  static Future<AppDatabase> getInstance() async {
    return await $FloorAppDatabase
        .databaseBuilder('superhero_database.db')
        .build();
  }
}

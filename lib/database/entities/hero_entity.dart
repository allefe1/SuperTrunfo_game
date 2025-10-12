// lib/database/entities/hero_entity.dart
import 'package:floor/floor.dart';
import 'dart:convert';
import '../../models/hero_models.dart';

@Entity(tableName: 'heroes')
class HeroEntity {
  @PrimaryKey()
  final int id;
  
  final String name;
  final String slug;
  
  // Campos serializados como JSON strings
  final String powerStatsJson;
  final String appearanceJson;
  final String biographyJson;
  final String workJson;
  final String connectionsJson;
  final String imagesJson;
  
  // Timestamp para controle de cache
  final int cachedAt;

  HeroEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.powerStatsJson,
    required this.appearanceJson,
    required this.biographyJson,
    required this.workJson,
    required this.connectionsJson,
    required this.imagesJson,
    required this.cachedAt,
  });

  // Converter de SuperHero para HeroEntity
  factory HeroEntity.fromSuperHero(SuperHero hero) {
    return HeroEntity(
      id: hero.id,
      name: hero.name,
      slug: hero.slug,
      powerStatsJson: jsonEncode(hero.powerStats.toJson()),
      appearanceJson: jsonEncode(hero.appearance.toJson()),
      biographyJson: jsonEncode(hero.biography.toJson()),
      workJson: jsonEncode(hero.work.toJson()),
      connectionsJson: jsonEncode(hero.connections.toJson()),
      imagesJson: jsonEncode(hero.images.toJson()),
      cachedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Converter de HeroEntity para SuperHero
  SuperHero toSuperHero() {
    return SuperHero(
      id: id,
      name: name,
      slug: slug,
      powerStats: PowerStats.fromJson(jsonDecode(powerStatsJson)),
      appearance: Appearance.fromJson(jsonDecode(appearanceJson)),
      biography: Biography.fromJson(jsonDecode(biographyJson)),
      work: Work.fromJson(jsonDecode(workJson)),
      connections: Connections.fromJson(jsonDecode(connectionsJson)),
      images: HeroImages.fromJson(jsonDecode(imagesJson)),
    );
  }
}

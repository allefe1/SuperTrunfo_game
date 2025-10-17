class SuperHero {
  final int id;
  final String name;
  final String slug;
  final PowerStats powerStats;
  final Appearance appearance;
  final Biography biography;
  final Work work;
  final Connections connections;
  final HeroImages images;

  const SuperHero({
    required this.id,
    required this.name,
    required this.slug,
    required this.powerStats,
    required this.appearance,
    required this.biography,
    required this.work,
    required this.connections,
    required this.images,
  });

  factory SuperHero.fromJson(Map<String, dynamic> json) {
    return SuperHero(
      id: _parseToInt(json['id']), 
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      powerStats: PowerStats.fromJson(json['powerstats'] ?? {}),
      appearance: Appearance.fromJson(json['appearance'] ?? {}),
      biography: Biography.fromJson(json['biography'] ?? {}),
      work: Work.fromJson(json['work'] ?? {}),
      connections: Connections.fromJson(json['connections'] ?? {}),
      images: HeroImages.fromJson(json['images'] ?? {}),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'powerstats': powerStats.toJson(),
      'appearance': appearance.toJson(),
      'biography': biography.toJson(),
      'work': work.toJson(),
      'connections': connections.toJson(),
      'images': images.toJson(),
    };
  }
}

class PowerStats {
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  const PowerStats({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });

  factory PowerStats.fromJson(Map<String, dynamic> json) {
    return PowerStats(
      intelligence: _parseToInt(json['intelligence']),
      strength: _parseToInt(json['strength']),
      speed: _parseToInt(json['speed']),
      durability: _parseToInt(json['durability']),
      power: _parseToInt(json['power']),
      combat: _parseToInt(json['combat']),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'intelligence': intelligence,
      'strength': strength,
      'speed': speed,
      'durability': durability,
      'power': power,
      'combat': combat,
    };
  }

  List<int> getAllPowers() {
    return [intelligence, strength, speed, durability, power, combat];
  }

  int getPowerByIndex(int index) {
    final powers = getAllPowers();
    return index < powers.length ? powers[index] : 0;
  }

  List<String> getPowerNames() {
    return [
      'Intelligence',
      'Strength',
      'Speed',
      'Durability',
      'Power',
      'Combat'
    ];
  }
}

class Appearance {
  final String gender;
  final String race;
  final List<String> height;
  final List<String> weight;
  final String eyeColor;
  final String hairColor;

  const Appearance({
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
  });

  factory Appearance.fromJson(Map<String, dynamic> json) {
    return Appearance(
      gender: json['gender'] ?? '',
      race: json['race'] ?? '',
      height: List<String>.from(json['height'] ?? []),
      weight: List<String>.from(json['weight'] ?? []),
      eyeColor: json['eyeColor'] ?? '',
      hairColor: json['hairColor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'race': race,
      'height': height,
      'weight': weight,
      'eyeColor': eyeColor,
      'hairColor': hairColor,
    };
  }
}

class Biography {
  final String fullName;
  final String alterEgos;
  final List<String> aliases;
  final String placeOfBirth;
  final String firstAppearance;
  final String? publisher;
  final String alignment;

  const Biography({
    required this.fullName,
    required this.alterEgos,
    required this.aliases,
    required this.placeOfBirth,
    required this.firstAppearance,
    this.publisher,
    required this.alignment,
  });

  factory Biography.fromJson(Map<String, dynamic> json) {
    return Biography(
      fullName: json['fullName'] ?? '',
      alterEgos: json['alterEgos'] ?? '',
      aliases: List<String>.from(json['aliases'] ?? []),
      placeOfBirth: json['placeOfBirth'] ?? '',
      firstAppearance: json['firstAppearance'] ?? '',
      publisher: json['publisher'],
      alignment: json['alignment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'alterEgos': alterEgos,
      'aliases': aliases,
      'placeOfBirth': placeOfBirth,
      'firstAppearance': firstAppearance,
      'publisher': publisher,
      'alignment': alignment,
    };
  }
}

class Work {
  final String occupation;
  final String base;

  const Work({
    required this.occupation,
    required this.base,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      occupation: json['occupation'] ?? '',
      base: json['base'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'occupation': occupation,
      'base': base,
    };
  }
}

class Connections {
  final String groupAffiliation;
  final String relatives;

  const Connections({
    required this.groupAffiliation,
    required this.relatives,
  });

  factory Connections.fromJson(Map<String, dynamic> json) {
    return Connections(
      groupAffiliation: json['groupAffiliation'] ?? '',
      relatives: json['relatives'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupAffiliation': groupAffiliation,
      'relatives': relatives,
    };
  }
}

class HeroImages {
  final String xs;
  final String sm;
  final String md;
  final String lg;

  const HeroImages({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
  });

  factory HeroImages.fromJson(Map<String, dynamic> json) {
    return HeroImages(
      xs: _fixImageUrl(json['xs'] ?? ''),
      sm: _fixImageUrl(json['sm'] ?? ''),
      md: _fixImageUrl(json['md'] ?? ''),
      lg: _fixImageUrl(json['lg'] ?? ''),
    );
  }

  static String _fixImageUrl(String url) {
    if (url.isEmpty) return '';

    // se a URL já estiver correta, retorna como está
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // corrige as url malformadas do tipo "httpscdn.jsdelivr.net"
    if (url.startsWith('httpscdn.jsdelivr.net')) {
      return url
          .replaceFirst('httpscdn.jsdelivr.net', 'https://cdn.jsdelivr.net/')
          .replaceFirst('ghakababsuperhero-api', 'gh/akabab/superhero-api/')
          .replaceFirst('0.3.0api', '0.3.0/api/')
          .replaceFirst('imagesxs', 'images/xs/')
          .replaceFirst('imagessm', 'images/sm/')
          .replaceFirst('imagesmd', 'images/md/')
          .replaceFirst('imageslg', 'images/lg/');
    }

    return url;
  }

  Map<String, dynamic> toJson() {
    return {
      'xs': xs,
      'sm': sm,
      'md': md,
      'lg': lg,
    };
  }
}

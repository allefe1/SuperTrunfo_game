import 'package:dio/dio.dart';
import '../models/hero_models.dart';

class HeroService {
  late final Dio _dio;
  static const String baseUrl = 'http://10.0.2.2:3000';

  HeroService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print('[DIO] $object'),
    ));
  }

  Future<List<SuperHero>> getAllHeroes() async {
    try {
      final response = await _dio.get('/heroes');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SuperHero.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar heróis: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<List<SuperHero>> getHeroesPaginated({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _dio.get('/heroes', queryParameters: {
        '_page': page,
        '_limit': limit,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SuperHero.fromJson(json)).toList();
      } else {
        throw Exception(
            'Falha ao carregar heróis paginados: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<SuperHero?> getHeroById(int id) async {
    try {
      final response = await _dio.get('/heroes/$id');

      if (response.statusCode == 200) {
        return SuperHero.fromJson(response.data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Falha ao carregar herói: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<SuperHero> getRandomHero() async {
    try {
      final allHeroes = await getAllHeroes();
      if (allHeroes.isEmpty) {
        throw Exception('Nenhum herói encontrado');
      }

      final random = DateTime.now().millisecondsSinceEpoch % allHeroes.length;
      return allHeroes[random];
    } catch (e) {
      throw Exception('Erro ao buscar herói aleatório: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Timeout de conexão';
      case DioExceptionType.sendTimeout:
        return 'Timeout de envio';
      case DioExceptionType.receiveTimeout:
        return 'Timeout de recebimento';
      case DioExceptionType.badResponse:
        return 'Resposta inválida do servidor: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Requisição cancelada';
      case DioExceptionType.connectionError:
        return 'Erro de conexão. Verifique se o json-server está rodando em $baseUrl';
      case DioExceptionType.unknown:
        return 'Erro desconhecido: ${e.message}';
      default:
        return 'Erro na requisição';
    }
  }
}

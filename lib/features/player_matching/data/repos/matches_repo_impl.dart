// player_matching/data/repositories/matches_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  final ApiService apiService;

  MatchesRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<MatchModel>>> getAvailableMatches() async {
    try {
      print('Fetching available matches...');
      final response =
          await apiService.get(endPoint: 'Match/available?sportType=Football');

      print('Response type: ${response.runtimeType}');
      print('Response data: $response');

      if (response is List) {
        final matches =
            response.map((match) => MatchModel.fromJson(match)).toList();
        print('Parsed matches: ${matches.length}');
        return right(matches);
      } else {
        return left(ServerFailure(
            'Unexpected response format: ${response.runtimeType}'));
      }
    } catch (e) {
      print('Error in getAvailableMatches: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          return left(ServerFailure('Invalid request: Sport type is required'));
        }
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchModel>>> getMyMatches() async {
    try {
      final response = await apiService.get(endPoint: 'Match/my-matches');

      if (response is List) {
        final matches =
            response.map((match) => MatchModel.fromJson(match)).toList();
        return right(matches);
      } else {
        return left(ServerFailure('Unexpected response format'));
      }
    } catch (e) {
      if (e is DioError) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchModel>> getMatchDetails(String matchId) async {
    try {
      final response = await apiService.get(endPoint: 'Match/$matchId');
      return right(MatchModel.fromJson(response));
    } catch (e) {
      if (e is DioError) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createMatch(
      Map<String, dynamic> matchData) async {
    try {
      print('Creating match with data: $matchData');

      // Make sure the auth token is included in the request
      final response =
          await apiService.post(endPoint: 'Match/create', data: matchData);

      print('Create match response: $response');
      return right(true);
    } catch (e) {
      print('Error in createMatch: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          // Handle 403 Forbidden specifically
          return left(ServerFailure(
              'You do not have permission to create a match. Please check your authentication.'));
        }
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> joinTeam(String matchId, String team) async {
    try {
      print('Joining team $team for match $matchId');
      final response = await apiService.post(
        endPoint: 'Match/$matchId/join',
        data: {'team': team},
      );
      print('Join team response: $response');
      return right(true);
    } catch (e) {
      print('Error in joinTeam: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          return left(ServerFailure('Team is full or invalid team selection'));
        }
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}

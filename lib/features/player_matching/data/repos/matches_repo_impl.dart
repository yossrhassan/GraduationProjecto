// player_matching/data/repositories/matches_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/models/sport_model.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  final ApiService apiService;

  MatchesRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<MatchModel>>> getAvailableMatches(
      {int? sportTypeId}) async {
    try {
      print('Getting available matches with sport filter: $sportTypeId');

      // Build endpoint with optional sport type filter
      String endpoint = 'Match/available';
      if (sportTypeId != null) {
        endpoint = '$endpoint?sportId=$sportTypeId';
      }

      final response = await apiService.get(endPoint: endpoint);

      if (response is List) {
        print('Got ${response.length} available matches from backend');

        print('🔍 DEBUGGING BACKEND RESPONSE - Available Matches:');
        for (int i = 0; i < response.length; i++) {
          final match = response[i];
          print('  Match ${match['id']}:');
          print('    Creator: ${match['creatorUserId']}');
          print('    Sport Type: ${match['sportType']}');
          print('    Players field exists: ${match.containsKey('players')}');
          print('    Players: ${match['players']}');
          if (match['players'] is List) {
            final players = match['players'] as List;
            print('    Players count: ${players.length}');
            for (int j = 0; j < players.length; j++) {
              print('      Player $j: ${players[j]}');
            }
          }
        }

        final matches =
            response.map((match) => MatchModel.fromJson(match)).toList();
        return right(matches);
      } else {
        return left(ServerFailure('Unexpected response format'));
      }
    } catch (e) {
      print('Error in getAvailableMatches: $e');
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SportModel>>> getSports() async {
    try {
      print('Getting sports list...');
      final response = await apiService.get(endPoint: 'Sport/getAll');

      if (response is List) {
        print('Got ${response.length} sports from backend');

        print('🔍 DEBUGGING SPORTS RESPONSE:');
        for (int i = 0; i < response.length; i++) {
          final sport = response[i];
          print('  Sport ${sport['id']}: ${sport['name']}');
        }

        final sports =
            response.map((sport) => SportModel.fromJson(sport)).toList();
        return right(sports);
      } else {
        return left(ServerFailure('Unexpected response format'));
      }
    } catch (e) {
      print('Error in getSports: $e');
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchModel>>> getMyMatches() async {
    try {
      print('Getting my matches from backend...');
      final response = await apiService.get(endPoint: 'Match/my-matches');

      if (response is List) {
        print('Got ${response.length} matches from my-matches endpoint');

        print('🔍 DEBUGGING BACKEND RESPONSE - My Matches:');
        for (int i = 0; i < response.length; i++) {
          final match = response[i];
          print('  Match ${match['id']}:');
          print('    Creator: ${match['creatorUserId']}');
          print('    Players field exists: ${match.containsKey('players')}');
          print('    Players: ${match['players']}');
          if (match['players'] is List) {
            final players = match['players'] as List;
            print('    Players count: ${players.length}');
            for (int j = 0; j < players.length; j++) {
              print('      Player $j: ${players[j]}');
            }
          }
        }

        final matches =
            response.map((match) => MatchModel.fromJson(match)).toList();
        return right(matches);
      } else {
        return left(ServerFailure('Unexpected response format'));
      }
    } catch (e) {
      print('Error in getMyMatches: $e');
      if (e is DioError) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchModel>> getMatchDetails(String matchId) async {
    try {
      print('🔍 DEBUGGING: Getting match details for match $matchId');
      final response = await apiService.get(endPoint: 'Match/$matchId');

      print('🔍 DEBUGGING: Raw match details response:');
      print('  Response type: ${response.runtimeType}');
      print('  Response data: $response');

      if (response is Map<String, dynamic>) {
        print('🔍 DEBUGGING: Match details fields:');
        print('  ID: ${response['id']}');
        print('  Creator: ${response['creatorUserId']}');
        print('  Players field exists: ${response.containsKey('players')}');
        print('  Players data: ${response['players']}');
        print('  Players type: ${response['players']?.runtimeType}');
        if (response['players'] is List) {
          final players = response['players'] as List;
          print('  Players count: ${players.length}');
          for (int i = 0; i < players.length; i++) {
            print('    Player $i: ${players[i]}');
          }
        }
      }

      final match = MatchModel.fromJson(response);
      print('🔍 DEBUGGING: Parsed match details:');
      print('  Match ID: ${match.id}');
      print('  Players count: ${match.players?.length ?? 0}');
      match.players?.forEach((player) {
        print(
            '    Player: ${player.userName} (ID: ${player.userId}, Team: ${player.team})');
      });

      return right(match);
    } catch (e) {
      print('❌ Error getting match details: $e');
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
      final response =
          await apiService.post(endPoint: 'Match', data: matchData);

      return right(true);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
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
      print('🔍 DEBUGGING: Attempting to join match $matchId, team $team');

      final response = await apiService.post(
        endPoint: 'Match/$matchId/join',
        data: {'team': team},
      );

      print('🔍 DEBUGGING: Join team successful!');
      print('  Response type: ${response.runtimeType}');
      print('  Response data: $response');

      return right(true);
    } catch (e) {
      print('🔥 DEBUGGING JOIN TEAM ERROR for match $matchId');
      print('Error type: ${e.runtimeType}');

      if (e is DioException) {
        print('DioException details:');
        print('  Status code: ${e.response?.statusCode}');
        print('  Response data: ${e.response?.data}');
        print('  Response data type: ${e.response?.data.runtimeType}');

        if (e.response?.statusCode == 400) {
          // Check different possible response formats
          dynamic responseData = e.response?.data;
          String responseText = '';

          if (responseData is String) {
            responseText = responseData;
          } else if (responseData is Map) {
            responseText = responseData.toString();
          } else {
            responseText = responseData?.toString() ?? '';
          }

          print('🔍 Response text for analysis: "$responseText"');

          // Check for "already joined" or "already part of" patterns
          if (responseText.toLowerCase().contains('already part of') ||
              responseText.toLowerCase().contains('already joined') ||
              responseText.toLowerCase().contains('already') &&
                  responseText.toLowerCase().contains('match')) {
            print('✅ DETECTED: User is already part of match $matchId');
            return right(
                true); // Return success since user is already in the match
          }

          return left(ServerFailure('Team is full or invalid team selection'));
        }

        return left(ServerFailure.fromDioError(e));
      }

      return left(ServerFailure(e.toString()));
    }
  }
}

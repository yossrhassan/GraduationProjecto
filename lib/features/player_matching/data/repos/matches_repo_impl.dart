// player_matching/data/repositories/matches_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  final ApiService apiService;

  MatchesRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<MatchModel>>> getAvailableMatches() async {
    try {
      print('Getting available matches...');

      // Since Match/available returns 0 results, let's use Match/my-matches
      // and filter on frontend to show matches NOT created by current user
      final response = await apiService.get(endPoint: 'Match/my-matches');

      if (response is List) {
        print('Got ${response.length} total matches');

        print('🔍 DEBUGGING BACKEND RESPONSE - Available Matches:');
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

        // Return all matches - let frontend filter for "available" ones
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
  Future<Either<Failure, List<MatchModel>>> getMyMatches() async {
    try {
      print('Getting my matches...');
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

        // Return all matches - let frontend filter for "my" ones
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
          await apiService.post(endPoint: 'Match/create', data: matchData);

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
      print('🔍 DEBUGGING: Current user ID: ${AuthManager.userId}');

      final response = await apiService.post(
        endPoint: 'Match/$matchId/join',
        data: {'team': team},
      );

      print('🔍 DEBUGGING: Join team successful!');
      print('  Response type: ${response.runtimeType}');
      print('  Response data: $response');

      // If join was successful, track it locally
      print('Successfully joined match $matchId');
      await AuthManager.addJoinedMatch(matchId, team);

      print('🔍 DEBUGGING: Local tracking updated');
      print('  Joined matches: ${AuthManager.joinedMatchIds}');
      print(
          '  Joined team for $matchId: ${AuthManager.getJoinedTeam(matchId)}');

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
            print('📱 Adding to local tracking...');

            // Add to local tracking so it appears in "My Matches"
            await AuthManager.addJoinedMatch(matchId, team);

            print(
                '🔍 DEBUGGING: Local tracking updated for already joined match');
            print('  Joined matches: ${AuthManager.joinedMatchIds}');
            print(
                '  Joined team for $matchId: ${AuthManager.getJoinedTeam(matchId)}');

            print('✅ SUCCESS: Match $matchId added to local tracking');
            return right(
                true); // Return success since user is already in the match
          }

          print('❌ Error not recognized as "already joined"');
          return left(ServerFailure('Team is full or invalid team selection'));
        }

        print('❌ Status code not 400: ${e.response?.statusCode}');
        return left(ServerFailure.fromDioError(e));
      }

      print('❌ Not a DioException: $e');
      return left(ServerFailure(e.toString()));
    }
  }
}

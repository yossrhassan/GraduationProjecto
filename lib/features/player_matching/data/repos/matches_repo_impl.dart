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

        // Since the /available endpoint doesn't return complete player data,
        // we need to fetch details for each match to get accurate player counts
        print('🔄 Fetching detailed data for each available match...');
        final detailedMatches = <MatchModel>[];

        for (final match in matches) {
          try {
            final detailsResponse =
                await apiService.get(endPoint: 'Match/${match.id}');
            final detailedMatch = MatchModel.fromJson(detailsResponse);
            detailedMatches.add(detailedMatch);
            print(
                '✅ Got details for match ${match.id}: ${detailedMatch.players?.length ?? 0} players');
          } catch (e) {
            print(
                '❌ Failed to get details for match ${match.id}, using basic data: $e');
            // If we can't get details, use the basic data
            detailedMatches.add(match);
          }
        }

        return right(detailedMatches);
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
      print('🔍 DEBUGGING: Getting my matches from backend...');
      print('🔍 DEBUGGING: Making request to: Match/my-matches');

      final response = await apiService.get(endPoint: 'Match/my-matches');

      if (response is List) {
        print('Got ${response.length} matches from my-matches endpoint');

        print('🔍 DEBUGGING BACKEND RESPONSE - My Matches:');
        for (int i = 0; i < response.length; i++) {
          final match = response[i];
          print('  Match ${match['id']}:');
          print('    Creator: ${match['creatorUserId']}');
          print('    Title: ${match['title']}');
          print('    Status: ${match['status']}');
          print('    Players field exists: ${match.containsKey('players')}');
          print('    Players: ${match['players']}');
          if (match['players'] is List) {
            final players = match['players'] as List;
            print('    Players count: ${players.length}');
            for (int j = 0; j < players.length; j++) {
              final player = players[j];
              print(
                  '      Player $j: ${player['userName']} (ID: ${player['userId']}, Team: ${player['team']})');
            }
          }
        }

        final matches =
            response.map((match) => MatchModel.fromJson(match)).toList();

        print('🔍 FINAL PROCESSED MATCHES:');
        for (int i = 0; i < matches.length; i++) {
          final match = matches[i];
          print('  Match ${match.id}:');
          print('    Title: ${match.title}');
          print(
              '    Creator: ${match.creatorUserId} (${match.creatorUserName ?? 'Unknown'})');
          print('    Players count: ${match.players?.length ?? 0}');
          match.players?.forEach((player) {
            print(
                '      ${player.userName} (ID: ${player.userId}, Team: ${player.team})');
          });
        }

        return right(matches);
      } else {
        return left(ServerFailure('Unexpected response format'));
      }
    } catch (e) {
      print('❌ Error in getMyMatches: $e');
      if (e is DioException) {
        print(
            '❌ DioException in getMyMatches: Status ${e.response?.statusCode}, Data: ${e.response?.data}');

        // If /my-matches endpoint fails, try using available matches and filter client-side
        if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
          print(
              '🔄 Fallback: /my-matches endpoint failed, trying to get all matches and filter');
          try {
            final fallbackResult = await getAvailableMatches();
            return fallbackResult.fold(
              (failure) => left(failure),
              (allMatches) {
                // TODO: Implement client-side filtering here if needed
                // For now, return empty list to see if endpoint issue is resolved
                print(
                    '🔄 Fallback successful, but returning empty for debugging');
                return right(<MatchModel>[]);
              },
            );
          } catch (fallbackError) {
            print('❌ Fallback also failed: $fallbackError');
            return left(ServerFailure.fromDioError(e));
          }
        }

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
          // Extract the actual error message from the API response
          dynamic responseData = e.response?.data;
          String errorMessage = 'Team is full or invalid team selection';

          if (responseData is String) {
            errorMessage = responseData;
          } else if (responseData is Map<String, dynamic>) {
            // Try different possible error message fields
            errorMessage = responseData['message'] ??
                responseData['error'] ??
                responseData['title'] ??
                responseData.toString();
          } else {
            errorMessage = responseData?.toString() ?? errorMessage;
          }

          print('🔍 Response text for analysis: "$errorMessage"');

          // Check for "already joined" or "already part of" patterns
          if (errorMessage.toLowerCase().contains('already part of') ||
              errorMessage.toLowerCase().contains('already joined') ||
              errorMessage.toLowerCase().contains('already') &&
                  errorMessage.toLowerCase().contains('match')) {
            print('✅ DETECTED: User is already part of match $matchId');
            return right(
                true); // Return success since user is already in the match
          }

          // Return the actual API error message
          return left(ServerFailure(errorMessage));
        }

        return left(ServerFailure.fromDioError(e));
      }

      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchModel>>> getCompletedMatches() async {
    try {
      print('Getting completed matches from backend...');
      final response = await apiService.get(endPoint: 'Match/completed');
      if (response is List) {
        final matches =
            response.map((match) => MatchModel.fromJson(match)).toList();
        return right(matches);
      } else {
        return left(ServerFailure('Unexpected response format'));
      }
    } catch (e) {
      print('Error in getCompletedMatches: $e');
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> leaveMatch(String matchId) async {
    try {
      print('🚪 Leaving match $matchId...');
      final response = await apiService.post(
        endPoint: 'Match/$matchId/leave',
        data: {}, // Empty body since matchId is in the URL
      );

      print('✅ Leave match response: $response');

      // Handle different response types
      if (response is String) {
        return right(response);
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return right(response['message'] ?? 'Successfully left the match');
        } else {
          return right(response['message'] ?? 'Successfully left the match');
        }
      }

      return right('Successfully left the match');
    } catch (e) {
      print('❌ Error leaving match: $e');
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> cancelMatch(String matchId) async {
    try {
      print('🚫 Canceling match $matchId...');
      final response = await apiService.post(
        endPoint: 'Match/$matchId/cancel',
        data: {}, // Empty body since matchId is in the URL
      );

      print('✅ Cancel match response: $response');

      // Handle different response types
      if (response is String) {
        return right(response);
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return right('Match canceled successfully');
        } else {
          return right(response['message'] ?? 'Match canceled successfully');
        }
      }

      return right('Match canceled successfully');
    } catch (e) {
      print('❌ Error canceling match: $e');
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> inviteFriend(
      String matchId, int invitedUserId) async {
    try {
      print('👥 Inviting friend $invitedUserId to match $matchId...');
      final response = await apiService.post(
        endPoint: 'Match/$matchId/invite',
        data: {
          'invitedUserId': invitedUserId,
        },
      );

      print('✅ Invite friend response: $response');

      // Handle different response types
      if (response is String) {
        return right(response);
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return right('Friend invited successfully');
        } else {
          return right(response['message'] ?? 'Friend invited successfully');
        }
      }

      return right('Friend invited successfully');
    } catch (e) {
      print('❌ Error inviting friend: $e');
      if (e is DioException) {
        // Extract error message from response
        String errorMessage = 'Failed to invite friend';

        if (e.response?.data != null) {
          final responseData = e.response!.data;
          print('❌ Error response data: $responseData');
          print('❌ Error response type: ${responseData.runtimeType}');

          if (responseData is String) {
            errorMessage = responseData;
          } else if (responseData is Map<String, dynamic>) {
            // Try different possible error message fields
            errorMessage = responseData['message'] ??
                responseData['error'] ??
                responseData['title'] ??
                'Failed to invite friend';
          }
        }

        return left(ServerFailure(errorMessage));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchModel>>> getMatchInvitations() async {
    try {
      print('📨 Getting match invitations...');
      final response = await apiService.get(endPoint: 'Match/invitations');

      print('✅ Match invitations response: $response');

      if (response is List) {
        final invitations =
            response.map((match) => MatchModel.fromJson(match)).toList();
        return right(invitations);
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] is List) {
          final invitations = (response['data'] as List)
              .map((match) => MatchModel.fromJson(match))
              .toList();
          return right(invitations);
        }
      }

      return right([]);
    } catch (e) {
      print('❌ Error getting match invitations: $e');
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> respondToInvitation(
      String matchId, bool accept) async {
    try {
      print(
          '📨 Responding to invitation for match $matchId with accept: $accept');
      final response = await apiService.post(
        endPoint: 'Match/$matchId/respond-invitation',
        data: {
          'accept': accept,
        },
      );

      print('✅ Respond to invitation response: $response');

      // Handle different response types
      if (response is String) {
        return right(response);
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return right(accept
              ? 'Invitation accepted successfully'
              : 'Invitation declined successfully');
        } else {
          return right(response['message'] ??
              (accept ? 'Invitation accepted' : 'Invitation declined'));
        }
      }

      return right(accept
          ? 'Invitation accepted successfully'
          : 'Invitation declined successfully');
    } catch (e) {
      print('❌ Error responding to invitation: $e');
      if (e is DioException) {
        // Extract error message from response
        String errorMessage = 'Failed to respond to invitation';

        if (e.response?.data != null) {
          final responseData = e.response!.data;
          print('❌ Error response data: $responseData');
          print('❌ Error response type: ${responseData.runtimeType}');

          if (responseData is String) {
            errorMessage = responseData;
          } else if (responseData is Map<String, dynamic>) {
            // Try different possible error message fields
            errorMessage = responseData['message'] ??
                responseData['error'] ??
                responseData['title'] ??
                'Failed to respond to invitation';
          }
        }

        return left(ServerFailure(errorMessage));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> kickPlayer(
      String matchId, int playerId) async {
    try {
      print('👢 Kicking player $playerId from match $matchId...');
      final response = await apiService.post(
        endPoint: 'Match/$matchId/kick/$playerId',
        data: {}, // Empty body since both IDs are in the URL
      );

      print('✅ Kick player response: $response');

      // Handle different response types
      if (response is String) {
        return right(response);
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          return right('Player kicked successfully');
        } else {
          return right(response['message'] ?? 'Player kicked successfully');
        }
      }

      return right('Player kicked successfully');
    } catch (e) {
      print('❌ Error kicking player: $e');
      if (e is DioException) {
        // Extract error message from response
        String errorMessage = 'Failed to kick player';

        if (e.response?.data != null) {
          final responseData = e.response!.data;
          print('❌ Error response data: $responseData');
          print('❌ Error response type: ${responseData.runtimeType}');

          if (responseData is String) {
            errorMessage = responseData;
          } else if (responseData is Map<String, dynamic>) {
            // Try different possible error message fields
            errorMessage = responseData['message'] ??
                responseData['error'] ??
                responseData['title'] ??
                'Failed to kick player';
          }
        }

        return left(ServerFailure(errorMessage));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}

// player_matching/data/repositories/matches_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/api_service.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/models/match_invitation_model.dart';
import 'package:graduation_project/features/player_matching/data/models/sport_model.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  final ApiService apiService;

  MatchesRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<MatchModel>>> getAvailableMatches(
      {int? sportTypeId}) async {
    try {
      String endpoint = 'Match/available';
      if (sportTypeId != null) {
        endpoint = '$endpoint?sportId=$sportTypeId';
      }

      final response = await apiService.get(endPoint: endpoint);

      if (response is List) {
        final matches =
            response.map((match) => MatchModel.fromJson(match)).toList();

        final detailedMatches = <MatchModel>[];

        for (final match in matches) {
          try {
            final detailsResponse =
                await apiService.get(endPoint: 'Match/${match.id}');
            final detailedMatch = MatchModel.fromJson(detailsResponse);
            detailedMatches.add(detailedMatch);
          } catch (e) {
            detailedMatches.add(match);
          }
        }

        return right(detailedMatches);
      } else {
        return left(ServerFailure('Unexpected response format'));
      }
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SportModel>>> getSports() async {
    try {
      final response = await apiService.get(endPoint: 'Sport/getAll');

      if (response is List) {
        final sports =
            response.map((sport) => SportModel.fromJson(sport)).toList();
        return right(sports);
      } else {
        return left(ServerFailure('Unexpected response format'));
      }
    } catch (e) {
      if (e is DioException) {
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
      if (e is DioException) {
        if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
          try {
            final fallbackResult = await getAvailableMatches();
            return fallbackResult.fold(
              (failure) => left(failure),
              (allMatches) => right(<MatchModel>[]),
            );
          } catch (fallbackError) {
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
      final response = await apiService.get(endPoint: 'Match/$matchId');

      final match = MatchModel.fromJson(response);
      return right(match);
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
      final response =
          await apiService.post(endPoint: 'Match', data: matchData);

      return right(true);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          return left(ServerFailure(
              'You do not have permission to create a match. Please check your authentication.'));
        } else if (e.response?.statusCode == 400) {
          dynamic responseData = e.response?.data;
          String errorMessage = 'Failed to create match';

          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message']?.toString() ??
                responseData['messege']?.toString() ??
                responseData['error']?.toString() ??
                'Failed to create match';
          } else if (responseData is String) {
            errorMessage = responseData;
          }

          return left(ServerFailure(errorMessage));
        }
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> joinTeam(String matchId, String team) async {
    try {
      final response = await apiService.post(
        endPoint: 'Match/$matchId/join',
        data: {'team': team},
      );

      return right(true);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          dynamic responseData = e.response?.data;
          String errorMessage = 'Team is full or invalid team selection';

          if (responseData is String) {
            errorMessage = responseData;
          } else if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ??
                responseData['error'] ??
                responseData['title'] ??
                responseData.toString();
          } else {
            errorMessage = responseData?.toString() ?? errorMessage;
          }

          if (errorMessage.toLowerCase().contains('already part of') ||
              errorMessage.toLowerCase().contains('already joined') ||
              errorMessage.toLowerCase().contains('already') &&
                  errorMessage.toLowerCase().contains('match')) {
            return right(true);
          }

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
      final response = await apiService.get(endPoint: 'Match/completed');
      if (response is List) {
        final matches =
            response.map((match) => MatchModel.fromJson(match)).toList();
        return right(matches);
      } else {
        return left(ServerFailure('Unexpected response format'));
      }
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> leaveMatch(String matchId) async {
    try {
      final response = await apiService.post(
        endPoint: 'Match/$matchId/leave',
        data: {},
      );

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
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> cancelMatch(String matchId) async {
    try {
      final response = await apiService.post(
        endPoint: 'Match/$matchId/cancel',
        data: {},
      );

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
      final response = await apiService.post(
        endPoint: 'Match/$matchId/invite',
        data: {
          'invitedUserId': invitedUserId,
        },
      );

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
      if (e is DioException) {
        String errorMessage = 'Failed to invite friend';

        if (e.response?.data != null) {
          final responseData = e.response!.data;

          if (responseData is String) {
            errorMessage = responseData;
          } else if (responseData is Map<String, dynamic>) {
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
  Future<Either<Failure, List<MatchInvitationModel>>>
      getMatchInvitations() async {
    try {
      final response =
          await apiService.get(endPoint: 'Match/match/invitations');

      if (response is List) {
        final invitations = response
            .map((invitation) => MatchInvitationModel.fromJson(invitation))
            .toList();
        return right(invitations);
      } else if (response is Map<String, dynamic>) {
        if (response['success'] == true && response['data'] is List) {
          final invitations = (response['data'] as List)
              .map((invitation) => MatchInvitationModel.fromJson(invitation))
              .toList();
          return right(invitations);
        } else if (response['data'] is List) {
          final invitations = (response['data'] as List)
              .map((invitation) => MatchInvitationModel.fromJson(invitation))
              .toList();
          return right(invitations);
        } else {
          String errorMessage = response['message'] ??
              response['error'] ??
              'Failed to load invitations';
          return left(ServerFailure(errorMessage));
        }
      }

      return right([]);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          return left(ServerFailure(
              'No invitations found. The invitation service may be temporarily unavailable.'));
        } else if (e.response?.statusCode == 401) {
          return left(
              ServerFailure('Please log in again to view your invitations.'));
        } else if (e.response?.statusCode == 400) {
          String errorMessage = 'Invalid request. Please try again.';
          if (e.response?.data != null) {
            final responseData = e.response!.data;
            if (responseData is String) {
              errorMessage = responseData;
            } else if (responseData is Map<String, dynamic>) {
              errorMessage = responseData['message'] ??
                  responseData['error'] ??
                  responseData['title'] ??
                  errorMessage;
            }
          }
          return left(ServerFailure(errorMessage));
        }

        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(
          'Unable to load invitations. Please check your internet connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, String>> respondToInvitation(
      String matchId, bool accept) async {
    try {
      final response = await apiService.post(
        endPoint: 'Match/$matchId/respond-invitation',
        data: {
          'accept': accept,
        },
      );

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
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          return left(
              ServerFailure('Invitation not found or already expired.'));
        } else if (e.response?.statusCode == 401) {
          return left(
              ServerFailure('Please log in again to respond to invitations.'));
        } else if (e.response?.statusCode == 409) {
          return left(
              ServerFailure('This invitation has already been responded to.'));
        } else if (e.response?.statusCode == 400) {
          String errorMessage =
              'Invalid invitation response. Please try again.';
          if (e.response?.data != null) {
            final responseData = e.response!.data;
            if (responseData is String) {
              errorMessage = responseData;
            } else if (responseData is Map<String, dynamic>) {
              errorMessage = responseData['message'] ??
                  responseData['error'] ??
                  responseData['title'] ??
                  errorMessage;
            }
          }
          return left(ServerFailure(errorMessage));
        }

        String errorMessage = 'Failed to respond to invitation';
        if (e.response?.data != null) {
          final responseData = e.response!.data;
          if (responseData is String) {
            errorMessage = responseData;
          } else if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ??
                responseData['error'] ??
                responseData['title'] ??
                'Failed to respond to invitation';
          }
        }

        return left(ServerFailure(errorMessage));
      }
      return left(ServerFailure(
          'Unable to respond to invitation. Please check your internet connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, String>> kickPlayer(
      String matchId, int playerId) async {
    try {
      final response = await apiService.post(
        endPoint: 'Match/$matchId/kick/$playerId',
        data: {},
      );

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
      if (e is DioException) {
        String errorMessage = 'Failed to kick player';

        if (e.response?.data != null) {
          final responseData = e.response!.data;

          if (responseData is String) {
            errorMessage = responseData;
          } else if (responseData is Map<String, dynamic>) {
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

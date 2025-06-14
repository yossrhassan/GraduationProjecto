// player_matching/presentation/cubit/matches_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';
import 'package:graduation_project/features/player_matching/data/models/match_invitation_model.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';

class MatchesCubit extends Cubit<MatchesState> {
  final MatchesRepository matchesRepository;

  MatchesCubit(this.matchesRepository) : super(MatchesInitial());

  Future<void> getAvailableMatches({int? sportTypeId}) async {
    emit(MatchesLoading());
    try {
      final result =
          await matchesRepository.getAvailableMatches(sportTypeId: sportTypeId);

      result.fold((failure) => emit(MatchesError(failure.errMessage)),
          (matches) => emit(AvailableMatchesLoaded(matches)));
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> getSports() async {
    try {
      final result = await matchesRepository.getSports();

      result.fold(
        (failure) => emit(MatchesError(failure.errMessage)),
        (sports) => emit(SportsLoaded(sports)),
      );
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> getMyMatches() async {
    print('CUBIT: Starting getMyMatches()');
    emit(MatchesLoading());
    try {
      final result = await matchesRepository.getMyMatches();

      result.fold((failure) {
        print('CUBIT: getMyMatches failed: ${failure.errMessage}');
        emit(MatchesError(failure.errMessage));
      }, (matches) {
        print('CUBIT: getMyMatches succeeded with ${matches.length} matches');
        emit(MyMatchesLoaded(matches));
      });
    } catch (e) {
      print('CUBIT: getMyMatches exception: $e');
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> getMatchDetails(String matchId) async {
    emit(MatchesLoading());

    try {
      final result = await matchesRepository.getMatchDetails(matchId);

      result.fold(
        (failure) => emit(MatchesError(failure.errMessage)),
        (match) => emit(MatchDetailsLoaded(match)),
      );
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> createMatch(Map<String, dynamic> matchData) async {
    emit(MatchesLoading());
    try {
      final result = await matchesRepository.createMatch(matchData);

      result.fold((failure) {
        emit(MatchesError(failure.errMessage));
        throw failure.errMessage;
      }, (match) {
        getAvailableMatches();
        getMyMatches();
        return match;
      });
    } catch (e) {
      emit(MatchesError(e.toString()));
      throw e;
    }
  }

  Future<void> joinTeam(String matchId, String team) async {
    try {
      print('CUBIT: Attempting to join match $matchId, team $team');
      final result = await matchesRepository.joinTeam(matchId, team);

      result.fold(
        (failure) {
          print('CUBIT: Join team failed: ${failure.errMessage}');
          emit(MatchesError(failure.errMessage));
        },
        (success) {
          print('CUBIT: Join successful, refreshing match details and lists');
          getMatchDetails(matchId);

          getAvailableMatches();
          getMyMatches();
        },
      );
    } catch (e) {
      print('CUBIT: Join team exception: $e');
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> getCompletedMatches() async {
    emit(MatchesLoading());
    try {
      final result = await matchesRepository.getCompletedMatches();
      result.fold((failure) {
        emit(MatchesError(failure.errMessage));
      }, (matches) {
        emit(CompletedMatchesLoaded(matches));
      });
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> leaveMatch(String matchId) async {
    try {
      print('CUBIT: Attempting to leave match $matchId');
      final result = await matchesRepository.leaveMatch(matchId);

      result.fold(
        (failure) {
          print('CUBIT: Leave match failed: ${failure.errMessage}');
          emit(MatchesError(failure.errMessage));
        },
        (message) {
          print('CUBIT: Leave match successful: $message');

          getMatchDetails(matchId);
          getAvailableMatches();
          getMyMatches();
        },
      );
    } catch (e) {
      print('CUBIT: Leave match exception: $e');
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> cancelMatch(String matchId) async {
    try {
      final result = await matchesRepository.cancelMatch(matchId);

      result.fold(
        (failure) {
          emit(MatchesError(failure.errMessage));
          throw failure.errMessage;
        },
        (message) {
          getMatchDetails(matchId);
          getAvailableMatches();
          getMyMatches();
          return message;
        },
      );
    } catch (e) {
      emit(MatchesError(e.toString()));
      throw e;
    }
  }

  Future<void> inviteFriend(String matchId, int invitedUserId) async {
    try {
      final result =
          await matchesRepository.inviteFriend(matchId, invitedUserId);

      result.fold(
        (failure) {
          emit(MatchesError(failure.errMessage));
          throw failure.errMessage;
        },
        (message) {
          return message;
        },
      );
    } catch (e) {
      emit(MatchesError(e.toString()));
      throw e;
    }
  }

  Future<void> getMatchInvitations({int retryCount = 0}) async {
    if (retryCount == 0) {
      emit(MatchesLoading());
    }

    try {
      final result = await matchesRepository.getMatchInvitations();

      result.fold(
        (failure) {
          if (retryCount < 2 &&
              (failure.errMessage.toLowerCase().contains('connection') ||
                  failure.errMessage.toLowerCase().contains('timeout') ||
                  failure.errMessage.toLowerCase().contains('network'))) {
            print('Retrying getMatchInvitations (attempt ${retryCount + 1})');
            Future.delayed(const Duration(seconds: 2), () {
              getMatchInvitations(retryCount: retryCount + 1);
            });
          } else {
            emit(MatchesError(failure.errMessage));
          }
        },
        (invitations) {
          print('Successfully loaded ${invitations.length} invitations');
          emit(MatchInvitationsLoaded(invitations));
        },
      );
    } catch (e) {
      print('Exception in getMatchInvitations: $e');
      emit(MatchesError('Unexpected error occurred. Please try again.'));
    }
  }

  Future<void> respondToInvitation(String matchId, bool accept) async {
    List<MatchInvitationModel> currentInvitations = [];
    if (state is MatchInvitationsLoaded) {
      currentInvitations =
          List.from((state as MatchInvitationsLoaded).invitations);
    }

    currentInvitations
        .removeWhere((invitation) => invitation.matchId.toString() == matchId);

    emit(MatchInvitationsLoaded(currentInvitations));

    try {
      final result =
          await matchesRepository.respondToInvitation(matchId, accept);

      result.fold(
        (failure) {
          print('Failed to respond to invitation: ${failure.errMessage}');
        },
        (message) {
          print('Successfully responded to invitation: $message');
        },
      );
    } catch (e) {
      print('Exception responding to invitation: $e');
    }
  }

  Future<void> kickPlayer(String matchId, int playerId) async {
    try {
      final result = await matchesRepository.kickPlayer(matchId, playerId);

      result.fold(
        (failure) {
          emit(MatchesError(failure.errMessage));
          throw failure.errMessage;
        },
        (message) {
          getMatchDetails(matchId);
          getAvailableMatches();
          getMyMatches();
          return message;
        },
      );
    } catch (e) {
      emit(MatchesError(e.toString()));
      throw e;
    }
  }
}

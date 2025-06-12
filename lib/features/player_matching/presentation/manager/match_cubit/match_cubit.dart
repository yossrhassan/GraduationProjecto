// player_matching/presentation/cubit/matches_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';
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
    print('🔍 CUBIT: Starting getMyMatches()');
    emit(MatchesLoading());
    try {
      final result = await matchesRepository.getMyMatches();

      result.fold((failure) {
        print('🔍 CUBIT: getMyMatches failed: ${failure.errMessage}');
        emit(MatchesError(failure.errMessage));
      }, (matches) {
        print(
            '🔍 CUBIT: getMyMatches succeeded with ${matches.length} matches');
        emit(MyMatchesLoaded(matches));
      });
    } catch (e) {
      print('🔍 CUBIT: getMyMatches exception: $e');
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
        // After successful creation, refresh both available and my matches
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
      print('🔍 CUBIT: Attempting to join match $matchId, team $team');
      final result = await matchesRepository.joinTeam(matchId, team);

      result.fold(
        (failure) {
          print('🔍 CUBIT: Join team failed: ${failure.errMessage}');
          emit(MatchesError(failure.errMessage));
        },
        (success) {
          // After successful join (or already joined), refresh match details and lists
          print(
              '🔍 CUBIT: Join successful, refreshing match details and lists');
          getMatchDetails(matchId);
          // Also refresh the matches lists since filtering will change
          getAvailableMatches();
          getMyMatches();
        },
      );
    } catch (e) {
      print('🔍 CUBIT: Join team exception: $e');
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
}

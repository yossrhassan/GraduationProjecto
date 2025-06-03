// player_matching/presentation/cubit/matches_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';

class MatchesCubit extends Cubit<MatchesState> {
  final MatchesRepository matchesRepository;

  MatchesCubit(this.matchesRepository) : super(MatchesInitial());

  Future<void> getAvailableMatches() async {
    emit(MatchesLoading());
    try {
      final result = await matchesRepository.getAvailableMatches();

      result.fold((failure) => emit(MatchesError(failure.errMessage)),
          (matches) => emit(AvailableMatchesLoaded(matches)));
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> getMyMatches() async {
    emit(MatchesLoading());
    try {
      final result = await matchesRepository.getMyMatches();

      result.fold((failure) => emit(MatchesError(failure.errMessage)),
          (matches) => emit(MyMatchesLoaded(matches)));
    } catch (e) {
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
    emit(MatchesLoading());
    try {
      final result = await matchesRepository.joinTeam(matchId, team);

      result.fold(
        (failure) => emit(MatchesError(failure.errMessage)),
        (success) {
          // After successful join, refresh match details
          getMatchDetails(matchId);
          // Also refresh available and my matches
          getAvailableMatches();
          getMyMatches();
        },
      );
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }
}

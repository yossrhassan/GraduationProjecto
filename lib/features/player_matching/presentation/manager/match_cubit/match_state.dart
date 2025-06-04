// player_matching/presentation/cubit/matches_state.dart

import 'package:graduation_project/features/player_matching/data/models/match_model.dart';

abstract class MatchesState {}

class MatchesInitial extends MatchesState {}

class MatchesLoading extends MatchesState {}

class AvailableMatchesLoaded extends MatchesState {
  final List<MatchModel> matches;

  AvailableMatchesLoaded(this.matches);
}

class MyMatchesLoaded extends MatchesState {
  final List<MatchModel> matches;

  MyMatchesLoaded(this.matches);
}

class MatchDetailsLoaded extends MatchesState {
  final MatchModel match;

  MatchDetailsLoaded(this.match);
}

class MatchesError extends MatchesState {
  final String message;

  MatchesError(this.message);
}

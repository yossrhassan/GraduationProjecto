// player_matching/data/repositories/matches_repository.dart
import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:graduation_project/features/player_matching/data/models/sport_model.dart';

abstract class MatchesRepository {
  Future<Either<Failure, List<MatchModel>>> getAvailableMatches(
      {int? sportTypeId});
  Future<Either<Failure, List<MatchModel>>> getMyMatches();
  Future<Either<Failure, MatchModel>> getMatchDetails(String matchId);
  Future<Either<Failure, bool>> createMatch(Map<String, dynamic> matchData);
  Future<Either<Failure, bool>> joinTeam(String matchId, String team);
  Future<Either<Failure, List<SportModel>>> getSports();
}

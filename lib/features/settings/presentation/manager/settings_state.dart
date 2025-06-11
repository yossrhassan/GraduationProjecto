import 'package:equatable/equatable.dart';
import 'package:graduation_project/features/settings/data/models/user_model.dart';

abstract class SettingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserModel user;

  SettingsLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

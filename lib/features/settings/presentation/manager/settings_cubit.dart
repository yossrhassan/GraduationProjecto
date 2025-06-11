import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_state.dart';
import 'package:graduation_project/features/settings/data/repos/settings_repo.dart';
import 'package:graduation_project/features/settings/data/models/user_model.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepo settingsRepo;

  SettingsCubit(this.settingsRepo) : super(SettingsInitial());

  Future<void> loadUserProfile(int userId) async {
    emit(SettingsLoading());

    try {
      final user = await settingsRepo.fetchUserProfile(userId);
      emit(SettingsLoaded(user));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}

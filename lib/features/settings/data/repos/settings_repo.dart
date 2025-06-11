import 'package:graduation_project/features/settings/data/models/user_model.dart';
import 'package:graduation_project/features/settings/data/repos/user_service.dart';

class SettingsRepo {
  final UserService userService;

  SettingsRepo(this.userService);

  Future<UserModel> fetchUserProfile(int userId) async {
    return await userService.getUserProfile(userId);
  }
}

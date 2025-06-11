import 'package:graduation_project/core/utils/api_service.dart';

class DeleteAccountService {
  final ApiService _apiService;

  DeleteAccountService(this._apiService);

  Future<void> deleteAccount() async {
    try {
      await _apiService.post(
        endPoint: 'account/delete',
        data: {}, // أو null حسب ما يتطلب الـ API
      );
      print('✅ Account deletion successful.');
    } catch (e) {
      print('❌ Account deletion failed: $e');
      rethrow;
    }
  }
}

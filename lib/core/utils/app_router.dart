import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/features/booking/data/repos/booking_repo.dart';
import 'package:graduation_project/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/booking_view.dart';
import 'package:graduation_project/features/booking_history/data/repos/booking_history_repo.dart';
import 'package:graduation_project/features/booking_history/presentation/manager/booking_history_cubit/booking_history_cubit.dart';
import 'package:graduation_project/features/booking_history/presentation/views/booking_history_view.dart';
import 'package:graduation_project/features/facilities/data/models/facilities/facilities.model.dart';
import 'package:graduation_project/features/facilities/presentation/views/facilities_view.dart';
import 'package:graduation_project/features/home/presentation/views/home_view.dart';
import 'package:graduation_project/features/login/presentation/views/login_view.dart';
import 'package:graduation_project/features/register/presentation/views/register_view.dart';
import 'package:graduation_project/features/settings/data/repos/settings_repo.dart';
import 'package:graduation_project/features/settings/presentation/manager/settings_cubit.dart';
import 'package:graduation_project/features/settings/presentation/views/change_password_view.dart';
import 'package:graduation_project/features/settings/presentation/views/delete_account_view.dart';
import 'package:graduation_project/features/settings/presentation/views/edit_profile_view.dart';
import 'package:graduation_project/features/splash/presentation/views/splash_view.dart';
import 'package:get_it/get_it.dart';
import 'package:graduation_project/features/settings/presentation/views/settings_view.dart';
import 'package:graduation_project/core/utils/service_locator.dart';

abstract class AppRouter {
  static const kFacilitiesView = '/facilitiesView';
  static const kBookingView = '/bookingView';
  static const kLoginView = '/loginView';
  static const kRegisterView = '/registerView';
  static const kHomeView = '/homeView';
  static const kBookingHistoryView = '/bookingHistoryView';
  static const kSettingsView = '/settingsView';
  static const kEditProfileView = '/editProfileView';
  static const kChangePasswordView = '/changePasswordView';
  static const kDeleteAccountView = '/deleteAccountView';

  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: kLoginView,
        builder: (context, state) {
          final isAuthenticated = AuthManager.isAuthenticated;
          return isAuthenticated ? const HomeView() : const LoginView();
        },
      ),
      GoRoute(
        path: kLoginView,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: kRegisterView,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: kFacilitiesView,
        builder: (context, state) => const FacilitiesView(),
      ),
      GoRoute(
        path: kBookingView,
        builder: (context, state) => BlocProvider(
          // Get the BookingRepo from the service locator
          create: (context) => BookingCubit(GetIt.instance<BookingRepo>()),
          child: BookingView(
            facilitiesModel: state.extra as FacilitiesModel,
          ),
        ),
      ),
      GoRoute(
        path: kBookingHistoryView,
        builder: (context, state) => BlocProvider(
          // Get the BookingRepo from the service locator
          create: (context) =>
              BookingHistoryCubit(GetIt.instance<BookingHistoryRepo>()),
          child: const BookingHistoryView(),
        ),
      ),
      GoRoute(
        path: kHomeView,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: kSettingsView,
        name: 'settings',
        builder: (context, state) => BlocProvider(
          create: (context) => SettingsCubit(getIt.get<SettingsRepo>()),
          child: const SettingsView(),
        ),
      ),
      GoRoute(
        path: kEditProfileView,
        name: 'editProfile',
        builder: (context, state) => const EditProfileView(),
      ),
      GoRoute(
        path: kChangePasswordView,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordView(),
      ),
      GoRoute(
        path: kDeleteAccountView,
        name: 'delete-account',
        builder: (context, state) => const DeleteAccountView(),
      ),
    ],
  );
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/features/booking/data/repos/booking_repo.dart';
import 'package:graduation_project/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/booking_view.dart';
import 'package:graduation_project/features/booking_history/data/repos/booking_history_repo.dart';
import 'package:graduation_project/features/booking_history/presentation/manager/booking_history_cubit/booking_history_cubit.dart';
import 'package:graduation_project/features/booking_history/presentation/views/booking_history_view.dart';
import 'package:graduation_project/features/chat_bot/chat_bot_view.dart';
import 'package:graduation_project/features/facilities/data/models/facilities/facilities.model.dart';
import 'package:graduation_project/features/facilities/presentation/views/facilities_view.dart';
import 'package:graduation_project/features/home/presentation/views/home_view.dart';
import 'package:graduation_project/features/home/presentation/views/main_navigation_view.dart';
import 'package:graduation_project/features/home/presentation/views/notifications_view.dart';
import 'package:graduation_project/features/login/presentation/views/login_view.dart';
import 'package:graduation_project/features/login/presentation/views/forgot_password_view.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/views/match_details_view.dart';
import 'package:graduation_project/features/player_matching/presentation/views/matche_creation_view.dart';
import 'package:graduation_project/features/player_matching/presentation/views/matches_view.dart';
import 'package:graduation_project/features/player_matching/presentation/views/player_profile_view.dart';
import 'package:graduation_project/features/player_matching/data/models/player_model.dart';
import 'package:graduation_project/features/register/presentation/views/register_view.dart';
import 'package:graduation_project/features/settings/data/repos/settings_repo.dart';
import 'package:graduation_project/features/settings/presentation/manager/settings_cubit.dart';
import 'package:graduation_project/features/settings/presentation/views/change_password_view.dart';
import 'package:graduation_project/features/settings/presentation/views/delete_account_view.dart';
import 'package:graduation_project/features/settings/presentation/views/edit_profile_view.dart';
import 'package:graduation_project/features/settings/presentation/views/profile_view.dart';
import 'package:graduation_project/features/settings/data/models/user_model.dart';
import 'package:graduation_project/features/splash/presentation/views/splash_view.dart';
import 'package:get_it/get_it.dart';
import 'package:graduation_project/features/settings/presentation/views/settings_view.dart';
import 'package:graduation_project/core/utils/service_locator.dart';

abstract class AppRouter {
  static const kFacilitiesView = '/facilitiesView';
  static const kBookingView = '/bookingView';
  static const kLoginView = '/loginView';
  static const kRegisterView = '/registerView';
  static const kForgotPasswordView = '/forgotPasswordView';
  static const kNotificationsView = '/notificationsView';
  static const kHomeView = '/homeView';
  static const kMainNavigationView = '/mainNavigationView';
  static const kBookingHistoryView = '/bookingHistoryView';
  static const kMatchesView = '/matchesView';
  static const kMatchCreationView = '/matchCreationView';
  static const kMatchDetailsView = '/matchDetailsView';
  static const kChatBotView = '/chatBotView';
  static const kProfileView = '/profileView';
  static const kEditProfileView = '/editProfileView';
  static const kChangePasswordView = '/changePasswordView';
  static const kDeleteAccountView = '/deleteAccountView';
  static const kPlayerProfileView = '/playerProfileView';

  static final router = GoRouter(
    routes: [
      GoRoute(
        path: kMatchesView,
        builder: (context, state) => BlocProvider.value(
          value: GetIt.instance<MatchesCubit>(),
          child: const MatchesView(),
        ),
      ),
      GoRoute(
        path: kMatchCreationView,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  BookingHistoryCubit(GetIt.instance<BookingHistoryRepo>()),
            ),
            BlocProvider.value(
              value: state.extra as MatchesCubit? ??
                  GetIt.instance<MatchesCubit>(),
            ),
          ],
          child: const MatchCreationView(),
        ),
      ),
      GoRoute(
        path: '$kMatchDetailsView/:id',
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;
          return BlocProvider.value(
            value: GetIt.instance<MatchesCubit>(),
            child: MatchDetailsView(
              matchId: state.pathParameters['id']!,
              isCreator: extra['is_creator'] ?? false,
              matchData: extra['match_data'],
              fromMyMatches: extra['from_my_matches'] ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: kLoginView,
        builder: (context, state) {
          final isAuthenticated = AuthManager.isAuthenticated;
          return isAuthenticated
              ? MainNavigationView(extra: state.extra as Map<String, dynamic>?)
              : const LoginView();
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
        path: kForgotPasswordView,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: kNotificationsView,
        builder: (context, state) => const NotificationsView(),
      ),
      GoRoute(
        path: '$kFacilitiesView/:sportId',
        builder: (context, state) {
          final sportId = int.tryParse(state.pathParameters['sportId'] ?? '');
          return FacilitiesView(sportId: sportId);
        },
      ),
      GoRoute(
        path: kBookingView,
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;
          return BlocProvider(
            // Get the BookingRepo from the service locator
            create: (context) => BookingCubit(GetIt.instance<BookingRepo>()),
            child: BookingView(
              facilitiesModel: extra['facility'] as FacilitiesModel,
              sportId: extra['sportId'] as int?,
            ),
          );
        },
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
        builder: (context, state) => MainNavigationView(
          extra: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: kMainNavigationView,
        builder: (context, state) => MainNavigationView(
          extra: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: kChatBotView,
        builder: (context, state) => ChatPage(),
      ),
      GoRoute(
        path: kProfileView,
        builder: (context, state) => BlocProvider(
          create: (context) => SettingsCubit(GetIt.instance<SettingsRepo>()),
          child: const ProfileView(),
        ),
      ),
      GoRoute(
        path: kEditProfileView,
        builder: (context, state) => BlocProvider(
          create: (context) => SettingsCubit(GetIt.instance<SettingsRepo>()),
          child: EditProfileView(
            user: state.extra as UserModel?,
          ),
        ),
      ),
      GoRoute(
        path: kChangePasswordView,
        builder: (context, state) => const ChangePasswordView(),
      ),
      GoRoute(
        path: kDeleteAccountView,
        builder: (context, state) => const DeleteAccountView(),
      ),
      GoRoute(
        path: kPlayerProfileView,
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;
          return PlayerProfileView(
            player: extra['player'] as PlayerModel,
            isCaptain: extra['isCaptain'] as bool,
          );
        },
      ),
    ],
  );
}

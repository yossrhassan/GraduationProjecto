import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/core/utils/service_locator.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/custom_home_button.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/navigation_card.dart';
import 'package:graduation_project/features/player_matching/data/models/sport_model.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/match_invitations_dialog.dart';
import 'package:graduation_project/features/home/presentation/manager/friend_requests_cubit.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with RouteAware {
  List<SportModel> sports = [];
  bool isLoadingSports = true;
  late MatchesRepository matchesRepository;
  late MatchesCubit matchesCubit;
  late FriendRequestsCubit friendRequestsCubit;

  @override
  void initState() {
    super.initState();
    matchesRepository = getIt<MatchesRepository>();
    matchesCubit = getIt<MatchesCubit>();
    friendRequestsCubit = getIt<FriendRequestsCubit>();
    _loadSports();
    _loadInvitations();
    _loadFriendRequests();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshWhenReturning() {
    _loadFriendRequests();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    matchesCubit.getMatchInvitations();
  }

  Future<void> _loadFriendRequests() async {
    friendRequestsCubit.loadReceivedFriendRequests();
  }

  Future<void> _loadSports() async {
    try {
      final result = await matchesRepository.getSports();
      result.fold(
        (failure) {
          print('Failed to load sports: ${failure.errMessage}');
          setState(() {
            isLoadingSports = false;
          });
        },
        (sportsList) {
          setState(() {
            sports = sportsList;
            isLoadingSports = false;
          });
        },
      );
    } catch (e) {
      print('Error loading sports: $e');
      setState(() {
        isLoadingSports = false;
      });
    }
  }

  String? _buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }

    return 'http://10.0.2.2:5000/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final int? currentUserId = AuthManager.userId;
    print('Current user ID: ${AuthManager.userId}');
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: matchesCubit),
        BlocProvider.value(value: friendRequestsCubit),
      ],
      child: Scaffold(
        backgroundColor: kBackGroundColor,
        appBar: AppBar(
          elevation: 0,
          title: const Text("Home",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor)),
          actions: [
            BlocBuilder<MatchesCubit, MatchesState>(
              builder: (context, state) {
                int invitationCount = 0;
                if (state is MatchInvitationsLoaded) {
                  invitationCount = state.invitations.length;
                }

                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mail, color: kPrimaryColor),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => BlocProvider.value(
                            value: getIt<MatchesCubit>(),
                            child: const MatchInvitationsDialog(),
                          ),
                        );
                      },
                    ),
                    if (invitationCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$invitationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            BlocBuilder<FriendRequestsCubit, FriendRequestsState>(
              builder: (context, state) {
                int requestCount = 0;
                if (state is FriendRequestsLoaded) {
                  requestCount = state.receivedRequests.length;
                }

                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.people, color: kPrimaryColor),
                      onPressed: () async {
                        await GoRouter.of(context)
                            .push(AppRouter.kNotificationsView);

                        _refreshWhenReturning();
                      },
                    ),
                    if (requestCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$requestCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: kPrimaryColor),
              onPressed: () {
                GoRouter.of(context).push(AppRouter.kProfileView);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Browse Sports',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoadingSports
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(kPrimaryColor),
                          ),
                        )
                      : sports.isEmpty
                          ? const Center(
                              child: Text(
                                'No sports available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: sports.length,
                              itemBuilder: (context, index) {
                                final sport = sports[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: NavigationCard(
                                    title: "Browse ${sport.name} Courts",
                                    imageUrl: _buildImageUrl(sport.imageUrl),
                                    onTap: () => GoRouter.of(context).push(
                                        '${AppRouter.kFacilitiesView}/${sport.id}'),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

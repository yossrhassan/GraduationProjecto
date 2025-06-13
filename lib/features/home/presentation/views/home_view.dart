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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<SportModel> sports = [];
  bool isLoadingSports = true;
  late MatchesRepository matchesRepository;
  late MatchesCubit matchesCubit;

  @override
  void initState() {
    super.initState();
    matchesRepository = getIt<MatchesRepository>();
    matchesCubit = getIt<MatchesCubit>();
    _loadSports();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    // Load invitations when home view opens
    matchesCubit.getMatchInvitations();
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
      // Return null if no imageUrl provided - will show blank placeholder
      return null;
    }

    // Build full URL with base server URL for API images
    return 'http://10.0.2.2:5000/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final int? currentUserId = AuthManager.userId;
    print('Current user ID: ${AuthManager.userId}');
    return BlocProvider.value(
      value: matchesCubit,
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
            // Match Invitations Icon
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
            IconButton(
              icon: const Icon(Icons.notifications, color: kPrimaryColor),
              onPressed: () {
                GoRouter.of(context).push(AppRouter.kNotificationsView);
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
                // Sports Section Header
                const Text(
                  'Browse Sports',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Sports List - Expanded to fill remaining space
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

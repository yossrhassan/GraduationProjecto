import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/core/utils/service_locator.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/custom_home_button.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/navigation_card.dart';
import 'package:graduation_project/features/player_matching/data/models/sport_model.dart';
import 'package:graduation_project/features/player_matching/data/repos/matches_repo.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<SportModel> sports = [];
  bool isLoadingSports = true;
  late MatchesRepository matchesRepository;

  @override
  void initState() {
    super.initState();
    matchesRepository = getIt<MatchesRepository>();
    _loadSports();
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

  String _getSportImagePath(String sportName) {
    // Use the available football image for all sports as fallback
    // since other sport images are not available in assets
    return 'assets/images/football.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final int? currentUserId = AuthManager.userId;
    print('Current user ID: ${AuthManager.userId}');
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Home",
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor)),
        actions: [
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Sports Section
                const Text(
                  'Browse Sports',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Sports List with fixed height
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.45, // 45% of screen height
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
                                    imageUrl: _getSportImagePath(sport.name),
                                    onTap: () => GoRouter.of(context)
                                        .push(AppRouter.kFacilitiesView),
                                  ),
                                );
                              },
                            ),
                ),
                const SizedBox(height: 20),
                // Quick Actions Section
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Quick Actions Buttons
                CustomHomeButton(
                  icon: Icons.calendar_month,
                  label: "My Bookings",
                  filled: false,
                  onPressed: () {
                    GoRouter.of(context).push(AppRouter.kBookingHistoryView);
                  },
                ),
                const SizedBox(height: 16),
                CustomHomeButton(
                  icon: Icons.people,
                  label: "Player Matching",
                  filled: false,
                  onPressed: () {
                    GoRouter.of(context).push(AppRouter.kMatchesView);
                  },
                ),
                const SizedBox(height: 16),
                CustomHomeButton(
                  icon: Icons.chat_bubble_outline,
                  label: "Chat Bot",
                  filled: false,
                  onPressed: () {
                    GoRouter.of(context).push(AppRouter.kChatBotView);
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

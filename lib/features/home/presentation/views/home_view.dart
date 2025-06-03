import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/custom_home_button.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/navigation_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
            icon: const Icon(Icons.logout, color: kPrimaryColor),
            onPressed: () async {
              await AuthManager.clearUserId();
              await AuthManager.clearAuthToken();
              if (context.mounted) {
                GoRouter.of(context).push(AppRouter.kLoginView);
              }
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
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return NavigationCard(
                      title: "Browse Football Courts ",
                      imageUrl: "assets/images/football.jpg",
                      onTap: () =>
                          GoRouter.of(context).push(AppRouter.kFacilitiesView),
                    );
                  },
                  itemCount: 3,
                ),
              ),
              CustomHomeButton(
                icon: Icons.calendar_month,
                label: "My Bookings",
                filled: false,
                onPressed: () {
                  GoRouter.of(context).push(AppRouter.kBookingHistoryView);
                },
              ),
              const SizedBox(
                height: 30,
              ),
              CustomHomeButton(
                icon: Icons.calendar_month,
                label: "player matching",
                filled: false,
                onPressed: () {
                  GoRouter.of(context).push(AppRouter.kMatchesView);
                },
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}

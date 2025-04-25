import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/custom_home_button.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/navigation_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text("Home", style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold,color: Colors.white)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: "Tournaments"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Favorites"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
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
              const SizedBox(height: 20),
              CustomHomeButton(
                icon: Icons.access_time,
                label: "Search for Courts by Time",
                filled: true,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              CustomHomeButton(
                icon: Icons.calendar_month,
                label: "My Bookings",
                filled: false,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
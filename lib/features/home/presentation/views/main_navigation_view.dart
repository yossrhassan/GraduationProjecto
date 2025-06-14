import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/features/booking_history/data/repos/booking_history_repo.dart';
import 'package:graduation_project/features/booking_history/presentation/manager/booking_history_cubit/booking_history_cubit.dart';
import 'package:graduation_project/features/booking_history/presentation/views/booking_history_view.dart';
import 'package:graduation_project/features/chat_bot/chat_bot_view.dart';
import 'package:graduation_project/features/home/presentation/views/home_view.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/views/matches_view.dart';

class MainNavigationView extends StatefulWidget {
  final int initialIndex;
  final Map<String, dynamic>? extra;

  const MainNavigationView({
    super.key,
    this.initialIndex = 0,
    this.extra,
  });

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    final extraIndex = widget.extra?['initial_index'] as int?;
    _currentIndex = extraIndex ?? widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          _onTabTapped(0);
          return false; // Don't pop the route
        }

        return true;
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            // Home Tab
            const HomeView(),

            // My Bookings Tab
            BlocProvider(
              create: (context) =>
                  BookingHistoryCubit(GetIt.instance<BookingHistoryRepo>()),
              child: const BookingHistoryView(),
            ),

            // Player Matching Tab
            BlocProvider.value(
              value: GetIt.instance<MatchesCubit>(),
              child: const MatchesView(),
            ),

            // Chat Bot Tab
            ChatPage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black,
            selectedItemColor: kPrimaryColor,
            unselectedItemColor: Colors.grey,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                activeIcon: Icon(Icons.home, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                activeIcon: Icon(Icons.calendar_month, size: 28),
                label: 'My Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                activeIcon: Icon(Icons.people, size: 28),
                label: 'Player Matching',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble, size: 28),
                label: 'Chat Bot',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

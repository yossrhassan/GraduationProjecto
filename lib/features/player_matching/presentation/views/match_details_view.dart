import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_cubit.dart';
import 'package:graduation_project/features/player_matching/presentation/manager/match_cubit/match_state.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/details_tab.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/manage_tab.dart';
import 'package:graduation_project/features/player_matching/data/models/match_model.dart';
import 'package:intl/intl.dart';

// In match_details_view.dart
class MatchDetailsView extends StatefulWidget {
  final String matchId;
  final bool isCreator;
  final MatchModel? matchData;

  const MatchDetailsView({
    Key? key,
    required this.matchId,
    required this.isCreator,
    this.matchData,
  }) : super(key: key);

  @override
  State<MatchDetailsView> createState() => _MatchDetailsViewState();
}

class _MatchDetailsViewState extends State<MatchDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

// Update in the initState method
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });

    // If we have match data passed from the list, emit it directly
    if (widget.matchData != null) {
      context.read<MatchesCubit>().emit(MatchDetailsLoaded(widget.matchData!));
    } else {
      // Fallback to API call if no data passed
      context.read<MatchesCubit>().getMatchDetails(widget.matchId);
    }
  }

  // Rest of the class remains the same...
  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: BlocBuilder<MatchesCubit, MatchesState>(
          builder: (context, state) {
            if (state is MatchDetailsLoaded) {
              final match = state.match;

              // Defensive date formatting
              String formattedDate = 'Date not set';
              if (state.match.date.isNotEmpty) {
                try {
                  final date = DateTime.parse(state.match.date);
                  formattedDate = DateFormat('EEEE, MMMM d, y').format(date);
                } catch (e) {
                  formattedDate = 'Invalid date';
                }
              }

              // Defensive time formatting
              String formattedTime = 'Time not set';
              if (state.match.startTime.isNotEmpty &&
                  state.match.endTime.isNotEmpty) {
                try {
                  final start = state.match.startTime.substring(0, 5);
                  final end = state.match.endTime.substring(0, 5);
                  formattedTime = '$start - $end';
                } catch (e) {
                  formattedTime = 'Invalid time';
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            } else if (state is MatchesLoading) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            } else if (state is MatchesError) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error loading match',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            } else {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date not set',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Time not set',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            }
          },
        ),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'UPDATES'),
            Tab(text: 'DETAILS'),
            Tab(text: 'MANAGE'),
          ],
          labelColor: Colors.white,
        ),
        elevation: 0,
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // Updates Tab
          const Center(
              child: Text('Updates content here',
                  style: TextStyle(color: Colors.white))),

          // Details Tab (Teams)
          DetailsTab(
            isCreator: widget.isCreator,
            matchData: widget.matchData,
          ),

          // Manage Tab
          const ManageTab(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/divider.dart';
import 'package:graduation_project/features/player_matching/presentation/views/widgets/manage_action.dart';

class ManageTab extends StatelessWidget {
  const ManageTab({super.key});

  @override
  Widget build (BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // First Row of Actions
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ManageAction(
                  icon: Icons.person_add,
                  label: 'ADD/REMOVE\nGUESTS',
                  onTap: () {},
                ),
                const CustomDivider(),
                ManageAction(
                  icon: Icons.navigation,
                  label: 'GET DIRECTIONS\nTO MATCH',
                  onTap: () {},
                ),
                const CustomDivider(),
                ManageAction(
                  icon: Icons.notifications_off,
                  label: 'TURN\nNOTIFICATIONS\nOFF',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Second Row of Actions
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ManageAction(
                  icon: Icons.check_circle,
                  label: 'MARK PITCH AS\nRESERVED',
                  onTap: () {},
                ),
               const CustomDivider(),
                ManageAction(
                  icon: Icons.edit,
                  label: 'EDIT MATCH',
                  onTap: () {},
                ),
                const CustomDivider(),
                ManageAction(
                  icon: Icons.delete,
                  label: 'CANCEL MATCH',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Delete Match Button
        ],
      ),
    );
  }
}

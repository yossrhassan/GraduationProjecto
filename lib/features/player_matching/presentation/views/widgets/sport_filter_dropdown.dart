import 'package:flutter/material.dart';
import 'package:graduation_project/features/player_matching/data/models/sport_model.dart';

class SportFilterDropdown extends StatelessWidget {
  final List<SportModel> sports;
  final SportModel? selectedSport;
  final Function(SportModel?) onSportChanged;
  final bool isLoading;

  const SportFilterDropdown({
    Key? key,
    required this.sports,
    required this.selectedSport,
    required this.onSportChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: isLoading
          ? const SizedBox(
              height: 48.0,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<SportModel?>(
                isExpanded: true,
                value: selectedSport,
                hint: const Text(
                  'Filter by sport type',
                  style: TextStyle(color: Colors.grey),
                ),
                dropdownColor: Colors.grey[800],
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(color: Colors.white),
                onChanged: onSportChanged,
                items: [
                  const DropdownMenuItem<SportModel?>(
                    value: null,
                    child: Text(
                      'All Sports',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ...sports.map((sport) => DropdownMenuItem<SportModel?>(
                        value: sport,
                        child: Text(
                          sport.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}

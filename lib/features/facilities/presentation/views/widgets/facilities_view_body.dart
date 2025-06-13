import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:graduation_project/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';
import 'package:graduation_project/features/facilities/presentation/views/widgets/facilities_list_view.dart';
import 'package:graduation_project/features/facilities/presentation/manager/facilities_cubit/facilities_cubit.dart';

class FacilitiesViewBody extends StatelessWidget {
  FacilitiesViewBody({
    super.key,
    this.sportId,
  });

  final int? sportId;

  final Color lighterColor = Color.lerp(kPrimaryColor, Colors.black, 0.5)!;

  @override
  Widget build(BuildContext context) {
    // Trigger facilities and cities fetch when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<FacilitiesCubit>();
      cubit.fetchCities(); // Fetch cities first
      if (sportId != null) {
        cubit.fetchFacilities(sportId: sportId);
      } else {
        cubit.fetchFacilities();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Facilities',
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(color: kBackGroundColor),
        child: Padding(
          padding: const EdgeInsets.only(top: 90, right: 20, left: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: BlocBuilder<FacilitiesCubit, FacilitiesState>(
                  builder: (context, state) {
                    final cubit = context.read<FacilitiesCubit>();

                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: cubit.selectedCity,
                        hint: const Text(
                          'Select City',
                          style: TextStyle(color: Color(0xff7E807B)),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: kPrimaryColor,
                        ),
                        isExpanded: true,
                        dropdownColor: kBackGroundColor,
                        style: const TextStyle(color: kPrimaryColor),
                        items: cubit.cities.map((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(
                              city,
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          cubit.selectCity(newValue);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              FacilitiesListView(sportId: sportId)
            ],
          ),
        ),
      ),
    );
  }
}

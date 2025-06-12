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
    // Trigger facilities fetch with sport filter when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sportId != null) {
        context.read<FacilitiesCubit>().fetchFacilities(sportId: sportId);
      } else {
        context.read<FacilitiesCubit>().fetchFacilities();
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              color: kPrimaryColor,
            ),
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                FontAwesomeIcons.circleUser,
                color: kPrimaryColor,
              ))
        ],
        // backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
            // gradient: RadialGradient(
            //   center: Alignment.topLeft,
            //   radius: 0.7,
            //   colors: [
            //     lighterColor,
            //     lighterColor,
            //     lighterColor,
            //     Colors.black, // Darker outer area
            //   ],
            // ),
            color: kBackGroundColor),
        child: Padding(
          padding: const EdgeInsets.only(top: 90, right: 20, left: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const CustomTextField.CustomformTextField(
                height: 40,
                hintText: 'Search Court',
                prefixicon: Icon(
                  Icons.search,
                  color: kPrimaryColor,
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

import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:graduation_project/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';
import 'package:graduation_project/features/facilities/presentation/views/widgets/facilities_list_view.dart';

class FacilitiesViewBody extends StatelessWidget {
  FacilitiesViewBody({
    super.key,
  });

  final Color lighterColor = Color.lerp(kPrimaryColor, Colors.black, 0.5)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text(
          'Facilities',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon:const Icon(
              Icons.notifications,
              color: kPrimaryColor,
            ),
          ),
          IconButton(onPressed: () {}, icon:const Icon(FontAwesomeIcons.circleUser))
        ],
        // backgroundColor: Colors.transparent,
        backgroundColor: kPrimaryColor,
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
          color: kBackGroundColor
        ),
        child: const Padding(
          padding:  EdgeInsets.only(top: 90, right: 20, left: 20),
          child: Column(
            children: [
              SizedBox(height: 20,),
              CustomTextField.CustomformTextField(
                height: 40,
                hintText: 'Search Court',
                prefixicon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
             SizedBox(
                height: 20,
              ),
              FacilitiesListView()
            ],
          ),
        ),
      ),
    );
  }
}

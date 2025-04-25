import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/booking/presentation/views/booking_view.dart';
import 'package:graduation_project/features/facilities/data/models/facilities/facilities.model.dart';
import 'package:graduation_project/features/facilities/presentation/views/widgets/description_facilities_tile.dart';

// cached network image
class FacilitiesTile extends StatelessWidget {
  const FacilitiesTile({
    super.key, required this.facilitiesModel,
  });

 final FacilitiesModel facilitiesModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (BuildContext context) {
        //   return const BookingView();
        // }));
        GoRouter.of(context).push(AppRouter.kBookingView);
      },
      child: Container(
        decoration: BoxDecoration(
            color: kBackGroundColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                'http://10.0.2.2:5000/${facilitiesModel.imageUrl!}',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            DescriptionFacilitiesTile(facilitiesModel:facilitiesModel ,),
          ],
        ),
      ),
    );
  }
}

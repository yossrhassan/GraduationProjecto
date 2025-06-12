import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:graduation_project/features/booking/data/repos/courts_repo.dart';
import 'package:graduation_project/features/booking/presentation/manager/booking_cubit/courts_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/booking_view_body.dart';
import 'package:graduation_project/features/facilities/data/models/facilities/facilities.model.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key, required this.facilitiesModel, this.sportId});
  final FacilitiesModel facilitiesModel;
  final int? sportId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourtsCubit(GetIt.instance<CourtsRepo>())
        ..fetchCourtsByFacilityId(facilitiesModel.id!, sportId: sportId),
      child: BookingViewBody(
        facilitiesModel: facilitiesModel,
        sportId: sportId,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/custom_error_widget.dart';
import 'package:graduation_project/core/widgets/custom_loading_indicator.dart';
import 'package:graduation_project/features/facilities/presentation/manager/facilities_cubit/facilities_cubit.dart';
import 'package:graduation_project/features/facilities/presentation/views/widgets/facilities_tile.dart';

class FacilitiesListView extends StatelessWidget {
  const FacilitiesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FacilitiesCubit, FacilitiesState>(
      builder: (context, state) {
        if (state is FacilitiesSuccess) {
          return Expanded(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                physics:  BouncingScrollPhysics(),
                itemCount: state.facilities.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:const EdgeInsets.only(bottom: 20),
                    child: FacilitiesTile(facilitiesModel: state.facilities[index],),
                  );
                }),
          );
        } else if (state is FacilitiesFailure) {
          return CustomErrorWidget(errMessage: state.errMessage);
        } else {
          return const CustomLoadingIndicator();
        }
      },
    );
  }
}

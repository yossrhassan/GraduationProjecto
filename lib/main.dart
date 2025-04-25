import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/auth_manager.dart';
import 'package:graduation_project/core/utils/service_locator.dart';
import 'package:graduation_project/features/facilities/data/repos/facilities_repo_impl.dart';
import 'package:graduation_project/features/facilities/presentation/manager/facilities_cubit/facilities_cubit.dart';
import 'package:graduation_project/features/splash/presentation/views/splash_view.dart';

void main() async {
  setup();
  WidgetsFlutterBinding.ensureInitialized();
  await AuthManager.loadAuthToken();

  runApp(const GraduationProject());
}

class GraduationProject extends StatelessWidget {
  const GraduationProject({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FacilitiesCubit(getIt.get<FacilitiesRepoImpl>())
            ..fetchFacilities(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: kPrimaryColor,
            textTheme:
                GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/assets.dart';
import 'package:graduation_project/features/login/presentation/views/login_view.dart';
import 'package:graduation_project/features/splash/presentation/views/widgets/sliding_text.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> slidingAnimation;

  @override
  void initState() {
    super.initState();

    initSlidingAnimation();

    navigateToHome();
  }


  @override
  void dispose() {
    super.dispose();

    animationController.dispose();
  }

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Background Image
      Positioned.fill(
        child: Image.asset(
          AssetsData.backgroundImage, 
          fit: BoxFit.cover,
        ),
      ),
      
      // Foreground Content
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(AssetsData.logo),
            const SizedBox(height: 14),
            SlidingText(slidingAnimation: slidingAnimation),
          ],
        ),
      ),
    ],
  );
}

  void initSlidingAnimation() {
    animationController =
        AnimationController(vsync: this, duration:const Duration(seconds: 1));

    slidingAnimation = Tween<Offset>(begin:const Offset(0, 2), end: Offset.zero)
        .animate(animationController);

    animationController.forward();
  }




    void navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      // Get.to(() => const LoginView(), transition: Transition.fade ,duration: kTransitionDuration);
      GoRouter.of(context).push(AppRouter.kLoginView);
    });
  }

}

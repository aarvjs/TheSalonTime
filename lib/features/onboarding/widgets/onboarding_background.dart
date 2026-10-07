import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/asset_constants.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -30,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: SvgPicture.asset(
          AssetConstants.curveBg,
          fit: BoxFit.cover,
          height: 180,
        ),
      ),
    );
  }
}

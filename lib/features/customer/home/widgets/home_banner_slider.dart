import 'package:flutter/material.dart';
import '../../../../shared/widgets/page_indicator.dart';
import '../models/home_banner_model.dart';
import 'home_banner_card.dart';

class HomeBannerSlider extends StatefulWidget {
  final List<HomeBannerModel> banners;

  const HomeBannerSlider({
    super.key,
    required this.banners,
  });

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return HomeBannerCard(banner: widget.banners[index]);
            },
          ),
        ),
        const SizedBox(height: 12),
        PageIndicator(
          count: widget.banners.length,
          currentIndex: _currentIndex,
        ),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/page_indicator.dart';
import '../models/home_banner_model.dart';
import '../models/home_slider_model.dart';
import 'home_banner_card.dart';

class HomeBannerSlider extends StatefulWidget {
  final List<HomeBannerModel>? banners;
  final List<HomeSliderModel>? dynamicSliders;

  const HomeBannerSlider({
    super.key,
    this.banners,
    this.dynamicSliders,
  });

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  int get itemCount {
    if (widget.dynamicSliders != null && widget.dynamicSliders!.isNotEmpty) {
      return widget.dynamicSliders!.length;
    }
    return widget.banners?.length ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HomeBannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentIndex >= itemCount && itemCount > 0) {
      _currentIndex = 0;
    }
    _restartAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (itemCount <= 1) return;

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients || itemCount <= 1) return;
      final nextIndex = (_currentIndex + 1) % itemCount;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _restartAutoPlay() {
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = itemCount;
    if (count == 0) return const SizedBox.shrink();

    final hasDynamicSliders = widget.dynamicSliders != null && widget.dynamicSliders!.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: count,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _restartAutoPlay();
            },
            itemBuilder: (context, index) {
              if (hasDynamicSliders) {
                final slider = widget.dynamicSliders![index];
                return HomeBannerCard(slider: slider);
              } else {
                final banner = widget.banners![index];
                return HomeBannerCard(banner: banner);
              }
            },
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 12),
          PageIndicator(
            count: count,
            currentIndex: _currentIndex,
          ),
        ],
      ],
    );
  }
}

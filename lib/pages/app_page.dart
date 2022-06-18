import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

enum PageTransition {
  scale,
  horizontal,
  vertical,
  fade,
  none,
}

abstract class AppPage extends Page {
  final PageTransition transition;

  const AppPage({
    this.transition = PageTransition.horizontal,
  });

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
        settings: this,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _buildTransition(context, animation, secondaryAnimation);
        });
  }

  Widget buildPage(BuildContext context);

  Widget _buildTransition(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    switch (transition) {
      case PageTransition.scale:
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: buildPage(context),
        );
      case PageTransition.horizontal:
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: buildPage(context),
        );
      case PageTransition.vertical:
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: buildPage(context),
        );
      case PageTransition.fade:
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: buildPage(context),
        );
      default:
        return buildPage(context);
    }
  }
}

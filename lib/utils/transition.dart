import 'package:flutter/material.dart';

const _duration =  Duration(milliseconds: 500);

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;
  

  CustomPageRoute({required this.builder})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return builder(context);
          },
          transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOutQuart;

            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final scaleAnimation = animation.drive(tween);

            return ScaleTransition(scale: scaleAnimation, child: child);
          },
          transitionDuration: _duration,
          reverseTransitionDuration: _duration
        );
}
import 'package:flutter/material.dart';

void navigateWithSlideTransition({
   BuildContext? context,
   Widget? destinationScreen,
  Duration transitionDuration = const Duration(milliseconds: 500),
}) {
  Navigator.push(
    context!, 
    PageRouteBuilder(
      transitionDuration: transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation), 
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) =>
          destinationScreen!,
    ),
  );
}

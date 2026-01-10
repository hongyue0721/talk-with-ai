import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark layer
        Container(
          color: const Color(0xFF0F0F13),
        ),
        // Animated gradient blobs
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple.withOpacity(0.3),
              filter: null, // Blur handled by backdrop usually, but here we blur the container
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds)
           .move(begin: const Offset(0, 0), end: const Offset(50, 50), duration: 5.seconds),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.3),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 6.seconds)
           .move(begin: const Offset(0, 0), end: const Offset(-50, -50), duration: 7.seconds),
        ),
         Positioned(
          top: 200,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pink.withOpacity(0.2),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .fadeIn(duration: 2.seconds)
           .move(begin: const Offset(0, 0), end: const Offset(-30, 100), duration: 8.seconds),
        ),
        // Blur the entire background to create the mesh effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
          child: Container(
             color: Colors.transparent,
          ),
        ),
        // Content
        SafeArea(child: child),
      ],
    );
  }
}

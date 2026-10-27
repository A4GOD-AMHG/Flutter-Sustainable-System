import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;

  const IconHeader(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      this.color1 = const Color(0xFF1B5E20),
      this.color2 = const Color(0xFF43A047)});

  @override
  Widget build(BuildContext context) {
    final whiteColor = Colors.white.withValues(alpha: 0.8);
    return Stack(
      children: [
        _IconHeaderBackground(color1: color1, color2: color2),
        Positioned(
          top: -50,
          left: -70,
          child: FaIcon(
            icon,
            size: 200,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(subtitle.toUpperCase(),
                    style: TextStyle(
                        fontSize: 14, letterSpacing: 2, color: whiteColor)),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                FaIcon(icon, size: 64, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IconHeaderBackground extends StatelessWidget {
  final Color color1;
  final Color color2;

  const _IconHeaderBackground({required this.color1, required this.color2});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(70),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color1, color2],
        ),
      ),
    );
  }
}

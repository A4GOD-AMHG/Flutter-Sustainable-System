import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Botón grande con degradado, icono de fondo y efecto ripple.
class MyButton extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final Color color1;
  final Color color2;
  final void Function() onPress;
  final void Function()? onLongPress;

  final EdgeInsetsGeometry? margin;
  final double? height;

  const MyButton(
      {super.key,
      this.icon = FontAwesomeIcons.circle,
      required this.child,
      this.color1 = Colors.grey,
      this.color2 = Colors.blueGrey,
      required this.onPress,
      this.onLongPress,
      this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      this.height = 100});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Container(
      height: height,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: color1.withValues(alpha: 0.35),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onPress,
          onLongPress: onLongPress,
          child: Stack(
            children: [
              Positioned(
                right: -15,
                top: -8,
                child: FaIcon(
                  icon,
                  size: 115,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    FaIcon(icon, color: Colors.white, size: 36),
                    const SizedBox(width: 20),
                    Expanded(child: child),
                    const FaIcon(
                      FontAwesomeIcons.chevronRight,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HoverWidget extends StatefulWidget {
  final Widget child;
  final Widget hoverChild;
  final Function(PointerEvent) onHover;

  const HoverWidget({
    required this.child,
    required this.hoverChild,
    required this.onHover,
    super.key,
  });

  @override
  _HoverWidgetState createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() => _isHovered = true);
        widget.onHover(event);
      },
      onExit: (event) {
        setState(() => _isHovered = false);
        widget.onHover(event);
      },
      child: _isHovered ? widget.hoverChild : widget.child,
    );
  }
}
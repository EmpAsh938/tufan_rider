import 'package:flutter/material.dart';

class CustomBottomsheet extends StatefulWidget {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  const CustomBottomsheet({
    super.key,
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  State<CustomBottomsheet> createState() => _CustomBottomsheetState();
}

class _CustomBottomsheetState extends State<CustomBottomsheet> {
  late double _currentHeight;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.minHeight;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _currentHeight = (_currentHeight - details.delta.dy)
          .clamp(widget.minHeight, widget.maxHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: _currentHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

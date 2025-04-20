import 'dart:async';
import 'package:flutter/material.dart';

enum ToastType { success, error, info }

class CustomToast {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;
  static Timer? _timer;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void show(
    String message, {
    BuildContext? context,
    Duration duration = const Duration(seconds: 2),
    ToastType toastType = ToastType.info,
  }) {
    try {
      // Cancel any existing toast
      _timer?.cancel();
      _overlayEntry?.remove();
      _isShowing = false;

      // Get the overlay state
      final overlayState = _getOverlayState(context);
      if (overlayState == null) {
        debugPrint('Toast Error: No overlay found');
        return;
      }

      // Create and show new toast
      _showToast(overlayState, message, toastType, duration);
    } catch (e) {
      debugPrint('Toast Error: ${e.toString()}');
    }
  }

  static OverlayState? _getOverlayState(BuildContext? context) {
    if (context != null) {
      final overlay = Overlay.of(context);
      if (overlay != null) return overlay;
    }

    if (navigatorKey.currentState?.overlay != null) {
      return navigatorKey.currentState!.overlay;
    }

    final rootNav =
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true);
    return rootNav.overlay;
  }

  static void _showToast(
    OverlayState overlayState,
    String message,
    ToastType toastType,
    Duration duration,
  ) {
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        toastType: toastType,
        duration: duration,
        onDismissed: () => hide(),
      ),
    );

    overlayState.insert(_overlayEntry!);
    _isShowing = true;
  }

  static void hide() {
    if (!_isShowing) return;

    _timer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType toastType;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.toastType,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _setupAnimations();
    _controller.forward();

    // Start auto-hide timer
    _autoHideTimer = Timer(widget.duration, () {
      _dismissWithAnimation();
    });
  }

  void _setupAnimations() {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  Future<void> _dismissWithAnimation() async {
    if (_controller.status == AnimationStatus.dismissed) return;

    // Reverse the animations
    await _controller.reverse();

    // Cancel the auto-hide timer if it's still active
    _autoHideTimer?.cancel();

    // Notify parent to remove the overlay
    widget.onDismissed();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color _getToastColor() {
    switch (widget.toastType) {
      case ToastType.success:
        return Colors.green.shade600;
      case ToastType.error:
        return Colors.red.shade600;
      case ToastType.info:
        return Colors.blue.shade600;
    }
  }

  IconData _getToastIcon() {
    switch (widget.toastType) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: _dismissWithAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 32,
                      top: 12,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _getToastColor(),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getToastIcon(), color: Colors.white),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: -4,
                          right: -8,
                          child: GestureDetector(
                            onTap: _dismissWithAnimation,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.3),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

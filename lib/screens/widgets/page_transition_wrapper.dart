import 'package:flutter/material.dart';

class PageTransitionWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const PageTransitionWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<PageTransitionWrapper> createState() => _PageTransitionWrapperState();
}

class _PageTransitionWrapperState extends State<PageTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Widget? _currentChild;
  Widget? _newChild;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));

    _currentChild = widget.child;
    _animationController.forward();
  }

  @override
  void didUpdateWidget(PageTransitionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.child != oldWidget.child) {
      _newChild = widget.child;
      _animationController.reset();
      _animationController.forward().then((_) {
        setState(() {
          _currentChild = _newChild;
          _newChild = null;
        });
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _newChild ?? _currentChild,
          ),
        );
      },
    );
  }
}

/// Custom page route with slide transition
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Curve curve;

  SlidePageRoute({
    required this.child,
    this.direction = SlideDirection.fromRight,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offsetAnimation = Tween<Offset>(
      begin: direction.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(0.0, 0.5, curve: curve),
    ));

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

/// Slide directions for page transitions
enum SlideDirection {
  fromLeft(Offset(-1.0, 0.0)),
  fromRight(Offset(1.0, 0.0)),
  fromTop(Offset(0.0, -1.0)),
  fromBottom(Offset(0.0, 1.0));

  const SlideDirection(this.offset);
  final Offset offset;
}

/// Hero page route with scaling animation
class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String heroTag;
  final Duration duration;

  HeroPageRoute({
    required this.child,
    required this.heroTag,
    this.duration = const Duration(milliseconds: 400),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6),
    ));

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

/// Modal page route that slides from bottom
class ModalPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final bool isFullscreen;
  final Duration duration;

  ModalPageRoute({
    required this.child,
    this.isFullscreen = true,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          opaque: isFullscreen,
          barrierColor: isFullscreen ? null : Colors.black54,
          barrierDismissible: !isFullscreen,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5),
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}
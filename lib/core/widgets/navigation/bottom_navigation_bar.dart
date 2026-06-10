// Dart imports
import 'dart:math' as math;
import 'dart:ui' as ui;

// Package imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core imports
import '/core/theme/app_colors.dart';
import '/core/theme/theme_extensions.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class NavBarItem {
  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;
}

// ─── Main Widget ─────────────────────────────────────────────────────────────

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.backgroundColor = AppColors.surfaceVariant,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.onSurfaceVariant,
    this.indicatorColor = const Color(0x1A2ED3FF),
    this.height,
    this.margin = const EdgeInsets.fromLTRB(20, 0, 20, 20),
    this.showLabels = false,
    this.enableHaptics = true,
    this.enableBlur = true,
  }) : assert(items.length >= 2 && items.length <= 5);

  final List<NavBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;
  final double? height;
  final EdgeInsets margin;
  final bool showLabels;
  final bool enableHaptics;
  final bool enableBlur;

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final _anim = CurvedAnimation(
    parent: _ctrl,
    curve: const _SpringCurve(),
  );
  int _prev = 0;

  @override
  void initState() {
    super.initState();
    _prev = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant CustomNavigationBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _prev = old.selectedIndex;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? (widget.showLabels ? 80.0 : 68.0);

    return Padding(
      padding: widget.margin,
      child: SizedBox(
        height: h,
        child: _Shell(
          color: widget.backgroundColor,
          enableBlur: widget.enableBlur,
          child: LayoutBuilder(
            builder: (_, box) {
              final itemW = box.maxWidth / widget.items.length;
              final pillW = math.min(58.0, itemW - 8);
              final pillH = math.min(56.0, h - 12);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Sliding indicator pill
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, child) {
                      final x = ui.lerpDouble(
                        (_prev + 0.5) * itemW,
                        (widget.selectedIndex + 0.5) * itemW,
                        _anim.value,
                      )!;
                      return Positioned(
                        left: x - pillW / 2,
                        top: (h - pillH) / 2,
                        child: child!,
                      );
                    },
                    child: Container(
                      width: pillW,
                      height: pillH,
                      decoration: BoxDecoration(
                        color: widget.indicatorColor,
                        borderRadius: BorderRadius.circular(pillH / 2),
                      ),
                    ),
                  ),

                  // Items
                  Row(
                    children: List.generate(
                      widget.items.length,
                      (i) => _NavItem(
                        item: widget.items[i],
                        isSelected: i == widget.selectedIndex,
                        activeColor: widget.activeColor,
                        inactiveColor: widget.inactiveColor,
                        showLabel: widget.showLabels,
                        width: itemW,
                        onTap: () {
                          if (widget.enableHaptics) {
                            HapticFeedback.selectionClick();
                          }
                          widget.onItemSelected(i);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Shell (glassmorphic container) ──────────────────────────────────────────

class _Shell extends StatelessWidget {
  const _Shell({
    required this.color,
    required this.enableBlur,
    required this.child,
  });

  final Color color;
  final bool enableBlur;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(40);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(r),
        color: color,
        border: Border.all(color: AppColors.outlineVariant, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(r),
        child: enableBlur
            ? BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: child,
              )
            : child,
      ),
    );
  }
}

// ─── Individual Nav Item ─────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.showLabel,
    required this.width,
    required this.onTap,
  });

  final NavBarItem item;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final bool showLabel;
  final double width;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final _scale = Tween(
    begin: 1.0,
    end: 0.86,
  ).animate(CurvedAnimation(parent: _press, curve: Curves.easeIn));

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? widget.activeColor : widget.inactiveColor;

    return Semantics(
      label: widget.item.label,
      selected: widget.isSelected,
      button: true,
      child: GestureDetector(
        key: ValueKey(widget.item.label),
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) {
          _press.reverse();
          if (!widget.isSelected) {
            widget.onTap();
          }
        },
        onTapCancel: () => _press.reverse(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scale,
          child: SizedBox(
            width: widget.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon + badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: Tween(begin: 0.55, end: 1.0).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        widget.isSelected
                            ? widget.item.activeIcon
                            : widget.item.icon,
                        key: ValueKey(
                          '${widget.item.label}_${widget.isSelected}',
                        ),
                        color: color,
                        size: 28,
                      ),
                    ),
                    if ((widget.item.badge ?? 0) > 0)
                      Positioned(
                        top: -5,
                        right: -8,
                        child: _Badge(widget.item.badge!),
                      ),
                  ],
                ),

                // Label
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: color,
                        letterSpacing: 0.35,
                      ),
                      child: widget.showLabel
                          ? Text(
                              widget.item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  crossFadeState: widget.showLabel
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),

                // Active dot
                const SizedBox(height: 5),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: widget.isSelected ? 4.0 : 0.0),
                  duration: const Duration(milliseconds: 450),
                  curve: widget.isSelected
                      ? Curves.elasticOut
                      : Curves.easeOutCubic,
                  builder: (_, v, _) {
                    final size = v.clamp(0.0, 4.0);
                    return SizedBox(
                      width: size,
                      height: size,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.activeColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Badge ───────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge(this.count);
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.colorScheme.error,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: context.colorScheme.onError,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

// ─── Spring Curve ────────────────────────────────────────────────────────────

/// Under-damped spring: slight overshoot (~4%) for a lively, physical feel.
class _SpringCurve extends Curve {
  const _SpringCurve();

  static const _k = 280.0; // stiffness
  static const _c = 26.0; // damping
  static const _m = 1.0; // mass

  @override
  double transform(double t) {
    if (t == 0.0 || t == 1.0) return t;
    final w0 = math.sqrt(_k / _m);
    final z = _c / (2 * math.sqrt(_k * _m));
    final wd = w0 * math.sqrt(1.0 - z * z);
    return 1.0 -
        math.exp(-z * w0 * t) *
            (math.cos(wd * t) + (z * w0 / wd) * math.sin(wd * t));
  }
}

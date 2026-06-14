import 'package:flutter/material.dart';

enum SnackbarType { info, success, warning, error, custom }

enum SnackbarActionPosition { end, below }

class CustomSnackbar {
  CustomSnackbar._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
    VoidCallback? onClosed,
    bool showCloseIcon = false,
    Widget? icon,
    Color? backgroundColor,
    Color? textColor,
    Color? actionColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
    ShapeBorder? shape,
    SnackBarBehavior? behavior,
    SnackbarActionPosition actionPosition = SnackbarActionPosition.end,
    double? width,
    DismissDirection dismissDirection = DismissDirection.down,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultColors = _getTypeColors(type, colorScheme);

    final effectiveBackgroundColor =
        backgroundColor ?? defaultColors.backgroundColor;
    final effectiveTextColor = textColor ?? defaultColors.textColor;
    final effectiveActionColor = actionColor ?? defaultColors.actionColor;

    Widget content = Row(
      children: [
        if (icon != null || type != SnackbarType.custom) ...[
          _buildIcon(type, icon, effectiveTextColor),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: effectiveTextColor,
            ),
          ),
        ),
        if (showCloseIcon)
          IconButton(
            icon: Icon(Icons.close, color: effectiveTextColor),
            onPressed: () {
              ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );

    SnackBarAction? snackBarAction;
    if (actionLabel != null && onActionPressed != null) {
      if (actionPosition == SnackbarActionPosition.below) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            content,
            const SizedBox(height: 8),
            TextButton(
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
                foregroundColor: effectiveActionColor,
                padding: EdgeInsets.zero,
              ),
              child: Text(actionLabel),
            ),
          ],
        );
      } else {
        snackBarAction = SnackBarAction(
          label: actionLabel,
          onPressed: onActionPressed,
          textColor: effectiveActionColor,
        );
      }
    }

    final snackbar = SnackBar(
      content: content,
      duration: duration,
      action: snackBarAction,
      backgroundColor: effectiveBackgroundColor,
      elevation: elevation,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      shape: shape,
      behavior: behavior ?? SnackBarBehavior.floating,
      width: width,
      dismissDirection: dismissDirection,
      onVisible: () {
        // Snackbar is now visible
      },
    );

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return null;

    final controller = messenger.showSnackBar(snackbar);

    if (onClosed != null) {
      controller.closed.then((reason) => onClosed());
    }

    return controller;
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? info({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
    VoidCallback? onClosed,
    bool showCloseIcon = false,
  }) {
    return show(
      context: context,
      message: message,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      onClosed: onClosed,
      showCloseIcon: showCloseIcon,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? success({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
    VoidCallback? onClosed,
    bool showCloseIcon = false,
  }) {
    return show(
      context: context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      onClosed: onClosed,
      showCloseIcon: showCloseIcon,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? warning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
    VoidCallback? onClosed,
    bool showCloseIcon = false,
  }) {
    return show(
      context: context,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      onClosed: onClosed,
      showCloseIcon: showCloseIcon,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? error({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 6),
    String? actionLabel,
    VoidCallback? onActionPressed,
    VoidCallback? onClosed,
    bool showCloseIcon = true,
  }) {
    return show(
      context: context,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      onClosed: onClosed,
      showCloseIcon: showCloseIcon,
    );
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  }

  static void clear(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
  }

  static Widget _buildIcon(SnackbarType type, Widget? customIcon, Color color) {
    if (customIcon != null) return customIcon;

    IconData iconData;
    switch (type) {
      case SnackbarType.info:
        iconData = Icons.info_outline;
        break;
      case SnackbarType.success:
        iconData = Icons.check_circle_outline;
        break;
      case SnackbarType.warning:
        iconData = Icons.warning_amber_outlined;
        break;
      case SnackbarType.error:
        iconData = Icons.error_outline;
        break;
      case SnackbarType.custom:
        return const SizedBox.shrink();
    }

    return Icon(iconData, color: color, size: 20);
  }

  static _SnackbarColors _getTypeColors(
    SnackbarType type,
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case SnackbarType.info:
        return _SnackbarColors(
          backgroundColor: colorScheme.inverseSurface,
          textColor: colorScheme.onInverseSurface,
          actionColor: colorScheme.inversePrimary,
        );
      case SnackbarType.success:
        return const _SnackbarColors(
          backgroundColor: Color(0xFF4CAF50),
          textColor: Colors.white,
          actionColor: Colors.white,
        );
      case SnackbarType.warning:
        return const _SnackbarColors(
          backgroundColor: Color(0xFFFF9800),
          textColor: Colors.white,
          actionColor: Colors.white,
        );
      case SnackbarType.error:
        return _SnackbarColors(
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
          actionColor: colorScheme.onError,
        );
      case SnackbarType.custom:
        return _SnackbarColors(
          backgroundColor: colorScheme.inverseSurface,
          textColor: colorScheme.onInverseSurface,
          actionColor: colorScheme.inversePrimary,
        );
    }
  }
}

class _SnackbarColors {
  const _SnackbarColors({
    required this.backgroundColor,
    required this.textColor,
    required this.actionColor,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color actionColor;
}

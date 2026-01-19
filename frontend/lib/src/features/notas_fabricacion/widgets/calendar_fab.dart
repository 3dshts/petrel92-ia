// frontend/lib/src/features/fabricacion/widgets/calendar_fab.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Botón flotante circular para abrir el calendario.
///
/// Características:
/// - Circular con icono de calendario
/// - Color naranja (AppColors.accent)
/// - Tooltip "Calendario"
/// - Sombra suave
/// - Animación de hover en desktop
class CalendarFAB extends StatefulWidget {
  const CalendarFAB({
    super.key,
    required this.onPressed,
  });

  /// Callback ejecutado al presionar el botón.
  final VoidCallback onPressed;

  @override
  State<CalendarFAB> createState() => _CalendarFABState();
}

class _CalendarFABState extends State<CalendarFAB>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Tooltip(
      message: 'Calendario',
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovered && !isMobile ? 1.1 : 1.0),
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.lightText,
            elevation: _isHovered && !isMobile ? 8.0 : 4.0,
            highlightElevation: 8.0,
            shape: const CircleBorder(),
            child: Icon(
              Icons.calendar_month,
              size: isMobile ? 28.0 : 32.0,
            ),
          ),
        ),
      ),
    );
  }

  /// Actualiza el estado de hover.
  void _setHovered(bool isHovered) {
    if (!mounted) return;
    setState(() => _isHovered = isHovered);
  }
}
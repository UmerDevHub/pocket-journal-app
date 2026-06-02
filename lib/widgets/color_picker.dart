import 'package:flutter/material.dart';

/// Color picker widget for selecting note background color
class ColorPicker extends StatelessWidget {
  final String selectedColor;
  final bool isDarkMode;
  final Function(String) onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.isDarkMode,
    required this.onColorSelected,
  });

  /// Light theme note colors
  static const List<String> lightColors = [
    '#FEF3C7', // Pastel Yellow
    '#DBEAFE', // Pastel Blue
    '#DCFCE7', // Pastel Green
    '#FCE7F3', // Pastel Pink
    '#F3F4F6', // Pastel Gray
  ];

  /// Dark theme note colors
  static const List<String> darkColors = [
    '#A16207', // Dark Yellow
    '#1E40AF', // Dark Blue
    '#166534', // Dark Green
    '#9D174D', // Dark Pink
    '#374151', // Dark Gray
  ];

  /// Get colors based on theme
  List<String> get colors => isDarkMode ? darkColors : lightColors;

  /// Convert hex string to Color
  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: colors.map((color) {
          final isSelected = selectedColor == color;
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 32 : 26,
              height: isSelected ? 32 : 26,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _hexToColor(color),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? (isDarkMode ? Colors.white : Colors.black87)
                      : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: _hexToColor(color).withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: _isLightColor(color) ? Colors.black87 : Colors.white,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Check if a color is light (for icon contrast)
  bool _isLightColor(String hex) {
    final color = _hexToColor(hex);
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }
}

/// Simple color palette popup for app bar
class ColorPickerPopup extends StatelessWidget {
  final String selectedColor;
  final bool isDarkMode;
  final Function(String) onColorSelected;

  const ColorPickerPopup({
    super.key,
    required this.selectedColor,
    required this.isDarkMode,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _hexToColor(selectedColor).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hexToColor(selectedColor),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.palette_rounded,
          color: isDarkMode ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            child: ColorPicker(
              selectedColor: selectedColor,
              isDarkMode: isDarkMode,
              onColorSelected: (color) {
                onColorSelected(color);
                Navigator.of(context).pop();
              },
            ),
          ),
        ];
      },
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

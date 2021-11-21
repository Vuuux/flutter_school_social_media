import 'package:flutter/material.dart';

class ChoiceChipData {
  final String? label;
  final bool isSelected;
  Color? textColor;
  Color? selectedColor;

  ChoiceChipData({
    this.label,
    required this.isSelected,
    this.textColor,
    this.selectedColor,
  });

  ChoiceChipData copy({
    String? label,
    required bool isSelected,
    Color? textColor,
    Color? selectedColor,
  }) =>
      ChoiceChipData(
        label: label ?? this.label,
        isSelected: isSelected,
        textColor: textColor ?? this.textColor,
        selectedColor: selectedColor ?? this.selectedColor,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChoiceChipData &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          isSelected == other.isSelected &&
          textColor == other.textColor &&
          selectedColor == other.selectedColor;

  @override
  int get hashCode =>
      label.hashCode ^
      isSelected.hashCode ^
      textColor.hashCode ^
      selectedColor.hashCode;
}


import 'package:flutter/material.dart';
import 'package:luanvanflutter/views/components/chips/data/chip_data.dart';

class Chips {
  static final all = <ChipData>[
    ChipData(
      label: 'Chip',
      backgroundColor: Colors.red,
    ),
    ChipData(
      label: 'ActionChip',
      backgroundColor: Colors.blue,
    ),
    ChipData(
      label: 'InputChip',
      backgroundColor: Colors.orange,
    ),
    ChipData(
      label: 'FilterChip',
      backgroundColor: Colors.green,
    ),
    ChipData(
      label: 'ChoiceChip',
      backgroundColor: Colors.purple,
    ),
  ];
}

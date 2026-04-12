import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/dao/body_measurement_dao.dart';
import '../../data/db/database.dart';
import '../../data/db/ulid.dart';
import '../../data/models/db_body_measurement.dart';
import '../../style/app_style.dart';
import 'measurement_types.dart';

/// Form screen for logging a new body measurement.
class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({
    super.key,
    required this.database,
    this.preselectedType,
  });

  final AppDatabase database;
  final MeasurementType? preselectedType;

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  late MeasurementType _selectedType;
  late String _selectedUnit;
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preselectedType ?? MeasurementType.weight;
    _selectedUnit = _selectedType.units.first;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onTypeChanged(MeasurementType type) {
    setState(() {
      _selectedType = type;
      _selectedUnit = type.units.first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final rawValue = _valueController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(rawValue);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid value')),
      );
      return;
    }

    setState(() => _saving = true);

    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final measuredAtSec = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    ).millisecondsSinceEpoch ~/
        1000;

    final measurement = DbBodyMeasurement(
      id: Ulid.generate(),
      measurementType: _selectedType.wireValue,
      value: value,
      unit: _selectedUnit,
      measuredAt: measuredAtSec,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: nowSec,
      updatedAt: nowSec,
    );

    final dao = BodyMeasurementDao(widget.database.raw);
    await dao.insertMeasurement(measurement);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Add Measurement'),
        backgroundColor: AppStyle.topBarBackground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppStyle.gapL),
        children: [
          // Measurement type dropdown
          const Text('Type', style: AppStyle.captionStyle),
          const SizedBox(height: AppStyle.gapS),
          Container(
            decoration: BoxDecoration(
              color: AppStyle.inputPillBackground,
              borderRadius: AppStyle.pillRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppStyle.gapM),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MeasurementType>(
                value: _selectedType,
                isExpanded: true,
                items: MeasurementType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label),
                        ))
                    .toList(),
                onChanged: (t) {
                  if (t != null) _onTypeChanged(t);
                },
              ),
            ),
          ),

          const SizedBox(height: AppStyle.gapL),

          // Value + unit row
          const Text('Value', style: AppStyle.captionStyle),
          const SizedBox(height: AppStyle.gapS),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppStyle.inputPillBackground,
                    borderRadius: AppStyle.pillRadius,
                  ),
                  child: TextField(
                    controller: _valueController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    style: AppStyle.inputPillStyle,
                    decoration: const InputDecoration(
                      hintText: '0.0',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppStyle.gapM,
                        vertical: AppStyle.gapM,
                      ),
                    ),
                  ),
                ),
              ),
              if (_selectedType.units.length > 1) ...[
                const SizedBox(width: AppStyle.gapM),
                Container(
                  decoration: BoxDecoration(
                    color: AppStyle.inputPillBackground,
                    borderRadius: AppStyle.pillRadius,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppStyle.gapM),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedUnit,
                      items: _selectedType.units
                          .map((u) =>
                              DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (u) {
                        if (u != null) setState(() => _selectedUnit = u);
                      },
                    ),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(left: AppStyle.gapM),
                  child: Text(
                    _selectedUnit,
                    style: AppStyle.captionStyle,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppStyle.gapL),

          // Date picker
          const Text('Date', style: AppStyle.captionStyle),
          const SizedBox(height: AppStyle.gapS),
          Material(
            color: AppStyle.inputPillBackground,
            borderRadius: AppStyle.pillRadius,
            child: InkWell(
              borderRadius: AppStyle.pillRadius,
              onTap: _pickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyle.gapM,
                  vertical: AppStyle.gapM,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: AppStyle.smallIconSize,
                        color: AppStyle.textSecondary),
                    const SizedBox(width: AppStyle.gapS),
                    Text(
                      _formatDate(_selectedDate),
                      style: AppStyle.inputPillStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppStyle.gapL),

          // Notes
          const Text('Notes (optional)', style: AppStyle.captionStyle),
          const SizedBox(height: AppStyle.gapS),
          Container(
            decoration: BoxDecoration(
              color: AppStyle.inputPillBackground,
              borderRadius: AppStyle.pillRadius,
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppStyle.inputPillStyle,
              decoration: const InputDecoration(
                hintText: 'e.g. morning, fasted',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(AppStyle.gapM),
              ),
            ),
          ),

          const SizedBox(height: AppStyle.gapXL),

          // Save button
          SizedBox(
            height: 48,
            child: Material(
              color: AppStyle.primaryBlue,
              borderRadius: AppStyle.pillRadius,
              child: InkWell(
                borderRadius: AppStyle.pillRadius,
                onTap: _saving ? null : _save,
                child: Center(
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save', style: AppStyle.finishButtonStyle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

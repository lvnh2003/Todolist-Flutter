import 'package:flutter/material.dart';

class OptionPicker extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<Color> colors;
  final String currentSelection;

  const OptionPicker({
    Key? key,
    required this.title,
    required this.options,
    required this.colors,
    required this.currentSelection,
  }) : super(key: key);

  @override
  _OptionPickerState createState() => _OptionPickerState();
}

class _OptionPickerState extends State<OptionPicker> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.currentSelection;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ...List.generate(widget.options.length, (index) {
                    return _buildRadioTile(widget.options[index], widget.colors[index]);
                  }),
                  const Divider(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile(String option, Color color) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      value: option,
      groupValue: selectedOption,
      onChanged: (value) {
        setState(() => selectedOption = value);
        Navigator.pop(context, value);
      },
    );
  }
}

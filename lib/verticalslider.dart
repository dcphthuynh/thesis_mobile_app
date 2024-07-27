import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class VerticalSliderWidget extends StatefulWidget {
  const VerticalSliderWidget({super.key});

  @override
  State<VerticalSliderWidget> createState() => _VerticalSliderWidgetState();
}

class _VerticalSliderWidgetState extends State<VerticalSliderWidget> {
  double _value = 40.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: SfSlider.vertical(
            min: 0.0,
            max: 100.0,
            value: _value,
            interval: 20,
            showTicks: true,
            showLabels: true,
            enableTooltip: true,
            minorTicksPerInterval: 1,
            onChanged: (dynamic value) {
              setState(() {
                _value = value;
              });
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function onSubmitted;
  final TextInputType inputType;

  AdaptiveTextField({
    @required this.label,
    @required this.controller,
    @required this.onSubmitted,
    @required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Column(
            children: <Widget>[
              SizedBox(
                height: 16.0,
              ),
              CupertinoTextField(
                placeholder: label,
                keyboardType: inputType,
                padding: EdgeInsets.all(16),
                controller: controller,
                onSubmitted: (_) => onSubmitted(),
              ),
            ],
          )
        : TextField(
            decoration: InputDecoration(
              labelText: label,
            ),
            controller: controller,
            keyboardType: inputType,
            onSubmitted: (_) => onSubmitted(),
            // onChanged: (val) => amountInput = val,
          );
  }
}

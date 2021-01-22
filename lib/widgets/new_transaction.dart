import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/adaptive_button.dart';
import '../widgets/adaptive_textfield.dart';

class NewTransaction extends StatefulWidget {
  final Function addNewTransaction;

  NewTransaction(this.addNewTransaction);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleEditingController = TextEditingController();
  final _amountEditingController = TextEditingController();
  DateTime _selectedDate;

  void _addTX() {
    if (_amountEditingController.text.isEmpty) return;

    final enteredTitle = _titleEditingController.text;
    final enteredAmount = double.parse(_amountEditingController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0 || _selectedDate == null) {
      return;
    }

    widget.addNewTransaction(
      enteredTitle,
      enteredAmount,
      _selectedDate,
    );

    Navigator.of(context).pop();
  }

  void _showDatePicker() {
    if (!Platform.isIOS) {
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2019),
        lastDate: DateTime.now(),
      ).then((pickedDate) {
        if (pickedDate == null) return;
        setState(() {
          _selectedDate = pickedDate;
        });
      });
    } else {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 500,
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (pickedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: media.viewInsets.bottom + 10,
          ),
          child: Column(
            crossAxisAlignment: Platform.isIOS
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.end,
            children: <Widget>[
              AdaptiveTextField(
                label: '買ったもの',
                controller: _titleEditingController,
                onSubmitted: _addTX,
                inputType: TextInputType.text,
              ),
              AdaptiveTextField(
                label: '金額',
                controller: _amountEditingController,
                onSubmitted: _addTX,
                inputType: TextInputType.number,
              ),
              Container(
                height: 80,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? '購入日を選んでね'
                            : '購入日: ${DateFormat.yMd('ja').format(_selectedDate)}',
                      ),
                    ),
                    AdaptiveButton(
                      label: '日にち選択',
                      onPressed: _showDatePicker,
                    ),
                  ],
                ),
              ),
              Platform.isIOS
                  ? CupertinoButton(
                      child: Text(
                        'お買い物登録',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: _addTX,
                    )
                  : RaisedButton(
                      child: Text(
                        'お買い物登録',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Theme.of(context).accentColor,
                      textColor: Colors.black87,
                      onPressed: _addTX,
                    ),
              SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

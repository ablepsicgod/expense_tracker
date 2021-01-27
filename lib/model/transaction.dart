import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  Transaction({
    @required this.id,
    @required this.title,
    @required this.amount,
    @required this.date,
  });

  Transaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        amount = json['amount'],
        date = DateTime.parse(json['date']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toString(),
      };
}

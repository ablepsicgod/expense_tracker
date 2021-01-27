import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './widgets/chart.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './model/transaction.dart';

void main() {
  // only allow portrait mode
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ja');
    return MaterialApp(
      title: '買い物日記',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        errorColor: Colors.amber[900],
        fontFamily: 'Quicksans',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline1: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
              button: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
      home: MyHomeApp(),
    );
  }
}

class MyHomeApp extends StatefulWidget {
  // String titleInput;
  // String amountInput;
  // final titleEditingController = TextEditingController();
  // final amountEditingController = TextEditingController();

  @override
  _MyHomeAppState createState() => _MyHomeAppState();
}

class _MyHomeAppState extends State<MyHomeApp> {
  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New shoes',
    //   amount: 69.99,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly Groceries',
    //   amount: 16.53,
    //   date: DateTime.now(),
    // ),
  ];

  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
    String txTitle,
    double txAmount,
    DateTime pickedDate,
  ) {
    final newTX = Transaction(
      title: txTitle,
      amount: txAmount,
      id: DateTime.now().toString(),
      date: pickedDate,
    );

    setState(() {
      _userTransactions.add(newTX);
      saveTransactions();
    });
  }

  void _removeTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);

      clearData();
      saveTransactions();
    });
  }

  //saves _userTransactions Every time when its modified and saves it in to sharedpreference
  void saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> txList = [];

    _userTransactions.forEach((element) {
      txList.add(json.encode(element.toJson()));
    });

    await prefs.setStringList('transactions', txList);
    print(prefs.getStringList('transactions'));
  }

  //get data from sharedpreference
  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.getStringList('transactions').forEach((element) {
        _userTransactions.add(Transaction.fromJson(json.decode(element)));
      });
    });
  }

  //clear sharedpreference
  void clearData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  //get data from sharedpreference at start
  @override
  void initState() {
    // clearData();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              '買い物日記',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: Text(
              '買い物日記',
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              ),
            ],
          );

    final txList = Container(
      height: (media.size.height -
              appBar.preferredSize.height -
              media.padding.top) *
          0.7,
      child: TransactionList(
        transactions: _userTransactions,
        removeTransaction: _removeTransaction,
      ),
    );

    final bodyWidget = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'show chart',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  Switch.adaptive(
                    activeColor: Theme.of(context).accentColor,
                    value: _showChart,
                    onChanged: (state) {
                      setState(() {
                        _showChart = state;
                      });
                    },
                  ),
                ],
              ),
            if (!isLandscape)
              Container(
                height: (media.size.height -
                        appBar.preferredSize.height -
                        media.padding.top) *
                    0.3,
                child: Chart(_recentTransactions),
              ),
            if (!isLandscape) txList,
            if (isLandscape)
              _showChart
                  ? Container(
                      height: (media.size.height -
                              appBar.preferredSize.height -
                              media.padding.top) *
                          0.7,
                      child: Chart(_recentTransactions),
                    )
                  : txList,
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: bodyWidget,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: bodyWidget,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: IconButton(
                      icon: Icon(Icons.add),
                      color: Colors.black87,
                      onPressed: () => _startAddNewTransaction(context),
                    ),
                    onPressed: () {},
                  ),
          );
  }
}

import 'dart:convert';

import 'package:fit_kit/fit_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:insightme/AppIntegrations/DataModels/google_fit_data.dart';

class FitKitGHub extends StatefulWidget {
  @override
  _FitKitGHubState createState() => _FitKitGHubState();
}

class _FitKitGHubState extends State<FitKitGHub> {
  String result = '';
  Map<DataType, List<FitData>> results = Map();
  bool permissions;

  RangeValues _dateRange = RangeValues(1, 8);

  // ignore: deprecated_member_use
  List<DateTime> _dates = List<DateTime>();
  double _limitRange = 0;

  DateTime get _dateFrom => _dates[_dateRange.start.round()];

  DateTime get _dateTo => _dates[_dateRange.end.round()];

  int get _limit => _limitRange == 0.0 ? null : _limitRange.round();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _dates.add(null);
    for (int i = 7; i >= 0; i--) {
      _dates.add(DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i)));
    }
    _dates.add(null);

    hasPermissions();
  }

  Future<void> read() async {
    results.clear();

    try {
      permissions = await FitKit.requestPermissions(DataType.values);
      if (!permissions) {
        result = 'requestPermissions: failed';
      } else {
        for (DataType type in DataType.values) {
          try {
            results[type] = await FitKit.read(
              type,
              dateFrom: _dateFrom,
              dateTo: _dateTo,
              limit: _limit,
            );
          } on UnsupportedException catch (e) {
            results[e.dataType] = [];
          }
        }

        result = 'readAll: success';
      }
    } catch (e) {
      result = 'readAll: $e';
    }

    setState(() {});
  }

  Future<void> revokePermissions() async {
    results.clear();

    try {
      await FitKit.revokePermissions();
      permissions = await FitKit.hasPermissions(DataType.values);
      result = 'revokePermissions: success';
    } catch (e) {
      result = 'revokePermissions: $e';
    }

    setState(() {});
  }

  Future<void> hasPermissions() async {
    try {
      permissions = await FitKit.hasPermissions(DataType.values);
    } catch (e) {
      result = 'hasPermissions: $e';
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items =
        results.entries.expand((entry) => [entry.key, ...entry.value]).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Google Fit Data'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            Text(
                'Date Range: ${_dateToString(_dateFrom)} - ${_dateToString(_dateTo)}'),
            Text('Limit: $_limit'),
            Text('Permissions: $permissions'),
            Text('Result: $result'),
            _buildDateSlider(context),
            _buildLimitSlider(context),
            _buildButtons(context),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item is DataType) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Datatype: $item',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    );
                  } else if (item is FitData) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Text(
                        'Result: $item',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  }

                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _floatingActionButton(),
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      child: Icon(Icons.save_alt),
      onPressed: () {
        _generateLocalJsonFile();
      },
    );
  }

  _generateLocalJsonFile() {
    final items = results.entries.expand((entry) => [entry.key, entry.value])
        .toList();

    print(items);
    print('------------');
    for (var data in items) {
      if (data is DataType) {
        //TODO
      }
    }

    print('------------');
    //NOTE: Test dataset for json construction
    List<Data> googleFitDataSet = [];
    Data data1 = Data(10.0, "2021-05-20", "2021-05-20", "BMI160 Step counter", false);
    Data data2 = Data(10.0, "2021-05-20", "2021-05-20", "BMI160 Step counter", false);
    GoogleFitData fitData = GoogleFitData("STEP_COUNT", googleFitDataSet);
    //print(jsonEncode(fitData.toJson()));
  }

  String _dateToString(DateTime dateTime) {
    if (dateTime == null) {
      return 'null';
    }

    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  Widget _buildDateSlider(BuildContext context) {
    return Row(
      children: [
        Text('Date Range'),
        Expanded(
          child: RangeSlider(
            values: _dateRange,
            min: 0,
            max: 9,
            divisions: 10,
            onChanged: (values) => setState(() => _dateRange = values),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitSlider(BuildContext context) {
    return Row(
      children: [
        Text('Limit'),
        Expanded(
          child: Slider(
            value: _limitRange,
            min: 0,
            max: 4,
            divisions: 4,
            onChanged: (newValue) => setState(() => _limitRange = newValue),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // ignore: deprecated_member_use
          child: TextButton(
            onPressed: () => read(),
            child: Text('Read'),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
        Expanded(
          // ignore: deprecated_member_use
          child: TextButton(
            onPressed: () => revokePermissions(),
            child: Text('Revoke permissions'),
          ),
        ),
      ],
    );
  }
}

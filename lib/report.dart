import 'dart:async';

import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:launch_review/launch_review.dart';

import 'config.dart';
import 'api.dart';
import 'navigationService.dart';
import 'progressPainter.dart';
import 'reportForm.dart';


class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report>{
  Future? _data;
  List<String> _requiredList = [];

  bool _isToday = true;
  String _dateMask = 'd MMM yyyy';
  String date = DateTime.now().toString().split(' ')[0];
  DateTime? currentBackPressTime;

  @override
  void initState() {
    _checkVersionUpdate();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args_date = ModalRoute.of(context)?.settings.arguments;
    if(args_date!=null) {
      date = args_date.toString();
      _isToday = date==DateTime.now().toString().split(' ')[0];
      _dateMask = _isToday?'d MMM yyyy':'EEEE, d MMM yyyy';
    }
    _data = _buildReportList();

    super.didChangeDependencies();
  }

  Future<void> _checkVersionUpdate() async {
    final needUpdate = await Api.getVersionUpdate();
    if(needUpdate!=null && needUpdate.isNotEmpty && (needUpdate['forced'].toString()=='1' || needUpdate['recommend'].toString()=='1')) {
      _showAppUpdateModalDialog(context, needUpdate);
    }
  }

  _showAppUpdateModalDialog(context, needUpdate) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(7)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 60),
                          child: const Text('Version Update available', style: TextStyle(fontSize: 16))
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Visibility(
                                visible: needUpdate['forced'].toString()!='1',
                                child: GestureDetector(
                                  onTap: () {
                                    NavigationService.instance.goBack();
                                  },
                                  child: const Text('SKIP', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold)),
                                )
                            ),
                            Container(
                                margin: const EdgeInsets.only(left: 30),
                                child: GestureDetector(
                                    onTap: () {
                                      LaunchReview.launch();
                                    },
                                    child: const Text('UPDATE', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold))
                                )
                            )
                          ]
                      )
                    ],
                  ),
                ),
              ),
              onWillPop: () => Future.value(false),
            );
          });
    });
  }

  Future _buildReportList() async {
    // var _nanny = (await Api.getNanny())['rows'];
    // var _child = (await Api.getChild())['rows'];
    var _mapping = (await Api.getMapping())['rows'];
    var _report = (await Api.getReportByDate(date))['rows'];

    // _nanny.sort((a, b) => a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase()));
    // _child.sort((a, b) => a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase()));

    await Api.getReportRequiredFields().then((res) {
      if(res!=null && res!='' && res.isNotEmpty && res['fields']!=null) {
        _requiredList = res['fields'].toString().split(',');
      }
    });

    List _d = [];

    if(_isToday) {
      _mapping.sort((a, b) {
        int cmp = a['nanny_name'].toString().toLowerCase().compareTo(b['nanny_name'].toString().toLowerCase());
        if (cmp != 0) return cmp;
        return a['child_name'].toString().toLowerCase().compareTo(b['child_name'].toString().toLowerCase());
      });

      for (var i = 0; i < _mapping.length; i++) {
        //for(var j = 0; j < _child.length; j++) {
        //int k = _report.indexWhere((e) => e['nanny_id'] == _nanny[i]['id'] && e['child_id'] == _child[j]['id']);
        int k = _report.indexWhere((e) =>
        e['nanny_id'] == _mapping[i]['nanny_id'] &&
            e['child_id'] == _mapping[i]['child_id']);

        // set data type
        if (k != -1) {
          _report[k].removeWhere((key, value) => value == null);
          _report[k].updateAll((key, value) => value.toString());
          _report[k].removeWhere((key, value) => value == '00:00:00');

          // if(_report[k]['id']!=null) {
          //   _report[k]['id'] = int.parse(_report[k]['id']);
          // }
          // if(_report[k]['attendance']!=null) {
          //   _report[k]['attendance'] = int.parse(_report[k]['attendance']);
          // }
          // if(_report[k]['temperature']!=null) {
          //   _report[k]['temperature'] = double.parse(_report[k]['temperature']);
          // }
          // if(_report[k]['weight']!=null) {
          //   _report[k]['weight'] = double.parse(_report[k]['weight']);
          // }
          // if(_report[k]['num_of_potty']!=null) {
          //   _report[k]['num_of_potty'] = int.parse(_report[k]['num_of_potty']);
          // }
          // if(_report[k]['is_morning_bath']!=null) {
          //   _report[k]['is_morning_bath'] = int.parse(_report[k]['is_morning_bath']);
          // }
          // if(_report[k]['is_afternoon_bath']!=null) {
          //   _report[k]['is_afternoon_bath'] = int.parse(_report[k]['is_afternoon_bath']);
          // }
          // if(_report[k]['medication']!=null) {
          //   _report[k]['medication'] = int.parse(_report[k]['medication']);
          // }
        }

        var _item = {
          'id': k == -1 ? null : _report[k].remove('id'),
          'nanny_id': _mapping[i]['nanny_id'],
          'nanny_name': _mapping[i]['nanny_name'],
          'location_id': _mapping[i]['location_id'],
          'child_id': _mapping[i]['child_id'],
          'child_name': _mapping[i]['child_name'],
          'report': k == -1 ? <String, dynamic>{} : _report[k],
          'status': k > -1 ? (_report[k]['attendance'] == '0' ? 'Absent' :
          (_progressReport(_report[k]) < 1.0 ? 'In-progress' : (
              _report[k]['shared_at'] != null ?
              ('Shared at ' + (
                  DateFormat(_report[k]['shared_at'].toString().split(' ')[0] ==
                      _report[k]['date'].toString()
                      ? 'HH:mm'
                      : 'd MMM yyyy HH:mm').format(DateTime.parse(
                      _report[k]['shared_at'].toString().split('.')[0]))
              )) : 'Ready to share'
          ))) : 'Have not started',
          'progress': (k == -1 ? 0 : _progressReport(_report[k])).toDouble()
        };

        //if (_isToday || _item['report'].isNotEmpty) {
          _d.add(_item);
        //}
        //}
      }
    } else {
      _report.sort((a, b) {
        int cmp = a['nanny_name'].toString().toLowerCase().compareTo(b['nanny_name'].toString().toLowerCase());
        if (cmp != 0) return cmp;
        return a['child_name'].toString().toLowerCase().compareTo(b['child_name'].toString().toLowerCase());
      });

      for (var i = 0; i < _report.length; i++) {
        _report[i].removeWhere((key, value) => value == null);
        _report[i].updateAll((key, value) => value.toString());
        _report[i].removeWhere((key, value) => value == '00:00:00');

        var _item = {
          'id': _report[i]['id'],
          'nanny_id': _report[i]['nanny_id'],
          'nanny_name': _report[i]['nanny_name'],
          'location_id': _report[i]['location_id'],
          'child_id': _report[i]['child_id'],
          'child_name': _report[i]['child_name'],
          'report': _report[i],
          'status': _report[i]['attendance'] == '0' ? 'Absent' :
          (_progressReport(_report[i]) < 1.0 ? 'In-progress' : (
              _report[i]['shared_at'] != null ?
              ('Shared at ' + (
                  DateFormat(_report[i]['shared_at'].toString().split(' ')[0] ==
                      _report[i]['date'].toString()
                      ? 'HH:mm'
                      : 'd MMM yyyy HH:mm').format(DateTime.parse(
                      _report[i]['shared_at'].toString().split('.')[0]))
              )) : 'Ready to share'
          )),
          'progress': _progressReport(_report[i]).toDouble()
        };

        _d.add(_item);
      }
    }

    return _d;
  }

  double _progressReport(Map<String, dynamic> report) {
    if(report['attendance']=='0') return 0;

    int total = 0;
    int items = 0;

    for(var i=0;i<_requiredList.length;i++) {
      total++;
      if(report[_requiredList[i]]!=null && report[_requiredList[i]]!='') items++;
    }

    return total>0?items/total:1;
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if(currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Press back again to exit');
      return Future.value(false);
    }
    return Future.value(true);
  }

  _showLogoutModalDialog(context){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(7)),
            child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: const Text('Are you sure you want to logout?', style: TextStyle(fontSize: 16))
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              child: GestureDetector(
                                onTap: () {
                                  NavigationService.instance.goBack();
                                },
                                child: const Text('GO BACK', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          Container(
                                  margin: const EdgeInsets.only(left: 30),
                                  child: GestureDetector(
                                      onTap: () {
                                        Config().logout();
                                      },
                                      child: const Text('LOGOUT', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold))
                                  )
                              )
                        ]
                    )
                  ],
                ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            backgroundColor: const Color(0xFFE2F2FF),
            foregroundColor: Colors.black,
            elevation: 0,
            title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Care Report'),
                  Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: const Icon(Icons.event)
                        ),
                        Visibility(
                          child: const Text("Today, ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
                          visible: _isToday,
                        ),
                        Expanded(
                            child: DateTimePicker(
                                dateMask: _dateMask,
                                initialValue: date,
                                firstDate: DateTime(2022),
                                lastDate: DateTime.now(),
                                onChanged: (val) {
                                  setState(() {
                                    date = val.toString();
                                    _isToday = date==DateTime.now().toString().split(' ')[0];
                                    _dateMask = _isToday?'d MMM yyyy':'EEEE, d MMM yyyy';
                                    _data = _buildReportList();
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                )
                            )
                        )
                      ]
                  )
                ]
            ),
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      _showLogoutModalDialog(context);
                    },
                    child: const Icon(Icons.logout),
                  )
              ),
            ],
          ),
          body: FutureBuilder(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return listViewReport(context, snapshot.data as List?);
              }
              return const Scaffold(
                  body: Center(
                      child: CircularProgressIndicator()
                  )
              );
            },
          )
      )
    );
  }

  Widget listViewReport(BuildContext context, List? data){

    return data==null || data.isEmpty ? const Center(
      heightFactor: 4,
      child: Text("No reports available.", style: TextStyle(fontSize: 16), overflow: TextOverflow.visible),
    ) :
    Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Visibility(
            visible: !_isToday,
            child: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                    color: Color(0xFFFFECDA),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))
                ),
                child: Row(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: const Icon(Icons.warning_rounded)
                      ),
                      const Flexible(
                        child: Text("You view reports on a past date, but cannot edit it.", style: TextStyle(fontSize: 16), overflow: TextOverflow.visible),
                      )
                    ]
                )
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: data.length,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  itemBuilder: (context, index) {
                    return Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: ListTile(
                          textColor: Colors.black,
                          contentPadding: const EdgeInsets.only(top: 10, bottom: 15),
                          onTap: () {
                            //if(_isToday) {
                              NavigationService.instance.navigateToRoute(MaterialPageRoute(
                                  builder: (BuildContext context){
                                    return ReportForm(data: data[index], progressReport: _progressReport, milks: data[index]['report']['milk_sessions'], isToday: _isToday);
                                  }
                              ));
                            //}
                          },
                          title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(padding: const EdgeInsets.only(bottom:3), child: Text(data[index]['nanny_name'], style: const TextStyle(fontSize: 15))),
                                Padding(padding: const EdgeInsets.only(bottom:8), child: Text(data[index]['child_name'], style: const TextStyle(fontSize: 20)))
                              ]
                          ),
                          subtitle: Row(
                            children: [
                              Text(data[index]['status'], style: const TextStyle(fontSize: 16)),
                              data[index]['status'].toString().split(' ')[0]=='Shared'?
                                Row(
                                  children: const [
                                    SizedBox(width: 5),
                                    Icon(Icons.check_circle, color: Colors.green),
                                  ]
                                )
                                  :Container(),
                            ]
                          ),
                          leading: CustomPaint(
                            foregroundPainter: ProgressPainter((data[index]['progress']).toDouble()),
                            child: CircleAvatar(
                              child: Text(data[index]['child_name'].toString().toUpperCase()[0]+(data[index]['child_name'].toString().split(' ').length>1?data[index]['child_name'].toString().split(' ')[1].toUpperCase()[0]:''), style: const TextStyle(fontSize: 27)),
                              backgroundColor: data[index]['report']!=null && data[index]['report']['attendance']=='0'?const Color(0xFFFFCB9A):const Color(0xFFDDF284),
                              foregroundColor: Colors.black,
                              radius: 30,
                            ),
                          ),
                          shape: const Border(
                              bottom: BorderSide(color: Colors.black26)
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.black87),
                        )
                    );
                  })
          )
        ]
    );
  }
}
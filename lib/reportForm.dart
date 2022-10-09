import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:kiwi_app_daycare/progressPainter.dart';

import 'api.dart';
import 'attendance.dart';
import 'moodAndHealth.dart';
import 'meals.dart';
import 'milk.dart';
import 'nap.dart';
import 'navigationService.dart';
import 'potty.dart';
import 'activities.dart';
import 'bath.dart';
import 'medication.dart';
import 'thingsToBringTmr.dart';
import 'specialNotes.dart';
import 'reportPdf.dart';


class ReportForm extends StatefulWidget{
  final dynamic data;
  dynamic milks;
  dynamic naps;
  final Function progressReport;
  final bool isToday;
  final List<String> requiredList;

  ReportForm({Key? key, required this.data, required this.progressReport, required this.milks, required this.naps, required this.isToday, required this.requiredList}) : super(key: key) {
    if(milks != null && milks.runtimeType == String) {
      milks = milks.replaceAll('null', '||||');
      milks = milks.replaceAll('{', '{"');
      milks = milks.replaceAll(': ', '": "');
      milks = milks.replaceAll(', ', '", "');
      milks = milks.replaceAll('}', '"}');
      milks = milks.replaceAll('}",', '},');
      milks = milks.replaceAll(', "{', ', {');
      milks = milks.replaceAll('"||||"', 'null');
      milks = jsonDecode(milks);

      milks.sort((a, b) => a['time'].toString().compareTo(b['time'].toString()));

      for(int i=0;i<milks.length;i++) {
        milks[i].removeWhere((key, value) => value == null);
        // time remove second
        if(milks[i]['time']!=null) {
          milks[i]['time'] = milks[i]['time'].toString().split(':')[0]+':'+milks[i]['time'].toString().split(':')[1];
        }
      }
    }

    if(naps != null && naps.runtimeType == String) {
      naps = naps.replaceAll('null', '||||');
      naps = naps.replaceAll('{', '{"');
      naps = naps.replaceAll(': ', '": "');
      naps = naps.replaceAll(', ', '", "');
      naps = naps.replaceAll('}', '"}');
      naps = naps.replaceAll('}",', '},');
      naps = naps.replaceAll(', "{', ', {');
      naps = naps.replaceAll('"||||"', 'null');
      naps = jsonDecode(naps);

      naps.sort((a, b) => a['start'].toString().compareTo(b['start'].toString()));

      for(int i=0;i<naps.length;i++) {
        naps[i].removeWhere((key, value) => value == null);
        // time remove second
        if(naps[i]['start']!=null) {
          naps[i]['start'] = naps[i]['start'].toString().split(':')[0]+':'+naps[i]['start'].toString().split(':')[1];
        }
        if(naps[i]['end']!=null) {
          naps[i]['end'] = naps[i]['end'].toString().split(':')[0]+':'+naps[i]['end'].toString().split(':')[1];
        }
      }
    }

  }

  @override
  _ReportFormState createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  late Map<String, dynamic> _data;
  Map<String, bool?> _isValid = {};
  final _validGroupFields = {
    'isvalid_arrival_time': ['arrival_time'],
    'isvalid_temperature': ['temperature'],
    'isvalid_weight': ['weight'],
    // 'isvalid_naptime1': ['naptime1_start', 'naptime1_end', 'naptime1_notes'],
    // 'isvalid_naptime2': ['naptime2_start', 'naptime2_end', 'naptime2_notes'],
    // 'isvalid_naptime3': ['naptime3_start', 'naptime3_end', 'naptime3_notes'],
    'isvalid_num_of_potty': ['num_of_potty', 'potty_notes']
  };
  List<Map<String, dynamic>> _milks = [];
  List<Map<String, dynamic>> _naps = [];
  List<bool?> _isValidMilk = [];
  List<bool?> _isValidNap = [];
  int _initLengthMilks = 0;
  int _initLengthNaps = 0;
  bool _isUpdated = false;
  bool _isConfirmKirimLaporan = false;

  // required per category
  List<bool> _reqCategoryFilled = [false, false, false, false, false, false, false, false, false, false, false];
  final List<List<String>> _reqCategoryFields = [
    ['attendance', 'arrival_time'],
    ['weight', 'temperature', 'child_feeling', 'condition'],
    ['breakfast', 'morningsnack', 'lunch', 'afternoonsnack', 'dinner', 'breakfast_qty', 'morningsnack_qty', 'lunch_qty', 'afternoonsnack_qty', 'dinner_qty'],
    [],
    [],
    ['num_of_potty'],
    ['activities'],
    ['is_morning_bath', 'is_afternoon_bath'],
    ['medication'],
    ['things_tobring_tmr'],
    ['special_notes']
  ];
  List<List<String>> _reqCategoryFieldsMapped = [];
  Map<String, int> _reqAtrMapped = {};

  @override
  void initState() {
    super.initState();

    _data = json.decode(json.encode(widget.data));

    // is valid potty
    if(_data['report']['num_of_potty']!=null && _data['report']['num_of_potty']!='') {
      _isValid['isvalid_num_of_potty'] = true;
    }

    // is valid nap time
    // if(_data['report']['naptime1_start']!=null && _data['report']['naptime1_start']!='' &&
    //     _data['report']['naptime1_end']!=null && _data['report']['naptime1_end']!='') {
    //   _isValid['isvalid_naptime1'] = true;
    // }
    // if(_data['report']['naptime2_start']!=null && _data['report']['naptime2_start']!='' &&
    //     _data['report']['naptime2_end']!=null && _data['report']['naptime2_end']!='') {
    //   _isValid['isvalid_naptime2'] = true;
    // }
    // if(_data['report']['naptime3_start']!=null && _data['report']['naptime3_start']!='' &&
    //     _data['report']['naptime3_end']!=null && _data['report']['naptime3_end']!='') {
    //   _isValid['isvalid_naptime3'] = true;
    // }

    // prefill static attribute
    if(_data['report']['nanny_id']==null) {
      _data['report']['nanny_id'] = _data['nanny_id'].toString();
    }
    if(_data['report']['child_id']==null) {
      _data['report']['child_id'] = _data['child_id'].toString();
    }
    if(_data['report']['location_id']==null) {
      _data['report']['location_id'] = _data['location_id'].toString();
    }
    if(_data['report']['date']==null) {
      _data['report']['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
    }

    if(widget.milks!=null && widget.milks.isNotEmpty) {
      _initLengthMilks = widget.milks.length;
      for(int i=0;i<_initLengthMilks;i++) {
        _milks.add(json.decode(json.encode(widget.milks[i]))); // widget.milks;
        _isValidMilk.add(true);
      }
    }else{
      _milks.add({});
      _isValidMilk.add(null);
    }

    if(widget.naps!=null && widget.naps.isNotEmpty) {
      _initLengthNaps = widget.naps.length;
      for(int i=0;i<_initLengthNaps;i++) {
        _naps.add(json.decode(json.encode(widget.naps[i]))); // widget.naps;
        _isValidNap.add(true);
      }
    }else{
      _naps.add({});
      _isValidNap.add(null);
    }

    // required fields filled
    for(int i=0;i<_reqCategoryFields.length;i++) {
      _reqCategoryFieldsMapped.add([]);
      for(int j=0;j<_reqCategoryFields[i].length;j++) {
        if(widget.requiredList.contains(_reqCategoryFields[i][j])) {
          _reqCategoryFieldsMapped[i].add(_reqCategoryFields[i][j]);
          _reqAtrMapped.addAll({_reqCategoryFields[i][j]: i});
        }
      }
    }
    for(int i=0;i<_reqCategoryFieldsMapped.length;i++) {
      bool _flagTemp = true;
      for(int j=0;j<_reqCategoryFieldsMapped[i].length;j++) {
        if(_data['report'][_reqCategoryFieldsMapped[i][j]]==null || _data['report'][_reqCategoryFieldsMapped[i][j]].toString().trim()=='') {
          _flagTemp = false;
          break;
        }
      }
      if(_flagTemp && _reqCategoryFieldsMapped[i].isNotEmpty) {
        _reqCategoryFilled[i] = true;
      }
    }

  }

  void _addNapTime() {
    if(widget.isToday) {
      setState(() {
        _naps.add({});
        _isValidNap.add(null);
      });
    }
  }

  dynamic _getNapData(int index, String label) {
    return _naps[index][label];
  }

  void _setNapData(int index, String label, dynamic newData) {
    if(widget.isToday) {
      setState(() {
        _naps[index][label] = newData;
        _isConfirmKirimLaporan = true;
      });
    }
  }

  bool? _getIsValidNap(int index) {
    return _isValidNap[index];
  }

  void _setIsValidNap(int index, bool valid) {
    if(widget.isToday) {
      setState(() {
        _isValidNap[index] = valid;
      });
    }
  }

  void _addMilkSession() {
    if(widget.isToday) {
      setState(() {
        _milks.add({});
        _isValidMilk.add(null);
      });
    }
  }

  dynamic _getMilkData(int index, String label) {
    return _milks[index][label];
  }

  void _setMilkData(int index, String label, dynamic newData) {
    if(widget.isToday) {
      setState(() {
        _milks[index][label] = newData;
        _isConfirmKirimLaporan = true;
      });
    }
  }

  bool? _getIsValidMilk(int index) {
    return _isValidMilk[index];
  }

  void _setIsValidMilk(int index, bool valid) {
    if(widget.isToday) {
      setState(() {
        _isValidMilk[index] = valid;
      });
    }
  }

  dynamic _getData(String label) {
    List<String> arr = label.split(',');
    dynamic d = _data;
    for(String a in arr){
      if(d[a]==null) return null;
      d = d[a];
    }
    return d;
  }

  // report label
  void _setData(String label, dynamic newData) {
    if(widget.isToday) {
      setState(() {
        if (_data['report'] == null) {
          _data['report'] = [];
        }
        _data['report'][label] = newData;

        _data['progress'] = widget.progressReport(_data['report']);
        _data['status'] = (_data['report']['attendance'] == '0' && _data['report']['shared_at'] == null) ? 'Absent' : (
            (_data['progress']<1.0 && _data['report']['attendance']=='1')?'In-progress': (
              _data['report']['shared_at'] != null ? (
                  'Shared at '+(DateFormat(_data['report']['shared_at'].toString().split(' ')[0]==_data['report']['date'].toString()?'HH:mm':'d MMM yyyy HH:mm').format(DateTime.parse(_data['report']['shared_at'].toString().split('.')[0])))
              ):'Ready to share'
            )
        );
        _data['report']['is_ready_to_share'] = _data['progress']==1.0?'1':'0';
      });
      _isConfirmKirimLaporan = true;
      _setRequiredCategory(label);
    }
  }

  void _setRequiredCategory(String label) {
    if(_reqAtrMapped[label]!=null) {
      int i = _reqAtrMapped[label]!;
      bool _reqValid = true;
      for(int j = 0; j < _reqCategoryFieldsMapped[i].length; j++) {
        if(_isValid['isvalid_'+_reqCategoryFieldsMapped[i][j]]==false || _data['report'][_reqCategoryFieldsMapped[i][j]] == null || _data['report'][_reqCategoryFieldsMapped[i][j]].toString().trim() == '') {
          _reqValid = false;
          break;
        }
      }
      setState(() {
        _reqCategoryFilled[i] = _reqValid;
      });
    }
  }

  bool? _getIsValid(String label) {
    return _isValid[label];
  }

  void _setIsValid(String label, bool valid) {
    if(widget.isToday) {
      setState(() {
        _isValid[label] = valid;
      });

      _setRequiredCategory(label.replaceAll('isvalid_', ''));
    }
  }

  void _validateForm() {
    for(String s in _validGroupFields.keys) {
      if(_isValid[s]!=null && _isValid[s]==false) {
        for(String f in (_validGroupFields[s] as List)) {
          setState(() {
            _data['report'].remove(f);
          });
        }
      }
    }
  }

  Future<void> _formSubmit({bool isBack = true, bool sharePastDate = false}) async {
    if(widget.isToday) {
      _validateForm();
      Map<String, dynamic> report = _data['report'];

      if (_data['id'] != null) {
        // report edit

        if (widget.data['report'] == null || !mapEquals(report, widget.data['report'])) {
          // if changes exist
          _isUpdated = true;
          // set utc +7
          if (report['shared_at'] != null && report['shared_at'] != '') {
            report['shared_at'] = report['shared_at'].replaceAll(' +7', '');
            report['shared_at'] = report['shared_at'] + ' +7';
          }
          String shared_at = (report['attendance'].toString()==widget.data['report']['attendance'].toString()) ?
            (report['shared_at'] ?? widget.data['report']['shared_at'] ?? '') : '';
          if (report['attendance'].toString() == '0') {
            await Api.setReportAbsent(_data['id'].toString(), shared_at: shared_at);
          } else {
            if(report['attendance'].toString()=='1' && widget.data['report']['attendance'].toString()=='0') {
              report['is_ready_to_share'] = _data['progress']==1.0?'1':'0';
            }
            await Api.editReport(_data['id'].toString(), report);
          }
          // unset utc +7
          if (report['shared_at'] != null && report['shared_at'] != '') {
            report['shared_at'] = report['shared_at'].replaceAll(' +7', '');
          }
        }
      } else if (report['attendance'] != null) {
        // report add

        if (report['attendance'].toString() == '0') {
          // set absent
          report = <String, String>{};
          report['attendance'] = '0';
          report['nanny_id'] = _data['nanny_id'].toString();
          report['child_id'] = _data['child_id'].toString();
          report['location_id'] = _data['location_id'].toString();
          report['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
          // if(_data['report']['shared_at']!=null) {
          //   report['shared_at'] = _data['report']['shared_at'].toString();
          // } else if(widget.data['report']['shared_at']!=null) {
          //   report['shared_at'] = widget.data['report']['shared_at'].toString();
          // }
        }

        _isUpdated = true;
        _data['id'] = await Api.addReport(report);
      }
      if (report['attendance'].toString() == '1' &&
          (_data['id'] != null && _data['id'] != false)) {
        await _formMilkSubmit();
        await _formNapSubmit();
      }
    } else if(sharePastDate) {
      final pd_shared_at = DateTime.now().toString().split('.')[0];
      setState(() {
        _data['report']['shared_at'] = pd_shared_at;
        _data['status'] = 'Shared at ' + (DateFormat(
            'd MMM yyyy HH:mm').format(DateTime.parse(
            _data['report']['shared_at'].toString().replaceAll(' +7', '').toString().split('.')[0])));
      });
      await Api.editReport(_data['id'].toString(), {'shared_at': pd_shared_at + ' +7'});
      _isUpdated = true;
    }

    if(isBack) {
      if (_isUpdated) {
        NavigationService.instance.navigateUntil("home", args: _data['report']['date']);
      } else {
        NavigationService.instance.goBack();
      }
    }
  }

  Future<void> _formNapSubmit() async {
    List napsStart = [];
    List napsEnd = [];
    for(int i=0;i<_naps.length;i++) {
      if(_isValidNap[i]==true) {
        if(_naps[i]['id']!=null) {
          napsStart.add(_naps[i]['start']);
          napsEnd.add(_naps[i]['end']);
          if(widget.naps[i]==null || !mapEquals(_naps[i], widget.naps[i])) {
            _isUpdated = true;
            await Api.editNapTime(_naps[i].remove('id').toString(), _naps[i]);
          }
        } else {
          _naps[i]['report_id'] = _data['id'].toString();
          _isUpdated = true;

          if(napsStart.where((item) => item == _naps[i]['start']).isEmpty && napsEnd.where((item) => item == _naps[i]['end']).isEmpty) {
            _naps[i]['id'] = await Api.addNapTime(Map<String, dynamic>.from(_naps[i]));
            napsStart.add(_naps[i]['start']);
            napsEnd.add(_naps[i]['end']);
          }
        }
      }
    }
  }

  Future<void> _formMilkSubmit() async {
    List milksTime = [];
    for(int i=0;i<_milks.length;i++) {
      if(_isValidMilk[i]==true) {
        if(_milks[i]['id']!=null) {
          milksTime.add(_milks[i]['time']);
          if(widget.milks[i]==null || !mapEquals(_milks[i], widget.milks[i])) {
            _isUpdated = true;
            await Api.editMilkSession(_milks[i].remove('id').toString(), _milks[i]);
          }
        } else {
          _milks[i]['report_id'] = _data['id'].toString();
          _isUpdated = true;

          if(milksTime.where((item) => item == _milks[i]['time']).isEmpty) {
            _milks[i]['id'] = await Api.addMilkSession(Map<String, dynamic>.from(_milks[i]));
            milksTime.add(_milks[i]['time']);
          }
        }
      }
    }
  }

  void onBack(context) async {
    await _formSubmit(isBack: false);
    if(widget.isToday && _isUpdated && (_data['report']['attendance']=='0' || _data['progress']==1.0) && _isConfirmKirimLaporan) {
        _showSendReportDialog(context, 'back');
    } else if (_isUpdated) {
      NavigationService.instance.navigateUntil("home", args: _data['report']['date']);
    } else {
      NavigationService.instance.goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    int _reqCategoryCounter = 0;
    return WillPopScope(
        onWillPop: () async {
          onBack(context);
          return false;
        },
        child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.0,
          leading: GestureDetector(
              onTap: () {
                onBack(context);
              },
              child: const Icon(Icons.arrow_back)
          ),
          title: Row(
              children: [
                Visibility(
                  visible: _data['report']['date'].toString()==DateTime.now().toString().split(' ')[0],
                  child: const Text("Today, ", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
                ),
                Text(DateFormat(_data['report']['date'].toString()==DateTime.now().toString().split(' ')[0]?'d MMM yyyy':'EEEE, d MMM yyyy').format(DateTime.parse(_data['report']['date'].toString().split('.')[0])), style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16))
              ]
          ),
          actions: [
            GestureDetector(
                onTap: () async {
                  if (_data['report']['attendance'] == '0' || _data['progress'] == 1.0) {
                    // if(widget.isToday) {
                    //   await _showSendReportDialog(context, 'share');
                    // } else {
                      Fluttertoast.showToast(msg: 'Processing to share, please wait...');
                      reportPdf(context, _data, _milks, _naps, _setData, _formSubmit, widget.isToday);
                    //}
                  } else {
                    Fluttertoast.showToast(msg: 'Complete the form first to share');
                  }
                },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.share),
                  )
                )
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(children:[Expanded(child:ListView(
            padding: const EdgeInsets.only(left: 5, right: 5),
            children: [
              Visibility(
                visible: !widget.isToday,
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
                            child: Text("You view a report on a past date and may edit the form, but the changes wont be submitted.", style: TextStyle(fontSize: 16), overflow: TextOverflow.visible),
                          )
                        ]
                    )
                ),
              ),
              Card(
                color: Colors.transparent,
                elevation: 0,
                child: ListTile(
                  textColor: Colors.black,
                  contentPadding: const EdgeInsets.all(10),
                  onTap: () {},
                  title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: const EdgeInsets.only(bottom:3), child: Text(_data['nanny_name'], style: const TextStyle(fontSize: 15))),
                        Padding(padding: const EdgeInsets.only(bottom:8), child: Text(_data['child_nickname'], style: const TextStyle(fontSize: 20)))
                      ]
                  ),
                  subtitle: Row(
                      children: [
                        Text(_data['status'], style: const TextStyle(fontSize: 16)),
                        _data['status'].toString().split(' ')[0]=='Shared'?
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
                    foregroundPainter: ProgressPainter(_data['progress']),
                    child: CircleAvatar(
                      child: Text(_data['child_nickname'].toString().toUpperCase()[0]+(_data['child_nickname'].toString().split(' ').length>1?_data['child_nickname'].toString().split(' ')[1].toUpperCase()[0]:''), style: const TextStyle(fontSize: 27)),
                      backgroundColor: _data['report']!=null && _data['report']['attendance']=='0'?const Color(0xFFFFCB9A):const Color(0xFFDDF284),
                      foregroundColor: Colors.black,
                      radius: 30,
                    ),
                  ),
                ),
              ),
              Attendance(getData: _getData, setData: _setData, getIsValid: _getIsValid, setIsValid: _setIsValid, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              MoodAndHealth(getData: _getData, setData: _setData, getIsValid: _getIsValid, setIsValid: _setIsValid, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              Meals(getData: _getData, setData: _setData, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              Milk(initLength: _initLengthMilks, getMilkData: _getMilkData, setMilkData: _setMilkData, getIsValidMilk: _getIsValidMilk, setIsValidMilk: _setIsValidMilk, addMilkSession: _addMilkSession, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              Nap(initLength: _initLengthNaps, getNapData: _getNapData, setNapData: _setNapData, getIsValidNap: _getIsValidNap, setIsValidNap: _setIsValidNap, addNapTime: _addNapTime, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              Potty(getData: _getData, setData: _setData, getIsValid: _getIsValid, setIsValid: _setIsValid, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              Activities(getData: _getData, setData: _setData, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              Bath(getData: _getData, setData: _setData, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              Medication(getData: _getData, setData: _setData, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              ThingsToBringTmr(getData: _getData, setData: _setData, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++]),
              SpecialNotes(getData: _getData, setData: _setData, reqCategoryFilled: _reqCategoryFilled[_reqCategoryCounter++])
            ]
        )),
            Container(
                padding: const EdgeInsets.all(15),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                if(widget.isToday) {
                                  if (_data['report']['attendance'] == '0' || _data['progress'] == 1.0) {
                                    _showSendReportDialog(context, 'send');
                                  } else {
                                    _showReportNotFinishDialog(context);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(primary: (widget.isToday && (_data['report']['attendance']=='0' || _data['progress']==1.0))?const Color(0xFF197CD0):Colors.grey),
                              child: Container(
                                  padding: const EdgeInsets.all(15),
                                  child: const Text('KIRIM LAPORAN', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 15))
                              )
                          )
                      )
                    ]
                )
            )])
    ));
  }

  _showSendReportDialog(context, String trigger){
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
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Kirim laporan sekarang?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),
                          Text('Jika dilanjutkan, parent akan segera menerima laporan.', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 15),
                          Text('Anda tetap bisa memperbarui informasi setelah laporan ini dikirim.', style: TextStyle(fontSize: 16))
                        ]
                      )
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              NavigationService.instance.goBack();

                              if(trigger == 'share') {
                                Fluttertoast.showToast(msg: 'Processing to share, please wait...');
                                reportPdf(context, _data, _milks, _naps, _setData, _formSubmit, widget.isToday);
                              } else if(trigger == 'back') {
                                if (_isUpdated) {
                                  NavigationService.instance.navigateUntil("home", args: _data['report']['date']);
                                } else {
                                  NavigationService.instance.goBack();
                                }
                              }
                            },
                            child: const Text('TUNGGU DULU', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 30),
                            child: GestureDetector(
                                onTap: () async {
                                  if(trigger == 'send' || trigger == 'share') {
                                    if(trigger == 'send') {
                                      _setData('shared_at', DateTime.now().toString().split('.')[0]);
                                    }
                                    await _formSubmit(isBack: false);
                                  }

                                  Fluttertoast.showToast(msg: 'Processing to send report, please wait...');
                                  await Api.sendReportNotif(_data['id'].toString());
                                  Fluttertoast.showToast(msg: 'Report notification successfully sent to parent.');

                                  NavigationService.instance.goBack();

                                  if(trigger == 'share') {
                                    Fluttertoast.showToast(msg: 'Processing to share, please wait...');
                                    reportPdf(context, _data, _milks, _naps, _setData, _formSubmit, widget.isToday);
                                  } else if(trigger == 'back') {
                                    if (_isUpdated) {
                                      NavigationService.instance.navigateUntil("home", args: _data['report']['date']);
                                    } else {
                                      NavigationService.instance.goBack();
                                    }
                                  }
                                  setState(() {
                                    _isConfirmKirimLaporan = false;
                                  });
                                },
                                child: const Text('KIRIM', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold))
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

  _showReportNotFinishDialog(context){
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
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Laporan belum selesai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            Text('Ada beberapa informasi yang belum Anda isi.', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 15),
                            Text('Jika anak tidak hadir, mohon klik "Absent" sebelum mengirim laporan.', style: TextStyle(fontSize: 16))
                          ]
                      )
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            NavigationService.instance.goBack();
                          },
                          child: const Text('OK', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 1, fontWeight: FontWeight.bold)),
                        )
                      ]
                  )
                ],
              ),
            ),
          );
        });
  }
}

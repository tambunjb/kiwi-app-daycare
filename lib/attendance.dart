import 'package:flutter/material.dart';

import 'accordion.dart';


class Attendance extends StatefulWidget {
  Function getData;
  Function setData;
  Function getIsValid;
  Function setIsValid;

  Attendance({Key? key, required this.getData, required this.setData, required this.getIsValid, required this.setIsValid}) : super(key: key);

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance>{
  TextEditingController _hourCtrl = TextEditingController();
  TextEditingController _minuteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    String? time = widget.getData('report,arrival_time');
    if(time!=null && time!='') {
      _hourCtrl = TextEditingController(text: time.split(':').isNotEmpty?time.split(':')[0]:'');
      _minuteCtrl = TextEditingController(text: time.split(':').length>1?time.split(':')[1]:'');
    }

    _hourCtrl.addListener(_setArrivalTime);
    _minuteCtrl.addListener(_setArrivalTime);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _hourCtrl.dispose();
    _minuteCtrl.dispose();

    super.dispose();
  }

  void _setArrivalTime() {
    if(_hourCtrl.text.trim()!='' && _minuteCtrl.text.trim()!='') {
      if(int.parse(_hourCtrl.text.trim()) > 23) {
        setState(() {
          _hourCtrl = TextEditingController(text: '23');
        });
      }
      if(int.parse(_minuteCtrl.text.trim()) > 59) {
        setState(() {
          _minuteCtrl = TextEditingController(text: '59');
        });
      }
      widget.setIsValid('isvalid_arrival_time', true);
    }else{
      widget.setIsValid('isvalid_arrival_time', false);
    }
    widget.setData('arrival_time', _hourCtrl.text.trim()+':'+_minuteCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Accordion(title:'Attendance', leadIcon: const Icon(Icons.event_available, size: 30),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  widget.setData('attendance', '1');
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                                    decoration: BoxDecoration(
                                        color: widget.getData('report,attendance')=='1'?const Color(0xFFADD9FF):Colors.white,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0))
                                    ),
                                    child: const Text('Present', style: TextStyle(fontSize: 16))
                                )
                            )
                        ),
                        Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  widget.setData('attendance', '0');
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                                    decoration: BoxDecoration(
                                        color: widget.getData('report,attendance')=='0'?const Color(0xFFADD9FF):Colors.white,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: const BorderRadius.only(topRight: Radius.circular(5.0), bottomRight: Radius.circular(5.0))
                                    ),
                                    child: const Text('Absent', style: TextStyle(fontSize: 16))
                                )
                            )
                        )
                      ]
                  ),
                  Visibility(
                      visible: widget.getData('report,attendance')=='1',
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(top: 15, bottom: 10),
                                child: const Text('Arrival time', style: TextStyle(fontSize: 15))
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: 60,
                                      child: TextField(
                                        maxLength: 2,
                                        textAlign: TextAlign.center,
                                        controller: _hourCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          filled: true,
                                          fillColor: Colors.white,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blue),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey),
                                          ),
                                        ),
                                      )
                                  ),
                                  const Text(' : ', style: TextStyle(fontSize: 16)),
                                  SizedBox(
                                      width: 60,
                                      child: TextField(
                                        maxLength: 2,
                                        textAlign: TextAlign.center,
                                        controller: _minuteCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          filled: true,
                                          fillColor: Colors.white,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blue),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey),
                                          ),
                                        ),
                                      )
                                  ),
                                ]
                            ),
                            Visibility(
                              visible: widget.getData('report,attendance')=='1' && widget.getIsValid('isvalid_arrival_time')==false,
                              child: Container(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: const Text('Please enter a valid arrival time', style: TextStyle(fontSize: 15, color: Colors.red))
                              ),
                            )
                          ]
                      )
                  )
                ]
            ),
            showContent: true
        ),
      ]
    );
  }
}

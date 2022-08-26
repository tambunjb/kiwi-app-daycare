import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'accordion.dart';


class Milk extends StatefulWidget {
  Function getMilkData;
  Function setMilkData;
  Function getIsValidMilk;
  Function setIsValidMilk;
  Function addMilkSession;
  int initLength;
  bool reqCategoryFilled;

  Milk({Key? key, required this.initLength, required this.getMilkData, required this.setMilkData, required this.getIsValidMilk, required this.setIsValidMilk, required this.addMilkSession, required this.reqCategoryFilled}) : super(key: key);

  @override
  _MilkState createState() => _MilkState();
}

class _MilkState extends State<Milk> {
  final List<TextEditingController> _hourCtrl = [];
  final List<TextEditingController> _minuteCtrl = [];
  final List<TextEditingController> _volumeCtrl = [];
  final List<TextEditingController> _noteCtrl = [];
  final List<bool?> _notes = [];

  @override
  void initState() {
    super.initState();

    for(int i=0;i<widget.initLength;i++) {
      String? time = widget.getMilkData(i, 'time');
      _hourCtrl.add(TextEditingController(text: time!=null?time.split(':')[0]:''));
      _minuteCtrl.add(TextEditingController(text: time!=null?time.split(':')[1]:''));
      String? volume = widget.getMilkData(i, 'volume');
      _volumeCtrl.add(TextEditingController(text: volume ?? ''));
      String? notes = widget.getMilkData(i, 'notes');
      _noteCtrl.add(TextEditingController(text: (notes!=null && notes!='')?notes:''));
      _notes.add((notes!=null && notes!='')?true:false);

      _hourCtrl[i].addListener(() => _setTime(i));
      _minuteCtrl[i].addListener(() => _setTime(i));
      _volumeCtrl[i].addListener(() => _setVolume(i));
      _noteCtrl[i].addListener(() => _setNotes(i));
    }

    if(widget.initLength==0) {
      _hourCtrl.add(TextEditingController());
      _minuteCtrl.add(TextEditingController());
      _volumeCtrl.add(TextEditingController());
      _noteCtrl.add(TextEditingController());

      _hourCtrl[0].addListener(() => _setTime(0));
      _minuteCtrl[0].addListener(() => _setTime(0));
      _volumeCtrl[0].addListener(() => _setVolume(0));
      _noteCtrl[0].addListener(() => _setNotes(0));
      _notes.add(null);
    }
  }

  void _setTime(int i) {
    if(_hourCtrl[i].text.trim()!='' && int.parse(_hourCtrl[i].text.trim()) > 23) {
      setState(() {
        _hourCtrl[i] = TextEditingController(text: '23');
      });
    }
    if(_minuteCtrl[i].text.trim()!='' && int.parse(_minuteCtrl[i].text.trim()) > 59) {
      setState(() {
        _minuteCtrl[i] = TextEditingController(text: '59');
      });
    }
    widget.setMilkData(i, 'time', _hourCtrl[i].text.trim()+':'+_minuteCtrl[i].text.trim());
    _setIsValidMilk(i);
  }

  void _setVolume(int i) {
    widget.setMilkData(i, 'volume', _volumeCtrl[i].text.trim());
    _setIsValidMilk(i);
  }

  void _setNotes(int i) {
    widget.setMilkData(i, 'notes', _noteCtrl[i].text.trim());
  }

  void _addMilkSession() {
    setState(() {
      _hourCtrl.add(TextEditingController());
      _minuteCtrl.add(TextEditingController());
      _volumeCtrl.add(TextEditingController());
      _noteCtrl.add(TextEditingController());
      _notes.add(null);

      widget.addMilkSession();
      int i = _hourCtrl.length-1;

      _hourCtrl[i].addListener(() => _setTime(i));
      _minuteCtrl[i].addListener(() => _setTime(i));
      _volumeCtrl[i].addListener(() => _setVolume(i));
      _noteCtrl[i].addListener(() => _setNotes(i));
    });
  }

  void _setIsValidMilk(int index) {
    String hour = _hourCtrl[index].text.trim();
    String minute = _minuteCtrl[index].text.trim();
    String volume = _volumeCtrl[index].text.trim();

    if(hour!='' && minute!='' && volume!='') {
      widget.setIsValidMilk(index, true);
    }else{
      widget.setIsValidMilk(index, false);
    }
  }

  @override
  void dispose() {
    for(int i=0;i<_hourCtrl.length;i++) {
      _hourCtrl[i].dispose();
      _minuteCtrl[i].dispose();
      _volumeCtrl[i].dispose();
      _noteCtrl[i].dispose();
    }
    super.dispose();
  }

  String _getTotalVolume(){
    double _totalVolume = 0;
    for(TextEditingController vol in _volumeCtrl){
      if(vol.text.trim()!='') {
        _totalVolume += double.parse(vol.text.trim());
      }
    }
    RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    return _totalVolume.toString().replaceAll(regex, '');
  }

  void reset(int index){
    setState(() {
      _hourCtrl[index] = TextEditingController();
      _minuteCtrl[index] = TextEditingController();
      _volumeCtrl[index] = TextEditingController();
      // _noteCtrl[index] = TextEditingController();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for(int i = 0; i < _hourCtrl.length; i++) {
      items.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: const Text('Time', style: TextStyle(fontSize: 15))
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: 60,
                                    child: TextField(
                                      maxLength: 2,
                                      textAlign: TextAlign.center,
                                      controller: _hourCtrl[i],
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
                                      controller: _minuteCtrl[i],
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
                        ]
                    ),
                  ),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: const Text('Volume', style: TextStyle(fontSize: 15))
                            ),
                            Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _volumeCtrl[i],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        suffixIcon: Padding(padding: EdgeInsets.only(right: 15), child: Text(" ml", style: TextStyle(fontSize: 16))),
                                        suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
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
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: GestureDetector(
                                        onTap: () {
                                          reset(i);
                                        },
                                        child: const Icon(Icons.close_rounded)
                                      )
                                  )
                                ]
                            )
                          ]
                      )
                  )
                ]
            ),
            Visibility(
              visible: widget.getIsValidMilk(i) == false,
              child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: const Text('Please enter a valid time and volume', style: TextStyle(fontSize: 15, color: Colors.red))
              ),
            ),
            Visibility(
              visible: _notes[i] != true,
              child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: GestureDetector(
                      onTap: () {
                          if (widget.getIsValidMilk(i) == true) {
                            setState(() {
                              _notes[i] = true;
                            });
                          }
                      },
                      child: const Text('Add notes', style: TextStyle(fontSize: 15, color: Colors.blue))
                  )
              ),
            ),
            Visibility(
                visible: _notes[i] == true,
                child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _noteCtrl[i],
                            decoration: const InputDecoration(
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
                          ),
                          Container(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              child: GestureDetector(
                                  onTap: () {
                                      setState(() {
                                        _noteCtrl[i] = TextEditingController();
                                        _notes[i] = false;
                                      });
                                      widget.setMilkData(i, 'notes', '');
                                  },
                                  child: const Text('Delete note', style: TextStyle(fontSize: 15, color: Colors.blue))
                              )
                          ),
                        ]
                    )
                )
            ),
          ]
        )
      );
    }

    return Accordion(title:"Milk \u2022 "+_getTotalVolume()+" ml", leadIcon: const Icon(Icons.local_drink, size: 30),
        content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items
              ),
              Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.add_circle, size: 27),
                        GestureDetector(
                            onTap: () {
                              _addMilkSession();
                            },
                            child: const Text('  Add milk sessions', style: TextStyle(fontSize: 18, color: Colors.black))
                        ),
                      ]
                  )
              ),
            ]
        ),
        reqCategoryFilled: widget.reqCategoryFilled
    );
  }
}

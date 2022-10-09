import 'package:flutter/material.dart';

import 'accordion.dart';


class Nap extends StatefulWidget {
  Function getNapData;
  Function setNapData;
  Function getIsValidNap;
  Function setIsValidNap;
  Function addNapTime;
  int initLength;
  bool reqCategoryFilled;

  Nap({Key? key, required this.initLength, required this.getNapData, required this.setNapData, required this.getIsValidNap, required this.setIsValidNap, required this.addNapTime, required this.reqCategoryFilled}) : super(key: key);

  @override
  _NapState createState() => _NapState();
}

class _NapState extends State<Nap> {
  final List<TextEditingController> _hourStartCtrl = [];
  final List<TextEditingController> _minuteStartCtrl = [];
  final List<TextEditingController> _hourEndCtrl = [];
  final List<TextEditingController> _minuteEndCtrl = [];
  final List<TextEditingController> _noteCtrl = [];
  final List<bool?> _notes = [];

  @override
  void initState() {
    super.initState();

    for(int i=0;i<widget.initLength;i++) {
      String? start = widget.getNapData(i, 'start');
      _hourStartCtrl.add(TextEditingController(text: start!=null?start.split(':')[0]:''));
      _minuteStartCtrl.add(TextEditingController(text: start!=null?start.split(':')[1]:''));
      String? end = widget.getNapData(i, 'end');
      _hourEndCtrl.add(TextEditingController(text: end!=null?end.split(':')[0]:''));
      _minuteEndCtrl.add(TextEditingController(text: end!=null?end.split(':')[1]:''));
      String? notes = widget.getNapData(i, 'notes');
      _noteCtrl.add(TextEditingController(text: (notes!=null && notes!='')?notes:''));
      _notes.add((notes!=null && notes!='')?true:false);

      _hourStartCtrl[i].addListener(() => _setStart(i));
      _minuteStartCtrl[i].addListener(() => _setStart(i));
      _hourEndCtrl[i].addListener(() => _setEnd(i));
      _minuteEndCtrl[i].addListener(() => _setEnd(i));
      _noteCtrl[i].addListener(() => _setNotes(i));
    }

    if(widget.initLength==0) {
      _hourStartCtrl.add(TextEditingController());
      _minuteStartCtrl.add(TextEditingController());
      _hourEndCtrl.add(TextEditingController());
      _minuteEndCtrl.add(TextEditingController());
      _noteCtrl.add(TextEditingController());

      _hourStartCtrl[0].addListener(() => _setStart(0));
      _minuteStartCtrl[0].addListener(() => _setStart(0));
      _hourEndCtrl[0].addListener(() => _setEnd(0));
      _minuteEndCtrl[0].addListener(() => _setEnd(0));
      _noteCtrl[0].addListener(() => _setNotes(0));
      _notes.add(null);
    }
  }

  void _setStart(int i) {
    if(_hourStartCtrl[i].text.trim()!='' && int.parse(_hourStartCtrl[i].text.trim()) > 23) {
      setState(() {
        _hourStartCtrl[i] = TextEditingController(text: '23');
      });
    }
    if(_minuteStartCtrl[i].text.trim()!='' && int.parse(_minuteStartCtrl[i].text.trim()) > 59) {
      setState(() {
        _minuteStartCtrl[i] = TextEditingController(text: '59');
      });
    }
    widget.setNapData(i, 'start', _hourStartCtrl[i].text.trim()+':'+_minuteStartCtrl[i].text.trim());
    _setIsValidNap(i);
  }

  void _setEnd(int i) {
    if(_hourEndCtrl[i].text.trim()!='' && int.parse(_hourEndCtrl[i].text.trim()) > 23) {
      setState(() {
        _hourEndCtrl[i] = TextEditingController(text: '23');
      });
    }
    if(_minuteEndCtrl[i].text.trim()!='' && int.parse(_minuteEndCtrl[i].text.trim()) > 59) {
      setState(() {
        _minuteEndCtrl[i] = TextEditingController(text: '59');
      });
    }
    widget.setNapData(i, 'end', _hourEndCtrl[i].text.trim()+':'+_minuteEndCtrl[i].text.trim());
    _setIsValidNap(i);
  }

  void _setNotes(int i) {
    widget.setNapData(i, 'notes', _noteCtrl[i].text.trim());
  }

  void _addNapTime() {
    setState(() {
      _hourStartCtrl.add(TextEditingController());
      _minuteStartCtrl.add(TextEditingController());
      _hourEndCtrl.add(TextEditingController());
      _minuteEndCtrl.add(TextEditingController());
      _noteCtrl.add(TextEditingController());
      _notes.add(null);

      widget.addNapTime();
      int i = _hourStartCtrl.length-1;

      _hourStartCtrl[i].addListener(() => _setStart(i));
      _minuteStartCtrl[i].addListener(() => _setStart(i));
      _hourEndCtrl[i].addListener(() => _setEnd(i));
      _minuteEndCtrl[i].addListener(() => _setEnd(i));
      _noteCtrl[i].addListener(() => _setNotes(i));
    });
  }

  void _setIsValidNap(int index) {
    String hourStart = _hourStartCtrl[index].text.trim();
    String minuteStart = _minuteStartCtrl[index].text.trim();
    String hourEnd = _hourEndCtrl[index].text.trim();
    String minuteEnd = _minuteEndCtrl[index].text.trim();

    if(hourStart!='' && minuteStart!='' && hourEnd!='' && minuteEnd!='') {
      widget.setIsValidNap(index, true);
    }else{
      widget.setIsValidNap(index, false);
    }
  }

  @override
  void dispose() {
    for(int i=0;i<_hourStartCtrl.length;i++) {
      _hourStartCtrl[i].dispose();
      _minuteStartCtrl[i].dispose();
      _hourEndCtrl[i].dispose();
      _minuteEndCtrl[i].dispose();
      _noteCtrl[i].dispose();
    }
    super.dispose();
  }

  void reset(int index){
    setState(() {
      _hourStartCtrl[index] = TextEditingController();
      _minuteStartCtrl[index] = TextEditingController();
      _hourEndCtrl[index] = TextEditingController();
      _minuteEndCtrl[index] = TextEditingController();
      // _noteCtrl[index] = TextEditingController();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for(int i = 0; i < _hourStartCtrl.length; i++) {
      items.add(
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 60,
                          child: TextField(
                            maxLength: 2,
                            textAlign: TextAlign.center,
                            controller: _hourStartCtrl[i],
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
                            controller: _minuteStartCtrl[i],
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
                      const Text('  until  ', style: TextStyle(fontSize: 16)),
                      SizedBox(
                          width: 60,
                          child: TextField(
                            maxLength: 2,
                            textAlign: TextAlign.center,
                            controller: _hourEndCtrl[i],
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
                            controller: _minuteEndCtrl[i],
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
                      Expanded(
                          child: GestureDetector(
                                onTap: () {
                                  reset(i);
                                },
                                child: const Icon(Icons.close_rounded)
                            )
                      )
                    ]
                ),
                Visibility(
                  visible: widget.getIsValidNap(i) == false,
                  child: Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: const Text('Please enter a valid nap time',
                          style: TextStyle(fontSize: 15, color: Colors.red))
                  ),
                ),
                Visibility(
                  visible: _notes[i] != true,
                  child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: GestureDetector(
                          onTap: () {
                            if(widget.getIsValidNap(i) == true) {
                              setState(() {
                                _notes[i] = true;
                              });
                            }
                          },
                          child: const Text('Add notes', style: TextStyle(
                              fontSize: 15, color: Colors.blue))
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
                                        widget.setNapData(i, 'notes', '');
                                      },
                                      child: const Text('Delete note',
                                          style: TextStyle(
                                              fontSize: 15, color: Colors.blue))
                                  )
                              ),
                            ]
                        )
                    )
                ),
                const SizedBox(height: 10)
              ]
          )
      );
    }

    return Accordion(title:"Nap times", leadIcon: const Icon(Icons.airline_seat_individual_suite, size: 30),
        content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items
              ),
              Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.add_circle, size: 27),
                        GestureDetector(
                            onTap: () {
                              _addNapTime();
                            },
                            child: const Text('  Add nap times', style: TextStyle(fontSize: 18, color: Colors.black))
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
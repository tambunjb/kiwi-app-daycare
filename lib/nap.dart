import 'package:flutter/material.dart';

import 'accordion.dart';


class Nap extends StatefulWidget {
  Function getData;
  Function setData;
  Function getIsValid;
  Function setIsValid;

  Nap({Key? key, required this.getData, required this.setData, required this.getIsValid, required this.setIsValid}) : super(key: key);

  @override
  _NapState createState() => _NapState();
}

class _NapState extends State<Nap> {
  final List<String> _nap = [];
  final List<String> _napKey = [];
  final List<TextEditingController> _hourStartCtrl = [];
  final List<TextEditingController> _minuteStartCtrl = [];
  final List<TextEditingController> _hourEndCtrl = [];
  final List<TextEditingController> _minuteEndCtrl = [];
  final List<TextEditingController> _notesCtrl = [];
  final List<bool> _notes = [];

  @override
  void initState() {
    super.initState();

    // naptime1
    _napKey.add('naptime1');
    _nap.add('1st nap time');

    // naptime2
    _napKey.add('naptime2');
    _nap.add('2nd nap time');

    // naptime3
    _napKey.add('naptime3');
    _nap.add('3rd nap time');

    // start, end, notes
    for(String n in _napKey){
      String text = (widget.getData('report,'+n+'_start')!=null && widget.getData('report,'+n+'_start')!='')?widget.getData('report,'+n+'_start'):'';
      _hourStartCtrl.add(TextEditingController(text: text!=''?text.split(':')[0]:''));
      _minuteStartCtrl.add(TextEditingController(text: text!=''?text.split(':')[1]:''));

      text = (widget.getData('report,'+n+'_end')!=null && widget.getData('report,'+n+'_end')!='')?widget.getData('report,'+n+'_end'):'';
      _hourEndCtrl.add(TextEditingController(text: text!=''?text.split(':')[0]:''));
      _minuteEndCtrl.add(TextEditingController(text: text!=''?text.split(':')[1]:''));

      text = (widget.getData('report,'+n+'_notes')!=null && widget.getData('report,'+n+'_notes')!='')?widget.getData('report,'+n+'_notes'):'';
      _notesCtrl.add(TextEditingController(text: text));

      _notes.add(text!=''?true:false);
    }

    for(int i=0;i<_napKey.length;i++) {
      void Function() setData = () {
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

        String hourStart = _hourStartCtrl[i].text.trim();
        String minuteStart = _minuteStartCtrl[i].text.trim();
        String hourEnd = _hourEndCtrl[i].text.trim();
        String minuteEnd = _minuteEndCtrl[i].text.trim();

        widget.setData(_napKey[i]+'_start', hourStart+':'+minuteStart);
        widget.setData(_napKey[i]+'_end', hourEnd+':'+minuteEnd);
        if((hourStart!='' && minuteStart!='' && hourEnd!='' && minuteEnd!='') &&
            //(int.parse(hourStart) < 24 && int.parse(minuteStart) < 60 && int.parse(hourEnd) < 24 && int.parse(minuteEnd) < 60) &&
            ((int.parse(hourStart) < int.parse(hourEnd)) ||
                (int.parse(hourStart) == int.parse(hourEnd) && int.parse(minuteStart) < int.parse(minuteEnd)))
        ) {
          widget.setIsValid('isvalid_'+_napKey[i], true);
        }else{
          widget.setIsValid('isvalid_'+_napKey[i], false);
        }
      };
      _hourStartCtrl[i].addListener(setData);
      _minuteStartCtrl[i].addListener(setData);
      _hourEndCtrl[i].addListener(setData);
      _minuteEndCtrl[i].addListener(setData);

      _notesCtrl[i].addListener(() {
        widget.setData(_napKey[i]+'_notes', _notesCtrl[i].text.trim());
      });
    }
  }

  void _deleteNotes(int i) {
    widget.setData(_napKey[i]+'_notes', '');
    setState(() {
      _notesCtrl[i] = TextEditingController();
      _notes[i] = false;
    });
  }

  @override
  void dispose() {
    for(int i=0;i<_napKey.length;i++) {
      _hourStartCtrl[i].dispose();
      _minuteStartCtrl[i].dispose();
      _hourEndCtrl[i].dispose();
      _minuteEndCtrl[i].dispose();
      _notesCtrl[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < _nap.length; i++) {
      items.add(
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(_nap[i], style: const TextStyle(fontSize: 15))
                ),
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
                    ]
                ),
                Visibility(
                  visible: widget.getIsValid('isvalid_'+_napKey[i])==false,
                  child: Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: const Text('Please enter a valid nap time',
                          style: TextStyle(fontSize: 15, color: Colors.red))
                  ),
                ),
                Visibility(
                  visible: !_notes[i],
                  child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: GestureDetector(
                          onTap: () {
                            if(widget.getIsValid('isvalid_'+_napKey[i])==true) {
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
                    visible: _notes[i],
                    child: Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _notesCtrl[i],
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
                                        _deleteNotes(i);
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
              )
            ]
        )
    );
  }
}

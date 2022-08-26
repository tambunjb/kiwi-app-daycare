import 'package:flutter/material.dart';

import 'accordion.dart';


class MoodAndHealth extends StatefulWidget {
  Function getData;
  Function setData;
  Function getIsValid;
  Function setIsValid;
  bool reqCategoryFilled;

  MoodAndHealth({Key? key, required this.getData, required this.setData, required this.getIsValid, required this.setIsValid, required this.reqCategoryFilled}) : super(key: key);

  @override
  _MoodAndHealthState createState() => _MoodAndHealthState();
}

class _MoodAndHealthState extends State<MoodAndHealth> {
  bool _isNotes = false;
  TextEditingController _temperatureCtrl = TextEditingController();
  TextEditingController _weightCtrl = TextEditingController();
  TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    String? temperature = widget.getData('report,temperature');
    if(temperature!=null && temperature!='') {
      _temperatureCtrl = TextEditingController(text: temperature);
    }

    String? weight = widget.getData('report,weight');
    if(weight!=null && weight!='') {
      _weightCtrl = TextEditingController(text: weight);
    }

    String? notes = widget.getData('report,condition_notes');
    if(notes!=null && notes!='') {
      _notesCtrl = TextEditingController(text: notes);
      _isNotes = true;
    }

    _temperatureCtrl.addListener(_setTemperature);
    _weightCtrl.addListener(_setWeight);
    _notesCtrl.addListener(_setNotes);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _temperatureCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _setWeight() {
    widget.setData('weight', _weightCtrl.text.trim());
    if(_weightCtrl.text.trim()=='') {
      widget.setIsValid('isvalid_weight', false);
    }else {
      widget.setIsValid('isvalid_weight', true);
    }
  }

  void _setTemperature() {
    widget.setData('temperature', _temperatureCtrl.text.trim());
    if(_temperatureCtrl.text.trim()=='') {
      widget.setIsValid('isvalid_temperature', false);
    }else {
      widget.setIsValid('isvalid_temperature', true);
    }
  }

  void _setNotes() {
    if(_notesCtrl.text.trim()!='') {
      widget.setData('condition_notes', _notesCtrl.text.trim());
    }
  }

  void _deleteNotes() {
    widget.setData('condition_notes', '');
    setState(() {
      _notesCtrl = TextEditingController();
      _isNotes = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Accordion(title:'Mood and health', leadIcon: const Icon(Icons.tag_faces_rounded, size: 30),
        content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: const Text('How is the child feeling?', style: TextStyle(fontSize: 15))
              ),
              Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              widget.setData('child_feeling', 'happy');
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 20, bottom: 20),
                                decoration: BoxDecoration(
                                    color: widget.getData('report,child_feeling')=='happy'?const Color(0xFFADD9FF):Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0))
                                ),
                                child: const Text('Happy', style: TextStyle(fontSize: 16))
                            )
                        )
                    ),
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              widget.setData('child_feeling', 'sad');
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 20, bottom: 20),
                                decoration: BoxDecoration(
                                  color: widget.getData('report,child_feeling')=='sad'?const Color(0xFFADD9FF):Colors.white,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Text('Sad', style: TextStyle(fontSize: 16))
                            )
                        )
                    ),
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              widget.setData('child_feeling', 'angry');
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 20, bottom: 20),
                                decoration: BoxDecoration(
                                    color: widget.getData('report,child_feeling')=='angry'?const Color(0xFFADD9FF):Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(5.0), bottomRight: Radius.circular(5.0))
                                ),
                                child: const Text('Angry', style: TextStyle(fontSize: 16))
                            )
                        )
                    )
                  ]
              ),
              Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: const Text('Temperature', style: TextStyle(fontSize: 15))
              ),
              TextField(
                controller: _temperatureCtrl,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Tap to enter temperature',
                  suffixIcon: Padding(padding: EdgeInsets.only(right: 15), child: Text(" \u2103", style: TextStyle(fontSize: 16))),
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
              Visibility(
                visible: widget.getIsValid('isvalid_temperature')==false,
                child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: const Text('Please enter a valid temperature', style: TextStyle(fontSize: 15, color: Colors.red))
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: const Text('Is the child healthy or sick?', style: TextStyle(fontSize: 15))
              ),
              Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              widget.setData('condition', 'healthy');
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 20, bottom: 20),
                                decoration: BoxDecoration(
                                    color: widget.getData('report,condition')=='healthy'?const Color(0xFFADD9FF):Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0))
                                ),
                                child: const Text('Healthy', style: TextStyle(fontSize: 16))
                            )
                        )
                    ),
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              widget.setData('condition', 'sick');
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 20, bottom: 20),
                                decoration: BoxDecoration(
                                    color: widget.getData('report,condition')=='sick'?const Color(0xFFADD9FF):Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(5.0), bottomRight: Radius.circular(5.0))
                                ),
                                child: const Text('Sick', style: TextStyle(fontSize: 16))
                            )
                        )
                    )
                  ]
              ),
              Visibility(
                visible: !_isNotes,
                child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: GestureDetector(
                        onTap: () {
                          if(widget.getData('report,condition') != null && widget.getData('report,condition') != '') {
                            setState(() {
                              _isNotes = true;
                            });
                          }
                        },
                        child: const Text('Add notes', style: TextStyle(fontSize: 15, color: Colors.blue))
                    )
                ),
              ),
              Visibility(
                  visible: _isNotes && widget.getData('report,condition')!=null && widget.getData('report,condition')!='',
                  child: Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _notesCtrl,
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
                                      _deleteNotes();
                                    },
                                    child: const Text('Delete note', style: TextStyle(fontSize: 15, color: Colors.blue))
                                )
                            ),
                          ]
                      )
                  )
              ),
              Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: const Text('Weight', style: TextStyle(fontSize: 15))
              ),
              TextField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Tap to enter weight',
                  suffixIcon: Padding(padding: EdgeInsets.only(right: 15), child: Text(" kg", style: TextStyle(fontSize: 16))),
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
              Visibility(
                visible: widget.getIsValid('isvalid_weight')==false,
                child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: const Text('Please enter a valid weight', style: TextStyle(fontSize: 15, color: Colors.red))
                ),
              ),
            ]
        ),
        reqCategoryFilled: widget.reqCategoryFilled
    );
  }
}

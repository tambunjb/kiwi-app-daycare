import 'package:flutter/material.dart';

import 'accordion.dart';


class Medication extends StatefulWidget {
  Function getData;
  Function setData;
  bool reqCategoryFilled;

  Medication({Key? key, required this.getData, required this.setData, required this.reqCategoryFilled}) : super(key: key);

  @override
  _MedicationState createState() => _MedicationState();
}

class _MedicationState extends State<Medication> {
  bool _isNa = false;
  bool _isYes = false;
  bool _isNo = false;
  bool _notes = false;
  TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    String? medication = widget.getData('report,medication');
    if(medication!=null && medication.toString()!='') {
      if(medication=='0') _isNo = true;
      else if(medication=='1') _isYes = true;
      else if(medication=='10') _isNa = true;
    }

    String? notes = widget.getData('report,medication_notes');
    if(notes!=null && notes!='') {
      _notesCtrl = TextEditingController(text: notes);
      _notes = true;
    }

    _notesCtrl.addListener(_setNotes);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();

    super.dispose();
  }

  void _setNotes() {
    widget.setData('medication_notes', _notesCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Accordion(title:'Medication', leadIcon: const Icon(Icons.medical_services, size: 30),
        content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: const Text('Has the child taken medicine?', style: TextStyle(fontSize: 15))
              ),
              Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isNa = true;
                                _isYes = false;
                                _isNo = false;
                              });
                              widget.setData('medication', '10');
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    color: _isNa?const Color(0xFFADD9FF):Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0))
                                ),
                                child: const Text('N.A.', style: TextStyle(fontSize: 16))
                            )
                        )
                    ),
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isNa = false;
                                _isYes = true;
                                _isNo = false;
                              });
                              widget.setData('medication', '1');
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    color: _isYes?const Color(0xFFADD9FF):Colors.white,
                                    border: Border.all(color: Colors.grey),
                                ),
                                child: const Text('Yes', style: TextStyle(fontSize: 16))
                            )
                        )
                    ),
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isNa = false;
                                _isYes = false;
                                _isNo = true;
                              });
                              widget.setData('medication', '0');
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    color: _isNo?const Color(0xFFADD9FF):Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(5.0), bottomRight: Radius.circular(5.0))
                                ),
                                child: const Text('No', style: TextStyle(fontSize: 16))
                            )
                        )
                    )
                  ]
              ),
              Visibility(
                visible: !_notes,
                child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: GestureDetector(
                        onTap: () {
                          if(_isYes || _isNo || _isNa) {
                            setState(() {
                              _notes = true;
                            });
                          }
                        },
                        child: const Text('Add notes', style: TextStyle(fontSize: 15, color: Colors.blue))
                    )
                ),
              ),
              Visibility(
                  visible: _notes,
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
                                      setState(() {
                                        _notesCtrl = TextEditingController();
                                        _notes = false;
                                      });
                                      widget.setData('medication_notes', '');
                                    },
                                    child: const Text('Delete note', style: TextStyle(fontSize: 15, color: Colors.blue))
                                )
                            ),
                          ]
                      )
                  )
              ),
            ]
        ),
        reqCategoryFilled: widget.reqCategoryFilled
    );
  }
}

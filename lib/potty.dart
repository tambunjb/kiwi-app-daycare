import 'package:flutter/material.dart';

import 'accordion.dart';


class Potty extends StatefulWidget {
  Function getData;
  Function setData;
  Function getIsValid;
  Function setIsValid;
  bool reqCategoryFilled;

  Potty({Key? key, required this.getData, required this.setData, required this.getIsValid, required this.setIsValid, required this.reqCategoryFilled}) : super(key: key);

  @override
  _PottyState createState() => _PottyState();
}

class _PottyState extends State<Potty> {
  TextEditingController _pottyCtrl = TextEditingController();
  TextEditingController _notesCtrl = TextEditingController();
  bool _notes = false;

  @override
  void initState() {
    super.initState();

    String? num_of_potty = widget.getData('report,num_of_potty');
    String? potty_notes = widget.getData('report,potty_notes');

    if(num_of_potty!=null && num_of_potty!='') {
      _pottyCtrl = TextEditingController(text: num_of_potty);
    }
    if(potty_notes!=null && potty_notes!='') {
      _notesCtrl = TextEditingController(text: potty_notes);
      _notes = true;
    }

    _pottyCtrl.addListener(_setData);
    _notesCtrl.addListener(() {
      widget.setData('potty_notes', _notesCtrl.text.trim());
    });
  }

  void _setData() {
    widget.setData('num_of_potty', _pottyCtrl.text.trim());
    if(_pottyCtrl.text.trim()!='') {
      widget.setIsValid('isvalid_num_of_potty', true);
    } else {
      widget.setIsValid('isvalid_num_of_potty', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Accordion(title:"Potty", leadIcon: const Icon(Icons.wash, size: 30),
      content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _pottyCtrl,
                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                decoration: const InputDecoration(
                  suffixIcon: Padding(padding: EdgeInsets.only(right: 15), child: Text(" times", style: TextStyle(fontSize: 16))),
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
                visible: widget.getIsValid('isvalid_num_of_potty')==false,
                child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: const Text('Please enter a valid number', style: TextStyle(fontSize: 15, color: Colors.red))
                ),
              ),
              Visibility(
                visible: !_notes,
                child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: GestureDetector(
                        onTap: () {
                          if(widget.getIsValid('isvalid_num_of_potty')==true) {
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
                                      widget.setData('potty_notes', '');
                                      setState(() {
                                        _notesCtrl = TextEditingController();
                                        _notes = false;
                                      });
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

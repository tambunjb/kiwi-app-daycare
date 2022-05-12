import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import 'api.dart';
import 'mealEdit.dart';
import 'accordion.dart';
import 'navigationService.dart';


class Meals extends StatefulWidget {
  Function getData;
  Function setData;

  Meals({Key? key, required this.getData, required this.setData}) : super(key: key);

  @override
  _MealsState createState() => _MealsState();
}

class _MealsState extends State<Meals> {
  final List<String> _mealName = [];
  final List<String> _mealKey = [];
  final List<String> _mealDefault = [];
  final List<bool> _mealNotes = [];
  final List<TextEditingController> _mealNotesCtrl = [];

  @override
  void initState() {
    super.initState();

    // breakfast
    _mealName.add('breakfast');
    _mealKey.add('breakfast');
    _mealDefault.add('');
    // morningsnack
    _mealName.add('morning snack');
    _mealKey.add('morningsnack');
    _mealDefault.add('');
    // lunch
    _mealName.add('lunch');
    _mealKey.add('lunch');
    _mealDefault.add('');
    // afternoonsnack
    _mealName.add('afternoon snack');
    _mealKey.add('afternoonsnack');
    _mealDefault.add('');
    // dinner
    _mealName.add('dinner');
    _mealKey.add('dinner');
    _mealDefault.add('');

    for(int i=0;i<_mealName.length;i++) {
      String? notes = widget.getData('report,'+_mealKey[i]+'_notes');
      _mealNotes.add((notes!=null && notes!='')?true:false);
      _mealNotesCtrl.add((notes!=null && notes!='')?TextEditingController(text: notes):TextEditingController());

      _mealNotesCtrl[i].addListener(() {
        widget.setData(_mealKey[i]+'_notes', _mealNotesCtrl[i].text.trim());
      });
    }

  }

  @override
  void didChangeDependencies() {
    _setMealDefault();

    super.didChangeDependencies();
  }

  Future _setMealDefault() async {
    List mealsConfig = await Api.getMealConfigByLocation(widget.getData('report,location_id'), widget.getData('report,date').split('-')[2]);
    for(int i=0;i<_mealKey.length;i++) {
      int mealIndex = mealsConfig.indexWhere((item) => item['type'] == _mealKey[i]);
      if(mealIndex!=-1) {
        setState(() {
          _mealDefault[i] = mealsConfig[mealIndex]['meal'];
        });
      }
    }
  }

  @override
  void dispose() {
    for(int i=0;i<_mealNotesCtrl.length;i++) {
      _mealNotesCtrl[i].dispose();
    }
    super.dispose();
  }

  void _setMealAuto(int i) {
    String? meal = widget.getData('report,'+_mealKey[i]);
    if(meal==null || meal=='') {
      widget.setData(_mealKey[i], _mealDefault[i]);
    }
  }

  void _deleteNotes(int i) {
    widget.setData(_mealKey[i]+'_notes', '');
    setState(() {
      _mealNotesCtrl[i] = TextEditingController();
      _mealNotes[i] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < _mealName.length; i++) {
      String meal = (widget.getData('report,'+_mealKey[i])==null || widget.getData('report,'+_mealKey[i])=='')?_mealDefault[i]:widget.getData('report,'+_mealKey[i]);
      items.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                    children: [
                      Text(toBeginningOfSentenceCase(_mealName[i]).toString()+': '+meal, style: const TextStyle(fontSize: 15)),
                      Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: GestureDetector(
                              onTap: () {
                                NavigationService.instance.navigateToRoute(MaterialPageRoute(
                                    builder: (BuildContext context){
                                      return MealEdit(child: widget.getData('child_name'), mealKey: _mealKey[i], mealName: _mealName[i], meal: meal, setData: widget.setData);
                                    }
                                ));
                              },
                              child: const Icon(Icons.edit, size: 16)
                          )
                      )
                    ]
                )
            ),
            Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                          onTap: () {
                            if(meal!='') {
                              widget.setData(_mealKey[i] + '_qty', 'none');
                              _setMealAuto(i);
                            }
                          },
                          child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 20, bottom: 20),
                              decoration: BoxDecoration(
                                  color: widget.getData('report,'+_mealKey[i]+'_qty')=='none'?const Color(0xFFADD9FF):Colors.white,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0))
                              ),
                              child: const Text('None', style: TextStyle(fontSize: 16))
                          )
                      )
                  ),
                  Expanded(
                      child: GestureDetector(
                          onTap: () {
                            if(meal!='') {
                              widget.setData(_mealKey[i] + '_qty', 'some');
                              _setMealAuto(i);
                            }
                          },
                          child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 20, bottom: 20),
                              decoration: BoxDecoration(
                                color: widget.getData('report,'+_mealKey[i]+'_qty')=='some'?const Color(0xFFADD9FF):Colors.white,
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Text('Some', style: TextStyle(fontSize: 16))
                          )
                      )
                  ),
                  Expanded(
                      child: GestureDetector(
                          onTap: () {
                            if(meal!='') {
                              widget.setData(_mealKey[i] + '_qty', 'a lot');
                              _setMealAuto(i);
                            }
                          },
                          child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 20, bottom: 20),
                              decoration: BoxDecoration(
                                  color: widget.getData('report,'+_mealKey[i]+'_qty')=='a lot'?const Color(0xFFADD9FF):Colors.white,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(5.0), bottomRight: Radius.circular(5.0))
                              ),
                              child: const Text('A lot', style: TextStyle(fontSize: 16))
                          )
                      )
                  ),
                ]
            ),
            Visibility(
              visible: !_mealNotes[i],
              child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: GestureDetector(
                      onTap: () {
                        if(widget.getData('report,'+_mealKey[i]+'_qty') != null && widget.getData('report,'+_mealKey[i]+'_qty') != '') {
                          setState(() {
                            _mealNotes[i] = true;
                          });
                        }
                      },
                      child: const Text('Add notes', style: TextStyle(fontSize: 15, color: Colors.blue))
                  )
              ),
            ),
            Visibility(
                visible: _mealNotes[i],
                child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _mealNotesCtrl[i],
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
    return Accordion(title:'Meals', leadIcon: const Icon(Icons.fastfood, size: 30),
        content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
        )
    );
  }
}

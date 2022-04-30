import 'package:flutter/material.dart';

import 'navigationService.dart';


class MealEdit extends StatefulWidget {
  final String child;
  final String mealKey;
  final String mealName;
  final String meal;
  final Function setData;

  MealEdit({Key? key, required this.child, required this.mealKey, required this.mealName, required this.meal, required this.setData}) : super(key: key);

  @override
  _MealEditState createState() => _MealEditState();
}

class _MealEditState extends State<MealEdit> {
  bool _mealEditVldt = false;
  TextEditingController _mealEditCtrl = TextEditingController();
  bool _mealEditReset = false;

  @override
  void initState() {
    super.initState();

    _mealEditCtrl = TextEditingController(text: widget.meal);
  }

  @override
  void dispose() {
    _mealEditCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.0,
            leading: GestureDetector(
                onTap: () {
                  _mealEditClose();
                },
                child: const Icon(Icons.close)
            ),
            title: Text("Edit "+widget.mealName),
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('This change will only apply to Child '+widget.child, style: const TextStyle(fontSize: 15))
                  ),
                  TextField(
                    controller: _mealEditCtrl,
                    decoration: InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.blue),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.red),
                      ),
                      errorText: _mealEditVldt ? 'Please enter a valid meal' : null,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _mealEditVldt = _validateMeal();
                        _mealEditReset = val!=widget.meal?true:false;
                      });
                    },
                  ),
                ]
            ),
          ),
          bottomNavigationBar: BottomAppBar(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Visibility(
                          visible: _mealEditReset,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState((){
                                  _mealEditCtrl = TextEditingController(text: widget.meal);
                                  _mealEditVldt = _validateMeal();
                                  _mealEditReset = false;
                                });
                              },
                              child: const Text('RESET', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 2, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Visibility(
                            visible: !_mealEditVldt,
                            child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                child: GestureDetector(
                                    onTap: () {
                                      widget.setData(widget.mealKey, _mealEditCtrl.text.trim());
                                      _mealEditClose();
                                    },
                                    child: const Text('SAVE', style: TextStyle(color: Color(0xFF197CD0), letterSpacing: 2, fontWeight: FontWeight.bold))
                                )
                            )
                        )
                      ]
                  )
              )
          ),
        )
    );
  }

  bool _validateMeal() {
    if (_mealEditCtrl.text.trim()=='') {
      return true;
    }
    return false;
  }

  void _mealEditClose(){
    NavigationService.instance.goBack();
  }
}
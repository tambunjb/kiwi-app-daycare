import 'package:flutter/material.dart';

import 'accordion.dart';


class SpecialNotes extends StatefulWidget {
  Function getData;
  Function setData;
  bool reqCategoryFilled;

  SpecialNotes({Key? key, required this.getData, required this.setData, required this.reqCategoryFilled}) : super(key: key);

  @override
  _SpecialNotesState createState() => _SpecialNotesState();
}

class _SpecialNotesState extends State<SpecialNotes> {
  TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    String? notes = widget.getData('report,special_notes');
    if(notes!=null && notes!='') {
      _notesCtrl = TextEditingController(text: notes);
    }
    _notesCtrl.addListener(_setData);
  }

  void _setData() {
    widget.setData('special_notes', _notesCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Accordion(title:'Special notes', leadIcon: const Icon(Icons.message, size: 30),
        content: TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
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
        reqCategoryFilled: widget.reqCategoryFilled
    );
  }
}
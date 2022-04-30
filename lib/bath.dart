import 'package:flutter/material.dart';

import 'accordion.dart';


class Bath extends StatefulWidget {
  Function getData;
  Function setData;

  Bath({Key? key, required this.getData, required this.setData}) : super(key: key);

  @override
  _BathState createState() => _BathState();
}

class _BathState extends State<Bath> {
  final List<String> _bathKey = [
    'is_morning_bath', 'is_afternoon_bath'
  ];
  final List<String> _bath = [
    'Morning bath', 'Afternoon bath'
  ];
  final List<bool> _isBath = [
    false, false
  ];

  @override
  void initState() {
    super.initState();

    for(int i=0;i<_bathKey.length;i++) {
      if(widget.getData('report,'+_bathKey[i]) != null && int.parse(widget.getData('report,'+_bathKey[i]).toString())==1) {
        _isBath[i] = true;
      }
    }
  }

  void _setData(int index) {
    setState(() {
      _isBath[index] = !_isBath[index];
    });
    widget.setData(_bathKey[index], _isBath[index]?'1':'0');
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for(int i=0;i<_bath.length;i++){
      items.add(
          GestureDetector(
              onTap: () {
                _setData(i);
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                      color: _isBath[i]?const Color(0xFFADD9FF):Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(30))
                  ),
                  child: Text(_bath[i], style: const TextStyle(fontSize: 17))
              )
          )
      );
    }
    return Accordion(title:"Bath", leadIcon: const Icon(Icons.bathtub, size: 30),
        content: Row(
            children: [
              Flexible(
                child: Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    direction: Axis.horizontal,
                    children: items
                )
              )
            ]
        )
    );
  }
}
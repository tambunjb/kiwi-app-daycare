import 'package:flutter/material.dart';

import 'accordion.dart';


class ThingsToBringTmr extends StatefulWidget {
  Function getData;
  Function setData;

  ThingsToBringTmr({Key? key, required this.getData, required this.setData}) : super(key: key);

  @override
  _ThingsToBringTmrState createState() => _ThingsToBringTmrState();
}

class _ThingsToBringTmrState extends State<ThingsToBringTmr> {
  final List<String> _things = [
    'Clothes', 'Diapers', 'Milk', 'Pajamas', 'Panties', 'Shampoo', 'Soap', 'Socks', 'Swimsuit', 'Towel', 'Vitamin', 'Nothing'
  ];
  final List<bool> _isThing = [
    false, false, false, false, false, false, false, false, false, false, false, false
  ];

  @override
  void initState() {
    super.initState();

    if(widget.getData('report,things_tobring_tmr')!=null && widget.getData('report,things_tobring_tmr')!='') {
      List<String> things = widget.getData('report,things_tobring_tmr').toString().split(',');
      for(int i=0;i<_things.length;i++) {
        if(things.contains(_things[i].toLowerCase())) {
          _isThing[i] = true;
        }
      }
    }
  }

  void _setData() {
    List<String> data = [];
    for(int i=0;i<_things.length;i++) {
      if(_isThing[i]) {
        data.add(_things[i].toLowerCase());
      }
    }
    widget.setData('things_tobring_tmr', data.join(','));
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for(int i=0;i<_things.length;i++){
      items.add(
          GestureDetector(
              onTap: () {
                setState(() {
                  _isThing[i] = !_isThing[i];
                  if(_things[i]=='Nothing' && _isThing[i]) {
                    for(int j=0;j<_isThing.length;j++) {
                      if(_things[j]!='Nothing') {
                        _isThing[j] = false;
                      }
                    }
                  } else if(_things[i]!='Nothing' && _isThing[i]) {
                    _isThing[_isThing.length-1] = false;
                  }
                });
                _setData();
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                      color: _isThing[i]?const Color(0xFFADD9FF):Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(30))
                  ),
                  child: Text(_things[i], style: const TextStyle(fontSize: 17))
              )
          )
      );
    }
    return Accordion(title:"Things to bring tomorrow", leadIcon: const Icon(Icons.alarm, size: 30),
        content: Row(
            children: [
              Flexible(
                child: Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    direction: Axis.horizontal,
                    children: items
                ),
              )
            ]
        )
    );
  }
}

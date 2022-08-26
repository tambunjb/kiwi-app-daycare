import 'package:flutter/material.dart';

import 'accordion.dart';


class Activities extends StatefulWidget {
  Function getData;
  Function setData;
  bool reqCategoryFilled;

  Activities({Key? key, required this.getData, required this.setData, required this.reqCategoryFilled}) : super(key: key);

  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  final List<String> _activities = [
    'Art', 'Books', 'Building blocks', 'Colouring', 'Cooking', 'Music', 'Puzzles', 'Socialising'
  ];
  final List<bool> _isActivity = [
    false, false, false, false, false, false, false, false
  ];

  @override
  void initState() {
    super.initState();

    if(widget.getData('report,activities')!=null && widget.getData('report,activities')!='') {
      List<String> activities = widget.getData('report,activities').toString().split(',');
      for(int i=0;i<_activities.length;i++) {
        if(activities.contains(_activities[i].toLowerCase())) {
          _isActivity[i] = true;
        }
      }
    }
  }

  void _setData() {
    List<String> data = [];
    for(int i=0;i<_activities.length;i++) {
      if(_isActivity[i]) {
        data.add(_activities[i].toLowerCase());
      }
    }
    widget.setData('activities', data.join(','));
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for(int i=0;i<_activities.length;i++){
      items.add(
          GestureDetector(
              onTap: () {
                setState(() {
                  _isActivity[i] = !_isActivity[i];
                });
                _setData();
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                      color: _isActivity[i]?const Color(0xFFADD9FF):Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(30))
                  ),
                  child: Text(_activities[i], style: const TextStyle(fontSize: 17))
              )
          )
      );
    }
    return Accordion(title:"Activities", leadIcon: const Icon(Icons.menu_book, size: 30),
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
      ),
      reqCategoryFilled: widget.reqCategoryFilled
    );
  }
}

import 'package:flutter/material.dart';

class Accordion extends StatefulWidget {
  final String title;
  final Icon leadIcon;
  final Widget content;
  bool showContent;

  Accordion({Key? key, required this.title, required this.leadIcon, required this.content, this.showContent = false/*, required this.setShowContent, required this.keyShowContent*/})
      : super(key: key);

  @override
  _AccordionState createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  late bool _showContent;

  @override
  void initState() {
    super.initState();
    _showContent = widget.showContent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFDFAEA),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: () {
                setState(() {
                  _showContent = !_showContent;
                });
              },
              textColor: Colors.black,
              contentPadding: const EdgeInsets.all(15),
              title: Text(widget.title, style: const TextStyle(fontSize: 20)),
              leading: CircleAvatar(
                child: widget.leadIcon,
                backgroundColor: const Color(0xFFADD9FF),
                foregroundColor: const Color(0xFF3F3E40),
                radius: 28,
              ),
              trailing: Icon(_showContent ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.black87),
            ),
            _showContent ? Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: widget.content,
            ) : Container()
          ]),
    );
  }
}
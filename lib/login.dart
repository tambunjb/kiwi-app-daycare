import 'package:flutter/material.dart';

import 'api.dart';
import 'navigationService.dart';

class Login extends StatefulWidget {

  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>{
  final _phone = TextEditingController();
  String? _errorText;

  bool _validateMobile() {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,13}$)';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(_phone.text.trim())) {
      setState(() {
        _errorText = 'Please enter a valid phone number';
      });
      return false;
    }
    setState(() {
      _errorText = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
              children: [
                Expanded(
                  child:
                  ListView(
                      padding: EdgeInsets.only(top: MediaQuery
                          .of(context)
                          .size
                          .height / 8),
                      children: [
                        Column(
                            children: [
                              SizedBox(
                                  height: 300,
                                  child: Image.asset("images/app-logo.jpeg")
                              ),
                              // const Text('DAYCARE', style: TextStyle(color: Color(0xFF5996CB),
                              //   letterSpacing: 4,
                              //   height: 1.5,
                              //   fontSize: 24,
                              //   fontWeight: FontWeight.w900,
                              // )),
                              Container(
                                  padding: const EdgeInsets.only(bottom: 28, left: 28, right: 28, top: 58),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: const Text('Login with phone number')
                                        ),
                                        TextField(
                                          controller: _phone,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                              focusedBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 2,
                                                    color: Color(0xFF197CD0)
                                                ),
                                              ),
                                              enabledBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFFE5E5E5)),
                                              ),
                                              focusedErrorBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.red),
                                              ),
                                              hintText: 'Tap to enter phone number',
                                              errorText: _errorText
                                          ),
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                      ]
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(28),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () async {
                                    if(_validateMobile()) {
                                      final login = await Api.login(_phone.text
                                          .trim());
                                      if(login){
                                        NavigationService.instance.navigateToReplacement("home");
                                      }else{
                                        setState(() {
                                          _errorText = 'Authentication failed';
                                        });
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(primary: const Color(0xFF197CD0)),
                                  child: Container(
                                      padding: const EdgeInsets.all(15),
                                      child: const Text('LOG IN', style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          fontSize: 15))
                                  )
                              )
                          )
                        ]
                    )
                )
              ]
          )
      );
  }
}
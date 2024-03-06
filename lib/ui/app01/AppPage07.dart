import 'dart:convert';

import 'package:actthemoon/config/global_style.dart';
import 'package:actthemoon/model/themoon/popup/popup_model5.dart';
import 'package:actthemoon/ui/app01/AppPager04list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../config/constant.dart';
import '../../model/themoon/popup/econtnm_model.dart';
import '../../model/themoon/popup/eperlist_model.dart';
import '../../model/themoon/popup/ereginm_model.dart';
import '../home/tab_home.dart';
import 'AppPager04Actnm.dart';
import 'AppPager05list.dart';
import 'AppPager07list.dart';

class AppPage07 extends StatefulWidget {
  const AppPage07({Key? key}) : super(key: key);

  @override
  _AppPage07State createState() => _AppPage07State();


}

class _AppPage07State extends State<AppPage07> {


  String cltcd = "";
  String cltnm = "";
  String spcd = "";
  String area = "";
  bool _isChecked = false;



  late String _hour, _minute, _time;

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();


  final List<String> _eContData = [];


  TextEditingController _etfrdate = TextEditingController();
  TextEditingController _ettodate = TextEditingController();
  TextEditingController _etcltnm = TextEditingController();



  String? _etManageTxt;




  final List<String> _etManageData = [];



  @override
  void initState(){
    super.initState();

    _etfrdate.text = DateTime.now().toString().substring(0,10);
    _ettodate.text = DateTime.now().toString().substring(0,10);

    pop_Manage();



  }



  String getAreaParameterValue() {
    return _isChecked ? '%' : _etManageTxt.toString();
  }


  /**** 관리처 조회  **/
  @override
  Future pop_Manage()async {
    var uritxt = CLOUD_URL + '/themoon/TB_JC002';
    var encoded = Uri.encodeFull(uritxt);
    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm' : 'ERP_THEMOON',

      },
    );
    if(response.statusCode == 200) {
      List<dynamic> alllist = [];
      alllist = jsonDecode(utf8.decode(response.bodyBytes));
      popData5.clear();
      _etManageData.clear();




      for (int i=0; i < alllist.length; i++) {
        popup_model5 emObject = popup_model5(
            divinm: alllist[i]['divinm'] ?? '',
            divicd: alllist[i]['divicd'] ?? ''
        );
        setState(() {
          popData5.add(emObject);
          _etManageData.add(alllist[i]['divinm']  + ' [' + alllist[i]['divicd'] + ']');

        });
      }
      return popData5;
    }else{
      print("error!!!!!");
      throw Exception('대분류를 불러오는 실패하였습니다.');
    }
  }



  @override
  void dispose() {
    super.dispose();

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text('기간별생산자별생산현황', style: GlobalStyle.appBarTitle,),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
          actions: <Widget>[
            TextButton(onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabHomePage()));
            }, child: Text('홈으로', style: TextStyle(color: Colors.lightBlue, fontSize: 16),))
          ],
        ),
        body:
        ListView(

            children :[
              Column(
                //mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text('조회 상세조건', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xffcccccc),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('조회기간', textAlign: TextAlign.left),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.432,
                          child: TextField(
                              controller: _etfrdate,
                              readOnly: true,
                              onTap: () {
                                _selectDateWithMinMaxDate(context);
                              },
                              maxLines: 1,
                              cursorColor: Colors.grey[600],
                              style: TextStyle(fontSize: 16, color: Colors.lightBlue[700]),
                              decoration: InputDecoration(
                                  isDense: true,
                                  suffixIcon: Icon(Icons.date_range, color: Colors.pinkAccent),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[600]!),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey[600]!),
                                  ),
                                  labelText: '',
                                  labelStyle:
                                  TextStyle(color: BLACK_GREY))
                          ),
                        ),
                      ),
                      Text("~"),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.432,

                          child: TextField(
                            controller: _ettodate,
                            readOnly: true,
                            onTap: () {
                              _selectDateWithMinMaxDate2(context);
                            },
                            maxLines: 1,
                            cursorColor: Colors.grey[600],
                            style: TextStyle(fontSize: 16, color: Colors.lightBlue[700]),
                            decoration: InputDecoration(
                                isDense: true,
                                suffixIcon: Icon(Icons.date_range, color: Colors.pinkAccent),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[600]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[600]!),
                                ),
                                labelText: '',
                                labelStyle:
                                TextStyle(color: BLACK_GREY)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Text('생산부서'),
                        Checkbox(value: _isChecked, onChanged: (bool? value)
                        {
                          setState(() {
                            _isChecked = value ?? true;
                          });
                        })
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      color: Colors.blue[800],
                      elevation: 5,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            icon: Icon(Icons.keyboard_arrow_down),
                            dropdownColor: Colors.blue[800],
                            iconEnabledColor: Colors.white,
                            hint: Text("생산부서", style: TextStyle(color: Colors.white)),
                            value: this._etManageTxt != null? this._etManageTxt :null ,
                            items: _etManageData.map((item) {
                              return DropdownMenuItem<String>(
                                child: Text(item, style: TextStyle(color: Colors.white)),
                                value: item,
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                this._etManageTxt = value;
                                //widget.e401Data.regicd = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  Container(
                    width: double.infinity,
                    child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) => SOFT_BLUE,
                          ),
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        ),
                        onPressed: () async
                        {
                          String etcltnmValue = _etcltnm.text.trim();



                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                AppPager07list(

                                )));



                          //getactnminfo();

                        },

                        child: Padding(padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text('조회',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )),
                  )
                ],
              ),
            ]
        )
    );

  }

  Future<Null> _selectDateWithMinMaxDate(BuildContext context) async {
    var firstDate = DateTime(initialDate.year, initialDate.month - 24, initialDate.day);
    var lastDate = DateTime(initialDate.year, initialDate.month, initialDate.day + 360);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.pinkAccent,
            colorScheme: ColorScheme.light(primary: Colors.pinkAccent, secondary: Colors.pinkAccent),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;



        _etfrdate = TextEditingController(
            text: _selectedDate.toLocal().toString().split(' ')[0]);

        /*_ettodate = TextEditingController(
            text: _selectedDate.toLocal().toString().split(' ')[0]);*/

      });
    }
  }

  Future<Null> _selectDateWithMinMaxDate2(BuildContext context) async {
    var firstDate = DateTime(initialDate.year, initialDate.month - 24, initialDate.day);
    var lastDate = DateTime(initialDate.year, initialDate.month, initialDate.day + 360);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.pinkAccent,
            colorScheme: ColorScheme.light(primary: Colors.pinkAccent, secondary: Colors.pinkAccent),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;



        _ettodate = TextEditingController(
            text: _selectedDate.toLocal().toString().split(' ')[0]);

      });
    }
  }

  void showAlertDialog(BuildContext context, String as_msg) async {

    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('기간별생산자별생산현황'),
          content: Text(as_msg),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, "확인");
              },
            ),
          ],
        );
      },
    );
  }
}
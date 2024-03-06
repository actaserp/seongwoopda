import 'dart:convert';

import 'package:actthemoon/config/global_style.dart';
import 'package:actthemoon/model/themoon/popup/popup_model3.dart';
import 'package:actthemoon/ui/app01/AppPager04list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/constant.dart';
import '../../model/themoon/popup/econtnm_model.dart';
import '../../model/themoon/popup/eperlist_model.dart';
import '../../model/themoon/popup/ereginm_model.dart';
import '../../model/themoon/popup/popup_model.dart';
import '../../model/themoon/popup/popup_model2.dart';
import '../../model/themoon/popup/popup_model4.dart';
import '../home/tab_home.dart';
import 'AppPager04Actnm.dart';
import 'AppPager06Actnm.dart';
import 'AppPager06list.dart';

class AppPage06 extends StatefulWidget {
  const AppPage06({Key? key}) : super(key: key);

  @override
  _AppPage06State createState() => _AppPage06State();


}

class _AppPage06State extends State<AppPage06> {


  String cltcd = "";
  String cltnm = "";
  String spcd = "";
  String area = "";

  bool _isChecked = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  bool _isChecked4 = false;



  late String _hour, _minute, _time;

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();


  final List<String> _eContData = [];


  TextEditingController _etfrdate = TextEditingController();
  TextEditingController _ettodate = TextEditingController();
  TextEditingController _etcltnm = TextEditingController();


  String? _etStoreTxt;
  String? _etMidTxt;
  String? _etManageTxt;
  String? _etpgunTxt;
  String? _etagrbTxt;
  String? _etbgrbTxt;





  final List<String> _eStoreData = [];
  final List<String> _eMidData = [];
  final List<String> _etManageData = [];
  final List<String> _etpgunData = [];
  final List<String> _etagrbData = [];
  final List<String> _etbgrbData = [];







  @override
  void initState(){
    super.initState();

    _etfrdate.text = DateTime.now().toString().substring(0,10);
    _ettodate.text = DateTime.now().toString().substring(0,10);

    pop_Store();
    pop_pgun();



  }

  String getAreaParameterValue() {
    return _isChecked ? '%' : _etStoreTxt.toString();
  }
  String getAreaParameterValue2() {
    return _isChecked2 ? '%' : _etpgunTxt.toString();
  }
  String getAreaParameterValue3() {
    return _isChecked3 ? '%' : _etagrbTxt.toString();
  }
  String getAreaParameterValue4() {
    return _isChecked4 ? '%' : _etbgrbTxt.toString();
  }


  /**대분류 조회****/
  @override
  Future pop_agrb()async {
    //_dbnm = await  SessionManager().get("dbnm");
    var uritxt = CLOUD_URL + '/themoon/agrdlist';
    var encoded = Uri.encodeFull(uritxt);
    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm': 'ERP_THEMOON',
        'pgun': _etpgunTxt.toString(),
      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;
      popData3.clear();
      _etagrbData.clear();
      for (int i = 0; i < alllist.length; i++) {
        if (alllist[i]['hnam'] != null || alllist[i]['hnam'].length > 0 ){
          popup_model3 emObject= popup_model3(
              hcod: alllist[i]['hcod'] ?? '',
              hnam: alllist[i]['hnam'] ?? '',
              combinedValue: alllist[i] ['combinedValue'] ?? ''

          );
          setState(() {
            popData3.add(emObject);
            _etagrbData.add(alllist[i]['hnam'] + ' [' + alllist[i]['combinedValue'] + ']');
            _etagrbTxt = alllist[0]['hnam'] + ' [' + alllist[0]['combinedValue'] + ']';
          });
        }
      }
      return popData3;
    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('고장부위상세내용 불러오는데 실패했습니다');
    }
  }

  /**중분류 조회****/
  @override
  Future pop_bgrb()async {
    //_dbnm = await  SessionManager().get("dbnm");
    var uritxt = CLOUD_URL + '/themoon/bgrdlist';
    var encoded = Uri.encodeFull(uritxt);
    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm': 'ERP_THEMOON',
        'param': _etagrbTxt.toString(),
      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;
      popData4.clear();
      _etbgrbData.clear();
      for (int i = 0; i < alllist.length; i++) {
        if (alllist[i]['bgrpnm'] != null || alllist[i]['bgrpnm'].length > 0 ){
          popup_model4 emObject= popup_model4(
              bgrpnm: alllist[i]['bgrpnm'] ?? '',
              bgroup: alllist[i]['bgroup'] ?? ''
          );
          setState(() {
            popData4.add(emObject);
            _etbgrbData.add(alllist[i]['bgrpnm'] + ' [' + alllist[i]['bgroup'] + ']' );
            _etbgrbTxt = alllist[0]['bgrpnm'] + ' [' + alllist[0]['bgroup'] + ']'  ;
          });
        }
      }
      return popData4;
    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('고장부위상세내용 불러오는데 실패했습니다');
    }
  }


  /**** 창고 조회  **/
  @override
  Future pop_Store()async {
    var uritxt = CLOUD_URL + '/themoon/store';
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
      popData.clear();
      _eStoreData.clear();




      for (int i=0; i < alllist.length; i++) {
        popup_model emObject = popup_model(
            store: alllist[i]['store'] ?? '',
            storenm: alllist[i]['storenm'] ?? ''
        );
        setState(() {
          popData.add(emObject);
          _eStoreData.add(alllist[i]['storenm'] + ' [' + alllist[i]['store'] + ']');

        });
      }
      return popData;
    }else{
      print("error!!!!!");
      throw Exception('대분류를 불러오는 실패하였습니다.');
    }
  }

  /**** 품목분류 조회  **/
  @override
  Future pop_pgun()async {
    var uritxt = CLOUD_URL + '/themoon/pgun';
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
      popData2.clear();
      _etpgunData.clear();




      for (int i=0; i < alllist.length; i++) {
        popup_model2 emObject = popup_model2(
            code: alllist[i]['code'] ?? '',
            cnam: alllist[i]['cnam'] ?? '',
            cord: alllist[i]['cord'] ?? ''
        );
        setState(() {
          popData2.add(emObject);
          _etpgunData.add(alllist[i]['cnam'] + ' [' + alllist[i]['code'] + ']');

        });
      }
      return popData2;
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
          title: Text('현재고현황', style: GlobalStyle.appBarTitle,),
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
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text('창고'),

                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
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
                            hint: Text("창고분류", style: TextStyle(color: Colors.white)),
                            value: this._etStoreTxt != null? this._etStoreTxt :null ,
                            items: _eStoreData.map((item) {
                              return DropdownMenuItem<String>(
                                child: Text(item, style: TextStyle(color: Colors.white)),
                                value: item,
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                this._etStoreTxt = value;
                                //widget.e401Data.regicd = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text('품목분류'),
                        Checkbox(value: _isChecked2, onChanged: (bool? value)
                        {
                          setState(() {
                            _isChecked2 = value ?? true;
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
                            hint: Text("품목분류", style: TextStyle(color: Colors.white)),
                            value: this._etpgunTxt != null? this._etpgunTxt :null ,
                            items: _etpgunData.map((item) {
                              return DropdownMenuItem<String>(
                                child: Text(item, style: TextStyle(color: Colors.white)),
                                value: item,
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                this._etpgunTxt = value;
                                //widget.e401Data.regicd = value;
                                pop_agrb();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text('대분류'),
                        Checkbox(value: _isChecked3, onChanged: (bool? value)
                        {
                          setState(() {
                            _isChecked3 = value ?? true;
                          });
                        })
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
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
                            hint: Text("대분류", style: TextStyle(color: Colors.white)),
                            value: this._etagrbTxt != null? this._etagrbTxt :null ,
                            items: _etagrbData.map((item) {
                              return DropdownMenuItem<String>(
                                child: Text(item, style: TextStyle(color: Colors.white)),
                                value: item,
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                this._etagrbTxt = value;
                                pop_bgrb();
                                //widget.e401Data.regicd = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    //margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Text('중분류'),
                        Checkbox(value: _isChecked4, onChanged: (bool? value)
                        {
                          setState(() {
                            _isChecked4 = value ?? true;
                          });
                        })
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
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
                            hint: Text("중분류", style: TextStyle(color: Colors.white)),
                            value: this._etbgrbTxt != null? this._etbgrbTxt :null ,
                            items: _etbgrbData.map((item) {
                              return DropdownMenuItem<String>(
                                child: Text(item, style: TextStyle(color: Colors.white)),
                                value: item,
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                this._etbgrbTxt = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text('품목조회: '),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextField(
                              controller: _etcltnm,
                              onChanged: (String value){
                                if(value.isEmpty){
                                  setState(() {
                                    cltcd = "";
                                  });
                                }
                              },
                              readOnly: false,
                              decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                                  ),
                                  suffixIcon: IconButton(onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AppPager06Actnm(data: _etcltnm.text))).then((value) {
                                      setState(() {
                                        cltcd = value[0];
                                        cltnm = value[1];

                                        _etcltnm.text = value[1];

                                      });

                                    });
                                  }, icon: Icon(Icons.search))
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  SizedBox(
                    height: 20,
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

                          String etcltnmValue = _etStoreTxt.toString().trim();
                          if(etcltnmValue == null || etcltnmValue == "")
                            {
                              showDialog(context: context, builder: (BuildContext context){
                                return AlertDialog(
                                  title: Text('현재고현황'),
                                  content: Text('창고분류를 입력해주세요'),
                                  actions: <Widget>[
                                    TextButton(onPressed: (){
                                      Navigator.of(context).pop();

                                    }, child: Text('확인'))
                                  ],
                                );
                              });

                            }

                            if(_etStoreTxt == null || _etStoreTxt == ''){
                              showAlertDialog(context, '창고분류를 선택해주세요');
                              return;
                            }

                            if(_etpgunTxt == null && _isChecked2 == false){
                              showAlertDialog(context, '품목분류를 선택해주세요');
                              return;
                            }

                          if(_etagrbTxt == null && _isChecked3 == false){
                            showAlertDialog(context, '대분류를 선택해주세요');
                            return;
                          }
                          if(_etbgrbTxt == null && _isChecked4 == false){
                            showAlertDialog(context, '중분류를 선택해주세요');
                            return;
                          }



                          //getactnminfo();
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              AppPager06list(
                                store: getAreaParameterValue(),
                                pgun: getAreaParameterValue2(),
                                agrb: getAreaParameterValue3(),
                                bgrb: getAreaParameterValue4(),
                                pcode: cltcd,

                              )));
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
          title: Text('현재고현황'),
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
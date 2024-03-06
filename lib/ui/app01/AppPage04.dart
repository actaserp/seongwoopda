import 'dart:convert';

import 'package:actthemoon/config/global_style.dart';
import 'package:actthemoon/ui/app01/AppPager04list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/constant.dart';
import '../../model/themoon/popup/econtnm_model.dart';
import '../../model/themoon/popup/eperlist_model.dart';
import '../../model/themoon/popup/ereginm_model.dart';
import '../home/tab_home.dart';
import 'AppPager04Actnm.dart';

class AppPage04 extends StatefulWidget {


  const AppPage04({Key? key}) : super(key: key);


  @override
  _AppPage04State createState() => _AppPage04State();
  

}

class _AppPage04State extends State<AppPage04> {

  bool _isChecked = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;

  String cltcd = "";
  String cltnm = "";
  String spcd = "";
  String area = "";


  late String _hour, _minute, _time;

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();


  final List<String> _eContData = [];


  TextEditingController _etfrdate = TextEditingController();
  TextEditingController _ettodate = TextEditingController();
  TextEditingController _etcltnm = TextEditingController();


  String? _etMainTxt;
  String? _etMidTxt;
  String? _etManageTxt;



  final List<String> _eActMainData = [];
  final List<String> _eMidData = [];
  final List<String> _etManageData = [];
  final List<String> _eRegiData = [];








  @override
  void initState(){
    super.initState();

    _etfrdate.text = DateTime.now().toString().substring(0,10);
    _ettodate.text = DateTime.now().toString().substring(0,10);
    pop_Main();
    pop_Manage();



  }

  String getAreaParameterValue() {
    return _isChecked ? '%' : _etMidTxt.toString();

  }
  String getAreaParameterValue2() {
    return _isChecked2 ? '%' : _etMainTxt.toString();

  }
  String getAreaParameterValue3() {
    return _isChecked3 ? '%' : _etManageTxt.toString();

  }

  /**전체조회**/
  @override
  Future getactnminfo() async {


    var uritxt = CLOUD_URL + '/themoon/MainList';
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
        'cltnm': _etcltnm.text,
        'cltcd': cltcd,
        'frdate': _etfrdate.text,
        'todate': _ettodate.text,
        'spcd' : _etMainTxt.toString(),
        'area' : getAreaParameterValue(),//_etMidTxt.toString(),
        'comcd': _etManageTxt.toString()



      },
    );
    if(response.statusCode == 200){

      /*List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;
      e601Data.clear();
      for (int i = 0; i < alllist.length; i++) {
        tbe601list_model emObject= tbe601list_model(

            cltnm: alllist[i]['cltnm'],
            cltcd: alllist[i]['cltcd']

        );
        setState(() {
          e601Data.add(emObject);
        });


      }
      return e601Data;*/
    }else{
      throw Exception('불러오는데 실패했습니다.');
    }
  }

  /**** 관리처 조회  **/
  @override
  Future pop_Manage()async {
    var uritxt = CLOUD_URL + '/themoon/pop_Per';
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
      ePerData.clear();
      _etManageData.clear();




      for (int i=0; i < alllist.length; i++) {
        eperlist_model emObject = eperlist_model(
            spjangcd: alllist[i]['spjangcd'] ?? '',
            spjangnm: alllist[i]['spjangnm'] ?? ''
        );
        setState(() {
          ePerData.add(emObject);
          _etManageData.add(alllist[i]['spjangnm'] + ' [' + alllist[i]['spjangcd'] + ']');

        });
      }
      return ePerData;
    }else{
      print("error!!!!!");
      throw Exception('대분류를 불러오는 실패하였습니다.');
    }
  }


  /**** 대분류 조회  **/
  @override
  Future pop_Main()async {
    var uritxt = CLOUD_URL + '/themoon/pop_Main';
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
        'contnm': '%',
      },
    );
    if(response.statusCode == 200) {
      List<dynamic> alllist = [];
      alllist = jsonDecode(utf8.decode(response.bodyBytes));
      eContData.clear();
      _eContData.clear();
      _eActMainData.clear();



      for (int i=0; i < alllist.length; i++) {
        econtnm_model emObject = econtnm_model(
            sortno: alllist[i]["sortno"] ?? '',
            hcod  : alllist[i]["hcod"] ?? '',
            hnam: alllist[i]["hnam"] ?? ''
        );
        setState(() {
          eContData.add(emObject);
          _eActMainData.add(alllist[i]['hnam'] + ' [' + alllist[i]['hcod'] + ']');

        });
      }
      return eContData;
    }else{
      print("error!!!!!");
      throw Exception('대분류를 불러오는 실패하였습니다.');
    }
  }

  /**중분류 조회****/
  @override
  Future pop_ereginm()async {
    //_dbnm = await  SessionManager().get("dbnm");
    var uritxt = CLOUD_URL + '/themoon/pop_Mid';
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
        'hcod': _etMainTxt.toString(),
      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;
      eRegiData.clear();
      _eMidData.clear();
      for (int i = 0; i < alllist.length; i++) {
        if (alllist[i]['bgroup'] != null || alllist[i]['bgroup'].length > 0 ){
          ereginm_model emObject= ereginm_model(
              bgroup: alllist[i]['bgroup'],
              bgrpnm: alllist[i]['bgrpnm']
          );
          setState(() {
            eRegiData.add(emObject);
            _eMidData.add(alllist[i]['bgrpnm'] + ' [' + alllist[i]['bgroup'] + ']' );
            _etMidTxt = alllist[0]['bgrpnm'] + ' [' + alllist[0]['bgroup'] + ']'  ;
          });
        }
      }
      return eRegiData;
    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('고장부위상세내용 불러오는데 실패했습니다');
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
        title: Text('기간별매출현황', style: GlobalStyle.appBarTitle,),
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
                Container(
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
                Text("~"),
                Padding(
                  padding: EdgeInsets.only(left: 20),
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
                  Text('대분류'),
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
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8),
              child:
              Card(
                color: Colors.blue[800],
                elevation: 5,
                child:
                Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      icon: Icon(Icons.keyboard_arrow_down),
                      dropdownColor: Colors.blue[800],
                      iconEnabledColor: Colors.white,
                      hint: Text("대분류", style: TextStyle(color: Colors.white)),
                      value:  this._etMainTxt != null? this._etMainTxt :null ,
                      items: _eActMainData.map((item) {
                        return DropdownMenuItem<String>(
                          child: Text(item, style: TextStyle(color: Colors.white)),
                          value: item,
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          this._etMainTxt = value;
                          /*widget.e401receData.contcd = value;*/

                        });
                        eRegiData.clear();
                        _eMidData.clear();
                        pop_ereginm();


                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text('중분류'),

                  Checkbox(value: _isChecked, onChanged: (bool? value)
                  {
                    setState(() {
                      _isChecked = value ?? true;
                    });
                  }),
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
                      hint: Text("중분류", style: TextStyle(color: Colors.white)),
                      value: this._etMidTxt != null? this._etMidTxt :null ,
                      items: _eMidData.map((item) {
                        return DropdownMenuItem<String>(
                          child: Text(item, style: TextStyle(color: Colors.white)),
                          value: item,
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          this._etMidTxt = value;

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
              margin: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text('관리처'),
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
                      hint: Text("관리처", style: TextStyle(color: Colors.white)),
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
            TextField(
              controller: _etcltnm,
              readOnly: false,
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                      BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                ),
                labelText: '거래처 *',
                labelStyle: TextStyle(color: BLACK_GREY)),
            ),
            SizedBox(height: 20),
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AppPager04Actnm(data: _etcltnm.text))).then((value) {
              setState(() {
                cltcd = value[0];
                cltnm = value[1];

                _etcltnm.text = value[1];

              });

              });
            }, child: Center(child: Text("현장 검색하기"))),
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
}
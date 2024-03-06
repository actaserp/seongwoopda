
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pointmobile_scanner/pointmobile_scanner.dart';


import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/kosep/Da035List_model.dart';
import '../../model/themoon/padlist_model.dart';
import '../../model/themoon/storelist_model.dart';
import '../home/tab_home.dart';
import 'AppPage01_Subpage.dart';

class AppPage01 extends StatefulWidget {
  const AppPage01({Key? key}) : super(key: key);

  @override
  _AppPage01State createState() => _AppPage01State();
}

class _AppPage01State extends State<AppPage01>   {

  String? _decodeResult = "Unknown";
  int _decodeCount = 0;
  List<String> _decodeResults = [];
  List<String> _decodePda = [];
  String result  = '';
  String resultset = '';

  TextEditingController _etDate = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();
  List<padlist_model> padlist = padlists;
  String _dbnm = '';
  String _userid = '';
  String _username = '';
  String pcode = '';
  bool chk = false;
  num sum  = 0;
  bool chk2 = false;
  List<num> sum2 = [];


  String _perid = '';
  String _custcd = "";

  List<storelist_model> storelists = storelist;

  @override
  void initState() {
    sessionData();

    super.initState();
    _etDate.text = getToday();

    PointmobileScanner.channel.setMethodCallHandler(_onBarcodeScannerHandler);
    PointmobileScanner.initScanner();
    PointmobileScanner.enableScanner();
    PointmobileScanner.enableBeep();
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_CODE128);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_EAN13);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_QR);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_UPCA);

    setState(() {
      _decodeResult = "Read to decode";
      _decodeCount = 0;
    });
  }

  @override
  void dispose() {
    _etDate.dispose();
    da035Data.clear();
    padlists.clear();
    super.dispose();
  }

  String getToday(){
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMMdd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }
  Future<void> sessionData() async {
    _dbnm     = (await SessionManager().get("dbnm")).toString();
    _userid   = (await SessionManager().get("userid")).toString();
    _username = (await SessionManager().get("username")).toString();
    _perid    = (await SessionManager().get("perid")).toString();
    _custcd = (await SessionManager().get("custcd")).toString();

    await log_history_h();




  }


  Future log_history_h() async {

    String ipAddress = '';
    for (var interface in await NetworkInterface.list()) {
      for (var address in interface.addresses){
        ipAddress = address.address;
      }
    }


    String _username  = '';
    String username = (await SessionManager().get("username")).toString();
    _username = utf8.decode(username.runes.toList());

    var uritxt = CLOUD_URL + '/themoon/loginlog_h';
    var encoded = Uri.encodeFull(uritxt);

    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {

        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'userid' : _perid,
        'ipaddr' : ipAddress,
        'usernm' : _username,
        'winnm'  : '입고등록',
        'winid'  : '입고등록',
        'buton'  : '020'
      },
    );
    if(response.statusCode == 200){
      return true;
    }else{
      print("통신에러");
    }

  }




  Future PDAlist_getdata(String? decodeResult) async {

    chk2 = false;

    String _dbnm = await  SessionManager().get("dbnm");

    var uritxt = CLOUD_URL + '/themoon/list01';
    var encoded = Uri.encodeFull(uritxt);

    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm': "ERP_THEMOON",
        'code88': decodeResult ?? '',
        'wendt': _etDate.text,
      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;

      //padlists.clear();

      if(alllist.isNotEmpty){
        for (int i = 0; i < alllist.length; i++) {
          padlist_model emObject= padlist_model(
            phm_pcod: alllist[i]["phm_pcod"],
            phm_pnam: alllist[i]["phm_pnam"],
            phm_size: alllist[i]["phm_size"],
            phm_unit: alllist[i]["phm_unit"],
            code88: alllist[i]["code88"],
            wfokqt_sum: alllist[i]["wfokqt_sum"] ?? "",

          );

          pcode = alllist[i]["phm_pcod"];



          String prefixToRemove = emObject.phm_pcod;



          bool isFirstMatched = true;
          padlists.removeWhere((element) {
            if (element.startsWith(prefixToRemove)) {

              // 두번째 이후로 매칭된 요소는 제거한다.
              return true;

            }
            return false;
          });


          setState(() {
            padlists.add(emObject);
            /*_decodePda.add(emObject.phm_pcod);
          */
          });

        }
        print("리스트 존재");
        return padlists;

      }else if(alllist.isEmpty){
        for (int i = 0; i < 1; i++) {
          padlist_model emObject= padlist_model(
            phm_pcod: "",
            phm_pnam: "",
            phm_size: "",
            phm_unit: "",
            code88: "",
            wfokqt_sum: "",
          );

          pcode = alllist[i]["phm_pcod"] ?? "";

          String prefixToRemove = emObject.phm_pcod;


          setState(() {
            padlists.add(emObject);

          });

        }
        print("리스트비어있음");
        return padlists;
      }


      print("진짜서버통신성공");



    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('불러오는데 실패했습니다');
    }
  }


  /* Future PDAlist_getdata2() async {

    sum = 0;
    chk = false;



    String _dbnm = await SessionManager().get("dbnm");

    var uritxt = CLOUD_URL + "/themoon/list02";
    var encoded = Uri.encodeFull(uritxt);

    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type' : 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm': "ERP_THEMOON",
        'wendt': _etDate.text,
        'pcode': pcode,
      },
    );
    if(response.statusCode == 200){

      List<dynamic> alllist = [];
      alllist = jsonDecode(utf8.decode(response.bodyBytes));
      storelist.clear();

      for(int i=0; i< alllist.length; i++){


        storelist_model emObject = storelist_model(
          cltnm : alllist[i]["cltnm"],
          pname: alllist[i]["pname"],
          psize: alllist[i]["psize"],
          wfokqt: alllist[i]["wfokqt"],
          plan_no: alllist[i]["plan_no"],
          wono: alllist[i]["wono"],
          lotno: alllist[i]["lotno"],
          pcode: alllist[i]["pcode"],
          wfokqt_sum: alllist[i]["wfokqt_sum"],
          isChecked: true,
          textEditingController: TextEditingController(text: alllist[i]["wfokqt"]),


        );
        padlist_model emObject2 = padlist_model(
          wfokqt_sum: alllist[i]["wfokqt_sum"]
        );

        //sum +=  int.parse(alllist[i]["wfokqt"]);


        setState(() {
          storelists.add(emObject);
        });

      }




      if(alllist.isNotEmpty){
        chk = true;
      }
      print("서버통신 2");
      print(alllist);
      return storelists;
    }else{
      throw Exception('불러오는데 실패했습니다2.');
    }
  }*/

  Future<void> _onBarcodeScannerHandler(MethodCall call) async {
    try{
      if(call.method == PointmobileScanner.ON_DECODE) {
        setState(() {
          final List lDecodeResult = call.arguments;
          result = lDecodeResult[1];

        });

        int count = 0;

        _decodeResults.add(result);

        for(String value in _decodeResults){
          if(value == result){
            count ++;
          }
        }


        await PDAlist_getdata(result);
        //await PDAlist_getdata2();


        _onDecode(call);




      } else if (call.method == PointmobileScanner.ON_ERROR){
        _onError(call.arguments);
      } else {
        //print(call.arguments);
      }
    } catch(e) {
      //print(e);
    }
  }


  void _onDecode(MethodCall call) async{

    setState(() {
      final List lDecodeResult = call.arguments;
      String result = "Symbology: ${lDecodeResult[0]}\nValue: ${lDecodeResult[1]}";

      String result1 = "${lDecodeResult[1]}";

      if(!_decodePda.contains(result1)){
        _decodePda.add(result1);

      }

      /*if(!_decodeResults.contains(result)){
        _decodeResults.add(result);
      }*/

      if(lDecodeResult.contains("READ_FAIL"))
      {
        _decodeCount;
      }
      else
      {
        _decodeCount++;
      }
      /*_decodeResult = "Symbology: ${lDecodeResult[0]}\nValue: ${lDecodeResult[1]}";
      */
      _decodeResult = "${lDecodeResult[1]}";
    });


  }

  void _onError(Exception error){
    setState(() {
      _decodeResult = error.toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: GlobalStyle.appBarIconThemeColor,
        ),
        elevation: GlobalStyle.appBarElevation,
        title: Text(
          '입고등록',
          style: GlobalStyle.appBarTitle,
        ),
        backgroundColor: GlobalStyle.appBarBackgroundColor,
        systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
        actions: <Widget>[
          TextButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabHomePage()));
          }, child: Text('홈으로', style: TextStyle(color: Colors.lightBlue, fontSize: 16),))
        ],
      ),
      body:
      WillPopScope(
        onWillPop: (){
          Navigator.pop(context);
          return Future.value(true);
        },
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _etDate,
                    readOnly: true,
                    onTap: () {
                      _selectDateWithMinMaxDate(context);
                    },
                    maxLines: 1,
                    cursorColor: Colors.grey[600],
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:  EdgeInsets.all(10),
                      suffixIcon: Icon(Icons.date_range, color: Colors.indigo),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      labelText: '입고예정일',
                      labelStyle: TextStyle(color: BLACK_GREY),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _etDate.text;
                    });
                    String ls_etdate = _etDate.text  ;
                    if(ls_etdate.length == 0){
                      print("일자를 입력하세요");
                      return;
                    }
                    /*da035list_getdata();*/
                    print(_etDate.text );
                  },
                  child: Text(
                    '목록조회',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
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
            /* Container(
              child: Text('$_decodeResult\n'),
            ),
            Container(
              child: Text('$_decodeCount\n'),
            ),*/
            Expanded(child: ListView.builder(itemCount: /*da035Datas.length*/   /*_decodeResults.length*/ padlists.length,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index){


                return _buildListCard(padlists[index]);


                /*if(chk){
                return _buildListCard(*//*da035Datas[index]*//* padlists[index]);
              }else{
                return Center(child: Text("해당 날짜에 데이터가 없습니다."));

              }*/

              },
            ))
          ],
        ),

      ),
    );

  }








  Widget _buildListCard(padlist_model padlistmodel /*String decodeResults*/){

    return Card(
        margin: EdgeInsets.only(top: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 2,
        color: Colors.white,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async{
              final result = await
              Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage01_Subpage(padlistmodel : padlistmodel, date : _etDate.text, removeCardCallback: (){ removeCardFromList(padlistmodel); })));
              if(result != null && result is bool && result){
                setState(() {
                  padlists.remove(padlistmodel);

                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: padlistmodel.phm_pcod.isNotEmpty,
                    child: Text("품목코드: " + padlistmodel.phm_pcod, style: GlobalStyle.couponName),
                  ),
                  Visibility(
                    visible: padlistmodel.phm_pnam.isNotEmpty,
                    child: Text("품목명: " + padlistmodel.phm_pnam, style: GlobalStyle.couponName),
                  ),
                  Visibility(
                      visible: padlistmodel.phm_size.isNotEmpty,
                      child: Text("규격: " + padlistmodel.phm_size, style: GlobalStyle.couponName)
                  ),
                  Visibility(
                      visible: padlistmodel.code88.isNotEmpty,
                      child: Text("바코드: " + padlistmodel.code88, style: GlobalStyle.couponName)
                  ),
                  Visibility(
                      visible: padlistmodel.code88.isEmpty,
                      child: Text("해당 날짜에 해당하는 데이터가 없습니다." + padlistmodel.code88, style: GlobalStyle.couponName)
                  ),
                  SizedBox(height: 10),

                  GestureDetector(
                    onTap: (){

                      // Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage11Detail(da035Data: da035Data)));
                    },
                    child: Visibility(
                      visible: padlistmodel.code88.isNotEmpty,
                      child: Text('수량 : ' + padlistmodel.wfokqt_sum , style: TextStyle(
                          fontSize: 14, color: SOFT_BLUE, fontWeight: FontWeight.bold
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }




  Future<Null> _selectDateWithMinMaxDate(BuildContext context) async {
    var firstDate = DateTime(initialDate.year, initialDate.month - 8, initialDate.day);
    var lastDate = DateTime(initialDate.year, initialDate.month, initialDate.day + 7);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.indigo,
            colorScheme: ColorScheme.light(primary: Colors.indigo, secondary: Colors.indigo),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;

        _etDate = TextEditingController(
            text: _selectedDate.toLocal().toString().split('-')[0]+_selectedDate.toLocal().toString().split('-')[1]+_selectedDate.toLocal().toString().split('-')[2].substring(0,2));
      });
    }
  }

  void removeCardFromList(padlist_model padlistmodel) {
    setState(() {
      padlists.remove(padlistmodel);

    });
  }




}




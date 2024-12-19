
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/ca609/ca609list_model.dart';
import '../home/tab_home.dart';

class App02Now extends StatefulWidget {
  const App02Now({Key? key}) : super(key: key);

  @override
  _App02NowState createState() => _App02NowState();
}

class _App02NowState extends State<App02Now>   {

  List<bool> checkboxValues = [];

  List<String> resultset = [];
  List<String> resultset2 = [];
  List<String> resultset3 = [];
  List<String> resultset4 = [];
  List<String> resultset5 = [];
  List<String> resultset6 = [];
  List<String> resultset7 = [];

  TextEditingController _etDate = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();
  List<ca609list_model> ca609list = ca609Data;
  String _dbnm = '';
  String _userid = '';
  String _username = '';
  String _perid = '';
  String _custcd = "";
  String _winid = "";
  String _winnm = "";

  String checkvalue = 'true';
  bool tf = false;



  @override
  void initState() {
    sessionData();
    resultset.clear();
    resultset2.clear();
    Nowlist_getdata();

    super.initState();
    _etDate.text = getToday();

  }

  @override
  void dispose() {
    _etDate.dispose();
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

    var uritxt = CLOUD_URL + '/ca609/insertLog';
    var encoded = Uri.encodeFull(uritxt);

    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {

        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm'   : 'ERP_SWSPANEL',
        'custcd' : 'THEMOON',
        'spjangcd': 'ZZ',
        'userid' : _perid,
        'ipaddr' : ipAddress,
        'usernm' : _username,
        'winnm'  : '수입검사현황',
        'winid'  : '수입검사현황',
        'buton'  : '010'
      },
    );
    if(response.statusCode == 200){
      
      return true;
    }else{
      print("통신에러");
    }

  }

  Future log_history_d() async {

    String ipAddress = '';
    for (var interface in await NetworkInterface.list()) {
      for (var address in interface.addresses){
        ipAddress = address.address;
      }
    }


    String _username  = '';
    String username = (await SessionManager().get("username")).toString();
    _username = utf8.decode(username.runes.toList());

    var uritxt = CLOUD_URL + '/ca609/insertLog';
    var encoded = Uri.encodeFull(uritxt);

    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {

        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm'   : 'ERP_SWSPANEL',
        'custcd' : 'THEMOON',
        'spjangcd': 'ZZ',
        'userid' : _perid,
        'ipaddr' : ipAddress,
        'usernm' : _username,
        'winnm'  : '수입검사취소',
        'winid'  : '수입검사취소',
        'buton'  : '040'
      },
    );
    if(response.statusCode == 200){
      print("로그 저장됨");
      return true;
    }else{
      print("통신에러");
    }

  }








  Future Nowlist_getdata() async {
    String _dbnm = await  SessionManager().get("dbnm");

    var uritxt = CLOUD_URL + '/ca609/list03';
    var encoded = Uri.encodeFull(uritxt);

    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm': "ERP_SWSPANEL",
        'custcd': 'THEMOON',
        'spjangcd': 'ZZ',
        'qcdate': _etDate.text
      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;
      ca609Data.clear();
      resultset.clear();
      resultset2.clear();
      resultset3.clear();
      for (int i = 0; i < alllist.length; i++) {
        ca609list_model emObject= ca609list_model(
            qcdate: alllist[i]["qcdate"],
            qcnum: alllist[i]["qcnum"],
            qcseq: alllist[i]["qcseq"],
            cltcd: alllist[i]["cltcd"],
            cltnm: alllist[i]["cltnm"],
            pname: alllist[i]["pname"],
            psize: alllist[i]["psize"],
            pcode: alllist[i]["pcode"],
            punit: alllist[i]["punit"],
            wqty: alllist[i]["qty"],
            baldate: alllist[i]["baldate"],
            balnum: alllist[i]["balnum"],
            balseq: alllist[i]["balseq"],
            isChecked: true
        );
        resultset.add(alllist[i]["baldate"]);
        resultset2.add(alllist[i]["balnum"]);
        resultset3.add(alllist[i]["balseq"]);
        resultset4.add(alllist[i]["qty"]);
        resultset5.add(alllist[i]["qcdate"]);
        resultset6.add(alllist[i]["qcnum"]);
        resultset7.add(alllist[i]["qcseq"]);

        setState(() {
          ca609Data.add(emObject);
        });

      }
      return ca609Data;
    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('불러오는데 실패했습니다');
    }
  }

  @override
  Future<bool> delete_data()async {
    _dbnm = await  SessionManager().get("dbnm");
    var uritxt = CLOUD_URL + '/ca609/delqc';
    var encoded = Uri.encodeFull(uritxt);
    Uri uri = Uri.parse(encoded);
   

    final response = await http.post(
        uri,
        headers: <String, String> {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept' : 'application/json'
        },
        body: <String, String> {
          'dbnm': 'ERP_SWSPANEL',
          'custcd': 'THEMOON',
          'spjangcd': 'ZZ',
          'baldate': resultset.join(','),
          'balnum': resultset2.join(','),
          'balseq': resultset3.join(','),
          'wqty': resultset4.join(','),
          'qcdate': resultset5.join(','),
          'qcnum' : resultset6.join(','),
          'qcseq' : resultset7.join(',')
        });
    if(response.statusCode == 200){
      print("저장됨");
      tf = true;
      Nowlist_getdata();
      return   true;
    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('취소 실패했습니다');
      return   false;
    }
  }

  Future log_history() async {

    String ipAddress = '';
    for (var interface in await NetworkInterface.list()) {
      for (var address in interface.addresses) {
        ipAddress = address.address;
      }
    }

    String _username = '';
    String username = (await SessionManager().get("username")).toString().replaceAll("p", "");
    _username = utf8.decode(username.runes.toList());


    var uritxt = CLOUD_URL + '/ca609/insertLog';
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
        'custcd' : 'THEMOOON',
        'spjangcd': 'ZZ',
        'ipaddr' : ipAddress,
        'userid' : _userid,
        'winnm'  : _winnm,
        'winid'  : _winid,
        'buton'  : '030'
      },
    );
    if(response.statusCode == 200){
      resultset.clear();
      resultset2.clear();
      resultset3.clear();
      resultset4.clear();
      resultset5.clear();
      resultset6.clear();

      Nowlist_getdata();

      return true;
    }else{
      print("통신에러");
    }
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
          '수입검사현황',
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
                      labelText: '수입검사일',
                      labelStyle: TextStyle(color: BLACK_GREY),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {

                    String ls_etdate = _etDate.text  ;
                    if(ls_etdate.length == 0){
                      print("일자를 입력하세요");
                      return;
                    }
                    resultset.clear();
                    resultset2.clear();
                    resultset3.clear();
                    resultset4.clear();
                    resultset5.clear();
                    resultset6.clear();
                    resultset7.clear();

                    await Nowlist_getdata();
                    setState(() {
                      _etDate.text  ;

                    });
                    _winid = "수입검사조회";
                    _winnm = "수입검사조회";

                    
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


            Expanded(child: ListView.builder(itemCount: /*ca609Datas.length*/   /*_decodeResults.length*/ ca609list.length,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index){
                return _buildListCard(ca609Data[index]);
              },
            )),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: Container(
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


                              _winid = "수입검사취소";
                              _winnm = "수입검사취소";


                              showDialog(context: context, builder: (context){
                                return AlertDialog(
                                  content: Text('수입검사 취소 하시겠습니까?'),
                                  actions: <Widget>[
                                    TextButton(onPressed: () async {
        

                                      print("체크");

                                      Navigator.pop(context);

                                      print(resultset4.toString());
                                      print(resultset5.toString());

                                      await delete_data();

                                      await Nowlist_getdata();

                                      resultset.clear();
                                      resultset2.clear();
                                      resultset3.clear();
                                      resultset4.clear();
                                      resultset5.clear();
                                      resultset6.clear();
                                      resultset7.clear();

                                      await Nowlist_getdata();
                                      setState(()  {

                                      });

                                      if(!tf)
                                      {
                                        openErrorPopup();
                                      }
                                      /*
                                      if(tf = true){
                                        openPopup();
                                      }else{
                                        openErrorPopup();
                                      }*/
                                    }, child: Text('OK')
                                    )
                                  ],
                                );
                              });
                              //save_fplandata();

                            }, child: Padding(padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text('수입검사 취소',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                            textAlign: TextAlign.center,
                          ),)),
                      )
                  )
                ]
            ),
          ],
        ),


      ),
    );

  }




  Widget _buildListCard(ca609list_model ca609Data){
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
            //Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage11view(ca609Data: da035Data)));
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /*Text(da035Data.cltnm, style: GlobalStyle.couponName),
                  Text(da035Data.grade, style: GlobalStyle.couponName),
                  Text(da035Data.thick+' ['+da035Data.width+'] '+da035Data.color, style: GlobalStyle.couponName),*/
                  Text("거래처: " + ca609Data.cltnm, style: GlobalStyle.couponName),
                  Text("품목명: " + ca609Data.pname, style: GlobalStyle.couponName),
                  Text("규격: " + ca609Data.psize, style: GlobalStyle.couponName),
                  Text("검사일: " + ca609Data.qcdate, style: GlobalStyle.couponName),

                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      GestureDetector(

                        child: Text('검사량 : ' + ca609Data.wqty, style: TextStyle(
                            fontSize: 14, color: SOFT_BLUE, fontWeight: FontWeight.bold
                        ),
                        ),
                      ),
                      Checkbox(
                          value: ca609Data.isChecked,
                          onChanged: (bool? value){
                            setState(() {
                              ca609Data.isChecked = value ?? true;

                              if (ca609Data.isChecked) {
                                resultset.add(ca609Data.baldate);
                                resultset2.add(ca609Data.balnum);
                                resultset3.add(ca609Data.balseq);
                                resultset4.add(ca609Data.wqty);
                                resultset5.add(ca609Data.qcdate);
                                resultset6.add(ca609Data.qcnum);
                                resultset7.add(ca609Data.qcseq);
                              } else {
                                resultset.remove(ca609Data.baldate);
                                resultset2.remove(ca609Data.balnum);
                                resultset3.remove(ca609Data.balseq);
                                resultset4.remove(ca609Data.wqty);
                                resultset5.remove(ca609Data.qcdate);
                                resultset6.remove(ca609Data.qcnum);
                                resultset7.remove(ca609Data.qcseq);
                              }

                              checkvalue = ca609Data.isChecked ? 'Y' : '';
                             
                            });
                          }
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }




  Future<Null> _selectDateWithMinMaxDate(BuildContext context) async {
    var firstDate = DateTime(initialDate.year, initialDate.month - 3, initialDate.day);
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

  void openPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('수입검사취소'),
          content: Text('취소되었습니다.'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                log_history_d();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabHomePage()));
              },
            ),
          ],
        );
      },
    );
  }

  void openErrorPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('수입검사취소'),
          content: Text('취소 실패하였습니다.'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabHomePage()));
              },
            ),
          ],
        );
      },
    );
  }


}





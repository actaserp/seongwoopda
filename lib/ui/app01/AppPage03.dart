
import 'dart:convert';
import 'dart:io';

import 'package:actthemoon/model/themoon/storelist_model.dart';
import 'package:actthemoon/ui/app01/AppPage01_Subpage.dart';
import 'package:actthemoon/ui/authentication/usercheck.dart';
import 'package:actthemoon/ui/home/tab_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pointmobile_scanner/pointmobile_scanner.dart';

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/kosep/Da035List_model.dart';

class AppPage03 extends StatefulWidget {
  const AppPage03({Key? key}) : super(key: key);

  @override
  _AppPage03State createState() => _AppPage03State();
}

class _AppPage03State extends State<AppPage03>   {


  String? _decodeResult = "Unknown";

  TextEditingController _etDate = TextEditingController();
  List<TextEditingController> textControllers = List.generate(storelist.length, (index) => TextEditingController(),);



  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();
  List<storelist_model> storelists = storelist;

  String _perid = '';


  List<String> _decodeResults = [];
  List<String> _decodePda = [];
  String result = '';
  String resultset = '';

  List<String> resultset2 = [];
  List<String> resultset3 = [];
  List<String> resultset4 = [];


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
  }

  @override
  void dispose() {
    _etDate.dispose();
    storelist.clear();
    storelists.clear();
    super.dispose();
  }


  String getToday(){
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMMdd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }
  Future<void> sessionData() async{

    _perid    = (await SessionManager().get("perid")).toString().replaceAll("p", "");
    await log_history_h();

  }


  Future tbca630_getdata(String? decodeResult, int arg) async {
    String _dbnm = await  SessionManager().get("dbnm");

    var uritxt = CLOUD_URL + '/themoon/list04';
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
        'gs_today': _etDate.text
      },
    );


    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;


      for (int i = 0; i < alllist.length; i++) {
        storelist_model emObject= storelist_model(
            pcode: alllist[i]["pcode"],
            pname: alllist[i]["pname"],
            psize: alllist[i]["psize"],
            punit: alllist[i]["punit"],
            lotno: alllist[i]["lotno"],
            stdate: alllist[i]["stdate"],
            jaeqty: alllist[i]["jaeqty"],
            isChecked: true,

        );

        String prefixToRemove = emObject.pcode;

        storelists.removeWhere((element) {

            if(element.startsWith(prefixToRemove)){
                return true;
            }
            return false;
        });

        resultset2.add(alllist[i]["pcode"]);
        resultset3.add(alllist[i]["jaeqty"]);


        setState(() {
          emObject.textEditingController = TextEditingController();
          storelist.add(emObject);
        });

      }
      return storelist;
    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('불러오는데 실패했습니다');
    }
  }

  Future log_history_h() async {

    String ipAddress = '';
    for (var interface in await NetworkInterface.list()) {
      for(var address in interface.addresses) {
        ipAddress = address.address;
      }
    }

    String _username = '';
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
          'userid': _perid,
          'ipaddr': ipAddress,
          'usernm' : _username,
          'winnm' : '재고실사',
          'winid' : '재고실사',
          'buton' : '020'
      },
    );
    if(response.statusCode == 200){
      print("통신완료");
      return true;
    }else{
      print("통신에러");
    }
  }

  Future log_history_h2() async {

    String ipAddress = '';
    for (var interface in await NetworkInterface.list()) {
      for(var address in interface.addresses) {
        ipAddress = address.address;
      }
    }

    String _username = '';
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
        'userid': _perid,
        'ipaddr': ipAddress,
        'usernm' : _username,
        'winnm' : '재고실사등록',
        'winid' : '재고실사등록',
        'buton' : '030'
      },
    );
    if(response.statusCode == 200){
      print("통신완료");
      return true;
    }else{
      print("통신에러");
    }
  }


  @override
  Future<bool> save_tbca630()async {


    var uritxt = CLOUD_URL + '/themoon/Insert_tb_ca630';

    var encoded = Uri.encodeFull(uritxt);
    Uri uri = Uri.parse(encoded);
    print("----------------------------");

    final response = await http.post(
        uri,
        headers: <String, String> {
          'Content-Type': 'application/json',
          'Accept' : 'application/json'
        },
        body: json.encode({
          'gs_today': _etDate.text,
          'close_perid': _perid,
          'pcodeList' : resultset2,
          'jaeqtyList': resultset3,
          'silqty'    : resultset4


        }));
    if(response.statusCode == 200){
      print("저장됨");
      return   true;
    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('고장부위 불러오는데 실패했습니다');
      return   false;
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
          '재고실사',
          style: GlobalStyle.appBarTitle,
        ),
        backgroundColor: GlobalStyle.appBarBackgroundColor,
        systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,

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
                      labelText: '실사일자',
                      labelStyle: TextStyle(color: BLACK_GREY),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _etDate.text  ;
                    });
                    String ls_etdate = _etDate.text  ;
                    if(ls_etdate.length == 0){
                      print("일자를 입력하세요");
                      return;
                    }

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
            Expanded(child: ListView.builder(itemCount: storelist.length,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index){
                return _buildListCard(storelist[index]);
              },
            )),
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


                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                        content: Text('실사등록 하시겠습니까?'),
                        actions: <Widget>[
                          TextButton(onPressed: (){

                            for(int i=0; i< storelist.length; i++){
                              String? value = storelist[i].textEditingController?.text;
                              resultset4.add(value ?? '');

                            }


                              save_tbca630();
                              log_history_h2();
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabHomePage()));

                          }, child: Text('OK'))
                        ],
                      );
                    });

                  },
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text('등록',
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

      ),


    );

  }

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


        await tbca630_getdata(result,count);
        print(count);
        print("수량체크");
        _onDecode(call);
        print(storelist.toString());



      } else if (call.method == PointmobileScanner.ON_ERROR){
        _onError(call.arguments);
      } else {
        print(call.arguments);
      }
    } catch(e) {
      print(e);
    }
  }


  void _onDecode(MethodCall call) async {

    setState(() {
      final List lDecodeResult = call.arguments;
      String result = "Symbology: ${lDecodeResult[0]}\nValue: ${lDecodeResult[1]}";

      String result1 = "${lDecodeResult[1]}";

      if(!_decodePda.contains(result1)){
        _decodePda.add(result1);
        print(_decodePda);
        print("object");
      }

      if(!_decodeResults.contains(result)){
        _decodeResults.add(result);
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


  Widget _buildListCard(storelist_model storelist){

    storelist.textEditingController = TextEditingController();

    //TextEditingController controller = textControllers[index];

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
            //Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage11view(da035Data: da035Data)));
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              // showAlertDialog_chulgoDelete(context, da035Data.lotno, da035Data.deldate, da035Data.delnum, da035Data.delseq);
              print(da035Data);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage01_Subpage(da035Data: da035Data)));
            },
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('품목명: ' + storelist.pname, style: GlobalStyle.couponName),
                  Text('규격: ' + storelist.psize, style: GlobalStyle.couponName),
                  Text('재고량: ' + storelist.jaeqty   , style: GlobalStyle.couponName),
                  SizedBox(height: 12),
                  Row(

                    children: [
                      Text( "실사수량", style: TextStyle(
                          fontSize: 14, color: SOFT_BLUE, fontWeight: FontWeight.bold
                      )),
                      Container(
                        width: 70,
                        height: 30,
                        child: TextField(
                          maxLength: 5,
                          controller: storelist.textEditingController,
                          cursorColor: Colors.grey[600],
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),

                        ),
                      )

                    ],
                  ),
                ],
              ),
            ),
          ),
        )
    );

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




}




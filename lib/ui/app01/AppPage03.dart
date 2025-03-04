
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pointmobile_scanner/pointmobile_scanner.dart';

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/kosep/Da035List_model.dart';
import '../../model/themoon/storelist_model.dart';
import '../../services/BarcodeScannerService.dart';
import '../home/tab_home.dart';

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
  List<String> resultset5 = [];



  List<String> resultset22 = [];
  List<String> resultset33 = [];
  List<String> resultset44 = [];
  List<String> resultset55 = [];


  String checkvalue = 'true';





  @override
  void initState() {
    super.initState();

    // Clear existing storelist and initialize session data
    storelist.clear();
    sessionData();

    // Set initial date
    _etDate.text = getToday();

    // Set up the barcode scanner's method call handler
    BarcodeScannerService.setMethodCallHandler(
          (decodedValue) => _onBarcodeDecoded(decodedValue),
          (errorMessage) => _onError(errorMessage),
    );

    // Initialize and configure the scanner
    Future.delayed(Duration.zero, () async {
      BarcodeScannerService.startScan();
      await BarcodeScannerService.setSymbologyEnable(13, true); // CODE128 활성화
      await BarcodeScannerService.setSymbologyEnable(25, true); // EAN13 활성화
      await BarcodeScannerService.setSymbologyEnable(49, true); // QR 활성화
    });
  }

  // Callback function for barcode decoding
  void _onBarcodeDecoded(String decodedValue) async {

    if(decodedValue == null || decodedValue.isEmpty || decodedValue == "NOT READ"){
      debugPrint("바코드 값이 없음");
      return;
    }

    setState(() {
      if (!_decodeResults.contains(decodedValue)) {
        _decodeResults.add(decodedValue);
      }
    });

    // Example: Log the decoded value
    debugPrint('Decoded Barcode: $decodedValue');

    // Custom logic for the decoded barcode
    int count = _decodeResults.where((value) => value == decodedValue).length;
    await tbca630_getdata(decodedValue, count);
  }

// Callback function for error handling
  void _onError(String errorMessage) {
    debugPrint('Scanner Error: $errorMessage');
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

    var uritxt = CLOUD_URL + '/seongwoo/list04';
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
        'code88': decodeResult ?? '',
        'gs_today': _etDate.text
      },
    );


    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;

      if(alllist.isEmpty){
        _showAlertDialog("알림", "해당 품목이 없습니다.");
        return;
      }

      for (int i = 0; i < alllist.length; i++) {
        storelist_model emObject= storelist_model(
            pcode: alllist[i]["pcode"],
            pname: alllist[i]["pname"],
            psize: alllist[i]["psize"],
            punit: alllist[i]["punit"],
            lotno: alllist[i]["lotno"],
            stdate: alllist[i]["stdate"],
            jaeqty: alllist[i]["jaeqty"],
            indate2: alllist[i]["indate2"],
            whether2: alllist[i]["whether2"],
            isChecked: true,
            textEditingController: TextEditingController()

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
        resultset5.add(alllist[i]["lotno"]);



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


    var uritxt = CLOUD_URL + '/seongwoo/loginlog_h';
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


    var uritxt = CLOUD_URL + '/seongwoo/loginlog_h';
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
  Future<bool> save_tbca630() async {


    var uritxt = CLOUD_URL + '/seongwoo/Insert_tb_ca630';
    var encoded = Uri.encodeFull(uritxt);
    Uri uri = Uri.parse(encoded);
    print("----------------------------");


    // if(resultset4.any((value) => value.trim().isEmpty)) {
    //   await showAlterDialog(context);
    //   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AppPage03()));
    //   return false;
    // }


    final response = await http.post(
        uri,
        headers: <String, String> {
          'Content-Type': 'application/json',
          'Accept' : 'application/json'
        },
        body: json.encode({
          'gs_today': _etDate.text,
          'close_perid': _perid,
          'pcodeList' : resultset22,
          'jaeqtyList': resultset33,
          'silqty'    : resultset4,
          'lotnoList' : resultset55,


        }));
    if(response.statusCode == 200){

      if(response.body == "exist") {
        showAlterDialogalready(context);
        return false;

      }


      showAlterDialogSucc(context);
      print(resultset2);
      print(resultset3);
      print(resultset4);
      print(resultset5);

      print("----------------------");

      print(resultset22);
      print(resultset33);
      print(resultset4);
      print(resultset55);

      return   true;
    }else{

      showAlterDialog(context);


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
                      labelText: '실사일자',
                      labelStyle: TextStyle(color: BLACK_GREY),
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
                          TextButton(
                              onPressed: () async {
                                for(var item in storelist) {
                                  if(item.isChecked){

                                    String? value = item.textEditingController?.text;
                                    String? value2 = item.pcode;
                                    String? value3 = item.jaeqty;
                                    String? value5 = item.lotno;


                                    print(value);
                                    resultset4.add(value ?? '');
                                    resultset22.add(value2 ?? '');
                                    resultset33.add(value3 ?? '');
                                    resultset55.add(value5 ?? '');
                                    print(resultset4);
                                    print("gg");
                                  }
                                }

/*
                                print(storelist.length);
                                print(storelist[0].textEditingController?.text);
                                print(storelist[1].textEditingController?.text);
*/



                                Navigator.pop(context);

                                await save_tbca630();
                                await log_history_h2();

                              }, child: Text('OK')),
                          TextButton(onPressed: (){

                            Navigator.pop(context);

                          }, child: Text('Cancel'))
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

  /*Future<void> _onBarcodeScannerHandler(MethodCall call) async {
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
  }*/


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


  /*void _onError(Exception error){
    setState(() {
      _decodeResult = error.toString();
    });
  }*/


  Widget _buildListCard(storelist_model storelist){

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
            onTap: (){
              print(da035Data);
            },
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('품목코드: ' + storelist.pcode, style: GlobalStyle.couponName),
                  Text('품목명: ' + storelist.pname, style: GlobalStyle.couponName),
                  Text('규격: ' + storelist.psize, style: GlobalStyle.couponName),
                  Text('재고량: ' + storelist.jaeqty   , style: GlobalStyle.couponName),
                  /*Text(storelist.whether2 + ' :' + storelist.indate2, style: TextStyle(
                      fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold
                  )),*/
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
                          keyboardType: TextInputType.number,
                          controller: storelist.textEditingController,
                          cursorColor: Colors.grey[600],
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                          enabled: storelist.isChecked,
                        ),
                      ),
                      Expanded(child: Container()),
                      Checkbox(value: storelist.isChecked,
                          onChanged: (bool? value){
                            setState(() {
                              storelist.isChecked = value ?? true;

                              if(storelist.isChecked) {
                                /*resultset2.add(storelist.pcode);
                                resultset3.add(storelist.jaeqty);
                                resultset5.add(storelist.lotno);
*/


                              }else{
                                /*resultset2.remove(storelist.pcode);
                                resultset3.remove(storelist.jaeqty);
                                resultset5.remove(storelist.lotno);*/


                              }
                              checkvalue = storelist.isChecked ? 'Y' : '';

                            });

                          })

                    ],
                  ),
                ],
              ),
            ),
          ),
        )
    );

  }


  Future<void> showAlterDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('재고실사 등록'),
          content: Text('등록중 오류가 발생했습니다. 관리자에게 문의하세요(화면을 나갔다가 바코드를 재인식 해보십시오 혹은 체크된 리스트는 값 입력이 필수입니다).'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, "확인");
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    ).then((result) {
      // 다이얼로그가 닫힌 후 실행될 코드 작성
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AppPage03()));
      return Future.value(); // null 반환
    });
  }


  Future<void> showAlterDialogalready(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('재고실사 등록'),
          content: Text('이미 집계가 완료된 품목이 있습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, "확인");
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void showAlterDialogSucc(BuildContext context) async {
    String result = await showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('재고실사 등록'),
            content: Text('등록이 완료되었습니다.'),
            actions: <Widget>[
              TextButton(onPressed: ()  {
                Navigator.pop(context, "확인");

                //await tbca630_getdata();

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AppPage03()));
                /*Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (context) => TabHomePage()));*/
              }, child: Text('OK'))
            ],
          );
        });
  }


  void showAlterDialogCheck(BuildContext context) async {
    String result = await showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('재고실사 등록'),
            content: Text('체크가 되어있는 리스트는 값을 필요로 합니다.'),
            actions: <Widget>[
              TextButton(onPressed: (){
                Navigator.pop(context, "확인");

              }, child: Text('OK'))
            ],
          );
        });
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void removeCardFromList(storelist_model storelistmodel) {
    setState(() {
      storelist.remove(storelistmodel);

    });
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




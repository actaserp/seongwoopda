import 'dart:convert';
import 'dart:io';

import 'package:actkosep/model/kosep/Da035List_model.dart';
import 'package:actkosep/model/themoon/padlist_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pointmobile_scanner/pointmobile_scanner.dart';
import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/themoon/storelist_model.dart';
import '../home/tab_home.dart';
import 'AppPage01.dart';

class AppPage01_Subpage extends StatefulWidget {
  final padlist_model padlistmodel;
  final String date;
  const AppPage01_Subpage({Key? key, required this.padlistmodel, required this.date}) : super(key: key);

  @override
  State<AppPage01_Subpage> createState() => _AppPage01_SubpageState();
}

class _AppPage01_SubpageState extends State<AppPage01_Subpage> {



  String resultsum = "";
  List<String> resultset = [];
  List<String> resultset2 = [];
  List<String> resultset3 = [];
  List<String> resultset4 = [];
  List<String> resultset5 = [];
  List<String> resultset6 = [];




  TextEditingController _etDate = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();
  List<storelist_model> storelists = storelist;

  List<TextEditingController> textControllers = List.generate(storelist.length, (index) => TextEditingController());





  String arrBarcode = "";
  final List<String> arrBarcodeText = <String>[];
  final List<int> colorCodes = <int>[500, 600, 100];
  String _dbnm = '';
  String _userid = '';
  String _username = '';
  int _totqty = 0;
  String checkvalue = 'true';
  String _perid = '';
  String? _decodeResult = "Unknown";


  @override
  void initState() {
    sessionData();
    super.initState();
    _initalizeState();
    setData();
    resultsum = storelists.where((item) => item.isChecked).map((item) => item.cltnm).join('|');


  }

  Future<void> _initalizeState() async {
    await PDAlist_getdata2();
  }

  String getToday(){
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMMdd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }
  Future<void> sessionData() async{
    _dbnm     = (await SessionManager().get("dbnm")).toString();
    _userid   = (await SessionManager().get("userid")).toString();
    _username = (await SessionManager().get("username")).toString();
    _perid    = (await SessionManager().get("perid")).toString().replaceAll("p", "");
    print(_perid);
  }


  @override
  void setData(){

    _etDate = TextEditingController(text: widget.date);
  }


  @override
  void dispose(){

    storelist.clear();
    super.dispose();
  }

  Future PDAlist_getdata2() async {


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
        'pcode': widget.padlistmodel.phm_pcod,
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
          isChecked: true,
          textEditingController: TextEditingController(text: alllist[i]["wfokqt"]),


        );

        /*Set<String> cltnm = Set();*/



        resultset.add(alllist[i]["wfokqt"]);
        resultset2.add(alllist[i]["plan_no"]);
        resultset3.add(alllist[i]["wono"]);
        resultset4.add(alllist[i]["pcode"]);
        resultset5.add(alllist[i]["lotno"]);

        setState(() {
          storelists.add(emObject);
        });

      }
      print("서버통신 성공");
      print(alllist);
      return storelists;
    }else{
      throw Exception('불러오는데 실패했습니다.');
    }
  }



  @override
  Future<bool> save_fplandata()async {
    _dbnm = await  SessionManager().get("dbnm");
    var uritxt = CLOUD_URL + '/themoon/Update_TB_FPLAN';
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
          'dbnm': _dbnm,
          'close_perid': _perid,
          'wokqtList' : resultset,
          'planNoList': resultset2,
          'wonolist' : resultset3,
          'close_date': widget.date,
          'lotnoList' : resultset5,
          'pcodeList' : resultset4,
          'end_qty'   : resultset6

        }));
    if(response.statusCode == 200){

      showAlterDialogSucc(context);

      print("저장됨");
      return   true;
    }else{

      showAlertDialog(context);


      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('고장부위 불러오는데 실패했습니다');
      return   false;
    }
  }

  Future log_history_h2() async {

    String ipAddress = '';
    for (var interface in await NetworkInterface.list()) {
      for (var address in interface.addresses) {
        ipAddress = address.address;
      }
    }

    String _username = '';
    String username = (await SessionManager().get("username")).toString().replaceAll("p", "");
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
        'buton'  : '030'
      },
    );
    if(response.statusCode == 200){
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
        title: Text('입고등록 상세',
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
                      print(_etDate.text);
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
              ],
            ),
            /* Container(
                height: MediaQuery.of(context).size.height * 0.56,
                child: WillPopScope(
                    child: ListView.builder(
                      itemCount: storelist.length,
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return _buildListCard(storelist[index]);
                      },
                    ),
                    onWillPop: (){
                      Navigator.pop(context);
                      return Future.value(true);
                    }),
              ),*/
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
                    print(storelists.toString());
                    print(resultset);
                    print(resultset2);
                    print(resultset3);
                    print(resultset4);
                    print(resultset5);





                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                        content: Text('입고등록 하시겠습니까?'),
                        actions: <Widget>[
                          TextButton(onPressed: () async {

                            for(var item in storelist){
                              if(item.isChecked){
                                for(int i=0; i<storelist.length; i++){
                                  String? value = storelist[i].textEditingController?.text;
                                  resultset6.add(value ?? '');
                                }
                              }
                            }
                            //Navigator.pop(context);
                            Navigator.pop(context);

                            await save_fplandata();
                            await log_history_h2();

                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabHomePage()));
                          }, child: Text('OK')),

                          TextButton(onPressed: (){
                            Navigator.pop(context);

                          }, child: Text('취소'))
                        ],
                      );
                    });
                    //save_fplandata();

                  }, child: Padding(padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text('입고등록',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                  textAlign: TextAlign.center,
                ),)),
            )
          ],
        ),
      ),
    );

  }


  Widget _buildListCard(storelist_model storelist){

    //storelist.textEditingController = TextEditingController();

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

          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('품목코드: ' + storelist.pcode, style: GlobalStyle.couponName),
                Text('거래처: ' + storelist.cltnm, style: GlobalStyle.couponName),
                Text('품목명: ' + storelist.pname, style: GlobalStyle.couponName),
                Text('규격: ' + storelist.psize, style: GlobalStyle.couponName),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    GestureDetector(
                      onTap: (){

                      },
                      child: Text('완료수량: ' + storelist.wfokqt, style: TextStyle(
                          fontSize: 14, color: SOFT_BLUE, fontWeight: FontWeight.bold
                      )),
                    ),

                  ],
                ),
                Row(
                  children: [
                    Text("수량 : ", style: TextStyle(
                        fontSize: 14, color: SOFT_BLUE, fontWeight: FontWeight.bold
                    )),
                    Container(
                      width: 120,
                      height: 30,
                      child: TextField(
                        maxLength: 9,
                        controller: storelist.textEditingController,
                        cursorColor: Colors.grey[600],
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                    ),
                    Checkbox(
                        value: storelist.isChecked,
                        onChanged: (bool? value){
                          setState(() {
                            storelist.isChecked = value ?? true;

                            if(storelist.isChecked) {
                              resultset.add(storelist.wfokqt);
                              resultset2.add(storelist.plan_no);
                              resultset3.add(storelist.wono);
                              resultset4.add(storelist.pcode);
                              resultset5.add(storelist.lotno);
                              resultsum += storelist.wfokqt + "|";

                            }else{
                              resultset.remove(storelist.wfokqt);
                              resultset2.remove(storelist.plan_no);
                              resultset3.remove(storelist.wono);
                              resultset4.remove(storelist.pcode);
                              resultset5.remove(storelist.lotno);

                              resultsum = resultsum.replaceAll(storelist.wfokqt, "");

                            }
                            checkvalue = storelist.isChecked ? 'Y' : '';
                            print('값 확인 ::: ' + checkvalue.toString());
                            print(resultset);
                            print(resultset2);
                            print(resultset3);

                          });
                        })
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




/*  void showAlertDialog_chulgoSave(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ACTAS 출고등록'),
          content: Text("출고등록을 하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async{
                Navigator.pop(context, "저장");
                var result = await da006list_getdata();
                if(result){
                  setState(() {
                  });
                  // Navigator.pushReplacement(
                  //     context, MaterialPageRoute(builder: (context) =>
                  //     mpuchase(pernm: widget.pernm, perid: widget.perid, userid: widget.userid)
                  // ));
                  // print("저장성공!");
                }else{
                  showAlertDialog(context, "출고저장 중 오류가 ");
                  return ;
                }
                print("chulgo_save result=>" + result.toString());
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context, "닫기");
              },
            ),
          ],
        );
      },
    );
  }*/

  void showAlertDialog_Clear(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ACTAS 출고등록'),
          content: Text("스캔한 LotNo를 리셋하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async{
                setState(() {
                  arrBarcode = "";
                  arrBarcodeText.clear();

                });
                Navigator.pop(context, "닫기");
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context, "닫기");
              },
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
            title: Text('입고 등록'),
            content: Text('등록이 완료되었습니다.'),
            actions: <Widget>[
              TextButton(onPressed: (){
                Navigator.pop(context, "확인");
                Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (context) => TabHomePage()));
              }, child: Text('OK'))
            ],
          );
        });
  }

  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('입고등록'),
          content: Text('등록중 오류가 발생했습니다. 관리자에게 문의하세요(화면을 나갔다가 바코드를 재인식 해보십시오 혹은 체크된 리스트는 값 입력이 필수입니다).'),
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

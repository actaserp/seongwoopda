
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/kosep/Da035List_model.dart';
import '../../model/themoon/storelist_model.dart';
import '../home/tab_home.dart';

class AppPage02 extends StatefulWidget {
  const AppPage02({Key? key}) : super(key: key);

  @override
  _AppPage02State createState() => _AppPage02State();
}

class _AppPage02State extends State<AppPage02>   {

  TextEditingController _etDate = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();
  List<storelist_model> storelistes = storelist;


  String _perid = '';
  List<String> resultset = [];
  String checkvalue = 'true';



  @override
  void initState() {
    sessionData();
    super.initState();
    _etDate.text = getToday();
    //_initalizeState();

  }


  Future<void> _initalizeState() async {
    await PDAlist_getdata3();
  }

  @override
  void dispose() {
    _etDate.dispose();
    storelist.clear();
    super.dispose();
  }


  Future PDAlist_getdata3() async {

    var uritxt = CLOUD_URL + "/themoon/list03";
    var encoded = Uri.encodeFull(uritxt);
    Uri uri = Uri.parse(encoded);

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type' : 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm' : "ERP_THEMOON",
        'gs_today' : _etDate.text,
      },

    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist = jsonDecode(utf8.decode(response.bodyBytes));
      storelist.clear();

      for(int i=0; i< alllist.length; i++){
        storelist_model emObject = storelist_model(
          wendt: alllist[i]["wendt"],
          wono: alllist[i]["wono"],
          lotno: alllist[i]["lotno"],
          plan_no: alllist[i]["plan_no"],
          cltcd: alllist[i]["cltcd"],
          cltnm: alllist[i]["cltnm"],
          pcode: alllist[i]["pcode"],
          pname: alllist[i]["pname"],
          psize: alllist[i]["psize"],
          punit: alllist[i]["punit"],
          wotqt: alllist[i]["wotqt"],
          isChecked: true,

        );


        resultset.add(alllist[i]["plan_no"]);

        setState(() {
          storelistes.add(emObject);
        });

      }
      print("이게 왜 실행?");

      return storelist;
    }else{
      throw Exception('불러오는데 실패했습니다.');
    }
  }


  @override
  Future<bool> update_fplandata()async {

    var uritxt = CLOUD_URL + '/themoon/Update_cancel';
    var encoded = Uri.encodeFull(uritxt);
    Uri uri = Uri.parse(encoded);

    final response = await http.post(
        uri,
        headers: <String, String> {
          'Content-Type': 'application/json',
          'Accept' : 'application/json'
        },
        body: json.encode({
          'planNoList' : resultset,
        }));
    if(response.statusCode == 200){

      showAlterDialogSucc(context);



      return   true;
    }else{

      showAlterDialog(context);


      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('고장부위 불러오는데 실패했습니다');
      return   false;
    }
  }

  Future log_history_h() async {

    String ipAddress = '';
    for(var interface in await NetworkInterface.list()) {
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
          'userid' : _perid,
          'ipaddr' : ipAddress,
          'usernm' : _username,
          'winnm'  : '입고현황',
          'winid'  : '입고현황',
          'buton'  : '010'
        }
    );
    if(response.statusCode == 200){
      return true;
    }else{
      print("object");
    }


  }

  Future log_history_h2() async {



    String ipAddress = '';
    for(var interface in await NetworkInterface.list()) {
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
          'userid' : _perid,
          'ipaddr' : ipAddress,
          'usernm' : _username,
          'winnm'  : '입고취소',
          'winid'  : '입고취소',
          'buton'  : '040'
        }
    );
    if(response.statusCode == 200){
      return true;
    }else{
      print("object");
    }


  }





  String getToday(){
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMMdd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }
  Future<void> sessionData() async{

    _perid    = (await SessionManager().get("perid")).toString();
    await log_history_h();
    print(_perid);
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
          '입고현황',
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
                      labelText: '출고일',
                      labelStyle: TextStyle(color: BLACK_GREY),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _etDate.text  ;
                      PDAlist_getdata3();

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
            storelist.length == 0 || storelist == null ?
            Text('정보가 없습니다.',
              style: TextStyle(
                color: BLACK_GREY,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
                :
            Expanded(child: ListView.builder(itemCount: storelist.length,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index){
                return _buildListCard(storelist[index]);
              },
            )),
            SizedBox(
              height: 50,
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
                        content: Text('입고취소를 하시겠습니까?'),
                        actions: <Widget>[
                          TextButton(onPressed: () async {

                            Navigator.pop(context);


                            await update_fplandata();
                            log_history_h2();


                            await PDAlist_getdata3();

                            setState(() {

                            });

                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabHomePage()));
                          }, child: Text('OK')),
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text('Cancel'))
                        ],
                      );
                    });
                    //save_fplandata();

                  }, child: Padding(padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text('입고취소',
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



  Widget _buildListCard(storelist_model storelists){
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
              print(da035Data);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage01_Subpage(da035Data: da035Data)));
            },
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('품목코드: ' + storelists.pcode, style: GlobalStyle.couponName),
                  Text('거래처: ' + storelists.cltnm, style: GlobalStyle.couponName),
                  Text('품목명: ' + storelists.pname, style: GlobalStyle.couponName),
                  Text('입고량: ' + storelists.wotqt, style: GlobalStyle.couponName),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [


                      Text('규격: ' + storelists.psize, style: GlobalStyle.couponName),



                      /*GestureDetector(
                        onTap: (){

                        },
                        child: Text('입고량: ' + storelists.wotqt, style: TextStyle(
                          fontSize: 14, color: SOFT_BLUE, fontWeight: FontWeight.bold
                        )),
                      ),*/
                      Checkbox(
                          value: storelists.isChecked, onChanged: (bool? value){
                        setState(() {
                          storelists.isChecked = value ?? true;

                          if(storelists.isChecked){
                            resultset.add(storelists.plan_no);
                          }else{
                            resultset.remove(storelists.plan_no);

                          }
                          checkvalue = storelists.isChecked ? 'Y' : '';
                          print(resultset);
                        });
                      })
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }





  Future<Null> _selectDateWithMinMaxDate(BuildContext context) async {
    var firstDate = DateTime(initialDate.year, initialDate.month - 6, initialDate.day);
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


  void showAlterDialogSucc(BuildContext context) async {
    String result = await showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('입고등록 취소'),
            content: Text('취소가 완료되었습니다.'),
            actions: <Widget>[
              TextButton(onPressed: (){
                Navigator.pop(context, "확인");
                /*Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (context) => TabHomePage()));*/
              }, child: Text('OK'))
            ],
          );
        });
  }







  void showAlterDialog(BuildContext context) async {
    String result = await showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('입고등록 취소'),
            content: Text('취소중 오류가 발생했습니다. 관리자에게 문의하세요(화면을 나갔다가 바코드를 재인식 해보십시오 혹은 체크된 리스트는 값 입력이 필수입니다).'),
            actions: <Widget>[
              TextButton(onPressed: (){
                Navigator.pop(context, "확인");
              }, child: Text('OK'))
            ],
          );
        });
  }

}




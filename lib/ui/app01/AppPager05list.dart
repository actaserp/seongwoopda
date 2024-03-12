

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/themoon/popup/eperlist_model.dart';
import '../../model/themoon/tb_da099_02_model.dart';
import 'AppPager04Actnm.dart';


class AppPager05list extends StatefulWidget {

  @override
  _AppPager05listState createState() => _AppPager05listState();
}

class _AppPager05listState extends State<AppPager05list> {
  TextEditingController _etSearch = TextEditingController();
  List<tb_da099_02_model> da099Datas = da099Data;
  bool chk = false;

  TextEditingController _etfrdate = TextEditingController();
  TextEditingController _ettodate = TextEditingController();
  TextEditingController _etcltnm = TextEditingController();

  String? _etManageTxt;

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();

  bool _isChecked = false;
  bool _isLoading = false;

  String cltcd = "";
  String cltnm = "";
  final List<String> _etManageData = [];

  int sumqty = 0;
  int sumsamt = 0;
  int summamt = 0;
  int sumjamt = 0;
  int lastjamt = 0;




  @override
  void initState(){
    super.initState();
    //da099list();
    pop_Manage();
    _etfrdate.text = DateTime.now().toString().substring(0,10);
    _ettodate.text = DateTime.now().toString().substring(0,10);

  }

  @override
  void dispose(){
    _etSearch.dispose();
    da099Data.clear();
    super.dispose();
  }

  NumberFormat amtvalue = NumberFormat.currency(locale: 'ko_KR', symbol: '', decimalDigits: 0);


  String removeValue(double value)
  {
    String result = value.toString();
    if(result.contains('.')) {
      while (result.endsWith('0')) {
        result = result.substring(0, result.length - 1);
      }
      if(result.endsWith('.')) {
        result = result.substring(0, result.length - 1);

      }
    }
    return result;
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

 /**체크박스 선택시 전체 선택*/
  String getAreaParameterValue(){
    return _isChecked ? '%' : _etManageTxt.toString();
  }

  /**전체 조회하기 **/
  Future da099list() async {


    //
    if(cltcd == null || cltcd == "")
      {
        showDialog(context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('판매거래처현황'),
                content: Text('거래처를 선택해주세요.'),
                actions: <Widget>[
                  TextButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, child: Text('확인'))
                ],
              );
            });

        return;
      }

    setState(() {
      _isLoading = true;
    });

    //if(_etcltnm.text == null || _etcltnm.text == "")
    //  {
    //    cltcd = '%';
    //  }


    String _dbnm = await  SessionManager().get("dbnm");

    var uritxt = CLOUD_URL + '/themoon/da099list';
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
        'cltnm': cltnm,
        'cltcd': cltcd,
        'frdate':_etfrdate.text.toString(),
        'todate':_ettodate.text.toString(),
        'comcd': getAreaParameterValue(),


      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];

      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;
      da099Data.clear();

      for (int i = 0; i < alllist.length; i++) {
        tb_da099_02_model emObject = tb_da099_02_model(

            CLTNM  : alllist[i]['cltnm'] ?? '',
            IODATE: alllist[i]['iodate'] ?? '',
            IODV  : alllist[i]['iodv'] ?? '',
            PCODE: alllist[i]['pcode'] ?? '',
            PNAME : alllist[i]['pname'] ?? '',
            PSIZE : alllist[i]['psize'] ?? '',
            PUNIT : alllist[i]['punit'] ?? '',
            QTY : alllist[i]['qty'] ?? '',
            UAMT : alllist[i]['uamt'] ?? '',
            SAMT : alllist[i]['samt'] ?? '',
            TAMT : alllist[i]['tamt'] ?? '',
            MAMT   : alllist[i]['mamt'] ?? '',
            IAMT : alllist[i]['iamt'] ?? '',
            JAMT : alllist[i]['jamt'] ?? '',
            IONO : alllist[i]['iono'] ?? '',
            summamt: alllist[i]['summamt'] ?? '',
            sumqty: alllist[i]['sumqty'] ?? '',
            sumsamt: alllist[i]['sumsamt'] ?? '',
            lastjamt: alllist[i]['lastjamt'] ?? ''


        );
        setState(() {
          da099Data.add(emObject);
        });
      }

      setState(() {
        _isLoading = false;
      });
     sumqty = int.parse(da099Data[0].sumqty);
     sumsamt = int.parse(da099Data[0].sumsamt);
     summamt = int.parse(da099Data[0].summamt);
     lastjamt = int.parse(da099Data[0].lastjamt);

      return da099Data;
    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('불러오는데 실패했습니다');
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////////////


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            '판매거래처현황 ',
            style: GlobalStyle.appBarTitle,
          ),
          actions: <Widget>[
            Row(
              children: [
                Padding(padding: const EdgeInsets.only(right: 10),
                child: TextButton(onPressed: (){
                  da099list();
                }, child: Text('조회하기')),
                )
              ],
            )
          ],
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,

        ),
        body:
        Center(
          child: _isLoading ? CircularProgressIndicator() : ListView(
            padding: EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Text('기간: '),
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.36,
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
                      width: MediaQuery.of(context).size.width * 0.355,

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
              Column(
                children: [
                  Row(
                    children: [
                      Text('거래처: '),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextField(
                          controller: _etcltnm,
                          readOnly: false,
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: PRIMARY_COLOR, width: 2.0)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                              ),
                              suffixIcon: IconButton(onPressed: (){

                                Navigator.push(context, MaterialPageRoute(builder: (context) => AppPager04Actnm(data: _etcltnm.text))).then((value) {
                                  setState(() {
                                    cltcd = value[0];
                                    cltnm = value[1];

                                    _etcltnm.text = value[1];

                                  });

                                });
                              }, icon: Icon(Icons.search))
                            /*labelText: '거래처 *',
                              labelStyle: TextStyle(color: BLACK_GREY)*/
                            /*hintText: '거래처 ',
                              hintStyle: TextStyle(color: BLACK_GREY)*/
                          ),
                        ),
                      ),
                    ],
                  ),
                  /*SizedBox(height: 20),
                  TextButton(onPressed: (){
                  }, child: Center(child: Text("현장 검색하기"))),*/
                ],
              ),


              Row(
                children: [
                  Container(
                    //margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Text('관리처'),
                        Checkbox(value: _isChecked, onChanged: (bool? value){
                          setState(() {
                            _isChecked = value ?? true;

                          });
                        })
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 200,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Card(
                        color: Colors.blue[800],
                        elevation: 5,
                        child: Container(
                          width: 200,
                          //width: double.infinity,
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
                  ),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                children: [
                  Text('수량    : ${NumberFormat('#,###').format(sumqty)}'),
                  SizedBox(width: 10,),
                  Text('공급가: ${NumberFormat('#,###').format(sumsamt)}'),
                ],
              ),

              Row(
                children: [
                  Text('합계    : ${NumberFormat('#,###').format(summamt)}'),
                  SizedBox(width: 10,),
                  Text('잔액: ${NumberFormat('#,###').format(lastjamt
                  )}'),
                ],
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  margin: EdgeInsets.only(top: 15),
                  height: 0.5 * MediaQuery.of(context).size.height,
                  //height: 0.7 * MediaQuery.of(context).size.height,
                  width: 1200,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: [
                      DataTable(
                          showCheckboxColumn: false,
                          columnSpacing: 25, dataRowHeight: 40,
                          headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          headingRowColor:
                          MaterialStateColor.resolveWith((states) => SOFT_BLUE),

                          columns: <DataColumn>[
                            //DataColumn(label: Text('거래처')),
                            DataColumn(label: Text('일자')),
                            DataColumn(label: Text('품목')),
                            DataColumn(label: Text('규격')),
                            DataColumn(label: Text('수량')),
                            DataColumn(label: Text('공급가')),
                            DataColumn(label: Text('부가세')),
                            DataColumn(label: Text('합계')),
                            DataColumn(label: Text('입금액')),
                            DataColumn(label: Text('잔액')),


                          ],

                          rows: List<DataRow>.generate(da099Data.length, (index)
                          {
                            final tb_da099_02_model item = da099Data[index];
                            return
                              DataRow(
                                  onSelectChanged: (value){
                                    /*Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => AppPager13Detail(mfixData: item)));*/
                                  },
                                  color: MaterialStateColor.resolveWith((states){
                                    if (index % 2 == 0){
                                      return Color(0xB8E5E5E5);
                                    }else{
                                      return Color(0x86FFFFFF);
                                    }
                                  }),
                                  cells: [
                                    /*DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 100, maxWidth: 100),
                                            child: Text(item.CLTNM
                                            ))),*/
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(item.IODATE
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(item.PNAME
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(item.PSIZE
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(removeValue(double.parse(item.QTY))
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(amtvalue.format(double.parse(removeValue(double.parse(item.SAMT))))
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(amtvalue.format(double.parse(removeValue(double.parse(item.TAMT))))
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(amtvalue.format(double.parse(removeValue(double.parse(item.MAMT))))
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(amtvalue.format(double.parse(removeValue(double.parse(item.IAMT))))
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 100, maxWidth: 100),
                                            child: Text(amtvalue.format(double.parse(removeValue(double.parse(item.JAMT))))
                                            ))),
                                    /* DataCell(Container(
                                      width: 30,
                                      child: Text(item.JJAMT,
                                          overflow: TextOverflow.ellipsis),
                                    )),
                                    DataCell(Container(
                                      width:30,
                                      child: Text(item.OUAMT,
                                          overflow: TextOverflow.ellipsis),
                                    )),
                                    DataCell(Text(item.INAMT,
                                        overflow: TextOverflow.ellipsis)),
                                    DataCell(Text(item.HJAMT,
                                        overflow: TextOverflow.ellipsis)),*/
                                  ]
                              );
                          }
                          )
                      ),],
                  ),
                ),
              ),


            ],
          ),
        )

    );

  }




  Widget _buildListCard(tb_da099_02_model da099Data){



    return Card(
      margin: EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 2,
      color: Colors.white,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {

        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Visibility(
                    visible: da099Data.CLTNM.isNotEmpty,
                    child: Text('거래처: ' + da099Data.CLTNM ?? '',
                        style: TextStyle(fontSize: 16, color: SOFT_BLUE, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20,),
                  Visibility(
                    visible: da099Data.IODATE.isNotEmpty,
                    child: Text('날짜: ' + da099Data.IODATE ?? '',
                        style: GlobalStyle.couponName),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('구분: ' + da099Data.IODV ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('품목코드: ' + da099Data.PCODE ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              // Text(e401Data.contents, style: GlobalStyle.couponName),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Visibility(
                        visible: da099Data.PNAME.isNotEmpty,
                        child: Text('품목:  ' + da099Data.PNAME + ' ',
                            style: GlobalStyle.couponName),
                      ),


                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 4,
                      ),
                      Visibility(
                        visible: da099Data.PSIZE.isNotEmpty,
                        child: Text('규격: ' + da099Data.PSIZE + ' ', style: TextStyle(
                            fontSize: 16,
                            color: SOFT_BLUE,
                            fontWeight: FontWeight.bold),),
                      ),


                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text('단위: ' + da099Data.PUNIT ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('공급가액: ' + da099Data.SAMT ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('부가세: ' + da099Data.TAMT ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('합계금액: ' + da099Data.MAMT ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('입금액: ' + da099Data.IAMT ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('잔액: ' + da099Data.JAMT ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
             
            ],
          ),
        ),
      ),
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


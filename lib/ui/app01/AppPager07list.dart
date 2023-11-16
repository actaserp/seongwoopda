

import 'dart:convert';

import 'package:actthemoon/model/themoon/tb_fplan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/themoon/popup/popup_model5.dart';
import '../../model/themoon/tb_da099_02_model.dart';


class AppPager07list extends StatefulWidget {




  @override
  _AppPager07listState createState() => _AppPager07listState();
}

class _AppPager07listState extends State<AppPager07list> {
  TextEditingController _etSearch = TextEditingController();

  bool chk = false;
  List<tb_fplan_model> planDatas = planData;



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

  int sumvalue = 0;

  String? _etManageTxt;




  final List<String> _etManageData = [];


  @override
  void initState(){
    super.initState();


    _etfrdate.text = DateTime.now().toString().substring(0,10);
    _ettodate.text = DateTime.now().toString().substring(0,10);

    //tb_last();
    pop_Manage();

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
  void dispose(){
    _etSearch.dispose();
    planData.clear();
    super.dispose();
  }

  String getAreaParameterValue() {
    return _isChecked ? '%' : _etManageTxt.toString();
  }

  bool _isLoading = false;


  Future tb_last() async {
    try {
      if (_etManageTxt == null && _isChecked == false) {
        showAlertDialog(context, '생산부서 분류를 선택하세요');
        return false;
      }

      setState(() {
        _isLoading = true;
      });

      String _dbnm = await SessionManager().get("dbnm");

      var uritxt = CLOUD_URL + '/themoon/tb_last';
      var encoded = Uri.encodeFull(uritxt);

      Uri uri = Uri.parse(encoded);
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json'
        },
        body: <String, String>{
          'dbnm': 'ERP_THEMOON',
          'ps_tdate': _ettodate.text,
          'ps_fdate': _etfrdate.text,
          'divicd': getAreaParameterValue()
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> alllist = [];

        alllist = jsonDecode(utf8.decode(response.bodyBytes));
        planData.clear();

        for (int i = 0; i < alllist.length; i++) {

          tb_fplan_model emObject = tb_fplan_model(

              divicd: alllist[i]['divicd'] ?? '',
              divinm: alllist[i]['divinm'] ?? '',
              pcode: alllist[i]['pcode'] ?? '',
              pname: alllist[i]['pname'] ?? '',
              punit: alllist[i]['punit'] ?? '',
              mtyn: alllist[i]['mtyn'] ?? '',
              wjqty: alllist[i]['wjqty'] ?? '',
              wpqty: alllist[i]['wpqty'] ?? '',
              wiqty: alllist[i]['wiqty'] ?? '',
              woqty: alllist[i]['woqty'] ?? '',
              whqty: alllist[i]['whqty'] ?? '',
              fdate: alllist[i]['fdate'] ?? '',
              tdate: alllist[i]['tdate'] ?? '',
              psize: alllist[i]['psize'] ?? '',
              sum: alllist[i]['sum'] ?? '',


          );
          setState(() {
            planData.add(emObject);
          });
        }

        setState(() {
          _isLoading = false;
        });
        sumvalue = planData[0].sum;
        return planData;
      } else {
        showDialog(context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('오류'),
                content: Text('서버 통신 오류입니다. 관리자에게 문의해주세요'),
                actions: <Widget>[
                  TextButton(onPressed: () {
                    Navigator.of(context).pop();
                  }, child: Text('확인'))
                ],
              );
            });
      }
    } catch (error) {
      showDialog(context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('오류'),
              content: Text('서버 통신 오류입니다. 관리자에게 문의해주세요'),
              actions: <Widget>[
                TextButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text('확인'))
              ],
            );
          });
    }

  }
///////////////////////////////////////////////////////////////////////////////////////////////////


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 185,
          flexibleSpace: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    IconButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, icon: Icon(Icons.arrow_back)),
                    Center(
                      child: Padding(padding: EdgeInsets.only(left: 0, top: 0),
                      child: Text(
                        '기간별생산자별현황  ' + planDatas.length.toString(),
                        style: GlobalStyle.appBarTitle,
                      ),),
                    ),
                    Spacer(),
                    TextButton(onPressed: (){
                      tb_last();
                    }, child: Text('조회하기'))
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
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
              ),),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    //margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Text('부서'),
                        Checkbox(value: _isChecked, onChanged: (bool? value)
                        {
                          setState(() {
                            _isChecked = value ?? true;
                          });
                        })
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 100,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Card(
                        color: Colors.blue[800],
                        elevation: 5,
                        child: Container(
                          width: 100,
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
                  ),
                ],
              ),)
            ],
          ),

          //elevation: GlobalStyle.appBarElevation,
          /*title: Text(
            '기간별생산자별현황 ' + planDatas.length.toString(),
            style: GlobalStyle.appBarTitle,
          ),*/
          actions: <Widget>[
            /*Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: TextButton(onPressed: (){

                    setState(() {

                      //mfixlist_getdata();
                       tb_last();

                    });
                    *//*searchBook(_etSearch.text);*//*
                    *//*searchBook2(_etSearch2.text);*//*
                  }, child: Text('조회하기')),
                ),

              ],
            )*/
          ],
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,

        ),
        body: Column(
          children: [
            Center(
              child: _isLoading ? CircularProgressIndicator() : ListView(
                padding: EdgeInsets.all(16),
                children: [



                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: EdgeInsets.only(top: 15),
                      height: 0.6 * MediaQuery.of(context).size.height,
                      //height: 0.7 * MediaQuery.of(context).size.height,
                      width: 1600,
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
                                DataColumn(label: Text('생산부서')),
                                DataColumn(label: Text('생산부서명')),
                                DataColumn(label: Text('품목코드')),
                                DataColumn(label: Text('품목명')),
                                DataColumn(label: Text('규격')),
                                DataColumn(label: Text('전재고')),
                                DataColumn(label: Text('작지량')),
                                DataColumn(label: Text('입고량')),
                                DataColumn(label: Text('달성율')),
                                DataColumn(label: Text('출고량')),
                                DataColumn(label: Text('현재고')),

                              ],
                              rows: List<DataRow>.generate(planData.length, (index)
                              {
                                final tb_fplan_model item = planData[index];
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
                                        DataCell(
                                            ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                                child: Text(item.divicd
                                                ))),
                                        DataCell(Container(
                                          width: 100,
                                          child: Text(item.divinm,
                                              overflow: TextOverflow.ellipsis),
                                        )),
                                        DataCell(Container(
                                          width:130,
                                          child: Text(item.pcode,
                                              overflow: TextOverflow.ellipsis),
                                        )),
                                        DataCell(Text(item.pname,
                                            overflow: TextOverflow.ellipsis)),
                                        DataCell(Text(item.psize,
                                            overflow: TextOverflow.ellipsis)),
                                        DataCell(
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(minWidth: 95, maxWidth: 95),
                                                  child: Text('${item.wjqty}',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: SOFT_BLUE,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold
                                                      )
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                        DataCell(Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(item.wpqty),
                                          ],
                                        )),
                                        DataCell(Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(item.wiqty),
                                          ],
                                        )),
                                        DataCell(
                                            Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text((double.parse(item.wiqty) / double.parse(item.wpqty)).toString()),
                                          ],
                                        )
                                        ),
                                        DataCell(Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(item.woqty),
                                          ],
                                        )),
                                        DataCell(Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(item.whqty),
                                          ],
                                        )),
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
            ),
          ],
        )

        /*WillPopScope(
          onWillPop: (){
            Navigator.pop(context);
            return Future.value(true);
          },
          child: Column(
            children: [

              Expanded(

                child: ListView.builder(itemCount: planDatas.length,
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index){
                    return _buildListCard(planDatas[index]);
                  },
                ),
              ),

            ],
          ),

        )*/

    );

  }



/*
  Widget _buildListCard(tb_fplan_model planData){



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
                    visible: planData.divicd.isNotEmpty,
                    child: Text('생산부서: ' + planData.divicd ?? '',
                        style: TextStyle(fontSize: 16, color: SOFT_BLUE, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('생산부서명: ' + planData.divinm ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('품목코드: ' + planData.pcode ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('품목명: ' + planData.pname ?? '',
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
                        visible: planData.psize.isNotEmpty,
                        child: Text('규격:  ' + planData.psize ?? '',
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
                        visible: planData.wjqty.isNotEmpty,
                        child: Text('전재고: ' + planData.wjqty + ' ', style: TextStyle(
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
                  Text('작지량: ' + planData.wpqty ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('입고량: ' + planData.wiqty ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('달성율: ' + planData.wpqty ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('출고량: ' + planData.woqty ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('현재고: ' + planData.whqty ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),

             
            ],
          ),
        ),
      ),
    );

  }*/
/*
  String calculateAchievementRate(tb_fplan_model planData){
    if(planData.wpqty.isNotEmpty && planData.wiqty.isNotEmpty){
      double wpqty = double.parse(planData.wpqty)
    }
  }*/


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
          title: Text('판매거래처현황'),
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


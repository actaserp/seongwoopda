

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/themoon/tb_da036_05_model.dart';
import 'AppPager04Actnm.dart';


class AppPager04list extends StatefulWidget {


  @override
  _AppPager04listState createState() => _AppPager04listState();
}

class _AppPager04listState extends State<AppPager04list> {
  TextEditingController _etSearch = TextEditingController();
  TextEditingController _etSearch2 = TextEditingController();

  List<tb_da036_05_model> e601Datas = da036Data;
  bool chk = false;


  List<String> elvlrt = [];
  String addres='';
  String buldNm='';
  String installationPlace='';
  String elvtrDivNm = '';
  String elvtrKindNm = '';
  String frstInstallationDe = "";
  String sigunguNm = '';

  String cltcd = "";
  String cltnm = "";



  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();


  final List<String> _eContData = [];


  TextEditingController _etfrdate = TextEditingController();
  TextEditingController _ettodate = TextEditingController();
  TextEditingController _etcltnm = TextEditingController();


  bool _isChecked = false;
  bool _isLoading = false;

  NumberFormat amtvalue = NumberFormat.currency(locale: 'ko_KR', symbol: '', decimalDigits: 0);



  @override
  void initState(){
    super.initState();

    _etfrdate.text = DateTime.now().toString().substring(0,10);
    _ettodate.text = DateTime.now().toString().substring(0,10);


  }

  @override
  void dispose(){
    _etSearch.dispose();
    da036Data.clear();
    super.dispose();
  }

  Future da036list() async {
    String _dbnm = await  SessionManager().get("dbnm");

    var uritxt = CLOUD_URL + '/themoon/da036list';
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
        'cltnm': _etcltnm.text.toString(),
        'cltcd': cltcd,
        'frdate':_etfrdate.text.toString(),
        'todate':_ettodate.text.toString(),
        'spcd' : '%',
        'area' : '%',
        'comcd': '%',


      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];

      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;
      da036Data.clear();

        for (int i = 0; i < alllist.length; i++) {
          tb_da036_05_model emObject = tb_da036_05_model(

              SPCD: alllist[i]['spcd'],
              SPCDNM: alllist[i]['spcdnm'],
              AREA: alllist[i]['area'],
              AREANM: alllist[i]['areanm'],
              CLTCD: alllist[i]['cltcd'],
              CLTNM: alllist[i]['cltnm'],
              JJAMT: alllist[i]['jjamt'],
              OUAMT: alllist[i]['ouamt'],
              INAMT: alllist[i]['inamt'],
              HJAMT: alllist[i]['hjamt'],
              JYAMT: alllist[i]['jyamt'],
              TAX: alllist[i]['tax'],
              FDATE: alllist[i]['fdate'],
              TDATE: alllist[i]['tdate']

          );
          setState(() {
            da036Data.add(emObject);
          });
        }

      return da036Data;
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
            '기간매출현황 ' + e601Datas.length.toString(),
            style: GlobalStyle.appBarTitle,
          ),
          actions: <Widget>[

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: TextButton(onPressed: (){

                    setState(() {

                      //mfixlist_getdata();
                      da036list();

                    });
                    /*searchBook(_etSearch.text);*/
                    /*searchBook2(_etSearch2.text);*/
                  }, child: Text('조회하기')),
                ),

              ],
            )

            /*IconButton(onPressed: (){

            }, icon: Icon(Icons.search))*/
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

              SizedBox(
                height: 40,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  margin: EdgeInsets.only(top: 15),
                  height: 0.6 * MediaQuery.of(context).size.height,
                  //height: 0.7 * MediaQuery.of(context).size.height,
                  width: 800,
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
                            DataColumn(label: Text('거래처')),
                            DataColumn(label: Text('전잔액')),
                            DataColumn(label: Text('매출액')),
                            DataColumn(label: Text('입금액')),
                            DataColumn(label: Text('잔액')),

                          ],

                          rows: List<DataRow>.generate(da036Data.length, (index)
                          {
                            final tb_da036_05_model item = da036Data[index];
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
                                            constraints: BoxConstraints(minWidth: 100, maxWidth: 100),
                                            child: Text(item.CLTNM
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(amtvalue.format(double.parse(item.JJAMT))
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(amtvalue.format(double.parse(item.OUAMT))
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(amtvalue.format(double.parse(item.INAMT))
                                            ))),
                                    DataCell(

                                        ConstrainedBox(
                                            constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                            child: Text(amtvalue.format(double.parse(item.HJAMT))
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




  Widget _buildListCard(tb_da036_05_model da036Data){



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
                      visible: da036Data.SPCD.isNotEmpty,
                      child: Text('대분류코드: ' + da036Data.SPCD ?? '',
                          style: GlobalStyle.couponName),
                    ),
                    SizedBox(width: 20,),
                    Visibility(
                      visible: da036Data.SPCDNM.isNotEmpty,
                      child: Text('대분류명: ' + da036Data.SPCDNM ?? '',
                          style: GlobalStyle.couponName),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Visibility(
                      visible: da036Data.AREA.isNotEmpty,
                      child: Text('중분류코드: ' + da036Data.AREA ?? '',
                          style: GlobalStyle.couponName),
                    ),
                    SizedBox(width: 20),
                    Visibility(
                      visible: da036Data.AREANM.isNotEmpty,
                      child: Text('중분류명: ' + da036Data.AREANM ?? '',
                          style: GlobalStyle.couponName),
                    ),
                  ],
                ),


                // Text(e401Data.contents, style: GlobalStyle.couponName),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 4,
                        ),
                        Visibility(
                          visible: da036Data.CLTCD.isNotEmpty,
                          child: Text('거래처코드:  ' + da036Data.CLTCD + ' ',
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
                          visible: da036Data.CLTNM.isNotEmpty,
                          child: Text('거래처명: ' + da036Data.CLTNM + ' ', style: TextStyle(
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
                    Text('전잔액: ' + da036Data.JJAMT ?? '',
                        style: GlobalStyle.couponName),
                  ],
                ),
                Row(
                  children: [
                    Text('매출액: ' + da036Data.OUAMT ?? '',
                        style: GlobalStyle.couponName),
                  ],
                ),
                Row(
                  children: [
                    Text('입금액: ' + da036Data.INAMT ?? '',
                        style: GlobalStyle.couponName),
                  ],
                ),
                Row(
                  children: [
                    Text('잔액: ' + da036Data.HJAMT ?? '',
                        style: GlobalStyle.couponName),
                  ],
                ),
                Row(
                  children: [
                    Text('전년동월: ' + da036Data.JYAMT ?? '',
                        style: GlobalStyle.couponName),
                  ],
                ),
                Visibility(
                    visible: da036Data.CLTCD.isEmpty,
                    child: Text('노데이타!'))
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


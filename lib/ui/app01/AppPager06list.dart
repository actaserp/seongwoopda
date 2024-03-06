

import 'dart:convert';

import 'package:actthemoon/model/themoon/tb_ca602_01_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/themoon/tb_da099_02_model.dart';
import '../home/tab_home.dart';


class AppPager06list extends StatefulWidget {

  final String store;
  final String pgun;
  final String agrb;
  final String bgrb;
  final String pcode;

  AppPager06list({
    required this.store,
    required this.pgun,
    required this.agrb,
    required this.bgrb,
    required this.pcode,
  });

  @override
  _AppPager06listState createState() => _AppPager06listState();
}

class _AppPager06listState extends State<AppPager06list> {
  TextEditingController _etSearch = TextEditingController();
  List<tb_ca602_01_model> ca602Datas = ca602Data;
  bool chk = false;


  @override
  void initState(){
    super.initState();
    da099list();


  }

  @override
  void dispose(){
    _etSearch.dispose();
    ca602Data.clear();
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

  Future da099list() async {

    try {
      var uritxt = CLOUD_URL + '/themoon/ca602_01';
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
          'store': widget.store,
          'pgun': widget.pgun,
          'agrb': widget.agrb ?? '',
          'bgrb': widget.bgrb,
          'pcode': widget.pcode,
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> alllist = [];

        alllist = jsonDecode(utf8.decode(response.bodyBytes));
        ca602Data.clear();

        for (int i = 0; i < alllist.length; i++) {
          tb_ca602_01_model emObject = tb_ca602_01_model(


              pgunnm: alllist[i]['pgunnm'] ?? '',
              pcode: alllist[i]['pcode'] ?? '',
              pname: alllist[i]['pname'] ?? '',
              psize: alllist[i]['psize'] ?? '',
              punit: alllist[i]['punit'] ?? '',
              wjqty: alllist[i]['wjqty'] ?? '',
              uamt: alllist[i]['uamt'] ?? '',
              amt: alllist[i]['amt'] ?? '',
              weqty: alllist[i]['weqty'] ?? '',
              wiqty: alllist[i]['wiqty'] ?? '',
              woqty: alllist[i]['woqty'] ?? '',
              storenm: alllist[i]['storen'] ?? '',
              store: alllist[i]['store'] ?? ''


          );
          setState(() {
            ca602Data.add(emObject);
          });
        }

        return ca602Data;
      } else {
        //만약 응답이 ok가 아니면 에러를 던집니다.
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
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            '현재고현황 ' + ca602Datas.length.toString(),
            style: GlobalStyle.appBarTitle,
          ),
          actions: <Widget>[
            TextButton(onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TabHomePage()));
            }, child: Text('홈으로', style: TextStyle(color: Colors.lightBlue, fontSize: 16),))
          ],
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,

        ),
        body:

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            margin: EdgeInsets.only(top: 15),
            height: 0.8 * MediaQuery.of(context).size.height,
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
                      DataColumn(label: Text('품목명')),
                      DataColumn(label: Text('규격')),
                      DataColumn(label: Text('재고량')),
                      DataColumn(label: Text('단가')),
                      DataColumn(label: Text('금액')),

                    ],

                    rows: List<DataRow>.generate(ca602Data.length, (index)
                    {
                      final tb_ca602_01_model item = ca602Data[index];
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
                                      constraints: BoxConstraints(minWidth: 100, maxWidth: 150),
                                      child: Text(item.pname
                                      ))),
                              DataCell(

                                  ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                      child: Text(item.psize
                                      ))),
                              DataCell(

                                  ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 70, maxWidth: 70),
                                      child: Text(item.wjqty
                                      ))),
                              DataCell(

                                  ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 50, maxWidth: 50),
                                      child: Text(item.uamt
                                      ))),
                              DataCell(

                                  ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 100, maxWidth: 100),
                                      child: Text(amtvalue.format(double.parse(removeValue(double.parse(item.amt))))
                                      ))),

                            ]
                        );
                    }
                    )
                ),],
            ),
          ),
        )

    );

  }




  Widget _buildListCard(tb_ca602_01_model ca602Data){



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
                    visible: ca602Data.pgunnm.isNotEmpty,
                    child: Text('품목분류: ' + ca602Data.pgunnm ?? '',
                        style: GlobalStyle.couponName),
                  ),
                  SizedBox(width: 20,),
                  Visibility(
                    visible: ca602Data.pcode.isNotEmpty,
                    child: Text('품목코드: ' + ca602Data.pcode ?? '',
                        style: GlobalStyle.couponName),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('품목명: ' + ca602Data.pname ?? '',
                      style: TextStyle(
                          fontSize: 16,
                          color: SOFT_BLUE,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Text('규격: ' + ca602Data.psize ?? '',
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
                        visible: ca602Data.punit.isNotEmpty,
                        child: Text('단위:  ' + ca602Data.punit + ' ',
                            style: GlobalStyle.couponName),
                      ),


                    ],
                  ),
                ],
              ),


                  Row(
                    children: [

                      Visibility(
                        visible: ca602Data.wjqty.isNotEmpty,
                        child: Text('재고량: ' + ca602Data.wjqty + ' ', style: GlobalStyle.couponName),
                      ),


                    ],
                  ),


              Row(
                children: [
                  Text('단가: ' + ca602Data.uamt ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('금액: ' + ca602Data.amt ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('기초: ' + ca602Data.weqty ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('입고: ' + ca602Data.wiqty ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('출고: ' + ca602Data.woqty ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('창고명: ' + ca602Data.storenm ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
              Row(
                children: [
                  Text('창고 : ' + ca602Data.store ?? '',
                      style: GlobalStyle.couponName),
                ],
              ),
             
            ],
          ),
        ),
      ),
    );

  }




}


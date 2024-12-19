import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import '../../../config/constant.dart';
import '../../../config/global_style.dart';
import '../../model/themoon/tb_ca501_model.dart';
import '../../model/themoon/tbe601list_model.dart';
import '../home/tab_home.dart';

class AppPager06Actnm extends StatefulWidget {

  final String data;

  AppPager06Actnm({required this.data});

  @override
  _AppPager06ActnmState createState() => _AppPager06ActnmState();
}


class _AppPager06ActnmState extends State<AppPager06Actnm> {

  String _searchTerm = '';

  List<tb_ca501_model> ca501Datas = ca501Data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchTerm = widget.data;
    getactnminfo();

  }

  Future getactnminfo() async {


    var uritxt = CLOUD_URL + '/seongwoo/ca501list';
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
        'pnam': _searchTerm,


      },
    );
    if(response.statusCode == 200){

      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;
      ca501Data.clear();
      for (int i = 0; i < alllist.length; i++) {
        tb_ca501_model emObject= tb_ca501_model(

            phm_psize: alllist[i]['phm_psize'] ?? '',
            phm_pnam: alllist[i]['phm_pnam'] ?? '',
            phm_pcod: alllist[i]['phm_pcod'] ?? ''

        );
        setState(() {
          ca501Data.add(emObject);
        });


      }
      return ca501Data;
    }else{
      throw Exception('불러오는데 실패했습니다.');
    }
  }



  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          elevation: GlobalStyle.appBarElevation,
          title: Text(
            '품목 조회' ,
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
        body: WillPopScope(
          onWillPop: (){
            Navigator.pop(context);
            return Future.value(true);
          },
          child: ListView.builder(itemCount: ca501Data.length,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder:  (BuildContext context, int index){
                return _buildListCard(ca501Data[index]);
              }
          ),
        ));
  }


  Widget _buildListCard(tb_ca501_model ca501Data){
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
          /*Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage02Detail(e401Data: e401Data)));*/
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(child: Text(ca501Data.phm_pnam, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                onPressed: () {

                  Navigator.pop(context, [ca501Data.phm_pcod, ca501Data.phm_pnam]);
                },
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('품목코드: ' + ca501Data.phm_pcod, style: GlobalStyle.couponName),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('규격: ' + ca501Data.phm_psize, style: GlobalStyle.couponName),
              ),

              // Text(e401Data.contents, style: GlobalStyle.couponName),
              SizedBox(height: 12),

            ],
          ),
        ),
      ),
    );
  }




}

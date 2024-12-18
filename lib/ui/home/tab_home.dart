import 'dart:convert';

import 'package:actseongwoo/ui/app01/AppPage05.dart';
import 'package:actseongwoo/ui/app01/AppPage06.dart';
import 'package:actseongwoo/ui/app01/AppPage07.dart';
import 'package:actseongwoo/ui/app01/AppPager04list.dart';
import 'package:http/http.dart' as http;
import 'package:actseongwoo/ui/app01/AppPager07list.dart';
import 'package:actseongwoo/ui/home.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:actseongwoo/config/constant.dart';
import 'package:actseongwoo/model/feature/banner_slider_model.dart';
import 'package:actseongwoo/model/feature/category_model.dart';
import 'package:actseongwoo/ui/reusable/cache_image_network.dart';
import 'package:actseongwoo/ui/reusable/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/themoon/userlist_model.dart';
import '../account/tab_account.dart';
import '../app01/AppPage01.dart';
import '../app01/AppPage02.dart';
import '../app01/AppPage03.dart';
import '../app01/AppPage04.dart';
import '../app01/AppPager05list.dart';
import '../app02/App02Now.dart';
import '../app02/App02Reg.dart';

class TabHomePage extends StatefulWidget {
  final String? id;
  final String? pass;
  TabHomePage({this.id, this.pass});

  @override
  _Home1PageState createState() => _Home1PageState();
}

class _Home1PageState extends State<TabHomePage> {
  static final storage = FlutterSecureStorage();
  // initialize global widget
  late String id;
  late String pass;

  final _globalWidget = GlobalWidget();
  Color _color1 = Color(0xFF005288);
  Color _color2 = Color(0xFF37474f);
  var _usernm = "";
  var _userid = "";
  var _sysmain = "";
  int _currentImageSlider = 0;
  bool chk = false;

  List<BannerSliderModel> _bannerData = [];
  List<CategoryModel> _categoryData = [];

  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 3),
        () => 'Data Loaded',
  );

  @override
  void initState()  {
     _initializeData();
    //GLOBAL_URL+'/home_banner/1.jpg'));  LOCAL_IMAGES_URL+'/elvimg/1.jpg'
   _bannerData.add(BannerSliderModel(id: 1, image: HYUNDAI_URL + '/tm1-2-5-S.jpg'));
   _bannerData.add(BannerSliderModel(id: 2, image: HYUNDAI_URL + '/tm1-1-3-S.jpg'));
   _bannerData.add(BannerSliderModel(id: 3, image: HYUNDAI_URL + '/tm1-3-1-2-S.jpg'));
   _bannerData.add(BannerSliderModel(id: 4, image: HYUNDAI_URL + '/tm1-4-2-S.jpg'));
   _bannerData.add(BannerSliderModel(id: 5, image: HYUNDAI_URL + '/tm1-6-1-S.jpg'));

     /*_bannerData.add(BannerSliderModel(id: 1, image: 'https://images.khan.co.kr/article/2023/09/01/rcv.YNA.20230724.PYH2023072416680001300_P1.jpg'));*/
     /*_bannerData.add(BannerSliderModel(id: 2, image: 'https://cdn.gukjenews.com/news/photo/202307/2772317_2809056_5928.jpg'));*/
     /*_bannerData.add(BannerSliderModel(id: 3, image: 'https://cdn.gukjenews.com/news/photo/202307/2772317_2809056_5928.jpg'));*/
     /*_bannerData.add(BannerSliderModel(id: 4, image: 'https://cdn.gukjenews.com/news/photo/202307/2772317_2809056_5928.jpg'));*/



     _categoryData.add(CategoryModel(id: 1, name: '입 고 등 록', image: GLOBAL_URL+'/menu/store.png', color:0xD3D3D3));
    _categoryData.add(CategoryModel(id: 2, name: '입 고 현 황', image: GLOBAL_URL+'/menu/products.png', color:0xD3D3D3));
    // _categoryData.add(CategoryModel(id: 3, name: '출 고 현 황', image: GLOBAL_URL+'/menu/buy_online.png', color:0xD3D3D3));
    _categoryData.add(CategoryModel(id: 4, name: '재 고 실 사', image: GLOBAL_URL+'/menu/apply_credit.png', color:0xD3D3D3));
    _categoryData.add(CategoryModel(id: 5, name: '수입검사등록', image: GLOBAL_URL+'/menu/store.png', color:0xD3D3D3));
    _categoryData.add(CategoryModel(id: 6, name: '수입검사현황', image: GLOBAL_URL+'/menu/products.png', color:0xD3D3D3));
    _categoryData.add(CategoryModel(id: 7, name: '기간매출현황', image: GLOBAL_URL+'/menu/apply_credit.png', color:0xD3D3D3));
    _categoryData.add(CategoryModel(id: 8, name: '판매거래처현황', image: GLOBAL_URL+'/menu/store.png', color:0xD3D3D3));
    _categoryData.add(CategoryModel(id: 9, name: '현재고현황', image: GLOBAL_URL+'/menu/products.png', color:0xD3D3D3));
    // _categoryData.add(CategoryModel(id: 3, name: '출 고 현 황', image: GLOBAL_URL+'/menu/buy_online.png', color:0xD3D3D3));
    _categoryData.add(CategoryModel(id: 10, name: '기간별생산자별현황', image: GLOBAL_URL+'/menu/apply_credit.png', color:0xD3D3D3));



    super.initState();

    //userchk();

  }

  Future<void> _initializeData() async {

    await setData(); // setData() 함수 비동기 호출
    //await userchk(); // userchk() 함수 호출


    // 나머지 초기화 코드
    _bannerData.add(BannerSliderModel(id: 1, image: HYUNDAI_URL + '/tm1-2-5-S.jpg'));
    _bannerData.add(BannerSliderModel(id: 2, image: HYUNDAI_URL + '/tm1-1-3-S.jpg'));
    // 나머지 카테고리 데이터 초기화 코드
  }


  Future<void> setData() async {
    String username = await  SessionManager().get("username");
    String userid = (await SessionManager().get("userid")).toString();
    String sysmain = (await SessionManager().get("sysmain")).toString();
    // 문자열 디코딩
    _usernm = utf8.decode(username.runes.toList());
    _userid = utf8.decode(userid.runes.toList());
    _sysmain = utf8.decode(sysmain.runes.toList());

  }




  Future userchk() async {

    var uritxt = CLOUD_URL + '/seongwoo/usercheck';
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
        'userid': _userid.toString()


      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];

      alllist = jsonDecode(utf8.decode(response.bodyBytes));
      userlist.clear();

      for (int i = 0; i < alllist.length; i++) {
        userlist_model emObject = userlist_model(

            sysmain: alllist[i]['sysmain']
        );
        setState(() {
          userlist.add(emObject);

        });
      }
      return userlist;
    }else{
      throw Exception('오류발생');
    }


  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: Image.asset(LOCAL_IMAGES_URL+'/logo.png', height: 24, color: Colors.white),
            backgroundColor: _color1,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () async {
                    const url = 'http://emmsg.co.kr:8080/actas/about_privacy';
                    if (await canLaunch(url)) {
                    await launch(url);
                    } else {
                    throw 'Could not launch $url';
                    }
                  })
            ]),
        body: ListView(
          children: [
            _buildTop(),
            _buildHomeBanner(),
            _createMenu(),
          ],
        ),
bottomNavigationBar: SizedBox.shrink(),
    );
  }

  Widget _buildTop(){
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: Hero(
                        tag: 'profilePicture',
                        child: ClipOval(
                          child: buildCacheNetworkImage(url: GLOBAL_URL+'/user/avatar.png', width: 30),
                        ),
                      ),
                  ),
                  start(),
                  Text(  _usernm ,
                    style: TextStyle(
                        color: SOFT_BLUE,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                    Text(' 님 반갑습니다.',
                      style: TextStyle(
                          color: _color2,
                          fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                ],
            ),
          ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 17,),
            child: Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
            ),
          ),
          Flexible(
            flex: 0,
            child: Container(
              child: GestureDetector(
                onTap: () {
                  storage.delete(key: "login");
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                },
                child: Text(
                    'Log Out',
                    style: TextStyle(color: _color2, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
                 ],
      ),
    );
  }

  Widget _buildHomeBanner(){
    return Stack(
      children: [
        CarouselSlider(
          items: _bannerData.map((item) => Container(
            child: GestureDetector(
                onTap: (){
                  Fluttertoast.showToast(msg: 'Click banner '+item.id.toString(), toastLength: Toast.LENGTH_SHORT);
                },
                child: buildCacheNetworkImage(width: 0, height: 0, url: item.image)
            ),
          )).toList(),
          options: CarouselOptions(
              aspectRatio: 2,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 6),
              autoPlayAnimationDuration: Duration(milliseconds: 300),
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageSlider = index;
                });
              }
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _bannerData.map((item) {
              int index = _bannerData.indexOf(item);
              return AnimatedContainer(
                duration: Duration(milliseconds: 150),
                width: _currentImageSlider == index?10:5,
                height: _currentImageSlider == index?10:5,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _createMenu(){
    final double HSize = MediaQuery.of(context).size.height/1.5;
    final double WSize = MediaQuery.of(context).size.width/1;
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      ///cell ratio
      childAspectRatio: WSize / HSize,
      shrinkWrap: true,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      crossAxisCount: 3,
      children: List.generate(_categoryData.length, (index) {
        return OverflowBox(
          maxHeight: double.infinity,
          child: GestureDetector(
              onTap: () {
                // Fluttertoast.showToast(msg: 'Click '+_categoryData[index].name.replaceAll('\n', ' '), toastLength: Toast.LENGTH_SHORT);
                String ls_name = _categoryData[index].name.replaceAll('\n', ' ');
                switch (ls_name){
                  case '입 고 등 록' :
                     Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage01()));
                    break;
                  case '입 고 현 황' :
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage02()));
                    break;
                  // case '출 고 현 황' :
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage03()));
                  //   break;
                  case '재 고 실 사' :
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage03()));
                    break;
                  case '수입검사등록' :
                    Navigator.push(context, MaterialPageRoute(builder: (context) => App02Reg()));
                    break;
                  case '수입검사현황' :
                    Navigator.push(context, MaterialPageRoute(builder: (context) => App02Now()));
                    break;
                  case '기간매출현황':

                    if(_sysmain == "1")
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AppPager04list()));
                    }
                    else
                    {
                        showDialog(context: context, builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('알림'),
                            content: Text('접속 권한이 없습니다.'),
                            actions: <Widget>[
                              TextButton(onPressed: (){Navigator.pop(context, "확인");}, child: Text('OK'))
                            ],
                          );

                        });
                    }
                    break;
                  case '판매거래처현황':


                    if(_sysmain == "1")
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AppPager05list()));
                    }
                    else
                    {
                      showDialog(context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('알림'),
                          content: Text('접속 권한이 없습니다.'),
                          actions: <Widget>[
                            TextButton(onPressed: (){Navigator.pop(context, "확인");}, child: Text('OK'))
                          ],
                        );

                      });
                    }
                    break;
                  case '현재고현황':


                    if(_sysmain == "1")
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage06()));
                    }
                    else
                    {
                      showDialog(context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('알림'),
                          content: Text('접속 권한이 없습니다.'),
                          actions: <Widget>[
                            TextButton(onPressed: (){Navigator.pop(context, "확인");}, child: Text('OK'))
                          ],
                        );

                      });
                    }
                    break;
                  case '기간별생산자별현황':


                    if(_sysmain == "1")
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AppPager07list()));
                    }
                    else
                    {
                      showDialog(context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('알림'),
                          content: Text('접속 권한이 없습니다.'),
                          actions: <Widget>[
                            TextButton(onPressed: (){Navigator.pop(context, "확인");}, child: Text('OK'))
                          ],
                        );

                      });
                    }
                    break;
                  default:
                    break;
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[100]!, width: 0.5),
                    color: Colors.white),  //Colors.white
                    padding: EdgeInsets.all(8),
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildCacheNetworkImage(width: 30, height: 30, url: _categoryData[index].image, plColor:  Colors.transparent),
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            child: Text(
                              _categoryData[index].name,
                              style: TextStyle(
                                color: _color1,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ])),
              )
          ),
        );
      }),
    );
  }

  Widget start(){
   return Padding(
     padding: const EdgeInsets.all(2.0),
     child: DefaultTextStyle(
        style: Theme.of(context).textTheme.displayMedium!,
        textAlign: TextAlign.center,
        child: FutureBuilder<String>(
          future: _calculation, // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            List<Widget> check;
            if (snapshot.hasData) {
              check = <Widget>[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 20,
                ),
              ];
            } else if (snapshot.hasError) {
              check = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ];
            } else {
              check = const <Widget>[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                ),
              ];
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: check,
              ),
            );
          },
        ),
      ),
   );
  }


}

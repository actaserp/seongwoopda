import 'dart:ffi';

import 'package:flutter/cupertino.dart';

class storelist_model{

  late var wono;
  late var lotno;
  late var plan_no;
  late var cltcd;
  late var cltnm;
  late var pcode;
  late var pname;
  late var psize;
  late var punit;
  late var wfokqt;
  late var wokqt;
  late var wendt;
  late var wotqt;
  late var stdate;
  late var jaeqty;
  late var wfokqt_sum;
  late var chk;
  late var whether2;
  late var indate2;

  bool isChecked = true;

  TextEditingController? textEditingController = TextEditingController();


  storelist_model({
    this.cltnm,
    this.pname,
    this.psize,
    this.wfokqt,
    this.wokqt,
    this.wono,
    this.lotno,
    this.plan_no,
    this.cltcd,
    this.pcode,
    this.whether2,
    this.indate2,
    this.punit,
    this.wendt,
    this.wotqt,
    this.stdate,
    this.jaeqty,
    this.wfokqt_sum,
    this.textEditingController,
    required this.isChecked,
    this.chk
  });

  bool startsWith(String prefix){
    return pcode.toString().startsWith(prefix);
  }


  @override
  String toString() {



    return '$cltnm $pname $psize $wfokqt';



  }



}

List<storelist_model> storelist =[];
import 'dart:ffi';

class padlist_model{

  late var phm_pcod;
  late var phm_pnam;
  late var phm_size;
  late var phm_unit;
  late var code88;
  late var Sum2;
  late var wfokqt_sum;


  padlist_model({
    this.phm_pnam,
    this.phm_size,
    this.phm_pcod,
    this.phm_unit,
    this.code88,
    this.Sum2,
    this.wfokqt_sum
  });

  bool startsWith(String prefix){
    return phm_pcod.toString().startsWith(prefix);
  }

  @override
  String toString() {
    return '$phm_pcod $phm_pnam $phm_size $phm_unit $code88';
  }



}

List<padlist_model> padlists =[];
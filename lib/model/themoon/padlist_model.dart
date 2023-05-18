import 'dart:ffi';

class padlist_model{

  late var phm_pcod;
  late var phm_pnam;
  late var phm_size;
  late var phm_unit;
  late var code88;
  int Count;

  padlist_model({
    required this.phm_pnam,
    required this.phm_size,
             this.phm_pcod,
             this.phm_unit,
             this.code88,
             this.Count = 0,
});

  bool startsWith(String prefix){
    return phm_pcod.toString().startsWith(prefix);
  }

  @override
  String toString() {
    return '$phm_pcod $phm_pnam $phm_size $phm_unit $code88 $Count';
  }



}

List<padlist_model> padlists =[];
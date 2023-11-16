

class tb_fplan_model{

 late var divicd;
 late var divinm;
 late var pcode;
 late var pname;
 late var punit;
 late var mtyn;
 late var wjqty;
 late var wpqty;
 late var wiqty;
 late var woqty;
 late var whqty;
 late var fdate;
 late var tdate;
 late var psize;
 late var sum;












  tb_fplan_model({

   this.divicd,  //부서
   this.divinm, //부서명
   this.pcode, //품목코드
   this.pname, //품목명
   this.punit, //
   this.mtyn,
   this.wjqty, //전재고
   this.wpqty, //작지량
   this.wiqty, //입고량
   this.woqty, //출고량
   this.whqty, //현재고
   this.fdate,
   this.tdate,
   this.psize,//규격
   this.sum
  });

}

List<tb_fplan_model> planData = [];

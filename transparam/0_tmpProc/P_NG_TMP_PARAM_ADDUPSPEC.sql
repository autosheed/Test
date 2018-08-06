CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_ADDUPSPEC
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_ADDUPSPEC过程执行成功!';

--跨月保底优惠的周期信息配置不标准，手工梳理出来填值 BEGIN    
delete from ng_tmp_tpinfo_addupbaodi;
commit;
insert into ng_tmp_tpinfo_addupbaodi
select a.discnt_name,a.discnt_code,c.price_id,50000482,50000428,b.feediscnt_id,'10250',b.base_fee,0 
  from td_b_discnt a , td_b_feediscnt b , td_b_price_comp c, NG_TMP_FEEPOLOICY d , NG_TMP_PRICE_DISCNT e
 where a.discnt_code = d.feepolicy_id and d.price_id = c.price_id and c.exec_type = '3'
   and c.exec_id = b.feediscnt_id and e.exec_id = b.feediscnt_id
   and b.compute_object_id in (60001,60004);
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 754;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 33056;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 753;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011025;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011027;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011045;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011063;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011029;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011031;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011030;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011064;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011041;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011028;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011034;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011033;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011065;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011035;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011066;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011040;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011032;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011067;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011042;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011068;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011069;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011070;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011071;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011036;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011072;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011043;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8002649;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011073;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011074;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011054;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011055;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011056;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011057;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011052;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011051;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011037;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011058;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011059;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011049;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011060;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011048;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011053;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011047;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011061;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011062;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011026;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 8011046;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 18 where discnt_code = 8011176;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 18 where discnt_code = 8011050;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 910066;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 910067;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 910068;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 9904;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 9905;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 9906;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 9907;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 9908;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 9909;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 792;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 771;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 793;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 794;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 772;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 33055;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 795;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 781;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 796;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 773;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011174;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 780;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 797;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 33054;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 774;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 775;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 783;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 776;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 760;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 798;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 777;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 782;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 778;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 799;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 791;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 779;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 770;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011082;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011083;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011075;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011076;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011077;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011078;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011079;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011080;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 8011081;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 30 where discnt_code = 973;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 30 where discnt_code = 972;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 30 where discnt_code = 910069;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 36 where discnt_code = 9963;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 36 where discnt_code = 970;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 36 where discnt_code = 784;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 983;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 982;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 987;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 978;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 988;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 979;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 980;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 989;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 981;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 975;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 984;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 985;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 976;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 977;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 986;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 10 where discnt_code = 99043;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 12 where discnt_code = 99044;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 14 where discnt_code = 99045;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 18 where discnt_code = 99046;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 99002;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 24 where discnt_code = 99022;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 99041;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 8  where discnt_code = 99042;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000982;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000985;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000989;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000980;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000979;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000986;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000987;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000981;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000983;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000984;
update ng_tmp_tpinfo_addupbaodi set cycle_num = 6  where discnt_code = 8000988;
commit;
--跨月保底优惠的周期信息配置不标准，手工梳理出来填值 END

--宽带包年套餐梳理BEGIN
delete from ng_tmp_tpinfo_ttlan;
delete from ng_tmp_tpinfo_ttlan_dayfee;
commit;
insert into ng_tmp_tpinfo_ttlan
select distinct a.discnt_name,a.b_discnt_code,d.price_id,50000482,e.exec_id,'',f.attr_id,b.base_fee,'',c.cycle_num-1
  from td_b_discnt a , td_b_feediscnt b , NG_TMP_FEEPOLOICY d , NG_TMP_PRICE_DISCNT e , 
       NG_TD_B_OBJECT f , NG_TD_B_OBJECT g , NG_TD_B_ADDUPITEM h , NG_TD_B_ADDUP_CYCLERULE c
 where a.discnt_code = d.feepolicy_id and d.price_id = e.price_id
   and e.exec_id = b.feediscnt_id 
   and b.compute_object_id in 
(
 select object_id from td_b_object where object_id not in (60001,60004) and attr_type = '1' and attr_id in 
  (select addup_item_code from td_b_addupitem where elem_type = '2')
) and b.compute_object_id = g.object_id and g.attr_id = h.addup_item_code and h.cycle_rule_id = c.cycle_rule_id
   and b.effect_object_id = f.object_id;
insert into ng_tmp_tpinfo_ttlan_dayfee
  select a.discnt_name,a.discnt_code,c.feediscnt_id,c.divied_child_value from ng_tmp_tpinfo_ttlan a , td_b_price_comp b , td_b_feediscnt c
   where a.price_id = b.price_id and b.exec_type = '3' and b.exec_id = c.feediscnt_id
     and c.compute_object_id = 42210;
update ng_tmp_tpinfo_ttlan a set dayfee_exec = (select feediscnt_id from ng_tmp_tpinfo_ttlan_dayfee b where a.discnt_code = b.discnt_code);
update ng_tmp_tpinfo_ttlan a set day_fee = (select abs(day_fee) from ng_tmp_tpinfo_ttlan_dayfee b where a.discnt_code = b.discnt_code);
commit;
--剔除无效配置   年包未配置日租费，配了个打折优惠，看不懂~~！
delete from ng_tmp_tpinfo_ttlan where day_fee is null;
commit;

--宽带包年套餐梳理END

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:='ADDUPSPEC err !!!'||substr(SQLERRM,1,200);
       v_resultcode:='-1';
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
END;

/

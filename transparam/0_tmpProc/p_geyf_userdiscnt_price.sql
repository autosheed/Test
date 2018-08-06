/*
����FEEDISCNT
*/
CREATE OR REPLACE PROCEDURE p_geyf_userdiscnt_price
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
  iv_priceId              number(8);
  iv_cycle_num            number(8);
  iv_feediscnt_id         number(8);
  iv_addup_id             number(8);
  iv_item_id              number(8);

  iv_price_comp1          td_b_price_comp%ROWTYPE;
  iv_price_comp2          td_b_price_comp%ROWTYPE;
  iv_price_comp3          td_b_price_comp%ROWTYPE;
  iv_price_comp4          td_b_price_comp%ROWTYPE;
  iv_orderNo              NUMBER(3);
  iv_cond_ids1            VARCHAR2(40);
  iv_cond_ids2            VARCHAR2(40);
  iv_cond_ids3            VARCHAR2(40);
  iv_cond_ids4            VARCHAR2(40);

  iv_states               VARCHAR2(40);
  iv_state                VARCHAR2(40);
  iv_sql                  VARCHAR2(2000);

  type cursor_type is ref CURSOR;
  iv_cursor1 cursor_type;
  iv_cursor2 cursor_type;
  iv_cursor3 cursor_type;
  iv_cursor4 cursor_type;


BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'p_geyf_userdiscnt_price����ִ�гɹ���';

    delete from zhangjt_feediscnt;
    commit;
    INSERT INTO ZHANGJT_FEEDISCNT
    select FEEDISCNT_ID,ORDER_NO,'0','' from NG_TD_B_FEEDISCNT 
     where feediscnt_id in (select distinct exec_id from NG_TMP_PRICE_DISCNT)
       and feediscnt_id not in (select feediscnt_id from ng_tmp_tpinfo_addupbaodi)
       and feediscnt_id not in (select yearfee_exec from ng_tmp_tpinfo_ttlan)
       and feediscnt_id not in (select dayfee_exec from ng_tmp_tpinfo_ttlan where dayfee_exec is not null);
    COMMIT;

--�޳���Ч��¼
update zhangjt_feediscnt set tag = 'Z' , remark = '�ο������շѣ����Ż����޳�'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM ng_td_b_feediscnt
  WHERE compute_method in ('17','27','28','16','19','23')
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt)
);
update zhangjt_feediscnt set tag = 'Z' , remark = 'δ����Ķ���43149,43150'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM ng_td_b_feediscnt
  WHERE (compute_object_id in (43149,43150) or effect_object_id in (1057,43149,43150))
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt)
);
update zhangjt_feediscnt set tag = 'Z' , remark = '��Ч-���ۼ�,���з����ۼ�'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM ng_td_b_feediscnt
  WHERE addup_id = 600001
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt)
);
update zhangjt_feediscnt set tag = 'Z' , remark = '��Ч��¼'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM ng_td_b_feediscnt
  WHERE compute_method='0' AND divied_child_Value='0' AND discnt_fee='0'
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt where tag = '0')
);
update zhangjt_feediscnt set tag = 'Z' , remark = '��Ч�ⶥ��¼'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM ng_td_b_feediscnt a
  WHERE compute_method='1' and divied_child_value = 0 and discnt_fee = '0'
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT where tag = '0')
);
update zhangjt_feediscnt set tag = 'Z' , remark = '��Ч���׼�¼'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM ng_td_b_feediscnt a
  WHERE compute_method = '2' and base_fee = '0'
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT where tag = '0')
);

update zhangjt_feediscnt set tag = 'Z' , remark = '������������--���Ż����޳�'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM td_b_feediscnt
  WHERE (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0')
    and compute_method = '8'
);
update zhangjt_feediscnt set tag = 'Z' , remark = '������������--���Ż����޳�'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM td_b_feediscnt
  WHERE (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0')
    and compute_method = '9'
);
update zhangjt_feediscnt set tag = 'Z' , remark = '�����������˻�����--����δ��'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM td_b_feediscnt a
  WHERE (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0')
    and compute_method = '6'
);
update zhangjt_feediscnt set tag = 'Z' , remark = 'baseobject���ô���'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM td_b_feediscnt a
  WHERE (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0')
    and base_fee like '*%'
);
update zhangjt_feediscnt set tag = 'Z' , remark = '��Ч���ñ��'
 where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM td_b_feediscnt
  WHERE (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0')
    and compute_method = '14'
);
--compute_method=24 ֮ǰ�Ĺ������޷���������ߵ���
insert into ng_tmp_tpinfo_ttlan (discnt_code,price_id,cond_id,yearfee_exec,dayfee_exec,item_id,year_fee,day_fee,cycle_num) 
 values (99088222,60011528,50000482,60011533,60011533,42734,45600,124,12);
insert into ng_tmp_tpinfo_ttlan (discnt_code,price_id,cond_id,yearfee_exec,dayfee_exec,item_id,year_fee,day_fee,cycle_num) 
 values (80028122,92031122,50000482,95018503,95018503,43422,48000,121,13);
update zhangjt_feediscnt set tag = 'Z' , remark = '����������ã�������������' where feediscnt_id in (60011533,95018503);
commit;
update zhangjt_feediscnt set tag = 'Z' , remark = '���������÷ⶥ���޳�(����Ч����)' where (feediscnt_id ,order_no) in
(
  SELECT feediscnt_id ,order_no FROM ng_td_b_feediscnt
  WHERE compute_object_id in (60062)
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt)
); 
--??����Ч��������
update zhangjt_feediscnt set tag = 'Z' , remark = '�������ã�����' where feediscnt_id in (60019337);
commit;



--tag = 'a' ��������--
delete from GEYF_FEEDISCNT_free_fee;
commit;
insert into GEYF_FEEDISCNT_free_fee
select a.feediscnt_id,b.attr_id,a.discnt_fee from ng_td_b_feediscnt a,ng_td_b_object b where 
 (feediscnt_id,order_no) in 
(
select feediscnt_id,order_no from ng_td_b_feediscnt
 where (feediscnt_id,order_no) in (select feediscnt_id,order_no from zhangjt_feediscnt)
   and compute_method='0' AND divied_child_Value='0' AND discnt_fee>'0'
) and a.effect_object_id = b.object_id;
update zhangjt_feediscnt set tag = 'a' , remark = '��������'
 where tag = '0' and (feediscnt_id,order_no) in
(
select feediscnt_id,order_no from ng_td_b_feediscnt
 where (feediscnt_id,order_no) in (select feediscnt_id,order_no from zhangjt_feediscnt)
   and compute_method='0' AND divied_child_Value='0' AND discnt_fee>'0'
);
commit;
--����ȫ�⣬�����ܳ����޶����
delete from geyf_feediscnt_freelimit;
insert into geyf_feediscnt_freelimit
select a.feediscnt_id,b.attr_id,a.base_fee from ng_td_b_feediscnt a,ng_td_b_object b where 
 (feediscnt_id,order_no) in 
(
select feediscnt_id,order_no from ng_td_b_feediscnt
 where (feediscnt_id,order_no) in (select feediscnt_id,order_no from zhangjt_feediscnt)
   and compute_method = '3'
) and a.effect_object_id = b.object_id;
update zhangjt_feediscnt set tag = 'A' , remark = '����ȫ�⣬�����ܳ����޶����'
 where tag = '0' and (feediscnt_id,order_no) in
(
select feediscnt_id,order_no from ng_td_b_feediscnt
 where (feediscnt_id,order_no) in (select feediscnt_id,order_no from zhangjt_feediscnt)
   and compute_method = '3'
);
commit;

--tag = 'b' ����������--
DELETE FROM GEYF_FEEDISCNT_free_per;
COMMIT;
insert into GEYF_FEEDISCNT_free_per
select a.feediscnt_id,b.attr_id,A.DIVIED_CHILD_VALUE,A.DIVIED_PARENT_VALUE from ng_td_b_feediscnt a,ng_td_b_object b where 
 (feediscnt_id,order_no) in 
(
  select FEEDISCNT_ID,ORDER_NO from ng_td_b_feediscnt 
   where (feediscnt_id,order_no) in (select feediscnt_id,order_no from zhangjt_feediscnt WHERE TAG = '0')
     and compute_method = '0' and base_fee = '0' and discnt_fee = '0'
     AND (compute_object_id=0 OR compute_object_id=effect_object_id OR compute_object_id in (select object_id from td_b_object where attr_type = '0'))
) and a.effect_object_id = b.object_id;
update zhangjt_feediscnt set tag = 'b' , remark = '����������'
 where tag = '0' and (feediscnt_id,order_no) in
(
  select FEEDISCNT_ID,ORDER_NO from ng_td_b_feediscnt 
   where (feediscnt_id,order_no) in (select feediscnt_id,order_no from zhangjt_feediscnt WHERE TAG = '0')
     and compute_method = '0' and base_fee = '0' and discnt_fee = '0'
     AND (compute_object_id=0 OR compute_object_id=effect_object_id OR compute_object_id in (select object_id from td_b_object where attr_type = '0'))
);
commit;
--�ٷְټ���
insert into GEYF_FEEDISCNT_free_per
select a.feediscnt_id,b.attr_id,A.DIVIED_CHILD_VALUE,A.DIVIED_PARENT_VALUE from ng_td_b_feediscnt a,ng_td_b_object b where 
 (feediscnt_id,order_no) in 
(
     SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt 
    WHERE (compute_method in ('0') and divied_child_value = divied_parent_value and discnt_fee > '0')  
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag='0')
) and a.effect_object_id = b.object_id;  
update zhangjt_feediscnt set tag = 'b' , remark = '����������'
 where tag = '0' and (feediscnt_id,order_no) in
(
     SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt 
    WHERE (compute_method in ('0') and divied_child_value = divied_parent_value and discnt_fee > '0')  
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag='0')
);
commit;

--�ⶥ--
delete from GEYF_FEEDISCNT_fengding;
commit;
insert into GEYF_FEEDISCNT_fengding
select a.feediscnt_id,b.attr_id,a.base_fee from ng_td_b_feediscnt a,ng_td_b_object b where 
 (feediscnt_id,order_no) in 
(
    SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt a
    WHERE compute_method='1' and divied_child_value = divied_parent_value and base_object_id = 0
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT where tag = '0')
) and a.effect_object_id = b.object_id;
  
update zhangjt_feediscnt set tag = 'c' , remark = '�ⶥ'
 where tag = '0' and (feediscnt_id,order_no) in
(
    SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt a
    WHERE compute_method='1' and divied_child_value = divied_parent_value
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT)
);
commit;

--����--
--��discnt����
delete from GEYF_FEEDISCNT_bs;
commit;
insert into GEYF_FEEDISCNT_bs(Feediscnt_Id,Item_Id,Fee)
  select a.feediscnt_id,b.attr_id,abs(a.discnt_fee) from ng_td_b_feediscnt a , ng_td_b_object b
   where (feediscnt_id,order_no) in
   (
    SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt 
    WHERE (compute_method in ('0','1') and divied_child_value = '0' and discnt_fee < '0')  
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag='0')
   ) and a.effect_object_id = b.object_id;
update zhangjt_feediscnt set tag = 'd' , remark = '��discnt����'
 where tag = '0' and (feediscnt_id,order_no) in
(
    SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt 
    WHERE (compute_method in ('0','1') and divied_child_value = '0' and discnt_fee < '0')  
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag='0')
);
commit;
insert into GEYF_FEEDISCNT_bs (feediscnt_id,item_id,fee)
 select a.feediscnt_id,b.attr_id,a.base_fee from ng_td_b_feediscnt a , ng_td_b_object b where (feediscnt_id) in (60021017) and a.effect_object_id = b.object_id;
update zhangjt_feediscnt set tag = 'd' , remark = '��discnt����' where tag = '0' and (feediscnt_id) in(60021017);
commit;
-----���ⲹ�����ã�������������������������������
insert into GEYF_FEEDISCNT_bs (feediscnt_id,item_id,fee)
 select a.feediscnt_id,b.attr_id,100 from ng_td_b_feediscnt a , ng_td_b_object b where (feediscnt_id) in (61000763,61000787) and a.effect_object_id = b.object_id;
update zhangjt_feediscnt set tag = 'd' , remark = '��discnt����' where tag = '0' and (feediscnt_id) in(61000763,61000787);
commit;


--sub1--��baseFee�̶�����շѣ������ٲ�
delete from GEYF_FEEDISCNT_FIXED;
insert into GEYF_FEEDISCNT_FIXED(Feediscnt_Id,Item_Id,Fee)
  select a.feediscnt_id,b.attr_id,a.base_fee from ng_td_b_feediscnt a , ng_td_b_object b
   where (feediscnt_id,order_no) in
   (
    select feediscnt_id,order_no from td_b_feediscnt 
     where compute_method = '0' and compute_object_id = effect_object_id 
      and base_fee > '0' and divied_child_value = divied_parent_value and discnt_fee = '0'
      and (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag='0')
   ) and a.effect_object_id = b.object_id;
update zhangjt_feediscnt set tag = 'g' , remark = '��baseFee�̶�����շѣ������ٲ�'
 where tag = '0' and (feediscnt_id,order_no) in
(
    select feediscnt_id,order_no from td_b_feediscnt 
     where compute_method = '0' and compute_object_id = effect_object_id 
      and base_fee > '0' and divied_child_value = divied_parent_value and discnt_fee = '0'
      and (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag='0')
);
commit;
--sub2--��discntFee�̶�����շѣ������ٲ�
insert into GEYF_FEEDISCNT_FIXED(Feediscnt_Id,Item_Id,Fee)
  select a.feediscnt_id,b.attr_id,abs(a.discnt_fee) from ng_td_b_feediscnt a , ng_td_b_object b
   where (feediscnt_id,order_no) in
   (
     SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt 
    WHERE (compute_method in ('0') and divied_child_value = divied_parent_value and discnt_fee < '0')  
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag='0')
   ) and a.effect_object_id = b.object_id;
update zhangjt_feediscnt set tag = 'g' , remark = '��baseFee�̶�����շѣ������ٲ�'
 where tag = '0' and (feediscnt_id,order_no) in
(
     SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt 
    WHERE (compute_method in ('0') and divied_child_value = divied_parent_value and discnt_fee < '0')  
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag='0')
);
commit;

--����--
delete from GEYF_FEEDISCNT_baodi;
commit;
INSERT INTO GEYF_FEEDISCNT_baodi
SELECT a.feediscnt_id,b.attr_id,c.attr_id,a.base_fee
 FROM td_b_feediscnt a,td_b_object b,td_b_object c
 WHERE (feediscnt_id,order_no) IN 
(
  SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt a
  WHERE compute_method='2' AND compute_object_id<>0 
    AND divied_child_Value=divied_parent_Value AND discnt_fee='0' AND base_fee>'0'
    AND NOT EXISTS 
    (SELECT 1 FROM td_b_object b WHERE b.object_id=a.compute_object_id AND b.attr_type='1')
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0')
) AND a.compute_object_id=b.object_id AND a.effect_object_id=c.object_id;
update zhangjt_feediscnt set tag = 'e' , remark = '����'
 where tag = '0' and (feediscnt_id,order_no) in
(
  SELECT feediscnt_id,order_no FROM ng_td_b_feediscnt a
  WHERE compute_method='2' AND compute_object_id<>0 
    AND divied_child_Value=divied_parent_Value AND discnt_fee='0' AND base_fee>'0'
    AND NOT EXISTS 
    (SELECT 1 FROM td_b_object b WHERE b.object_id=a.compute_object_id AND b.attr_type='1')
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0')
);
commit;
INSERT INTO GEYF_FEEDISCNT_baodi
SELECT a.feediscnt_id,b.attr_id,c.attr_id,a.base_fee
 FROM td_b_feediscnt a,td_b_object b,td_b_object c
 WHERE (feediscnt_id,order_no) IN 
(
  select feediscnt_id,order_no from td_b_feediscnt 
   where (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag = '0')
     and effect_object_id = 40250 and compute_object_id <> 0 and discnt_fee = '0' and base_fee <> '0'
) AND a.compute_object_id=b.object_id AND a.effect_object_id=c.object_id;
update zhangjt_feediscnt set tag = 'e' , remark = '����'
 where tag = '0' and (feediscnt_id,order_no) in
(
  select feediscnt_id,order_no from td_b_feediscnt 
   where (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM ZHANGJT_FEEDISCNT WHERE tag = '0')
     and effect_object_id = 40250 and compute_object_id <> 0 and discnt_fee = '0' and base_fee <> '0'
);
commit;

--�����ο�ֵ�Ĳ��ֽ����޶�����--
delete from GEYF_FEEDISCNT_REFEE_LIMIT;
commit;
insert into GEYF_FEEDISCNT_REFEE_LIMIT
 select a.feediscnt_id,c.attr_id,b.attr_id,a.divied_child_value,a.divied_parent_value,a.discnt_fee,a.base_fee
   from ng_td_b_feediscnt a , ng_td_b_object b , ng_td_b_object c
   where (feediscnt_id,order_no) in
   (
    select feediscnt_id,order_no from ng_td_b_feediscnt
     where (feediscnt_id,order_no) in (select feediscnt_id,order_no from ZHANGJT_FEEDISCNT where tag = '0')
       and compute_method = '12'
   ) and a.effect_object_id = b.object_id and a.compute_object_id = c.object_id;
update zhangjt_feediscnt set tag = 'l' , remark = '�����ο�ֵ�Ĳ��ֽ����޶�����'
 where tag = '0' and (feediscnt_id,order_no) in
(
    select feediscnt_id,order_no from ng_td_b_feediscnt
     where (feediscnt_id,order_no) in (select feediscnt_id,order_no from ZHANGJT_FEEDISCNT where tag = '0')
       and compute_method = '12'
);
commit;

--�۷�����--
delete from GEYF_FEEDISCNT_SMS;
commit;
INSERT INTO GEYF_FEEDISCNT_SMS
SELECT a.feediscnt_id,b.attr_id,a.discnt_fee
 FROM td_b_feediscnt a,td_b_object b
 WHERE (feediscnt_id,order_no) IN 
 (
    SELECT feediscnt_id,order_no FROM td_b_feediscnt a
    WHERE compute_method='13'
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0')      
 ) AND a.effect_object_id=b.object_id;
update zhangjt_feediscnt set tag = 'f' , remark = '�۷�����'
 where tag = '0' and (feediscnt_id,order_no) in
(
    SELECT feediscnt_id,order_no FROM td_b_feediscnt a
    WHERE compute_method='13'
      AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0')    
);
commit;

--SPEC�շ�--
delete from GEYF_FEEDISCNT_bs_group;
commit;
insert into GEYF_FEEDISCNT_bs_group(feediscnt_id,Compute_Object_Id,Item_Id,Base_Fee,Base_Num,Single_Fee)
SELECT a.feediscnt_id,a.compute_object_id ʵ�ʸ���,b.attr_id �շ���Ŀ,
       0,a.base_fee,abs(a.divied_child_Value/a.divied_parent_Value)--����
FROM td_b_feediscnt a,td_b_object b
WHERE (feediscnt_id,order_no) IN 
(
  SELECT feediscnt_id,order_no FROM td_b_feediscnt
  WHERE compute_method='0' AND compute_object_id<>0 AND compute_object_id<>effect_object_id
    AND divied_child_Value<>divied_parent_Value AND discnt_fee='0'/* AND base_fee='0'*/
    AND divied_child_Value not like '?%'
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0') 
)
 AND a.effect_object_id=b.object_id ;
update zhangjt_feediscnt set tag = 'i' , remark = '���ݶ������*���۲���'
 where tag = '0' and (feediscnt_id,order_no) in
(
  SELECT feediscnt_id,order_no FROM td_b_feediscnt
  WHERE compute_method='0' AND compute_object_id<>0 AND compute_object_id<>effect_object_id
    AND divied_child_Value<>divied_parent_Value AND discnt_fee='0'/* AND base_fee='0'*/
    AND divied_child_Value not like '?%'
    AND (feediscnt_id,order_no) IN (SELECT feediscnt_id,order_no FROM zhangjt_feediscnt WHERE tag='0') 
);
commit;

insert into GEYF_FEEDISCNT_bs_group(feediscnt_id,Compute_Object_Id,Item_Id,Base_Fee,Base_Num,Single_Fee)
SELECT a.feediscnt_id,a.compute_object_id,b.attr_id �շ���Ŀ,
       a.discnt_fee,a.base_fee,abs(a.divied_child_Value/a.divied_parent_Value)--����
FROM td_b_feediscnt a,td_b_object b
WHERE (feediscnt_id,order_no) IN 
(
 select feediscnt_id,order_no from ng_td_b_feediscnt 
  where (feediscnt_id,order_no) in (select feediscnt_id,order_no from ZHANGJT_FEEDISCNT where tag = '0')
    and base_fee like '?%' and divied_child_value <> '0' and divied_child_value <> divied_parent_value  --27��28����
) AND a.effect_object_id=b.object_id ;
update zhangjt_feediscnt set tag = 'i' , remark = '���ݶ������*���۲���'
 where tag = '0' and (feediscnt_id,order_no) in
(
 select feediscnt_id,order_no from ng_td_b_feediscnt 
  where (feediscnt_id,order_no) in (select feediscnt_id,order_no from ZHANGJT_FEEDISCNT where tag = '0')
    and base_fee like '?%' and divied_child_value <> '0' and divied_child_value <> divied_parent_value
);
commit;
        
EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       v_resulterrinfo:='p_geyf_userdiscnt_price err!!!'||substr(sqlerrm,1,200);
       v_resultcode:='-1';
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
END;
/

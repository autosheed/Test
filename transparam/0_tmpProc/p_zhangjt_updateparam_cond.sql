CREATE OR REPLACE PROCEDURE p_zhangjt_updateparam_cond
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
------------------------------------------------

------------------------------------------------
AS

BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'p_zhangjt_updateparam_cond ����ִ�гɹ���';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE ZHANGJT_COND';

    --��ȡ����������ʹ�õ�����
    INSERT INTO ZHANGJT_COND(COND_ID)
    select distinct b.exec_id from NG_TMP_FEEPOLOICY a , td_b_price_comp b 
     where a.price_id = b.price_id and b.exec_type = '0' and a.type = '3' 
       and feepolicy_id not in (select discnt_code from ng_tmp_tpinfo_addupbaodi)
       and feepolicy_id not in (select discnt_code from ng_tmp_tpinfo_ttlan)
     order by 1;

    --���ּ������͸�������
    UPDATE ZHANGJT_COND a SET COND_TYPE = '0'
    WHERE EXISTS
    (SELECT 1 FROM td_b_simplecond b WHERE b.cond_id=a.cond_id );
    UPDATE ZHANGJT_COND a SET COND_TYPE = '1'
    WHERE EXISTS
    (SELECT 1 FROM td_b_compcond b WHERE b.cond_id=a.cond_id );
    COMMIT;
    
    update ZHANGJT_COND set isdeal = '0';
    update ZHANGJT_COND set isdeal = '1' where COND_TYPE = '0';
    
    BEGIN
        p_zhangjt_deal_compcond(v_resultCode,v_resultErrInfo);  --�����������
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_zhangjt_deal_compcond call error'||SQLERRM;
            RETURN;
    END;
    
    update ZHANGJT_COND SET POLICY_ID = 820100000 + ROWNUM WHERE COND_TYPE = '0';--��
    update ZHANGJT_COND SET POLICY_ID = 820110000 + ROWNUM WHERE COND_TYPE = '1';--���
    
    BEGIN
        p_zhangjt_compcond_lua(v_resultCode,v_resultErrInfo);  --�������������LUA���ʽ
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_zhangjt_compcond_lua call error'||SQLERRM;
            RETURN;
    END;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE ZHANGJT_SIMPLECOND';

    INSERT INTO ZHANGJT_SIMPLECOND(policy_id,cond_id)
    SELECT policy_id,cond_id FROM ZHANGJT_COND WHERE cond_type='0';

-------------------------------��������������-------------------------------
    update ZHANGJT_SIMPLECOND a set a.yes_or_no = (select yes_or_no from td_b_simplecond b where a.cond_id = b.cond_id );
    update ZHANGJT_SIMPLECOND set tag = null ,remark =null;
    update ZHANGJT_SIMPLECOND set policy_expr = 'return 1';
    update ZHANGJT_SIMPLECOND set remark = '���������';
    
--Z--ʧЧ
update ZHANGJT_SIMPLECOND a set tag = 'Z' , remark = 'invalid--���������ж�'
 where cond_id in
 (
  select cond_id from td_b_simplecond where judge_object_id in
   (select object_id from td_b_object where attr_type = '1' and attr_id in (select addup_item_code from td_b_addupitem where elem_type = '1'))
      and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
 );
--Z--invalid--�۷��������
update ZHANGJT_SIMPLECOND a set tag = 'Z' , remark = 'invalid--�۷��������'
where cond_id in
(
select cond_id from td_b_simplecond where judge_object_id in (80035) and cond_id in (select cond_id from ZHANGJT_SIMPLECOND)
);
--Z--invalid--��������
update ZHANGJT_SIMPLECOND a set tag = 'Z' , remark = 'invalid--��������',policy_expr = '
return 0
' where cond_id in (50050005,92001327,92001339);
commit;

     --1--���ô���ĳ��������: (]
    update ZHANGJT_SIMPLECOND a set tag = '1' , remark = '���ô���ĳ��������'
      where a.tag is null and a.cond_id in
      (select cond_id from td_b_simplecond
        where judge_object_id in (select object_id from td_b_object where attr_type='0') and judge_method='1'
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );
    update ZHANGJT_SIMPLECOND a set a.judge_fee = (select min_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.cycle_num = (select max_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.judge_item_id = (select attr_id from td_b_simplecond b , td_b_object c where a.cond_id = b.cond_id and b.judge_object_id = c.object_id)
      where tag = '1';

    update ZHANGJT_SIMPLECOND a set remark = a.judge_item_id||'��Ŀ����>'||a.judge_fee/100||'Ԫ,<='||a.cycle_num/100||'Ԫ',
policy_expr = '--'||a.judge_item_id||'��Ŀ����>'||a.judge_fee/100||'Ԫ,<='||a.cycle_num/100||'Ԫ

function get_fee(_inparam1,_inparam2)

  return (PROM_TYPE_ITEM_FEE(p,_inparam1,_inparam2))

end

local itemFee = get_fee( '||a.judge_item_id||' , 2 )

if(itemFee > '||a.judge_fee||' and itemFee <= '||a.cycle_num||') then

  return 1

else

  return 0

end'
where tag = '1';

    --2--���ô���ĳ��������:[)--
    update ZHANGJT_SIMPLECOND a set tag = '2' , remark = '��Ŀ����С��XXԪ'
      where a.tag is null and a.cond_id in
      (select cond_id from td_b_simplecond
        where judge_object_id in (select object_id from td_b_object where attr_type='0') and judge_method='2'
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );

    update ZHANGJT_SIMPLECOND a set a.judge_fee = (select min_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.cycle_num = (select max_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.judge_item_id = (select attr_id from td_b_simplecond b , td_b_object c where a.cond_id = b.cond_id and b.judge_object_id = c.object_id)
      where tag = '2';

    update ZHANGJT_SIMPLECOND a set remark = a.judge_item_id||'��Ŀ����>='||a.judge_fee/100||'Ԫ,<'||a.cycle_num/100||'Ԫ',
policy_expr = '--'||a.judge_item_id||'��Ŀ����>='||a.judge_fee/100||'Ԫ,<'||a.cycle_num/100||'Ԫ

function get_fee(_inparam1,_inparam2)
  return (PROM_TYPE_ITEM_FEE(p,_inparam1,_inparam2))
end

local itemFee = get_fee( '||a.judge_item_id||' , 2 )

if(itemFee >= '||a.judge_fee||' and itemFee < '||a.cycle_num||') then
  return 1
else
  return 0
end'
where tag = '2';

    --3--���ô���ĳ��������[]--
    update ZHANGJT_SIMPLECOND a set tag = '3' , remark = '��Ŀ���õ���XXԪ'
      where a.tag is null and a.cond_id in
      (select cond_id from td_b_simplecond
        where judge_object_id in (select object_id from td_b_object where attr_type='0') and judge_method in('3')
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );
   update ZHANGJT_SIMPLECOND a set a.judge_fee = (select min_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.cycle_num = (select max_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.judge_item_id = (select attr_id from td_b_simplecond b , td_b_object c where a.cond_id = b.cond_id and b.judge_object_id = c.object_id)
      where tag = '3';

    update ZHANGJT_SIMPLECOND a set remark = a.judge_item_id||'��Ŀ����>='||a.judge_fee/100||'Ԫ,<='||a.cycle_num/100||'Ԫ',
policy_expr = '--'||a.judge_item_id||'��Ŀ����>='||a.judge_fee/100||'Ԫ,<='||a.cycle_num/100||'Ԫ
function get_fee(_inparam1,_inparam2)
  return (PROM_TYPE_ITEM_FEE(p,_inparam1,_inparam2))
end

local itemFee = get_fee( '||a.judge_item_id||' , 2 )

if(itemFee >= '||a.judge_fee||' and itemFee <= '||a.cycle_num||') then
  return 1
else
  return 0
end'
where tag = '3';

--�ۼƷ����ж�
    update ZHANGJT_SIMPLECOND a set tag = '4' , remark = '�ۼƷ���С��xxԪ'
      where a.tag is null and a.cond_id in
      (select cond_id from td_b_simplecond
        where judge_object_Id in 
        (select object_id from td_b_object where attr_type = '1' and attr_id in (select addup_item_code from td_b_addupitem where elem_type = '2'))
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );
    update ZHANGJT_SIMPLECOND a set a.judge_fee = (select min_value from td_b_simplecond b where a.cond_id = b.cond_id)
      where tag = '4';
    update ZHANGJT_SIMPLECOND a set a.cycle_num = (select max_value from td_b_simplecond b where a.cond_id = b.cond_id)
      where tag = '4';
    update ZHANGJT_SIMPLECOND a set a.judge_item_id = (select judge_object_id from td_b_simplecond b where a.cond_id = b.cond_id)
      where tag = '4';
    --��ȡ�����Ӧ���ۻ���
    update zhangjt_simplecond a set judge_item_id = (select attr_id from td_b_object b where a.judge_item_id = b.object_id)
     where tag = '4';
    --��ȡ�ۻ�����Ӧ�Ŀ�Ŀ
    update zhangjt_simplecond a set judge_item_id = (select b.elem_id from td_b_addupitem b where a.judge_item_id = b.addup_item_code)
     where tag = '4';
    update ZHANGJT_SIMPLECOND a set remark = a.judge_item_id||'�ۼƷ��ô���'||a.judge_fee/100||'Ԫ'||',С��'||a.cycle_num/100||'Ԫ',
                                    policy_expr = '--
local addupFee = GET_LAST_ADDUPSEPC_FEE(p,'||a.judge_item_id||')
if(addupFee >= '||a.judge_fee||' and addupFee <= '||a.cycle_num||') then
  return 1
else
  return 0
end' where tag = '4';

--ָ������Ʒ�Ƿ񶩹���
update ZHANGJT_SIMPLECOND set tag = '5' 
 where tag is null and cond_id in
(
  select cond_id from td_b_simplecond 
   where cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null) and judge_method = '5' and min_value = '0'
);
update ZHANGJT_SIMPLECOND a set cycle_num = (select enum_value from td_b_simplecond b where a.cond_id = b.cond_id)
 where tag = '5';
update ZHANGJT_SIMPLECOND set remark = 'û�ж�����'||cycle_num||'�ײ�',
                              policy_expr = '--û�ж�����'||cycle_num||'�ײ�
if (JUDGE_EXIST_TP(p,'||cycle_num||') == 1) then
  return 0
else
  return 1
end' where tag = '5' and yes_or_no = '1';
update ZHANGJT_SIMPLECOND set remark = '������'||cycle_num||'�ײ�',
                              policy_expr = '--������'||cycle_num||'�ײ�
if (JUDGE_EXIST_TP(p,'||cycle_num||') == 1) then
  return 1
else
  return 0
end' where tag = '5' and yes_or_no = '0';

   --6--ĳЩ״̬������������
    update ZHANGJT_SIMPLECOND a set tag = '6'
      where a.tag is null and a.cond_id in
      (
      select cond_id from td_b_simplecond
        where judge_method = '5' and min_value = '1'
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );
    update ZHANGJT_SIMPLECOND a set a.state_set = (select replace(enum_value,',','') from td_b_simplecond b where a.cond_id = b.cond_id ),
                              a.cycle_num = (select max_value from td_b_simplecond b where a.cond_id = b.cond_id )
      where tag = '6';
    update ZHANGJT_SIMPLECOND a set remark = '--����['||a.state_set||']״̬'||to_char(cycle_num)||'������,�Ż�'||decode(yes_or_no,'1','ʧЧ','0','��Ч')
      where tag = '6';
    BEGIN
        p_zhangjt_deal_stateset(v_resultCode,v_resultErrInfo);  --����enumparam���״̬������λӳ�����ϵͳ��״̬��
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_zhangjt_deal_stateset call error'||SQLERRM;
            RETURN;
    END;
update ZHANGJT_SIMPLECOND a set
policy_expr = '--����'||a.state_set||'״̬'||to_char(cycle_num)||'������,�Ż�'||decode(yes_or_no,'1','ʧЧ','0','��Ч')||'
local r_ret = CAL_JUDGE_STS_CYCLES(p,"'||state_set||'",'||cycle_num||')
local yes_or_no = '|| yes_or_no ||'
if yes_or_no == 1 then
  if r_ret == 0 then
     return 1
  else
     return 0
  end
end
return r_ret
'
 where tag = '6';

--Ʒ���ж�
update zhangjt_simplecond set tag = '7' where cond_id in (select cond_id from td_b_simplecond where judge_object_id = 81051);
update zhangjt_simplecond a set a.state_set = (select enum_value from td_b_simplecond b where a.cond_id = b.cond_id) where tag = '7';
update zhangjt_simplecond set state_set = '108,123,124,125,126,137' where tag = '7';  --Ʒ����ӳ�䣬ǿתһ��ȫ��ͨ
update zhangjt_simplecond a set remark = 'Ʒ��Ϊ'||decode(yes_or_no,1,'��','')||'ȫ��ͨƷ��',
                                policy_expr = '--Ʒ��Ϊ'||decode(yes_or_no,1,'��','')||'ȫ��ͨƷ��
local brandCode = CAL_GET_BRAND(p)
local array_QQT = {'||state_set||'}
local isFound = 0
for i= 1, 6 do
   if (brandCode == array_QQT[i]) then
     isFound = 1
   end
end
local yes_or_no = '|| yes_or_no ||'
if yes_or_no == 1 then
  if isFound == 0 then
     return 1
  else
     return 0
  end
end
return isFound' where tag = '7';

    --8--�ʷѳ���������
    update ZHANGJT_SIMPLECOND a set tag = '8' , remark = '�ʷѶ���ĳ��������Ч'
      where a.tag is null and a.cond_id in
      (
      select cond_id from td_b_simplecond
        where judge_object_id = 81035 and value_param is null
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );
    update ZHANGJT_SIMPLECOND a set a.valid_region = (select min_value||' - '||max_value from td_b_simplecond b where a.cond_id = b.cond_id )
      where tag = '8';
    update ZHANGJT_SIMPLECOND a set a.judge_fee = (select judge_method from td_b_simplecond b where a.cond_id = b.cond_id )
      where tag = '8';
      /*ȱʧPRICE_COMP�Ļ��⴦��*/

    update ZHANGJT_SIMPLECOND set remark = '--�ʷѶ���'||valid_region||'������Ч',
policy_expr = '--�ʷѶ���'||valid_region||'������Ч
if CALC_PROD_USED_CYCLES(p) >= '||substr(valid_region,1,instr(valid_region,' - ')-1)||' and CALC_PROD_USED_CYCLES(p) '||decode(judge_fee,'2','< ','3','<= ')||substr(valid_region,instr(valid_region,' - ')+3)||' then
   return 1
else
   return 0
end'
where tag in ('8','x') and yes_or_no = 0;
    update ZHANGJT_SIMPLECOND set remark = '--�ʷѶ���'||valid_region||'���ڲ���Ч',
policy_expr = '--�ʷѶ���'||valid_region||'���ڲ���Ч
if CALC_PROD_USED_CYCLES(p) >= '||substr(valid_region,1,instr(valid_region,' - ')-1)||' and CALC_PROD_USED_CYCLES(p) '||decode(judge_fee,'2','< ','3','<= ')||substr(valid_region,instr(valid_region,' - ')+3)||' then
   return 0
else
   return 1
end'
where tag in ('8','x') and yes_or_no = 1;

    --9--�����Ժ������Ƿ������õ�����
    update ZHANGJT_SIMPLECOND a set tag = '9' , remark = 'CYCLE_NUM����Ϊ����,����(1)ĩ��(0)��Ч'
      where a.tag is null and a.cond_id in
      (
      select cond_id from td_b_simplecond
        where judge_object_id = 81035 and judge_method = 3 and value_param is not null
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );
    update ZHANGJT_SIMPLECOND a set a.valid_region = (select min_value from td_b_simplecond b where a.cond_id = b.cond_id )
      where tag = '9' ;
    update ZHANGJT_SIMPLECOND a set a.cycle_num = (select substr(value_param,2) from td_b_simplecond b where a.cond_id = b.cond_id )
      where tag = '9' ;
      
    update ZHANGJT_SIMPLECOND a set remark = CYCLE_NUM||'����Ϊ����'||decode(valid_region,1,'����',0,'ĩ��')||'��Ч',
                                policy_expr = '--'||CYCLE_NUM||'����Ϊ����'||decode(valid_region,1,'����',0,'ĩ��')||'��Ч
if CALC_PROD_USED_CYCLES(p)%'||cycle_num||' == '||valid_region||' then
   return 1
else
   return 0
end' where tag = '9' and yes_or_no = 0;
    update ZHANGJT_SIMPLECOND a set remark = CYCLE_NUM||'����Ϊ����'||decode(valid_region,1,'����',0,'ĩ��')||'����Ч',
                                policy_expr = '--'||CYCLE_NUM||'����Ϊ����'||decode(valid_region,1,'����',0,'ĩ��')||'����Ч
if CALC_PROD_USED_CYCLES(p)%'||cycle_num||' == '||valid_region||' then
   return 0
else
   return 1
end' where tag = '9' and yes_or_no = 1;

--�ʷѿ�ʼʱ���ж�BEGIN
update zhangjt_simplecond set tag = 'a' , remark = '�ʷѿ�ʼʱ��>=����ʱ���           ' , policy_expr = '--�ʷѿ�ʼʱ��>=����ʱ���            
 local tpBeginTime = PROM_VALID_DATE(p)
 local cycHalfTime = CALC_HALF_MONTH_TIME(p)
 if tpBeginTime >= cycHalfTime then
     return 1
 else
     return 0
 end
' where cond_id = 50000465;	
update zhangjt_simplecond set tag = 'a' , remark = '�ʷѿ�ʼʱ��<����ʱ���            ' , policy_expr = '--�ʷѿ�ʼʱ��<����ʱ���             
 local tpBeginTime = PROM_VALID_DATE(p)
 local cycHalfTime = CALC_HALF_MONTH_TIME(p)
 if tpBeginTime < cycHalfTime then
     return 1
 else
     return 0
 end
' where cond_id = 50000466;	
update zhangjt_simplecond set tag = 'a' , remark = '�ʷѿ�ʼʱ��>=25                   ' , policy_expr = '--�ʷѿ�ʼʱ��>=25                    
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpDate = (math.floor(tpBeginTime/1000000))%100
 if tpDate >= 25 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50000525;	
update zhangjt_simplecond set tag = 'a' , remark = '�ʷѿ�ʼʱ��<25                    ' , policy_expr = '--�ʷѿ�ʼʱ��<25                     
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpDate = (math.floor(tpBeginTime/1000000))%100
 if tpDate < 25 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50000526;	
update zhangjt_simplecond set tag = 'a' , remark = '�ʷѿ�ʼʱ��>=20                   ' , policy_expr = '--�ʷѿ�ʼʱ��>=20                    
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpDate = (math.floor(tpBeginTime/1000000))%100
 if tpDate >= 20 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50000527;	
update zhangjt_simplecond set tag = 'a' , remark = '�ʷѿ�ʼʱ��<=20                    ' , policy_expr = '--�ʷѿ�ʼʱ��<=20                     
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpDate = (math.floor(tpBeginTime/1000000))%100
 if tpDate <= 20 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50000528;	
update zhangjt_simplecond set tag = 'a' , remark = 'Сʱ����ʱ����ʱ��Σ�23:00-23:59��' , policy_expr = '--Сʱ����ʱ����ʱ��Σ�23:00-23:59�� 
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpHourMin = math.floor((tpBeginTime%1000000)/100)
 if tpHourMin >= 2300 and tpHourMin <= 2359 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50001086;	
update zhangjt_simplecond set tag = 'a' , remark = 'Сʱ����ʱ����ʱ��Σ�00:00-07:00��' , policy_expr = '--Сʱ����ʱ����ʱ��Σ�00:00-07:00�� 
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpHourMin = math.floor((tpBeginTime%1000000)/100)
 if tpHourMin >= 0000 and tpHourMin <= 0659 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50001087;	
update zhangjt_simplecond set tag = 'a' , remark = '�û��ʷѵĿ�ʼʱ���ڵ�ǰ����' , policy_expr = '--�û��ʷѵĿ�ʼʱ���ڵ�ǰ����
 local tpBeginTime = PROM_VALID_DATE(p)
 local cycBeginTime = PROM_BEGIN_DATE(p)
 local cycEndTime = CALC_BILL_END_DATE(p)
 
 if math.floor(tpBeginTime/1000000) >= cycBeginTime and math.floor(tpBeginTime/1000000) <= cycEndTime then
     return 1
 else
     return 0
 end
' where cond_id = 93060018;	
update zhangjt_simplecond set tag = 'a' , remark = '�û��ʷѵĿ�ʼʱ���ڵ�ǰ����֮ǰ' , policy_expr = '--�û��ʷѵĿ�ʼʱ���ڵ�ǰ����֮ǰ
 local tpBeginTime = PROM_VALID_DATE(p)
 local cycBeginTime = PROM_BEGIN_DATE(p)

 if math.floor(tpBeginTime/1000000) < cycBeginTime then
     return 1
 else
     return 0
 end
' where cond_id = 93060019;	
--�ʷѿ�ʼʱ���ж�END

update zhangjt_simplecond set tag = 'a' , remark = '���γ���Ϊ��ĩ����' , policy_expr = '
 if CALC_BILL_CYCLE_TYPE(p) == 1 then
     return 1
 else
     return 0
 end 
' where cond_id = 50000428;	
update zhangjt_simplecond set tag = 'a' , remark = '�û�����Ϊ4' , policy_expr = '
local userTypeCode = CALC_USER_TYPE_CODE(p)
if userTypeCode == 4 then
	return 1
end
return 0
' where cond_id = 50000463;	
update zhangjt_simplecond set tag = 'a' , remark = '���ر���Ϊã��H77D' , policy_expr = '
local cityCode = CALC_CITY_CODE(p)
if cityCode == 1100 then
  return 1
end
return 0
' where cond_id = 50000464;	
update zhangjt_simplecond set tag = 'a' , remark = '���ݱ���Ϊ����0977' , policy_expr = '
local regionCode = CALC_REGION_CODE(p)
if regionCode == 977 then
	return 1
end
return 0
' where cond_id = 50000477;	
update zhangjt_simplecond set tag = 'a' , remark = '�ʷѿ�ʼʱ��<= 20120930' , policy_expr = '
--NG����������
return 1
' where cond_id = 50000625;	
update zhangjt_simplecond set tag = 'a' , remark = '�ʷѿ�ʼʱ��> 20120930' , policy_expr = '
--NG����������
return 1
' where cond_id = 50000626;	
update zhangjt_simplecond set tag = 'a' , remark = '�û��ʷѳ�����������С��3����' , policy_expr = '
local prodUsedCycles = CALC_PROD_USED_CYCLES(p)
if prodUsedCycles >=1 and prodUsedCycles <=3 then
	return 1
end
return 0
' where cond_id = 60000132;	
--b--�жϼ����³�Ա��
    update ZHANGJT_SIMPLECOND a set tag = 'b' , remark = '�жϼ����³�Ա��'
      where a.tag is null and a.cond_id in
      (
      select cond_id from td_b_simplecond
        where judge_object_id=1031
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );
    update ZHANGJT_SIMPLECOND a set a.judge_item_id = (select judge_method from td_b_simplecond b where a.cond_id = b.cond_id),
    a.judge_fee=(select min_value from td_b_simplecond b where a.cond_id = b.cond_id),
    a.cycle_num=(select max_value from td_b_simplecond b where a.cond_id = b.cond_id)
      where tag = 'b';

    update ZHANGJT_SIMPLECOND set remark = '�������û���'||judge_fee||'-'||cycle_num ,
policy_expr = '--'||remark||'
 local memberNum = CALC_GOURP_MEMBER_BY_ROLEID(p,-1,-1)

 if memberNum '||decode(judge_item_id,'0','> ','1','> ','3','>= ')||judge_fee||' and memberNum <= '||cycle_num||' then
     return 1
 else
     return 0
 end'
 where tag = 'b';

update ZHANGJT_SIMPLECOND set tag = 'c' , remark = '�ж��û��Ƿ��¶���' ,
policy_expr = '--�ж��û��Ƿ��¶���
 local r_FirstTime = CALC_PROD_FIRST_TIME(p)
 local cycBeginTime = PROM_BEGIN_DATE(p)
 local cycEndTime = PROM_END_DATE(p)

 if r_FirstTime/1000000 >= cycBeginTime and r_FirstTime/1000000 <= cycEndTime then
     return 1
 else
     return 0
 end
' where cond_id = 60000218;

COMMIT;

   --d--�ж������·�
update ZHANGJT_SIMPLECOND a set tag = 'd' , remark = '�жϵ�ǰ������2�·�',
policy_expr = '
local currMonth = PROM_BEGIN_DATE(p)/100%100
if currMonth == 2 then
   return 1
else
   return 0
end
' where cond_id = 50001034;
update ZHANGJT_SIMPLECOND a set tag = 'd' , remark = '�жϵ�ǰ������8�·�',
policy_expr = '
local currMonth = PROM_BEGIN_DATE(p)/100%100
if currMonth == 8 then
   return 1
else
   return 0
end
' where cond_id = 50001033;


----��������������ƣ�����������µ�������������ƴ��������������⣬�츣������
    BEGIN
        p_xuqk_compcond_name(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_xuqk_compcond_name call error'||SQLERRM;
            RETURN;
    END;

--��sys_policy����¼ʱ����zhangjt_cond��Ϊ׼
update zhangjt_cond a set policy_expr = (select policy_expr from zhangjt_simplecond b where a.cond_id = b.cond_id) where cond_type = '0';
update zhangjt_cond a set cond_name = (select remark from zhangjt_simplecond b where a.cond_id = b.cond_id) where cond_type = '0';
update zhangjt_cond set cond_name = 'NG����Ϊ�����������ʵ��δ�����������������ã�����0',policy_expr = 'return 0'
 where cond_type = '1' and policy_expr is null;
COMMIT;

--��ϵͳg״̬δ�жϣ��ֹ�����
update ZHANGJT_COND set cond_name = '--����[23456789ABFUg]״̬1������,�Ż���Ч' , 
                        policy_expr = '--����1200000002|1200000003|1200000042|1200000043|1200000005|1200000006|1200000007|1200000008|1200000009|1100000005|1100000007|1200000011|1200000041|1200000034״̬1������,�Ż���Ч
local r_ret = CAL_JUDGE_STS_CYCLES(p,"1200000002|1200000003|1200000042|1200000043|1200000005|1200000006|1200000007|1200000008|1200000009|1100000005|1100000007|1200000011|1200000041|1200000034",1)
local yes_or_no = 0
if yes_or_no == 1 then
  if r_ret == 0 then
     return 1
  else
     return 0
  end
end
return r_ret
' where cond_id = 50000480;
COMMIT;

--�������⴦�� æ��ʱ
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111111','Сʱ��æʱ����ʱ��Σ�07��00-23��00��',820109000,'--Сʱ��æʱ����ʱ��Σ�07��00-23��00��
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpHourMin = math.floor((tpBeginTime%1000000)/100)
 if tpHourMin >= 0700 and tpHourMin <= 2259 then
 	return 1
 else
 	return 0
 end' from dual;
COMMIT;

--���´��ڿ���״̬���շ�
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111112','���´��ڿ���״̬���շ�',820109001,'--���´��ڿ���״̬���շ�
local r_ret = CAL_JUDGE_STS_CYCLES(p,"1200000001|1200000002|1200000003|1200000042|1200000043|1200000005|1200000006|1200000007|1200000008|1200000009|1100000005|1100000007|1200000011|1200000041",1)
local yes_or_no = 1
if yes_or_no == 1 then
  if r_ret == 0 then
     return 1
  else
     return 0
  end
end
return r_ret' from dual;
COMMIT;

--û�ж�����3502\3503\3507\3508�ײ�
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111113','û�ж�����3502\3503\3507\3508�ײ�',820109002,'--û�ж�����3502\3503\3507\3508�ײ�
if (JUDGE_EXIST_TP(p,3502) == 0 and JUDGE_EXIST_TP(p,3503) == 0 and JUDGE_EXIST_TP(p,3507) == 0 and JUDGE_EXIST_TP(p,3508) == 0) then
  return 1
else
  return 0
end' from dual;
COMMIT;

--����Ʒ�ж� 7013
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111114','�û�����ƷΪ7013',820109003,'--�û�����ƷΪ7013
if (JUDGE_EXIST_TP(p,100007013) == 1) then
  return 1
else
  return 0
end' from dual;
COMMIT;
--����Ʒ�ж� 7015
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111115','�û�����ƷΪ7015',820109004,'--�û�����ƷΪ7015
if (JUDGE_EXIST_TP(p,100007015) == 1) then
  return 1
else
  return 0
end' from dual;
COMMIT;
--����Ʒ�ж� 7016
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111116','�û�����ƷΪ7016',820109005,'--�û�����ƷΪ7016
if (JUDGE_EXIST_TP(p,100007016) == 1) then
  return 1
else
  return 0
end' from dual;
COMMIT;
--����Ʒ���� 7013/7015/7016
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111117','����Ʒ���� 7013/7015/7016',820109006,'--����Ʒ���� 7013/7015/7016
if (JUDGE_EXIST_TP(p,100007013) == 0 and JUDGE_EXIST_TP(p,100007015) == 0 and JUDGE_EXIST_TP(p,100007016) == 0) then
  return 1
else
  return 0
end' from dual;
COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:=substr(SQLERRM,1,200);
       v_resultcode:='-1';
END;
/

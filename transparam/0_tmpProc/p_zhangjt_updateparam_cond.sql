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
    v_resulterrinfo := 'p_zhangjt_updateparam_cond 过程执行成功！';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE ZHANGJT_COND';

    --提取出所有账务使用的条件
    INSERT INTO ZHANGJT_COND(COND_ID)
    select distinct b.exec_id from NG_TMP_FEEPOLOICY a , td_b_price_comp b 
     where a.price_id = b.price_id and b.exec_type = '0' and a.type = '3' 
       and feepolicy_id not in (select discnt_code from ng_tmp_tpinfo_addupbaodi)
       and feepolicy_id not in (select discnt_code from ng_tmp_tpinfo_ttlan)
     order by 1;

    --区分简单条件和复杂条件
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
        p_zhangjt_deal_compcond(v_resultCode,v_resultErrInfo);  --解析组合条件
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_zhangjt_deal_compcond call error'||SQLERRM;
            RETURN;
    END;
    
    update ZHANGJT_COND SET POLICY_ID = 820100000 + ROWNUM WHERE COND_TYPE = '0';--简单
    update ZHANGJT_COND SET POLICY_ID = 820110000 + ROWNUM WHERE COND_TYPE = '1';--组合
    
    BEGIN
        p_zhangjt_compcond_lua(v_resultCode,v_resultErrInfo);  --生产组合条件的LUA表达式
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_zhangjt_compcond_lua call error'||SQLERRM;
            RETURN;
    END;

    EXECUTE IMMEDIATE 'TRUNCATE TABLE ZHANGJT_SIMPLECOND';

    INSERT INTO ZHANGJT_SIMPLECOND(policy_id,cond_id)
    SELECT policy_id,cond_id FROM ZHANGJT_COND WHERE cond_type='0';

-------------------------------简单条件分类梳理-------------------------------
    update ZHANGJT_SIMPLECOND a set a.yes_or_no = (select yes_or_no from td_b_simplecond b where a.cond_id = b.cond_id );
    update ZHANGJT_SIMPLECOND set tag = null ,remark =null;
    update ZHANGJT_SIMPLECOND set policy_expr = 'return 1';
    update ZHANGJT_SIMPLECOND set remark = '条件恒成立';
    
--Z--失效
update ZHANGJT_SIMPLECOND a set tag = 'Z' , remark = 'invalid--流量区间判断'
 where cond_id in
 (
  select cond_id from td_b_simplecond where judge_object_id in
   (select object_id from td_b_object where attr_type = '1' and attr_id in (select addup_item_code from td_b_addupitem where elem_type = '1'))
      and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
 );
--Z--invalid--扣费提醒相关
update ZHANGJT_SIMPLECOND a set tag = 'Z' , remark = 'invalid--扣费提醒相关'
where cond_id in
(
select cond_id from td_b_simplecond where judge_object_id in (80035) and cond_id in (select cond_id from ZHANGJT_SIMPLECOND)
);
--Z--invalid--错误配置
update ZHANGJT_SIMPLECOND a set tag = 'Z' , remark = 'invalid--错误配置',policy_expr = '
return 0
' where cond_id in (50050005,92001327,92001339);
commit;

     --1--费用处于某段区间内: (]
    update ZHANGJT_SIMPLECOND a set tag = '1' , remark = '费用处于某段区间内'
      where a.tag is null and a.cond_id in
      (select cond_id from td_b_simplecond
        where judge_object_id in (select object_id from td_b_object where attr_type='0') and judge_method='1'
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );
    update ZHANGJT_SIMPLECOND a set a.judge_fee = (select min_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.cycle_num = (select max_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.judge_item_id = (select attr_id from td_b_simplecond b , td_b_object c where a.cond_id = b.cond_id and b.judge_object_id = c.object_id)
      where tag = '1';

    update ZHANGJT_SIMPLECOND a set remark = a.judge_item_id||'科目费用>'||a.judge_fee/100||'元,<='||a.cycle_num/100||'元',
policy_expr = '--'||a.judge_item_id||'科目费用>'||a.judge_fee/100||'元,<='||a.cycle_num/100||'元

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

    --2--费用处于某段区间内:[)--
    update ZHANGJT_SIMPLECOND a set tag = '2' , remark = '科目费用小于XX元'
      where a.tag is null and a.cond_id in
      (select cond_id from td_b_simplecond
        where judge_object_id in (select object_id from td_b_object where attr_type='0') and judge_method='2'
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );

    update ZHANGJT_SIMPLECOND a set a.judge_fee = (select min_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.cycle_num = (select max_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.judge_item_id = (select attr_id from td_b_simplecond b , td_b_object c where a.cond_id = b.cond_id and b.judge_object_id = c.object_id)
      where tag = '2';

    update ZHANGJT_SIMPLECOND a set remark = a.judge_item_id||'科目费用>='||a.judge_fee/100||'元,<'||a.cycle_num/100||'元',
policy_expr = '--'||a.judge_item_id||'科目费用>='||a.judge_fee/100||'元,<'||a.cycle_num/100||'元

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

    --3--费用处于某段区间内[]--
    update ZHANGJT_SIMPLECOND a set tag = '3' , remark = '科目费用等于XX元'
      where a.tag is null and a.cond_id in
      (select cond_id from td_b_simplecond
        where judge_object_id in (select object_id from td_b_object where attr_type='0') and judge_method in('3')
          and cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null)
      );
   update ZHANGJT_SIMPLECOND a set a.judge_fee = (select min_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.cycle_num = (select max_value from td_b_simplecond b where a.cond_id = b.cond_id),
      a.judge_item_id = (select attr_id from td_b_simplecond b , td_b_object c where a.cond_id = b.cond_id and b.judge_object_id = c.object_id)
      where tag = '3';

    update ZHANGJT_SIMPLECOND a set remark = a.judge_item_id||'科目费用>='||a.judge_fee/100||'元,<='||a.cycle_num/100||'元',
policy_expr = '--'||a.judge_item_id||'科目费用>='||a.judge_fee/100||'元,<='||a.cycle_num/100||'元
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

--累计费用判断
    update ZHANGJT_SIMPLECOND a set tag = '4' , remark = '累计费用小于xx元'
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
    --获取对象对应的累积量
    update zhangjt_simplecond a set judge_item_id = (select attr_id from td_b_object b where a.judge_item_id = b.object_id)
     where tag = '4';
    --获取累积量对应的科目
    update zhangjt_simplecond a set judge_item_id = (select b.elem_id from td_b_addupitem b where a.judge_item_id = b.addup_item_code)
     where tag = '4';
    update ZHANGJT_SIMPLECOND a set remark = a.judge_item_id||'累计费用大于'||a.judge_fee/100||'元'||',小于'||a.cycle_num/100||'元',
                                    policy_expr = '--
local addupFee = GET_LAST_ADDUPSEPC_FEE(p,'||a.judge_item_id||')
if(addupFee >= '||a.judge_fee||' and addupFee <= '||a.cycle_num||') then
  return 1
else
  return 0
end' where tag = '4';

--指定销售品是否订购过
update ZHANGJT_SIMPLECOND set tag = '5' 
 where tag is null and cond_id in
(
  select cond_id from td_b_simplecond 
   where cond_id in (select cond_id from ZHANGJT_SIMPLECOND where tag is null) and judge_method = '5' and min_value = '0'
);
update ZHANGJT_SIMPLECOND a set cycle_num = (select enum_value from td_b_simplecond b where a.cond_id = b.cond_id)
 where tag = '5';
update ZHANGJT_SIMPLECOND set remark = '没有订购过'||cycle_num||'套餐',
                              policy_expr = '--没有订购过'||cycle_num||'套餐
if (JUDGE_EXIST_TP(p,'||cycle_num||') == 1) then
  return 0
else
  return 1
end' where tag = '5' and yes_or_no = '1';
update ZHANGJT_SIMPLECOND set remark = '订购过'||cycle_num||'套餐',
                              policy_expr = '--订购过'||cycle_num||'套餐
if (JUDGE_EXIST_TP(p,'||cycle_num||') == 1) then
  return 1
else
  return 0
end' where tag = '5' and yes_or_no = '0';

   --6--某些状态持续的账期数
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
    update ZHANGJT_SIMPLECOND a set remark = '--处于['||a.state_set||']状态'||to_char(cycle_num)||'个账期,优惠'||decode(yes_or_no,'1','失效','0','生效')
      where tag = '6';
    BEGIN
        p_zhangjt_deal_stateset(v_resultCode,v_resultErrInfo);  --处理enumparam里的状态集，按位映射成新系统的状态集
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_zhangjt_deal_stateset call error'||SQLERRM;
            RETURN;
    END;
update ZHANGJT_SIMPLECOND a set
policy_expr = '--处于'||a.state_set||'状态'||to_char(cycle_num)||'个账期,优惠'||decode(yes_or_no,'1','失效','0','生效')||'
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

--品牌判断
update zhangjt_simplecond set tag = '7' where cond_id in (select cond_id from td_b_simplecond where judge_object_id = 81051);
update zhangjt_simplecond a set a.state_set = (select enum_value from td_b_simplecond b where a.cond_id = b.cond_id) where tag = '7';
update zhangjt_simplecond set state_set = '108,123,124,125,126,137' where tag = '7';  --品牌有映射，强转一下全球通
update zhangjt_simplecond a set remark = '品牌为'||decode(yes_or_no,1,'非','')||'全球通品牌',
                                policy_expr = '--品牌为'||decode(yes_or_no,1,'非','')||'全球通品牌
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

    --8--资费持续账期数
    update ZHANGJT_SIMPLECOND a set tag = '8' , remark = '资费订购某段账期生效'
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
      /*缺失PRICE_COMP的互斥处理*/

    update ZHANGJT_SIMPLECOND set remark = '--资费订购'||valid_region||'账期生效',
policy_expr = '--资费订购'||valid_region||'账期生效
if CALC_PROD_USED_CYCLES(p) >= '||substr(valid_region,1,instr(valid_region,' - ')-1)||' and CALC_PROD_USED_CYCLES(p) '||decode(judge_fee,'2','< ','3','<= ')||substr(valid_region,instr(valid_region,' - ')+3)||' then
   return 1
else
   return 0
end'
where tag in ('8','x') and yes_or_no = 0;
    update ZHANGJT_SIMPLECOND set remark = '--资费订购'||valid_region||'账期不生效',
policy_expr = '--资费订购'||valid_region||'账期不生效
if CALC_PROD_USED_CYCLES(p) >= '||substr(valid_region,1,instr(valid_region,' - ')-1)||' and CALC_PROD_USED_CYCLES(p) '||decode(judge_fee,'2','< ','3','<= ')||substr(valid_region,instr(valid_region,' - ')+3)||' then
   return 0
else
   return 1
end'
where tag in ('8','x') and yes_or_no = 1;

    --9--周期性函数，是否到了作用的账期
    update ZHANGJT_SIMPLECOND a set tag = '9' , remark = 'CYCLE_NUM个月为周期,首月(1)末月(0)生效'
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
      
    update ZHANGJT_SIMPLECOND a set remark = CYCLE_NUM||'个月为周期'||decode(valid_region,1,'首月',0,'末月')||'生效',
                                policy_expr = '--'||CYCLE_NUM||'个月为周期'||decode(valid_region,1,'首月',0,'末月')||'生效
if CALC_PROD_USED_CYCLES(p)%'||cycle_num||' == '||valid_region||' then
   return 1
else
   return 0
end' where tag = '9' and yes_or_no = 0;
    update ZHANGJT_SIMPLECOND a set remark = CYCLE_NUM||'个月为周期'||decode(valid_region,1,'首月',0,'末月')||'不生效',
                                policy_expr = '--'||CYCLE_NUM||'个月为周期'||decode(valid_region,1,'首月',0,'末月')||'不生效
if CALC_PROD_USED_CYCLES(p)%'||cycle_num||' == '||valid_region||' then
   return 0
else
   return 1
end' where tag = '9' and yes_or_no = 1;

--资费开始时间判断BEGIN
update zhangjt_simplecond set tag = 'a' , remark = '资费开始时间>=半月时间点           ' , policy_expr = '--资费开始时间>=半月时间点            
 local tpBeginTime = PROM_VALID_DATE(p)
 local cycHalfTime = CALC_HALF_MONTH_TIME(p)
 if tpBeginTime >= cycHalfTime then
     return 1
 else
     return 0
 end
' where cond_id = 50000465;	
update zhangjt_simplecond set tag = 'a' , remark = '资费开始时间<半月时间点            ' , policy_expr = '--资费开始时间<半月时间点             
 local tpBeginTime = PROM_VALID_DATE(p)
 local cycHalfTime = CALC_HALF_MONTH_TIME(p)
 if tpBeginTime < cycHalfTime then
     return 1
 else
     return 0
 end
' where cond_id = 50000466;	
update zhangjt_simplecond set tag = 'a' , remark = '资费开始时间>=25                   ' , policy_expr = '--资费开始时间>=25                    
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpDate = (math.floor(tpBeginTime/1000000))%100
 if tpDate >= 25 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50000525;	
update zhangjt_simplecond set tag = 'a' , remark = '资费开始时间<25                    ' , policy_expr = '--资费开始时间<25                     
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpDate = (math.floor(tpBeginTime/1000000))%100
 if tpDate < 25 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50000526;	
update zhangjt_simplecond set tag = 'a' , remark = '资费开始时间>=20                   ' , policy_expr = '--资费开始时间>=20                    
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpDate = (math.floor(tpBeginTime/1000000))%100
 if tpDate >= 20 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50000527;	
update zhangjt_simplecond set tag = 'a' , remark = '资费开始时间<=20                    ' , policy_expr = '--资费开始时间<=20                     
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpDate = (math.floor(tpBeginTime/1000000))%100
 if tpDate <= 20 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50000528;	
update zhangjt_simplecond set tag = 'a' , remark = '小时包闲时条件时间段（23:00-23:59）' , policy_expr = '--小时包闲时条件时间段（23:00-23:59） 
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpHourMin = math.floor((tpBeginTime%1000000)/100)
 if tpHourMin >= 2300 and tpHourMin <= 2359 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50001086;	
update zhangjt_simplecond set tag = 'a' , remark = '小时包闲时条件时间段（00:00-07:00）' , policy_expr = '--小时包闲时条件时间段（00:00-07:00） 
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpHourMin = math.floor((tpBeginTime%1000000)/100)
 if tpHourMin >= 0000 and tpHourMin <= 0659 then
 	return 1
 else
 	return 0
 end
' where cond_id = 50001087;	
update zhangjt_simplecond set tag = 'a' , remark = '用户资费的开始时间在当前帐期' , policy_expr = '--用户资费的开始时间在当前帐期
 local tpBeginTime = PROM_VALID_DATE(p)
 local cycBeginTime = PROM_BEGIN_DATE(p)
 local cycEndTime = CALC_BILL_END_DATE(p)
 
 if math.floor(tpBeginTime/1000000) >= cycBeginTime and math.floor(tpBeginTime/1000000) <= cycEndTime then
     return 1
 else
     return 0
 end
' where cond_id = 93060018;	
update zhangjt_simplecond set tag = 'a' , remark = '用户资费的开始时间在当前帐期之前' , policy_expr = '--用户资费的开始时间在当前帐期之前
 local tpBeginTime = PROM_VALID_DATE(p)
 local cycBeginTime = PROM_BEGIN_DATE(p)

 if math.floor(tpBeginTime/1000000) < cycBeginTime then
     return 1
 else
     return 0
 end
' where cond_id = 93060019;	
--资费开始时间判断END

update zhangjt_simplecond set tag = 'a' , remark = '本次出账为月末处理' , policy_expr = '
 if CALC_BILL_CYCLE_TYPE(p) == 1 then
     return 1
 else
     return 0
 end 
' where cond_id = 50000428;	
update zhangjt_simplecond set tag = 'a' , remark = '用户类型为4' , policy_expr = '
local userTypeCode = CALC_USER_TYPE_CODE(p)
if userTypeCode == 4 then
	return 1
end
return 0
' where cond_id = 50000463;	
update zhangjt_simplecond set tag = 'a' , remark = '市县编码为茫崖H77D' , policy_expr = '
local cityCode = CALC_CITY_CODE(p)
if cityCode == 1100 then
  return 1
end
return 0
' where cond_id = 50000464;	
update zhangjt_simplecond set tag = 'a' , remark = '地州编码为海西0977' , policy_expr = '
local regionCode = CALC_REGION_CODE(p)
if regionCode == 977 then
	return 1
end
return 0
' where cond_id = 50000477;	
update zhangjt_simplecond set tag = 'a' , remark = '资费开始时间<= 20120930' , policy_expr = '
--NG条件有问题
return 1
' where cond_id = 50000625;	
update zhangjt_simplecond set tag = 'a' , remark = '资费开始时间> 20120930' , policy_expr = '
--NG条件有问题
return 1
' where cond_id = 50000626;	
update zhangjt_simplecond set tag = 'a' , remark = '用户资费持续的账期数小于3个月' , policy_expr = '
local prodUsedCycles = CALC_PROD_USED_CYCLES(p)
if prodUsedCycles >=1 and prodUsedCycles <=3 then
	return 1
end
return 0
' where cond_id = 60000132;	
--b--判断集团下成员数
    update ZHANGJT_SIMPLECOND a set tag = 'b' , remark = '判断集团下成员数'
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

    update ZHANGJT_SIMPLECOND set remark = '集团下用户数'||judge_fee||'-'||cycle_num ,
policy_expr = '--'||remark||'
 local memberNum = CALC_GOURP_MEMBER_BY_ROLEID(p,-1,-1)

 if memberNum '||decode(judge_item_id,'0','> ','1','> ','3','>= ')||judge_fee||' and memberNum <= '||cycle_num||' then
     return 1
 else
     return 0
 end'
 where tag = 'b';

update ZHANGJT_SIMPLECOND set tag = 'c' , remark = '判断用户是否当月订购' ,
policy_expr = '--判断用户是否当月订购
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

   --d--判断账期月份
update ZHANGJT_SIMPLECOND a set tag = 'd' , remark = '判断当前账期是2月份',
policy_expr = '
local currMonth = PROM_BEGIN_DATE(p)/100%100
if currMonth == 2 then
   return 1
else
   return 0
end
' where cond_id = 50001034;
update ZHANGJT_SIMPLECOND a set tag = 'd' , remark = '判断当前账期是8月份',
policy_expr = '
local currMonth = PROM_BEGIN_DATE(p)/100%100
if currMonth == 8 then
   return 1
else
   return 0
end
' where cond_id = 50001033;


----生成组合条件名称（把组合条件下的子条件的名称拼接起来）方便理解，造福后来人
    BEGIN
        p_xuqk_compcond_name(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_xuqk_compcond_name call error'||SQLERRM;
            RETURN;
    END;

--往sys_policy表插记录时，以zhangjt_cond表为准
update zhangjt_cond a set policy_expr = (select policy_expr from zhangjt_simplecond b where a.cond_id = b.cond_id) where cond_type = '0';
update zhangjt_cond a set cond_name = (select remark from zhangjt_simplecond b where a.cond_id = b.cond_id) where cond_type = '0';
update zhangjt_cond set cond_name = 'NG声明为组合条件，但实际未挂子条件，错误配置，返回0',policy_expr = 'return 0'
 where cond_type = '1' and policy_expr is null;
COMMIT;

--老系统g状态未判断，手工处理
update ZHANGJT_COND set cond_name = '--处于[23456789ABFUg]状态1个账期,优惠生效' , 
                        policy_expr = '--处于1200000002|1200000003|1200000042|1200000043|1200000005|1200000006|1200000007|1200000008|1200000009|1100000005|1100000007|1200000011|1200000041|1200000034状态1个账期,优惠生效
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

--互斥特殊处理 忙闲时
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111111','小时包忙时条件时间段（07：00-23：00）',820109000,'--小时包忙时条件时间段（07：00-23：00）
 local tpBeginTime = PROM_VALID_DATE(p)
 local tpHourMin = math.floor((tpBeginTime%1000000)/100)
 if tpHourMin >= 0700 and tpHourMin <= 2259 then
 	return 1
 else
 	return 0
 end' from dual;
COMMIT;

--当月存在开机状态才收费
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111112','当月存在开机状态才收费',820109001,'--当月存在开机状态才收费
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

--没有订购过3502\3503\3507\3508套餐
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111113','没有订购过3502\3503\3507\3508套餐',820109002,'--没有订购过3502\3503\3507\3508套餐
if (JUDGE_EXIST_TP(p,3502) == 0 and JUDGE_EXIST_TP(p,3503) == 0 and JUDGE_EXIST_TP(p,3507) == 0 and JUDGE_EXIST_TP(p,3508) == 0) then
  return 1
else
  return 0
end' from dual;
COMMIT;

--主产品判断 7013
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111114','用户主产品为7013',820109003,'--用户主产品为7013
if (JUDGE_EXIST_TP(p,100007013) == 1) then
  return 1
else
  return 0
end' from dual;
COMMIT;
--主产品判断 7015
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111115','用户主产品为7015',820109004,'--用户主产品为7015
if (JUDGE_EXIST_TP(p,100007015) == 1) then
  return 1
else
  return 0
end' from dual;
COMMIT;
--主产品判断 7016
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111116','用户主产品为7016',820109005,'--用户主产品为7016
if (JUDGE_EXIST_TP(p,100007016) == 1) then
  return 1
else
  return 0
end' from dual;
COMMIT;
--主产品不是 7013/7015/7016
insert into zhangjt_cond (COND_ID,COND_NAME,POLICY_ID,POLICY_EXPR)
 select '11111117','主产品不是 7013/7015/7016',820109006,'--主产品不是 7013/7015/7016
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

CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_OTPFEE
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_OTPFEE过程执行成功!';

delete from NG_TMP_OTPFEE;
COMMIT;

insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100600,810000000,810000000,820109001,10644);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100601,810000001,810000001,820109001,10698);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100602,810000002,810000002,820109001,12320);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100603,810000003,810000003,820109001,10818);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100604,810000004,810000004,820109001,12339);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100605,810000005,810000005,820109001,12116);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100606,810000006,810000006,820109001,19317);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100607,810000007,810000007,820109001,19318);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100608,810000008,810000008,820109001,19319);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100609,810000009,810000009,820109001,19320);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100610,810000010,810000010,820109001,19321);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100611,810000011,810000011,820109001,19322);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100612,810000012,810000012,820109001,19323);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100613,810000013,810000013,820109001,19324);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100614,810000014,810000014,820109001,19325);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100615,810000015,810000015,820109001,19326);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100616,810000016,810000016,820109001,19327);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100617,810000017,810000017,820109001,19328);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100618,810000018,810000018,820109001,19329);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100619,810000019,810000019,820109001,19330);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100620,810000020,810000020,820109001,19331);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100621,810000021,810000021,820109001,19332);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100622,810000022,810000022,820109001,19333);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100623,810000023,810000023,820109001,19334);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100624,810000024,810000024,820109001,10490);
insert into NG_TMP_OTPFEE(tp_id,price_id,adjustrate_id,cond_id,item_id) values (60100625,810000025,810000025,820109001,12314);

update NG_TMP_OTPFEE set policy_id = 820300001 , policy_expr = '
    --一次性费用 按指定金额补收费用
    function get_Numerator(_in_para1)
      if CALC_EXIST_PROD_PARAM(p,_in_para1) == 1 then
         return (CALC_PRODUCT_PARAM(p,_in_para1))
      else
         return PROM_NUMERATOR(p)
      end
    end

    return -get_Numerator(830001)
';
COMMIT;
      --销售品定义
      insert into PD.PM_PRODUCT_OFFERING(PRODUCT_OFFERING_ID,OFFER_TYPE_ID,NAME,BRAND_SEGMENT_ID,IS_MAIN,LIFECYCLE_STATUS_ID,OPERATOR_ID,PROD_SPEC_ID,OFFER_CLASS,
              PRIORITY,BILLING_PRIORITY,IS_GLOBAL,VALID_DATE,EXPIRE_DATE,DESCRIPTION,SPEC_TYPE_FLAG)
      select distinct TP_ID,
             0,                          --OFFER_TYPE_ID
             '一次性费用转成销售品',                        
             -1,                         --BRAND_SEGMENT_ID
             0,                          --IS_MAIN
             1,                          --LIFECYCLE_STATUS_ID
             0,                          --OPERATOR_ID
             10180000,                   --PROD_SPEC_ID
             111,                        --OFFER_CLASS
             0,                          --PRIORITY
             0,                          --BILLING_PRIORITY 【账务使用】
             0,                          --IS_GLOBAL【APS_XC未读】
             to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss'),
             'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss'),
             0
        from NG_TMP_OTPFEE
        where TP_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFERING);
      --销售品属性
      insert into PD.PM_PRODUCT_OFFER_ATTRIBUTE   
			select distinct TP_ID,0,1,-1,0,-999,-999,'','',0,
             1,                          --DISCOUNT_EXPIRE_MODE【账务使用】
             '',0 from NG_TMP_OTPFEE
       where TP_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFER_ATTRIBUTE);
      --销售品扣费规则（对于APS而言，貌似没啥卵用）
      insert into PD.PM_COMPOSITE_DEDUCT_RULE 
      select distinct TP_ID,
             1,                --BILLING_TYPE
             0,1,              --DEDUCT_FLAG
             -1,1002,-1,1,0,   --NEGATIVE_FLAG
             0,                --IS_CHANGE_BILL_CYCLE
             0,                --IS_PER_BILL
             0,0,0,'','',-999,-999,0,-1 from NG_TMP_OTPFEE
         where TP_ID not in (select PRODUCT_OFFERING_ID from PD.PM_COMPOSITE_DEDUCT_RULE);
      --失效标记
      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = 2
       where a.product_offering_id in (select TP_ID from NG_TMP_OTPFEE);
         
------------------------------------------2--定价计划-------------------------------------------
     --定价计划定义
     insert into PD.PM_PRICING_PLAN
      select distinct TP_ID,'一次性费用','一次性费用','VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_OTPFEE
       where TP_ID not in (select pricing_plan_id from PD.PM_PRICING_PLAN);
     --销售品与定价计划关联关系   默认1对1   优先级都填1  恒生效
     insert into PD.PM_PRODUCT_PRICING_PLAN
      select distinct tp_id,0,tp_id,1,-1,0
        from NG_TMP_OTPFEE
       where tp_id not in (select product_offering_id from PD.PM_PRODUCT_PRICING_PLAN);
     --定价声明
     insert into PD.PM_COMPONENT_PRODOFFER_PRICE
      select price_id,'一次性费用定价',8,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_OTPFEE;
     --定价计划_定价关联关系
     insert into PD.PM_COMPOSITE_OFFER_PRICE (PRICING_PLAN_ID,PRICE_ID,BILLING_TYPE,OFFER_STS,VALID_DATE,EXPIRE_DATE,SERV_ID,PRIORITY)
      select tp_id,price_id,'1','-1',to_date('01-01-2001', 'dd-mm-yyyy'), to_date('01-01-2100', 'dd-mm-yyyy'),'-1',5000
        from NG_TMP_OTPFEE;
    --优惠曲线定义
    INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
      SELECT ADJUSTRATE_ID,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        FROM NG_TMP_OTPFEE;
    --定价与优惠曲线关系	
    INSERT INTO PD.PM_BILLING_DISCOUNT_DTL (PRICE_ID, CALC_SERIAL, ADJUSTRATE_ID,VALID_DATE, EXPIRE_DATE, USE_TYPE, MEASURE_ID, DESCRIPTION)
    SELECT PRICE_ID,1,ADJUSTRATE_ID,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --日月账都有效
      10403,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
      FROM NG_TMP_OTPFEE;

-----------补收----------
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.adjustrate_id,cond_id,2 REF_TYPE,0,
            0,a.item_id,1,a.item_id,1,0,
            1,1 PRIORITY,0,-1,0,0,0,
            3,0,0 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,8 PROM_TYPE,0,0,'一次性费用 补收',
            1,-1,0
    FROM NG_TMP_OTPFEE a;
   
    COMMIT;


--并行时发现现网OTP的存储过程被修改过，现手工补刀。
insert into PD.PM_BILLING_DISCOUNT_DTL 
    SELECT 810000000,2,810000100,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --日月账都有效
      10403,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
      FROM dual;
insert into PD.PM_BILLING_DISCOUNT_DTL 
    SELECT 810000000,3,810000200,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --日月账都有效
      10403,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
      FROM dual;
insert into PD.PM_BILLING_DISCOUNT_DTL 
    SELECT 810000000,4,810000300,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --日月账都有效
      10403,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
      FROM dual;
INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
  SELECT 810000100,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
    FROM DUAL;
INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
  SELECT 810000200,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
    FROM DUAL;
INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
  SELECT 810000300,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
    FROM DUAL;
delete from PD.PM_ADJUST_SEGMENT where adjustrate_id = 810000000;
COMMIT;
INSERT INTO PD.PM_ADJUST_SEGMENT
       (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
        EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
        ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
        PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
        FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
        FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
SELECT  DISTINCT
        810000000,'820109001'||'&'||'820109003',2 REF_TYPE,0,
        0,12678,1,12678,1,0,
        1,1 PRIORITY,0,-1,0,0,0,
        3,0,0 ITEM_SHARE_FLAG,0,0,
        820300001,-1,0,8 PROM_TYPE,0,0,'一次性费用 补收',
        1,-1,0
FROM DUAL a;
INSERT INTO PD.PM_ADJUST_SEGMENT
       (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
        EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
        ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
        PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
        FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
        FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
SELECT  DISTINCT
        810000100,'820109001'||'&'||'820109004',2 REF_TYPE,0,
        0,12679,1,12679,1,0,
        1,1 PRIORITY,0,-1,0,0,0,
        3,0,0 ITEM_SHARE_FLAG,0,0,
        820300001,-1,0,8 PROM_TYPE,0,0,'一次性费用 补收',
        1,-1,0
FROM DUAL a;
INSERT INTO PD.PM_ADJUST_SEGMENT
       (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
        EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
        ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
        PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
        FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
        FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
SELECT  DISTINCT
        810000200,'820109001'||'&'||'820109005',2 REF_TYPE,0,
        0,12145,1,12145,1,0,
        1,1 PRIORITY,0,-1,0,0,0,
        3,0,0 ITEM_SHARE_FLAG,0,0,
        820300001,-1,0,8 PROM_TYPE,0,0,'一次性费用 补收',
        1,-1,0
FROM DUAL a;
INSERT INTO PD.PM_ADJUST_SEGMENT
       (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
        EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
        ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
        PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
        FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
        FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
SELECT  DISTINCT
        810000300,'820109001'||'&'||'820109006',2 REF_TYPE,0,
        0,10644,1,10644,1,0,
        1,1 PRIORITY,0,-1,0,0,0,
        3,0,0 ITEM_SHARE_FLAG,0,0,
        820300001,-1,0,8 PROM_TYPE,0,0,'一次性费用 补收',
        1,-1,0
FROM DUAL a;
COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:=substr(SQLERRM,1,200);
       v_resultcode:='-1';
END;

/
         
        

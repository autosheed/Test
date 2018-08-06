CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_DAYGPRS
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_GRPSTP过程执行成功!';

      --销售品定义
      insert into PD.PM_PRODUCT_OFFERING(PRODUCT_OFFERING_ID,OFFER_TYPE_ID,NAME,BRAND_SEGMENT_ID,IS_MAIN,LIFECYCLE_STATUS_ID,OPERATOR_ID,PROD_SPEC_ID,OFFER_CLASS,
              PRIORITY,BILLING_PRIORITY,IS_GLOBAL,VALID_DATE,EXPIRE_DATE,DESCRIPTION,SPEC_TYPE_FLAG)
      select distinct feepolicy_id,
             0,                          --OFFER_TYPE_ID
             DISCNT_NAME,                        
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
             'VB割接导入(GPRS日租卡) -- '||to_char(sysdate,'yyyymmddhh24miss'),
             0
        from NG_TMP_DAYGPRS_TP
        where feepolicy_id not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFERING);
      --销售品属性
      insert into PD.PM_PRODUCT_OFFER_ATTRIBUTE   
      select distinct feepolicy_id,0,1,-1,0,-999,-999,'','',0,
             1,                          --DISCOUNT_EXPIRE_MODE【账务使用】
             '',0 from NG_TMP_DAYGPRS_TP
       where feepolicy_id not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFER_ATTRIBUTE);
      --销售品扣费规则（对于APS而言，貌似没啥卵用）
      insert into PD.PM_COMPOSITE_DEDUCT_RULE 
      select distinct feepolicy_id,
             1,                --BILLING_TYPE
             0,1,              --DEDUCT_FLAG
             -1,1002,-1,1,0,   --NEGATIVE_FLAG
             0,                --IS_CHANGE_BILL_CYCLE
             0,                --IS_PER_BILL
             0,0,0,'','',-999,-999,0,-1 from NG_TMP_DAYGPRS_TP
         where feepolicy_id not in (select PRODUCT_OFFERING_ID from PD.PM_COMPOSITE_DEDUCT_RULE);
      --失效标记         个人认为日租卡的生失效规则应该是，订购时立即生效，取消时下账期生效
      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = 2
       where a.product_offering_id in (select feepolicy_id from NG_TMP_DAYGPRS_TP);

------------------------------------------2--定价计划-------------------------------------------
     --定价计划定义
     insert into PD.PM_PRICING_PLAN
      select distinct A.feepolicy_id,A.DISCNT_NAME,B.DISCNT_EXPLAIN,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_DAYGPRS_TP A , NG_TD_B_DISCNT B
       where A.feepolicy_id = B.discnt_code
         and A.feepolicy_id not in (select pricing_plan_id from PD.PM_PRICING_PLAN);
     --销售品与定价计划关联关系   默认1对1   优先级都填1  恒生效
     insert into PD.PM_PRODUCT_PRICING_PLAN
      select distinct feepolicy_id,0,feepolicy_id,1,-1,0
        from NG_TMP_DAYGPRS_TP
       where feepolicy_id not in (select product_offering_id from PD.PM_PRODUCT_PRICING_PLAN);
     --定价声明
     insert into PD.PM_COMPONENT_PRODOFFER_PRICE
      select distinct a.price_id,'GRPS日租卡账务收费',8,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_DAYGPRS_TP a
        order by 1;
     --定价计划_定价关联关系
     insert into PD.PM_COMPOSITE_OFFER_PRICE (PRICING_PLAN_ID,PRICE_ID,BILLING_TYPE,OFFER_STS,VALID_DATE,EXPIRE_DATE,SERV_ID,PRIORITY)
      select distinct feepolicy_id,price_id,'1','-1',to_date('01-01-2001', 'dd-mm-yyyy'), to_date('01-01-2100', 'dd-mm-yyyy'),'-1',0
        from NG_TMP_DAYGPRS_TP a
       order by 1;
    --优惠曲线定义
    INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
      SELECT distinct ADJUSTRATE_ID,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        FROM NG_TMP_DAYGPRS_TP a;
    --定价与优惠曲线关系  
    INSERT INTO PD.PM_BILLING_DISCOUNT_DTL (PRICE_ID, CALC_SERIAL, ADJUSTRATE_ID,VALID_DATE, EXPIRE_DATE, USE_TYPE, MEASURE_ID, DESCRIPTION)
    SELECT DISTINCT
      a.PRICE_ID,1,ADJUSTRATE_ID,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --日月账都有效
      10403,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
      FROM NG_TMP_DAYGPRS_TP a ORDER BY 1 , 2;

----PROM_TYPE=11-------
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.adjustrate_id,nvl(a.expr_id,0),2 REF_TYPE,0,
            0,nvl(a.addup_item,0),1,a.effect_item,1,0,
            1,1 PRIORITY,0,-1,a.feepolicy_id RULE_ID,0,0,
            3,0,0 ITEM_SHARE_FLAG,0,0,
            0,-1,0,11 PROM_TYPE,0,0,'GRPS业务收费',
            1,-1,0
    FROM NG_TMP_DAYGPRS_TP a;
		COMMIT;

--收取流量费
--费用精确到分
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) 
  select distinct feepolicy_id,feepolicy_type,1,0,0,discnt_data,0,0,discnt_fee,0,1048576 from NG_TMP_DAYGPRS_TP;

COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:=substr(SQLERRM,1,200);
       v_resultcode:='-1';
END;
/


CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_DISCNT
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_DISCNT过程执行成功!';

    --清理方案  按ID区间约定清理--
    --本过程只清理优惠定价相关数据   定价计划的定义、销售品相关属性与计费商定后再外层删除
    DELETE FROM PD.PM_ADJUST_SEGMENT;
    DELETE FROM PD.PM_BILLING_DISCOUNT_DTL;
    DELETE FROM PD.PM_ADJUST_RATES WHERE ADJUSTRATE_ID between 800000000 and 899999999;
    DELETE FROM PD.PM_COMPOSITE_OFFER_PRICE WHERE PRICE_ID between 800000000 and 999999999;
    DELETE FROM PD.PM_COMPONENT_PRODOFFER_PRICE WHERE PRICE_ID between 800000000 and 999999999;
    COMMIT;

		BEGIN
----------------------------------------1--销售品属性相关表-----------------------------------------------
      --销售品定义
      insert into PD.PM_PRODUCT_OFFERING(PRODUCT_OFFERING_ID,OFFER_TYPE_ID,NAME,BRAND_SEGMENT_ID,IS_MAIN,LIFECYCLE_STATUS_ID,OPERATOR_ID,PROD_SPEC_ID,OFFER_CLASS,
              PRIORITY,BILLING_PRIORITY,IS_GLOBAL,VALID_DATE,EXPIRE_DATE,DESCRIPTION,SPEC_TYPE_FLAG)
      select distinct PRODUCT_OFFERING_ID,
             0,                          --OFFER_TYPE_ID
             PRODUCT_OFFERING_NAME,
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
        from NG_TMP_TP_DISCNT
        where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFERING);
      update PD.PM_PRODUCT_OFFERING set PROD_SPEC_ID = 12880000 where PRODUCT_OFFERING_ID = 486100001;----xuetao 要求。  分账销售品归属128
      --销售品属性
      insert into PD.PM_PRODUCT_OFFER_ATTRIBUTE
			select distinct PRODUCT_OFFERING_ID,0,1,-1,0,-999,-999,'','',0,
             0,                          --DISCOUNT_EXPIRE_MODE【账务使用】
             '',0 from NG_TMP_TP_DISCNT
       where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFER_ATTRIBUTE);
      --销售品扣费规则（对于APS而言，貌似没啥卵用）
      insert into PD.PM_COMPOSITE_DEDUCT_RULE
      select distinct PRODUCT_OFFERING_ID,
             1,                --BILLING_TYPE
             0,1,              --DEDUCT_FLAG
             -1,1002,-1,1,0,   --NEGATIVE_FLAG
             0,                --IS_CHANGE_BILL_CYCLE
             0,                --IS_PER_BILL
             0,0,0,'','',-999,-999,0,-1 from NG_TMP_TP_DISCNT
         where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from PD.PM_COMPOSITE_DEDUCT_RULE where billing_type = '1');
      --系统级销售品
      insert into pd.PM_GLOBAL_OFFER_AVAILABLE
      select distinct PRODUCT_OFFERING_ID,-1, to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss'),sysdate
        from NG_TMP_TP_DISCNT
       where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID in (select feepolicy_id from td_base_tariff where biz_type = '22')
         and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from pd.PM_GLOBAL_OFFER_AVAILABLE);
      --系统级销售品
      insert into pd.PM_PRODUCT_OFFER_AVAILABLE
      select distinct PRODUCT_OFFERING_ID,'-1','-1',0,0,to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss')
        from NG_TMP_TP_DISCNT
       where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID in (select feepolicy_id from td_base_tariff where biz_type = '22')
         and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from pd.PM_PRODUCT_OFFER_AVAILABLE);
      --失效标记
      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = '0'
       where a.product_offering_id in (select b.DISCNT_CODE from NG_TD_B_DISCNT b where b.enable_tag = '0')
         and exists (select 1 from NG_TD_B_DISCNT b where a.product_offering_id = b.DISCNT_CODE);

      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = '1'
       where a.product_offering_id in (select b.DISCNT_CODE from NG_TD_B_DISCNT b where b.enable_tag in ('1'))
         and exists (select 1 from NG_TD_B_DISCNT b where a.product_offering_id = b.DISCNT_CODE);
         
      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = '2'
       where a.product_offering_id in (select b.DISCNT_CODE from NG_TD_B_DISCNT b where b.enable_tag in ('2'))
         and exists (select 1 from NG_TD_B_DISCNT b where a.product_offering_id = b.DISCNT_CODE);
         
      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = '3'
       where a.product_offering_id in (select b.DISCNT_CODE from NG_TD_B_DISCNT b where b.enable_tag in ('3'))
         and exists (select 1 from NG_TD_B_DISCNT b where a.product_offering_id = b.DISCNT_CODE);
       
      --PM_PRODUCT_OFFER_SPEC_CHAR
      --PM_PRODUCT_OFFERING_CENPAY   统付参见《特殊业务处理》
      --PM_ITEM_SPLIT_RATE;  ???????

			EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='销售品生成-1 err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;
    commit;

    BEGIN
------------------------------------------2--定价计划-------------------------------------------
     --定价计划定义
     insert into PD.PM_PRICING_PLAN
      select distinct PRODUCT_OFFERING_ID,PRODUCT_OFFERING_NAME,B.DISCNT_EXPLAIN,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_TP_DISCNT A , (select discnt_code,min(discnt_explain) DISCNT_EXPLAIN from NG_TD_B_DISCNT group by discnt_code) B
       where a.DISCNT_TYPE <> 'Z' and a.remark <> 'invalid tp'
          and A.PRODUCT_OFFERING_ID = B.DISCNT_CODE
         and A.PRODUCT_OFFERING_ID not in (select pricing_plan_id from PD.PM_PRICING_PLAN);
     --销售品与定价计划关联关系   默认1对1   优先级都填1  恒生效
     insert into PD.PM_PRODUCT_PRICING_PLAN
      select distinct product_offering_id,0,product_offering_id,1,-1,0
        from NG_TMP_TP_DISCNT
       where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and product_offering_id not in (select product_offering_id from PD.PM_PRODUCT_PRICING_PLAN);
     --定价声明
     insert into PD.PM_COMPONENT_PRODOFFER_PRICE
      select distinct decode(a.account_share_flag,0,a.price_id+800000000,1,a.price_id+900000000),nvl(a.price_name,'优惠定价-没名字~'),8,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_TP_DISCNT a
       where a.DISCNT_TYPE <> 'Z' and a.remark <> 'invalid tp'
        order by 1;
     --定价计划_定价关联关系
     insert into PD.PM_COMPOSITE_OFFER_PRICE (PRICING_PLAN_ID,PRICE_ID,BILLING_TYPE,OFFER_STS,VALID_DATE,EXPIRE_DATE,SERV_ID,PRIORITY)
      select distinct product_offering_id,decode(a.account_share_flag,0,a.price_id+800000000,1,a.price_id+900000000),'1','-1',to_date('01-01-2001', 'dd-mm-yyyy'), to_date('01-01-2100', 'dd-mm-yyyy'),'-1',a.event_priority
        from NG_TMP_TP_DISCNT a
        where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
       order by 1;
       
    --优惠曲线定义
    INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
      SELECT DISTINCT a.ADJUSTRATE_ID,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        FROM NG_TMP_TP_DISCNT a
        where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp';
    --定价与优惠曲线关系
    INSERT INTO PD.PM_BILLING_DISCOUNT_DTL (PRICE_ID, CALC_SERIAL, ADJUSTRATE_ID,VALID_DATE, EXPIRE_DATE, USE_TYPE, MEASURE_ID, DESCRIPTION)
    SELECT DISTINCT
      decode(a.account_share_flag,0,a.price_id+800000000,1,a.price_id+900000000),100-a.ORDER_NO,a.ADJUSTRATE_ID,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --日月账都有效
      10403,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
      FROM NG_TMP_TP_DISCNT a
      where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp' ORDER BY 1 , 2;

    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='资费树生成-1 err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;
    commit;

    BEGIN
--------------------------------------------优惠定价实现---------------------------------------------
/* PRIORITY   天津feediscnt表中feediscnt_id唯一，VB中该字段填写默认值‘1’ */
--按金额减免--配置到分子上   PROM_TYPE=4
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id,1,a.item_id,1,a.item_id,
            1,1 PRIORITY,0,-1,a.fee,10,0,
            3,0,1 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,4 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type in ('A','H');

--按比例减免--llBaseFee * llNumerator / llDenominator   PROM_TYPE=1
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id,1,a.item_id,1,a.item_id,
            1,1 PRIORITY,0,-1,a.divied_child_value,a.divied_parent_value,0,
            3,0,1 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,1 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'B';
    
--按配置金额补收-- lNumerator;  PROM_TYPE = 8
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id,1,a.item_id,1,0,
            1,1 PRIORITY,nvl(a.single_fee,0),-1,decode(isparam,0,a.fee,1,0),1,0,
            3,0,0 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,8 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    where discnt_type = 'C';
    
--封顶--     llPromFee = llBaseFee - llNumerator;  PROM_TYPE = 3
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id BASE_ITEM,1,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,0,-1,a.fee,10,0,
            3,0,1 ITEM_SHARE_FLAG,0,0,                   --之前是20，封顶时好像是按优先级减免的，改为1，等待验证
            policy_id,-1,0,3 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'D';
    
--普通保底  llPromFee = llBaseFee - llNumerator;  PROM_TYPE = 5
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.compute_object_id BASE_ITEM,1,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,0,-1,decode(policy_id,820209998,a.fee,null,a.fee,0),10,0,
            3,0,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,5 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'E';
    
--LUA收费  群组相关
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.compute_object_id BASE_ITEM,1,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,a.single_fee,-1,fee,decode(isparam,0,a.base_num,1,0),0,
            3,0,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,8,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'F';
    
--累计保底   --PROM_TYPE = 5  累计周期REF_CYCLES  StartValue表示参数的ID，保底金额二次议价
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.compute_object_id BASE_ITEM,a.cyc_nums,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,decode(isparam,1,nvl(new_param_id,0),0,0),-1,decode(isparam,0,a.fee,0),10,0,  --!!!!!!!!!!!!!!!!!!!!!!
            3,0,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,5 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'G';
    
----超过参考值的部分进行限定减免
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id BASE_ITEM,1,a.compute_object_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,a.fee,a.single_fee,a.divied_child_value NUMERATOR,a.DIVIED_PARENT_VALUE DENOMINATOR,0,
            3,a.account_share_flag,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,14,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'Q';   
    
--固定金额，多退少补-- lNumerator;  PROM_TYPE = 2
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id,1,a.item_id,1,0,
            1,1 PRIORITY,0,-1,decode(isparam,0,a.fee,1,0),1,0,
            3,0,0 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,2 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    where discnt_type = 'R';
    
/*宽带年包   prom_type = 20
 *1.	包年费用记录在DENOMINATOR字段里；
 *2.	日租费用记录在NUMERATOR字段里；
 *3.	年包周期月份记录在REF_CYCLES字段里；
 */
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id BASE_ITEM,a.cyc_nums,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,0,-1,a.single_fee,a.fee,0,
            3,0,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,20 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'I';

--分账强制补足--参考湖南
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id BASE_ITEM,1,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,0,-1,0,0,0,
            3,0,20 ITEM_SHARE_FLAG,0,0,
            0,-1,0,2,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'X';
    
--账户优惠标记统一更新
    UPDATE PD.PM_ADJUST_SEGMENT SET ACCOUNT_SHARE_FLAG = 1
     WHERE ADJUSTRATE_ID IN (SELECT ADJUSTRATE_ID FROM NG_TMP_TP_DISCNT WHERE ACCOUNT_SHARE_FLAG = '1');
--分摊规则标记统一更新
    --1--账目均摊
    UPDATE PD.PM_ADJUST_SEGMENT SET ITEM_SHARE_FLAG = 10
     WHERE ADJUSTRATE_ID IN (SELECT ADJUSTRATE_ID FROM NG_TMP_TP_DISCNT WHERE dispatch_method = '0');
    --2--账目优先
    UPDATE PD.PM_ADJUST_SEGMENT SET ITEM_SHARE_FLAG = 20
     WHERE ADJUSTRATE_ID IN (SELECT ADJUSTRATE_ID FROM NG_TMP_TP_DISCNT WHERE dispatch_method in ('1','3'));
         
    ------------群虚拟销售品-------
    DELETE FROM PD.PM_PRODUCT_OFFER_SPEC_CHAR where SPEC_CHAR_ID = '13511';
    INSERT INTO PD.PM_PRODUCT_OFFER_SPEC_CHAR (PRODUCT_OFFERING_ID,SPEC_CHAR_ID,VALUE_TYPE,VALUE,VALUE_MAX,DESCRIPTION,GROUP_ID)
      SELECT distinct feepolicy_id,13511,'1','1',NULL,NULL,0
        FROM UCR_PARAM.td_b_feepolicy_comp
       WHERE effect_role_code IN ('-1') and (event_type_id>=100 or event_type_id in (22,23));
    COMMIT;
    ---------重复订购的销售品处理--------考虑直接将不能重复订购的销售品导入该表
    delete from PD.PM_PRODUCT_OFFER_SPEC_CHAR  where SPEC_CHAR_ID = '13512';
    insert into PD.PM_PRODUCT_OFFER_SPEC_CHAR 
      select distinct feepolicy_id,13512,'1','1','','',0 from NG_TMP_FEEPOLOICY where REPEAT_TYPE = '0' and type = '3';  --不可重复订购的优惠资费
    ---------KD00类型资费，通过UUREL继承----------
    DELETE FROM PD.PM_PRODUCT_OFFER_SPEC_CHAR where SPEC_CHAR_ID = '13513';
    INSERT INTO PD.PM_PRODUCT_OFFER_SPEC_CHAR (PRODUCT_OFFERING_ID,SPEC_CHAR_ID,VALUE_TYPE,VALUE,VALUE_MAX,DESCRIPTION,GROUP_ID)
      SELECT distinct feepolicy_id,13513,'1','1',NULL,NULL,0
        FROM UCR_PARAM.td_b_feepolicy_comp
       WHERE (effect_role_code IN ('KD00') and (event_type_id>=100 or event_type_id in (22,23))) or feepolicy_id in (90010956,99410257);
    COMMIT;

    --分账强制补足销售品--
    DELETE FROM PD.PM_PRODUCT_OFFER_SPEC_CHAR WHERE PRODUCT_OFFERING_ID = 486100001;
    insert into PD.PM_PRODUCT_OFFER_SPEC_CHAR values(486100001, 1000, 1, 491234567, '', '强制补足销售品ID', 0);
            
    --固费销售品编码修改(天津无固费群订购)
    update pd.PM_PRODUCT_OFFER_SPEC_CHAR a set PRODUCT_OFFERING_ID =
    (select distinct b.PRODUCT_OFFERING_ID from VB_PM_PRODUCT_OFFERING b where a.product_offering_id = b.feepolicy_id)
    where exists (select 1 from VB_PM_PRODUCT_OFFERING c where a.product_offering_id = c.feepolicy_id);
    COMMIT;
    
    --角色编码
    update NG_TMP_TP_DISCNT set effect_role_code = '-1' where effect_role_code not in ('-1','-2','0');--!!!有角色编码的都先改为-1再说
    UPDATE pd.PM_COMPOSITE_OFFER_PRICE a SET a.ROLE_CODE=
    (SELECT DISTINCT effect_role_code FROM NG_TMP_TP_DISCNT b
    WHERE b.PRODUCT_OFFERING_ID=a.PRICING_PLAN_ID AND '8'||b.PRICE_ID=a.PRICE_ID  ) 
    WHERE (PRICING_PLAN_ID,price_id) IN 
    (SELECT product_offering_id,'8'||price_id
      FROM ucr_param.NG_TMP_TP_DISCNT 
     WHERE effect_role_code<>'-2');
     
    --在PM_PRODUCT_OFFERING中添加prod_object_type字段，用来区分用户资费和账户资费，给crm用
    update pd.pm_product_offering a set a.prod_object_type = 0;--默认为用户
    update pd.pm_product_offering a
       set a.prod_object_type = 1  --账户
     where a.product_offering_id in
           (select discnt_code
              from td_b_discnt
             where b_discnt_code in (select feepolicy_id
                                       from td_b_feepolicy_comp
                                      where event_type_id = 23
                                        and exec_mode = 'A'));
    commit;
     
    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='资费树(优惠)生成-2 err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;
    commit;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:='P_NG_TMP_PARAM_DISCNT err !'||substr(SQLERRM,1,200);
       v_resultcode:='-1';
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
END;
/

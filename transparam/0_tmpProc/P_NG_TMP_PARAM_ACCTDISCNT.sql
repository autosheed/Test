CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_ACCTDISCNT
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_ACCTDISCNT过程执行成功!';

      delete from NG_TMP_ACCT_DISCNT;
      COMMIT;
      --modify top5's price_id
      --insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('5341 ','72002209','43040010','43040012','42009982','39999','15223','68 ');
      --insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('5343 ','72002209','43040010','43040012','42009982','39999','15223','68 ');
      --insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('5345 ','72002209','43040010','43040012','42009982','39999','15223','68 ');
      --insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('5347 ','70007322','43040010','43040012','42125474','39999','15223','30 ');
      --insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('5349 ','72002212','43040010','43040012','42009985','39999','15223','228');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('5370 ','42002303','43040010','43040012','40009177','39966','15223','68 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8178 ','42002255','43040010','43040012','42009994','39999','15223','68 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8179 ','42002255','43040010','43040012','42009994','39999','15223','68 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8180 ','42002256','43040010','43040012','42009995','39999','15223','98 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8181 ','42002257','43040010','43040012','42009996','39999','15223','188');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8182 ','42002258','43040010','43040012','42009997','39999','15223','228');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8336 ','42002209','43040010','43040012','42009982','39999','15223','68 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8337 ','42002210','43040010','43040012','42009983','39999','15223','98 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8338 ','42002211','43040010','43040012','42009984','39999','15223','188');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8339 ','42002212','43040010','43040012','42009985','39999','15223','228');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8340 ','42002213','43040010','43040012','42009986','39999','15223','58 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8341 ','42002214','43040010','43040012','42009987','39999','15223','88 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8342 ','42002215','43040010','43040012','42009988','39999','15223','168');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8343 ','42002216','43040010','43040012','42009989','39999','15223','208');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8344 ','42002217','43040010','43040012','42009990','39999','15223','58 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8345 ','42002218','43040010','43040012','42009991','39999','15223','88 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('8346 ','42002219','43040010','43040012','42009992','39999','15223','168');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('99999','42002220','43040010','45003105','42009993','39999','15223','68 ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,price_id,cond_id1,cond_id2,feediscnt_id,base_item,effect_item,fee) values ('100506','49002220','43040010','43040012','49009993','39999','12944','0');
      update NG_TMP_ACCT_DISCNT set fee = fee*100;
      update NG_TMP_ACCT_DISCNT a set discnt_name = (select discnt_name from ng_td_b_discnt b where a.feepolicy_id = b.discnt_code);
      update NG_TMP_ACCT_DISCNT a set cond_id1 = (select policy_id from zhangjt_simplecond b where a.cond_id1 = b.cond_id);
      update NG_TMP_ACCT_DISCNT a set cond_id2 = (select policy_id from zhangjt_simplecond b where a.cond_id2 = b.cond_id);
      update NG_TMP_ACCT_DISCNT a set policy_id = 820400001 where feepolicy_id <> 100506;
      update NG_TMP_ACCT_DISCNT a set policy_id = 820400002 where feepolicy_id = 100506;
      update NG_TMP_ACCT_DISCNT a set policy_expr = '
--多终端共享保底收费(合户)
local t_groupFee = CALC_GROUP_TOTAL_FEE_BY_ROLEID(p,0)
local t_discntFee = PROM_NUMERATOR(p)
if t_groupFee < t_discntFee then
	return t_groupFee-t_discntFee
end
return 0
      ' where policy_id = 820400001;
      update NG_TMP_ACCT_DISCNT a set policy_expr = '
--多终端共享保底收费(非合户)
local t_groupFee = CALC_GROUP_TOTAL_FEE_BY_ROLEID(p,0)
local t_discntFee = CALC_PRODUCT_PARAM(p,820001)
if t_groupFee < t_discntFee then
	return t_groupFee-t_discntFee
end
return 0
      ' where policy_id = 820400002;
      COMMIT;

----------------------------------生成VB群组优惠----------------------
      --销售品定义
      insert into PD.PM_PRODUCT_OFFERING(PRODUCT_OFFERING_ID,OFFER_TYPE_ID,NAME,BRAND_SEGMENT_ID,IS_MAIN,LIFECYCLE_STATUS_ID,OPERATOR_ID,PROD_SPEC_ID,OFFER_CLASS,
              PRIORITY,BILLING_PRIORITY,IS_GLOBAL,VALID_DATE,EXPIRE_DATE,DESCRIPTION,SPEC_TYPE_FLAG)
      select distinct FEEPOLICY_ID,
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
             'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss'),
             0
        from NG_TMP_ACCT_DISCNT
        where FEEPOLICY_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFERING);
      --销售品属性
      insert into PD.PM_PRODUCT_OFFER_ATTRIBUTE   
			select distinct FEEPOLICY_ID,0,1,-1,0,-999,-999,'','',0,
             0,                          --DISCOUNT_EXPIRE_MODE【账务使用】
             '',0 from NG_TMP_ACCT_DISCNT
       where FEEPOLICY_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFER_ATTRIBUTE);
      --销售品扣费规则（对于APS而言，貌似没啥卵用）
      insert into PD.PM_COMPOSITE_DEDUCT_RULE 
      select distinct FEEPOLICY_ID,
             1,                --BILLING_TYPE
             0,1,              --DEDUCT_FLAG
             -1,1002,-1,1,0,   --NEGATIVE_FLAG
             0,                --IS_CHANGE_BILL_CYCLE
             0,                --IS_PER_BILL
             0,0,0,'','',-999,-999,0,-1 from NG_TMP_ACCT_DISCNT
         where FEEPOLICY_ID not in (select PRODUCT_OFFERING_ID from PD.PM_COMPOSITE_DEDUCT_RULE);
      
------------------------------------------2--定价计划-------------------------------------------
     --定价计划定义
     insert into PD.PM_PRICING_PLAN
      select distinct A.FEEPOLICY_ID,A.DISCNT_NAME,B.DISCNT_EXPLAIN,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_ACCT_DISCNT A , NG_TD_B_DISCNT B
       where A.FEEPOLICY_ID = B.DISCNT_CODE
         and A.FEEPOLICY_ID not in (select pricing_plan_id from PD.PM_PRICING_PLAN);
     --销售品与定价计划关联关系   默认1对1   优先级都填1  恒生效
     insert into PD.PM_PRODUCT_PRICING_PLAN
      select distinct FEEPOLICY_ID,0,FEEPOLICY_ID,1,-1,0
        from NG_TMP_ACCT_DISCNT
       where FEEPOLICY_ID not in (select product_offering_id from PD.PM_PRODUCT_PRICING_PLAN);
     --定价声明
     insert into PD.PM_COMPONENT_PRODOFFER_PRICE
      select distinct a.price_id+800000000,b.price_name,13,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_ACCT_DISCNT a , ng_td_b_price b
       where a.price_id = b.price_id
        order by 1;
/*     insert into PD.PM_COMPONENT_PRODOFFER_PRICE
      select distinct a.price_id+800000000,'账户优惠-群优惠（费用收在个人头上）',8,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_ACCT_DISCNT a 
       where a.feepolicy_id in (5341,5343,5345,5347,5349)
        order by 1;*/
------------------------------非合户多终端共享资费，新增price_id，也是新增编码，上线前需要确认其唯一性---------------
insert into PD.PM_COMPONENT_PRODOFFER_PRICE values (849002220,'非合户多终端共享',13,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss'));
     
     --定价计划_定价关联关系
     insert into PD.PM_COMPOSITE_OFFER_PRICE (PRICING_PLAN_ID,PRICE_ID,BILLING_TYPE,OFFER_STS,VALID_DATE,EXPIRE_DATE,SERV_ID,PRIORITY)
      select distinct FEEPOLICY_ID,price_id+800000000,'1','-1',to_date('01-01-2001', 'dd-mm-yyyy'), to_date('01-01-2100', 'dd-mm-yyyy'),'-1',5600
        from NG_TMP_ACCT_DISCNT a
       order by 1;
    --优惠曲线定义
    INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
      SELECT DISTINCT 810000000+a.FEEDISCNT_ID,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
        FROM NG_TMP_ACCT_DISCNT a;
    --定价与优惠曲线关系	
    INSERT INTO PD.PM_BILLING_DISCOUNT_DTL (PRICE_ID, CALC_SERIAL, ADJUSTRATE_ID,VALID_DATE, EXPIRE_DATE, USE_TYPE, MEASURE_ID, DESCRIPTION)
    SELECT DISTINCT
      a.PRICE_ID+800000000,1,810000000+a.FEEDISCNT_ID,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --日月账都有效
      10403,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
      FROM NG_TMP_ACCT_DISCNT a ORDER BY 1 , 2;
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE, 
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM, 
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID, 
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE, 
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION, 
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            810000000+a.FEEDISCNT_ID,a.cond_id2,2 REF_TYPE,0,
            0,a.base_item,1,a.effect_item ADJUST_ITEM,1,0 FILL_ITEM,
            1,1 PRIORITY,0,-1,a.fee,10,0,
            3,0,0,0,0,
            policy_id,-1,0,5 PROM_TYPE,0,0,'多终端共享保底',
            4,-1,0
    FROM NG_TMP_ACCT_DISCNT a;
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:=substr(SQLERRM,1,200);
       v_resultcode:='-1';
END;
/

      
      
      

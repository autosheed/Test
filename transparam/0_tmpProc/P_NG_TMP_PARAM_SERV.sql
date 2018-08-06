 CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_SERV
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_SERV过程执行成功!';
    
    --清理方案  按ID区间约定清理--
    --本过程只清理固费定价相关数据   定价计划的定义、销售品相关属性与计费商定后再外层删除
    DELETE FROM PD.PM_RECURRING_FEE_DTL;
    DELETE FROM PD.PM_CURVE_SEGMENTS;
    DELETE FROM PD.PM_RATES;
    DELETE FROM PD.PM_CURVE;
    DELETE FROM pd.PM_CYCLEFEE_RULE;
    DELETE FROM PD.PM_COMPONENT_PRODOFFER_PRICE WHERE PRICE_ID between 600000000 and 699999999;
    DELETE FROM PD.PM_COMPOSITE_OFFER_PRICE WHERE PRICE_ID between 600000000 and 699999999;
    COMMIT;

    update VB_PM_PRODUCT_OFFERING set PRODUCT_OFFERING_ID = feepolicy_id;  --跟勇哥讨论，计费账务的资费编码保持不变
    commit;
    
		BEGIN
---------------------------1.销售品定义-属性---------------------------
			insert into PD.PM_PRODUCT_OFFERING
       (PRODUCT_OFFERING_ID,OFFER_TYPE_ID,NAME,BRAND_SEGMENT_ID,IS_MAIN,
        LIFECYCLE_STATUS_ID,OPERATOR_ID,PROD_SPEC_ID,OFFER_CLASS,PRIORITY,
        BILLING_PRIORITY,IS_GLOBAL,VALID_DATE,EXPIRE_DATE,DESCRIPTION,SPEC_TYPE_FLAG)
         select distinct PRODUCT_OFFERING_ID,    --销售品编码
                0,                               --OFFER_TYPE_ID
                OFFERING_NAME,                   --NAME
                -1,                              --BRAND_SEGMENT_ID
                0,                               --IS_MAIN
                1,                               --LIFECYCLE_STATUS_ID
                0,                               --OPERATOR_ID
                10180000,                        --PROD_SPEC_ID
                111,                             --OFFER_CLASS
                0,                               --PRIORITY
                0,                               --BILL_PRIORITY
                0,                               --IS_GLOBAL
                to_date('20100101000000','yyyymmddhh24miss'),
                to_date('20990101000000','yyyymmddhh24miss'),
                OFFERING_NAME,                    
                0                                --SPEC_TYPE_FLAG
           from VB_PM_PRODUCT_OFFERING 
          where product_offering_id not in (select product_offering_id from PD.PM_PRODUCT_OFFERING);
						
 			 insert into PD.PM_PRODUCT_OFFER_ATTRIBUTE
         select distinct PRODUCT_OFFERING_ID,   --PRODUCT_OFFERING_ID
                0,                              --POLICY_ID
                1,                              --BILLING_TYPE
                -1,                             --SUITABLE_NET
                0,                              --PROBATION_EFFECT_MOD
                -999,                           --PROBATION_CYCLE_UNIT
                -999,                           --PROBATION_CYCLE_TYPE
                null,                           --OFFSET_CYCLE_TYPE
                null,                           --OFFSET_CYCLE_UNIT
                0,                              --IS_REFUND
                0,                              --DISCOUNT_EXPIRE_MODE
                null,                           --DEPEND_FREERES_ITEM
                0                               --AVAILABLE_SEG_ID
           from VB_PM_PRODUCT_OFFERING
          where PRODUCT_OFFERING_ID not in (select product_offering_id from PD.PM_PRODUCT_OFFER_ATTRIBUTE);
	
			insert into PD.PM_COMPOSITE_DEDUCT_RULE
				 select distinct PRODUCT_OFFERING_ID,   --PRODUCT_OFFERING_ID
				        1,                     --BILLING_TYPE
				        0,                     --RESOURCE_FLAG
				        1,                     --DEDUCT_FLAG
				        -1,                    --RENT_DEDUCT_RULE_ID
				        1002,                  --PRORATE_DEDUCT_RULE_ID
				        -1,                    --FAILURE_RULE_ID
				        1,                     --REDO_AF_TOPUP
				        0,                     --NEGATIVE_FLAG
				        0,                     --IS_CHANGE_BILL_CYCLE
				        0,                     --IS_PER_BILL
				        0,                     --RETRY_MODE
				        0,                     --RETRY_TIME
				        0,                     --RETRY_CYCLES
				        null,                  --INTERVAL_CYCLE_TYPE
				        null,                  --INTERVAL_CYCLE_UNIT
				        -999,                  --CYCLE_TYPE
				        -999,                  --CYCLE_UNIT
				        0,                     --NEED_AUTH
				        -1                     --MAIN_PROMOTION
				   from VB_PM_PRODUCT_OFFERING
				  where PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from PD.PM_COMPOSITE_DEDUCT_RULE where billing_type = '1');
       
---------------------------2.定价计划定义---------------------------
	     insert into PD.PM_PRICING_PLAN 
         select DISTINCT PRODUCT_OFFERING_ID,
                OFFERING_NAME,
                OFFERING_NAME,
                'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
           from VB_PM_PRODUCT_OFFERING
          where PRODUCT_OFFERING_ID not in (select pricing_plan_id from PD.PM_PRICING_PLAN);
--------------------------3.销售品_定价计划------------------------
	     insert into PD.PM_PRODUCT_PRICING_PLAN
				 select distinct PRODUCT_OFFERING_ID,
				        0,                      --return 1
				        PRODUCT_OFFERING_ID,    --PLAN
				        1,                      --PRIORITY
				        -1,                     --MAIN_PROMOTION
				        0                       --DISP_FLAG
				   from VB_PM_PRODUCT_OFFERING
				  where PRODUCT_OFFERING_ID not in (select product_offering_id from PD.PM_PRODUCT_PRICING_PLAN);
----------------4.固费定价定义  定价计划_定价----------算费周期 4(天) 8(月)
				insert into PD.PM_COMPONENT_PRODOFFER_PRICE
				   (PRICE_ID,NAME,PRICE_TYPE,TAX_INCLUDED,DESCRIPTION)				
				   select  distinct a.new_price_id,a.price_name,7,2,'基本月租费计算' from VB_PM_PRODUCT_OFFERING a;
				insert into PD.PM_COMPOSITE_OFFER_PRICE 
				  (PRICING_PLAN_ID,PRICE_ID,BILLING_TYPE,OFFER_STS,VALID_DATE,EXPIRE_DATE,SERV_ID,EVENT_TYPE_ID,PRIORITY)
					select DISTINCT a.product_offering_id,a.new_price_id,1,-1,
						to_date('01-01-2002', 'dd-mm-yyyy'), 
						to_date('01-01-2099', 'dd-mm-yyyy'),
            a.serv_id,a.event_type_id,a.event_priority from VB_PM_PRODUCT_OFFERING a;
        COMMIT;
    END;

---------------5.固费定价定义明细   4张表----------------------

    BEGIN
        -----------------定义表，形式主义--------
        insert into PD.PM_CURVE (CURVE_ID,DESCRIPTION)
				select distinct a.rate_id,'VB割接导入--'||to_char(sysdate,'yyyymmddhh24miss') from VB_PM_PRODUCT_OFFERING a;
        COMMIT;
        
        insert into PD.PM_RATES
				(RATE_ID,RATE_NAME,SERVICE_ID,MINIMUM,MAXIMUM,RATE_PRECISION,PRECISION_ROUND,CURVE_ID,MEASURE_ID,DESCRIPTION)
				select distinct a.rate_id,a.rate_name,0,-1,-1,10,3,a.rate_id,10402,'VB割接导入--'||to_char(sysdate,'yyyymmddhh24miss')
          from VB_PM_PRODUCT_OFFERING a;
        COMMIT;
 
				--按天收取cycle_type_id = 4	不规整 sumtoint_type = ‘00’	 810200001
        insert into  PD.PM_RECURRING_FEE_DTL
				(PRICE_ID,ITEM_CODE,RATE_ID,ACCOUNT_TYPE,VALID_CYCLE,VALID_COUNT,PRE_PAY_TYPE,CAL_INDI,EXPR_ID,PRIORITY,USE_MARKER_ID,SEG_INDI,SEG_REP,DESCRIPTION,PARAM_MODE)
				select new_price_id,a.item_code,a.rate_id,3,0,-1,0,3 CAL_INDI,nvl(a.EXPR_ID,0),9,a.User_Marker_Id,0,0,'VB割接导入--'||to_char(sysdate,'yyyymmddhh24miss'),1 
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=4 and a.sumtoint_type in ('00');         
        COMMIT;
        insert into PD.PM_CURVE_SEGMENTS 
				(CURVE_ID,SEGMENT_ID,START_VAL,END_VAL,BASE_VAL,RATE_VAL,TAIL_UNIT,TAIL_ROUND,TAIL_RATE,FORMULA_ID,SHARE_NUM,DESCRIPTION,CHARGE_MODE)
				select distinct a.rate_id,1,0,-1,0 CYCLE_FEE,a.day_fee,0,0,0,810200001,0,a.rate_name,'4'   --对于按天收费、不规整的，无需CYCLE_FEE day_fee为unit_radio
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=4 and a.sumtoint_type in ('00');
        COMMIT;
        --按天收取cycle_type_id = 4	全月费用相同规整 sumtoint_type = ‘10’ 810200002
        insert into  PD.PM_RECURRING_FEE_DTL
				(PRICE_ID,ITEM_CODE,RATE_ID,ACCOUNT_TYPE,VALID_CYCLE,VALID_COUNT,PRE_PAY_TYPE,CAL_INDI,EXPR_ID,PRIORITY,USE_MARKER_ID,SEG_INDI,SEG_REP,DESCRIPTION,PARAM_MODE)
				select new_price_id,a.item_code,a.rate_id,3,0,-1,0,3 CAL_INDI,nvl(a.EXPR_ID,0),9,a.User_Marker_Id,0,0,'VB割接导入--'||to_char(sysdate,'yyyymmddhh24miss'),1 
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=4 and a.sumtoint_type = '10';             
        COMMIT;
        insert into PD.PM_CURVE_SEGMENTS 
				(CURVE_ID,SEGMENT_ID,START_VAL,END_VAL,BASE_VAL,RATE_VAL,TAIL_UNIT,TAIL_ROUND,TAIL_RATE,FORMULA_ID,SHARE_NUM,DESCRIPTION,CHARGE_MODE)
				select distinct a.rate_id,1,0,-1,a.cycle_fee,a.day_fee,0,0,0,810200002,0,a.rate_name,'4' --规整费用cycle_fee
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=4 and a.sumtoint_type = '10';   
        COMMIT;
        --按半月收取cycle_type_id = 7  810200003
        insert into  PD.PM_RECURRING_FEE_DTL
				(PRICE_ID,ITEM_CODE,RATE_ID,ACCOUNT_TYPE,VALID_CYCLE,VALID_COUNT,PRE_PAY_TYPE,CAL_INDI,EXPR_ID,PRIORITY,USE_MARKER_ID,SEG_INDI,SEG_REP,DESCRIPTION,PARAM_MODE)
				select new_price_id,a.item_code,a.rate_id,3,0,-1,0,3 CAL_INDI,nvl(a.EXPR_ID,0),9,a.User_Marker_Id,0,0,'VB割接导入--'||to_char(sysdate,'yyyymmddhh24miss'),1 
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=7;    
        COMMIT;
        insert into PD.PM_CURVE_SEGMENTS 
				(CURVE_ID,SEGMENT_ID,START_VAL,END_VAL,BASE_VAL,RATE_VAL,TAIL_UNIT,TAIL_ROUND,TAIL_RATE,FORMULA_ID,SHARE_NUM,DESCRIPTION,CHARGE_MODE)
				select distinct a.rate_id,1,0,-1,0 CYCLE_FEE,a.day_fee,0,0,0,810200003,0,a.rate_name,'7'
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=7;
        COMMIT;
        --按月收取 cycle_type_id = 8	月初显示 sumtoint_type = ‘00’	810200004  首月不按天折算  first_effect in ('0');
        insert into  PD.PM_RECURRING_FEE_DTL
				(PRICE_ID,ITEM_CODE,RATE_ID,ACCOUNT_TYPE,VALID_CYCLE,VALID_COUNT,PRE_PAY_TYPE,CAL_INDI,EXPR_ID,PRIORITY,USE_MARKER_ID,SEG_INDI,SEG_REP,DESCRIPTION,PARAM_MODE)
				select new_price_id,a.item_code,a.rate_id,3,0,-1,0,1,nvl(a.EXPR_ID,0),9,nvl(a.User_Marker_Id,0),0,0,'VB割接导入--'||to_char(sysdate,'yyyymmddhh24miss'),1 
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=8 and a.first_effect in ('0');           
        COMMIT;
        insert into PD.PM_CURVE_SEGMENTS 
				(CURVE_ID,SEGMENT_ID,START_VAL,END_VAL,BASE_VAL,RATE_VAL,TAIL_UNIT,TAIL_ROUND,TAIL_RATE,FORMULA_ID,SHARE_NUM,DESCRIPTION,CHARGE_MODE)
				select distinct a.rate_id,1,0,-1,a.cycle_fee,a.day_fee DAY_FEE,0,0,0,810200004,0,a.rate_name,'8'   --dayfee需要填写 ，下半月订购折半
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=8 and a.first_effect in ('0');   
        COMMIT;
        --按月收取 cycle_type_id = 8	月初显示 sumtoint_type = ‘00’ 810200005  首月按天折算   first_effect in ('1');
        insert into  PD.PM_RECURRING_FEE_DTL
				(PRICE_ID,ITEM_CODE,RATE_ID,ACCOUNT_TYPE,VALID_CYCLE,VALID_COUNT,PRE_PAY_TYPE,CAL_INDI,EXPR_ID,PRIORITY,USE_MARKER_ID,SEG_INDI,SEG_REP,DESCRIPTION,PARAM_MODE)
				select new_price_id,a.item_code,a.rate_id,3,0,-1,0,1,nvl(a.EXPR_ID,0),9,nvl(a.User_Marker_Id,0),0,0,'VB割接导入--'||to_char(sysdate,'yyyymmddhh24miss'),1 
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=8 and a.first_effect in ('1');           
        COMMIT;
        insert into PD.PM_CURVE_SEGMENTS 
				(CURVE_ID,SEGMENT_ID,START_VAL,END_VAL,BASE_VAL,RATE_VAL,TAIL_UNIT,TAIL_ROUND,TAIL_RATE,FORMULA_ID,SHARE_NUM,DESCRIPTION,CHARGE_MODE)
				select distinct a.rate_id,1,0,-1,a.cycle_fee,a.day_fee DAY_FEE,0,0,0,810200005,0,a.rate_name,'8'   --dayfee需要填写 ，下半月订购折半
				from VB_PM_PRODUCT_OFFERING a where a.cycle_type_id=8 and a.first_effect in ('1');   
        COMMIT;
                
        --停机保号费按月收取
        update pd.PM_RECURRING_FEE_DTL set use_marker_id = (select max(POLICY_ID) from VB_TMP_POLICY_RENTFEE_COND)
         where item_code = 10004;

        --CYCLEFEE_RULE
        insert into pd.PM_CYCLEFEE_RULE select distinct item_code,sum_mode,'' from td_b_cyclefee_rule;
        COMMIT;

      EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='固定费资费树 err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;       
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:='P_NG_TMP_PARAM_SERV err!:'||substr(SQLERRM,1,200);
       v_resultcode:='-1';
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
       RETURN;
END;
/


CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_SPECIAL_TP
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_SPECIAL_TP过程执行成功!';

      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,DISCNT_NAME) values ('487100010','立即调账外部费用');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,Discnt_Name) values ('487100011','小额支付产品');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,Discnt_Name) values ('487100012','用户挂账业务');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,Discnt_Name) values ('487100013','清帐稽核');
      COMMIT;
      
      delete from SD.SYS_PARAMETER where param_code in ('BS_PRODUCT_ID_EXT','BS_PRODUCT_ID_MIC','BS_PRODUCT_ID_HUNG','BS_PRODUCT_ID_BILLCDR_CHK','BS_DETACH_MERGE_ADJUST_FEE');
      COMMIT;
      --立即调账外部费用ID
      insert into SD.SYS_PARAMETER values('BS_PRODUCT_ID_EXT', '立即调账外部费用ID', 5, 0, 2, 487100010, '立即调账外部费用ID', -999);
      commit;
      --小额支付产品ID
      insert into SD.SYS_PARAMETER values('BS_PRODUCT_ID_MIC', '小额支付产品ID', 5, 0, 2, 487100011, '小额支付产品ID', -999);
      commit;
      --用户挂账业务
      insert into SD.SYS_PARAMETER values('BS_PRODUCT_ID_HUNG', '用户挂账业务', 5, 0, 2, 487100012, '用户挂账业务', -999);
      commit;
      --清帐稽核
      insert into SD.SYS_PARAMETER values('BS_PRODUCT_ID_BILLCDR_CHK', '清帐稽核', 5, 0, 2, 487100013, '清帐稽核', -999);
      commit;
      --调账科目合并规则
      insert into SD.SYS_PARAMETER values('BS_DETACH_MERGE_ADJUST_FEE', '调账科目合并规则', 5, 0, 2, 0, '0:不合并 1:合并', -999);
      commit;

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
      
EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:=substr(SQLERRM,1,200);
       v_resultcode:='-1';
END;
/

      
      
      

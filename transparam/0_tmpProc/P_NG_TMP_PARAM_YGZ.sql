CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_YGZ
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
-----------------------------------------------------
--VerisBilling参数割接使用
--营改增税费拆分规则
-----------------------------------------------------
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_YGZ 过程执行成功!';
--PD.PM_ITEM_SPLIT_RATE 
--PD.PM_ITEM_TAX_RATE
--NG_TD_B_DETAILITEM
--NG_TD_B_FEETRANSRULE
    delete from pd.PM_ITEM_TAX_RATE;
    delete from pd.PM_ITEM_SPLIT_RATE;
    delete from pd.PM_PRODUCT_OFFERING_CENPAY;
    commit;

    BEGIN
       insert into pd.PM_ITEM_TAX_RATE (ITEM_CODE, TAX_RATE, VALID_DATE, EXPIRE_DATE, DESCRIPTION)
       select a.item_id,a.tax_type * 100 ,to_date('01-01-1990', 'dd-mm-yyyy'), to_date('01-01-2030', 'dd-mm-yyyy'),'VB割接导入 zhangjt  '||to_char(sysdate,'yyyy-mm-dd')
       from ng_td_b_detailitem a where a.tax_type in (6,17,11);
       
       insert into pd.PM_ITEM_SPLIT_RATE (PRODUCT_OFFERING_ID, ITEM_CODE, DST_ITEM_CODE, DST_RATE, VALID_DATE, EXPIRE_DATE, SPLIT_SEQ)
       select a.feepolicy_id,a.trans_item_id,a.item_id,a.fee,to_date('01-01-2001', 'dd-mm-yyyy'), to_date('01-01-2050', 'dd-mm-yyyy'), 0
       from NG_TD_B_FEETRANSRULE a;
       update pd.PM_ITEM_SPLIT_RATE a set a.product_offering_id = -1 where a.product_offering_id = 0;
       
       --固费销售品编码修改    固费资费也会参与混业拆分
       update pd.PM_ITEM_SPLIT_RATE a set PRODUCT_OFFERING_ID = 
       (select distinct b.PRODUCT_OFFERING_ID from VB_PM_PRODUCT_OFFERING b where a.product_offering_id = b.feepolicy_id)
       where exists (select 1 from VB_PM_PRODUCT_OFFERING c where a.product_offering_id = c.feepolicy_id);
       
       
       --统付的也放到这边来
        insert into pd.PM_PRODUCT_OFFERING_CENPAY (PRODUCT_OFFERING_ID,FEE,Data,BEGIN_DAY,END_DAY,REMARK)
          select tp_id,fee/10,data,begin_day,end_day,remark from td_b_cenpay_tp;

        update pd.PM_PRODUCT_OFFERING_CENPAY a set PRODUCT_OFFERING_ID = 
          (select distinct b.PRODUCT_OFFERING_ID from VB_PM_PRODUCT_OFFERING b where a.product_offering_id = b.feepolicy_id)
               where exists (select 1 from VB_PM_PRODUCT_OFFERING c where a.product_offering_id = c.feepolicy_id);
         
      EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='P_NG_TMP_PARAM_YGZ err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           RETURN;
    END;    
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:=substr(SQLERRM,1,200);
       v_resultcode:='-1';
END;
/


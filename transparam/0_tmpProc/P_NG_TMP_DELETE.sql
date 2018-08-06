CREATE OR REPLACE PROCEDURE P_NG_TMP_DELETE
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_DELETE过程执行成功!';
    BEGIN

    --销售品\定价计划相关数据清理--
    DELETE FROM PD.PM_PRODUCT_OFFERING;
    DELETE FROM PD.PM_PRODUCT_OFFER_ATTRIBUTE;
    DELETE FROM PD.PM_COMPOSITE_DEDUCT_RULE;
    DELETE FROM pd.PM_GLOBAL_OFFER_AVAILABLE;
    DELETE FROM pd.PM_PRODUCT_OFFER_AVAILABLE;
    DELETE FROM PD.PM_PRICING_PLAN;
    DELETE FROM PD.PM_PRODUCT_PRICING_PLAN;
    COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='P_NG_TMP_DELETE err!:'||substr(SQLERRM,1,200);
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


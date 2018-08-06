CREATE OR REPLACE PROCEDURE P_ASP_NG2VB_PROD_OFFER
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_ASP_NG2VB_PROD_OFFER 过程执行成功!';
    
    --NG固费资费整理及中间表形成
    BEGIN
        P_NG_TMP_PARAM_SERV_PRE(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_SERV_PRE call error'||SQLERRM;
            RETURN;
    END;
    --NG优惠资费整理及中间表形成
    BEGIN
        P_NG_TMP_PARAM_DISCNT_PRE(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_DISCNT_PRE call error'||SQLERRM;
            RETURN;
    END;
    --导入固费资费
    BEGIN
        P_NG_TMP_PARAM_SERV(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_SERV call error'||SQLERRM;
            RETURN;
    END;
    --导入优惠资费
    BEGIN
        P_NG_TMP_PARAM_DISCNT(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_DISCNT call error'||SQLERRM;
            RETURN;
    END;
    --导入一次性费用资费
    BEGIN
        P_NG_TMP_PARAM_OTPFEE(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_DISCNT call error'||SQLERRM;
            RETURN;
    END;
    --导入账户优惠资费(多终端共享转成群组优惠)
    BEGIN
        P_NG_TMP_PARAM_ACCTDISCNT(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_ACCTDISCNT call error'||SQLERRM;
            RETURN;
    END;
    --导入分账规则及分账销售品
    BEGIN
        P_NG_TMP_PARAM_FENZHANG(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_FENZHANG call error'||SQLERRM;
            RETURN;
    END;
    --导入营改增参数
/*    BEGIN
        P_NG_TMP_PARAM_YGZ(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_YGZ call error'||SQLERRM;
            RETURN;
    END;*/
    --导入科目
    /*BEGIN
        P_NG_TMP_PARAM_ITEM(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_ITEM call error'||SQLERRM;
            RETURN;
    END;*/
    --导入条件表达式
    BEGIN
        P_ASP_INSERT_SYSPOLICY(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_ASP_INSERT_SYSPOLICY call error'||SQLERRM;
            RETURN;
    END;
    --导入用户状态定义
    BEGIN
        P_ASP_INSERT_USERSTATUS(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_ASP_INSERT_USERSTATUS call error'||SQLERRM;
            RETURN;
    END;
    
  EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       v_resulterrinfo:='P_ASP_ZHANGJT err!:'||substr(SQLERRM,1,200);
       v_resultcode:='-1';
       RETURN;
END;    
/


 CREATE OR REPLACE PROCEDURE p_zhangjt_getServPrice
(
    v_errcode           OUT NUMBER,
    v_errmsg            OUT VARCHAR2
)
AS
  iv_price_comp1          td_b_price_comp%ROWTYPE;
  iv_price_comp2          td_b_price_comp%ROWTYPE;
  iv_price_comp3          td_b_price_comp%ROWTYPE;
  iv_price_comp4          td_b_price_comp%ROWTYPE;
  iv_price_comp5          td_b_price_comp%ROWTYPE;
  iv_orderNo              NUMBER(3);
  iv_cond_ids1            VARCHAR2(40);
  iv_cond_ids2            VARCHAR2(40);
  iv_cond_ids3            VARCHAR2(40);
  iv_cond_ids4            VARCHAR2(40);
  iv_cond_ids5            VARCHAR2(40);

  type cursor_type is ref CURSOR;
  iv_cursor1 cursor_type;
  iv_cursor2 cursor_type;
  iv_cursor3 cursor_type;
  iv_cursor4 cursor_type;
  iv_cursor5 cursor_type;


BEGIN
    v_errcode := 0;
    v_errmsg := 'p_zhangjt_getServPrice过程执行成功！';

   EXECUTE IMMEDIATE 'TRUNCATE TABLE NG_SYS_CONNECT_BY_PATH_SERV';
   EXECUTE IMMEDIATE 'TRUNCATE TABLE NG_TMP_PRICE_SERV';

   BEGIN
      FOR X IN 0..9
      LOOP
        insert into NG_SYS_CONNECT_BY_PATH_SERV
        select distinct price_id,X TYPE_ID FROM NG_TMP_FEEPOLOICY WHERE TYPE in ('1','2') and mod(price_id,10)=X;     
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_errcode := SQLCODE;
           v_errmsg := 'P_NG_TMP_PARAM_SERV_PRE err!:'||substr(SQLERRM,1,200);
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_errcode,v_errmsg,sysdate);
           RETURN;
    END;  
    COMMIT;

    BEGIN
        FOR Y IN 0..9
        LOOP
        INSERT INTO NG_TMP_PRICE_SERV
        (PRICE_ID,ORDER_NO,PATH_INFO,COND_IDS,EXEC_ID,UNIT_RATIO,PARAM_ID,TYPE)
        select PRICE_ID,row_number() over(partition by PRICE_ID order by PATH_INFO) AS ORDER_NUM,PATH_INFO,
               REPLACE(substr(EXEC_INFO,1,instr(EXEC_INFO,'|',-1,1)),'||') COND_ID,EXEC_ID,
               DECODE(SUBSTR(B.unit_ratio,1,1),'?','',B.unit_ratio),
               DECODE(SUBSTR(B.unit_ratio,1,1),'?',SUBSTR(B.unit_ratio,2),''),
               '1' TYPE
         from (
              select a.price_id,a.node_id,a.exec_id,level,
                     --排序信息,根据NODE_ID分层排序
                     SYS_CONNECT_BY_PATH(node_id,'|') PATH_INFO,
                     --EXEC_ID记录
                     SYS_CONNECT_BY_PATH(exec_id,'|') EXEC_INFO
                from NG_TD_B_PRICE_COMP a,NG_SYS_CONNECT_BY_PATH_SERV b
               where a.price_id =b.price_id
                 and b.type_id = Y
                 and a.EXEC_TYPE IN('0','2')
                 and CONNECT_BY_ISLEAF='1' --只获取叶子
               start with p_node_id = 0
              connect by prior node_id = p_node_id) a,NG_TD_B_FEECOUNT b
        where EXEC_ID=b.feecount_id 
        order by PRICE_ID,ORDER_NUM;  
      END LOOP;
      COMMIT;
      END;
      
      --清理条件字段中前置后缀字符'|'                                 
      UPDATE NG_TMP_PRICE_SERV
         SET cond_ids=SUBSTR(cond_ids,1,length(cond_ids)-1)
       WHERE cond_ids LIKE '%|';
      UPDATE NG_TMP_PRICE_SERV
         SET COND_IDS = SUBSTR(COND_IDS, 2)
       WHERE COND_IDS LIKE '|%';
      COMMIT;
      
      

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       v_errcode := SQLCODE;
       v_errmsg := 'P_NG_TMP_PARAM_SERV_PRE err!:'||substr(SQLERRM,1,200);
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_errcode,v_errmsg,sysdate);
       RETURN;
END;
/

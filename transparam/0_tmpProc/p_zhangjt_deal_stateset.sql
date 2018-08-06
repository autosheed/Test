/*
把状态集[123456789ACDHJKLMOPXYZ]   解析为
2001,2002,2003,2004,2005,2006,2007,2008,2009,9999,2011,9999,9999,2015,2016,2017,2018,2020,2021,2024,2025,2026
*/
CREATE OR REPLACE PROCEDURE p_zhangjt_deal_stateset
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS 
  type cursor_type is ref CURSOR;
  iv_cursor cursor_type;
  iv_poicy_id        number(9);
  iv_state_set       varchar2(200);
  iv_new_stateset    varchar2(400);
  iv_set_length      number(30);
  iv_new_state_code  varchar2(30);

BEGIN

    v_resultcode := 0;
    v_resulterrinfo := 'p_zhangjt_deal_stateset 过程执行成功！';
    
       OPEN iv_cursor FOR select policy_id,state_set,length(state_set) set_length from ZHANGJT_SIMPLECOND where tag = '6';
         LOOP
         FETCH iv_cursor INTO iv_poicy_id,iv_state_set,iv_set_length;
         EXIT WHEN iv_cursor%NOTFOUND;
         
         iv_new_stateset:=null;
         for iv_index in 1..iv_set_length
         loop
           select new_state_code into iv_new_state_code from TMP_NG2VB_SERVSTATE where old_state_code = substr(iv_state_set,iv_index,1);
           iv_new_stateset:=iv_new_stateset||iv_new_state_code||'|';
         end loop;
         
         update ZHANGJT_SIMPLECOND set state_set = substr(iv_new_stateset,1,length(iv_new_stateset)-1)
         where tag = '6' and policy_id = iv_poicy_id;
         
         END LOOP;
       CLOSE iv_cursor;

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       v_resulterrinfo:=substr(sqlerrm,1,200);
       v_resultcode:='-1';
END;

/

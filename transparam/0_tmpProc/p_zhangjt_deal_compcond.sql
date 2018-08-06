CREATE OR REPLACE PROCEDURE p_zhangjt_deal_compcond
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS 
  type cursor_type is ref CURSOR;
  iv_cursor cursor_type;
  
  iv_count           number(3);
  iv_compcond_id     number(8);

BEGIN

    v_resultcode := 0;
    v_resulterrinfo := 'p_zhangjt_deal_compcond 过程执行成功！';
    
    select count(*) into iv_count from ZHANGJT_COND where isdeal = '0';
    while iv_count > 0 loop
       OPEN iv_cursor FOR select cond_id from ZHANGJT_COND where isdeal = '0';
         LOOP
         FETCH iv_cursor INTO iv_compcond_id;
         EXIT WHEN iv_cursor%NOTFOUND;

         insert into ZHANGJT_COND 
          select sub_cond_id,'',b.comp_tag,'','','0','子条件' from td_b_compcond a , td_b_cond b
           where a.cond_id = iv_compcond_id and b.cond_id = a.sub_cond_id
             and a.sub_cond_id not in (select cond_id from ZHANGJT_COND);
         update ZHANGJT_COND set isdeal = '1' where cond_id = iv_compcond_id;
         commit;
         
         END LOOP;
       CLOSE iv_cursor;
       
       select count(*) into iv_count from ZHANGJT_COND where isdeal = '0';
   end loop;


EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       v_resulterrinfo:=substr(sqlerrm,1,200);
       v_resultcode:='-1';
END;
/
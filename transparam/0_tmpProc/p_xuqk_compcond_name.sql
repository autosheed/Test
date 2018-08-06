CREATE OR REPLACE PROCEDURE p_xuqk_compcond_name
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS 
  type cursor_type is ref CURSOR;
  iv_cursor cursor_type;
  iv_subcursor cursor_type;
  
  iv_compcond_id       number(8);
  iv_subcondId         number(8);
  iv_cond_name         varchar2(4000);
  iv_remark            varchar2(2000);
  iv_rownum            number(2);
  iv_minNo             number(2);
  iv_maxNo             number(2);

BEGIN

    v_resultcode := 0;
    v_resulterrinfo := 'p_xuqk_compcond_name 过程执行成功！';
    
   OPEN iv_cursor FOR select cond_id from ZHANGJT_COND a where a.cond_type = '1';
     LOOP
     FETCH iv_cursor INTO iv_compcond_id;
     EXIT WHEN iv_cursor%NOTFOUND;

     iv_cond_name:='';
     iv_remark:='';

       OPEN iv_subcursor FOR select a.remark,rownum from zhangjt_simplecond a where cond_id in (select sub_cond_id from td_b_compcond where cond_id = iv_compcond_id);
         LOOP
         FETCH iv_subcursor INTO iv_remark,iv_rownum;
         EXIT WHEN iv_subcursor%NOTFOUND;

         select max(rownum) into iv_maxNo from zhangjt_simplecond where cond_id in (select sub_cond_id from td_b_compcond where cond_id = iv_compcond_id);
         select min(rownum) into iv_minNo from zhangjt_simplecond where cond_id in (select sub_cond_id from td_b_compcond where cond_id = iv_compcond_id);
         
         if (iv_rownum=iv_minNo) then
             iv_cond_name:=iv_remark;
         elsif (iv_rownum=iv_maxNo) then
             iv_cond_name:=iv_cond_name||';'||iv_remark;
         else
             iv_cond_name:=iv_cond_name||';'||iv_remark||' ; ';
         end if;
         
         
         END LOOP;
       CLOSE iv_subcursor;

      
UPDATE ZHANGJT_COND SET cond_name = iv_cond_name where cond_id = iv_compcond_id;
commit;

     END LOOP;
   CLOSE iv_cursor;



EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       v_resulterrinfo:=substr(sqlerrm,1,200);
       v_resultcode:='-1';
END;
/
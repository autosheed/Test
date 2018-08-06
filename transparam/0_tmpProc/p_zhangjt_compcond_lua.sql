CREATE OR REPLACE PROCEDURE p_zhangjt_compcond_lua
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
  type cursor_type is ref CURSOR;
  iv_cursor cursor_type;
  iv_subcursor cursor_type;

  iv_compcond_id     number(8);
  iv_count           number(2);
  iv_maxNo           number(2);
  iv_minNo           number(2);
  iv_andortag        varchar2(20);
  iv_orderNo         number(2);
  iv_subcondId       number(9);
  iv_conds           varchar2(2000);
  iv_judge           varchar2(2000);
  iv_lua             varchar2(2000);
  iv_index           number(2);

BEGIN

    v_resultcode := 0;
    v_resulterrinfo := 'p_zhangjt_compcond_lua 过程执行成功！';

   OPEN iv_cursor FOR select cond_id from ZHANGJT_COND a where a.cond_type = '1';
     LOOP
     FETCH iv_cursor INTO iv_compcond_id;
     EXIT WHEN iv_cursor%NOTFOUND;

     select count(*) into iv_count from td_b_compcond where cond_id = iv_compcond_id;
     if (iv_count = 0) then  --存在在cond表声明的组合条件，但未在comp_cond表中实现的
        continue;
     end if;

     select max(order_no) into iv_maxNo from td_b_compcond where cond_id = iv_compcond_id;
     select min(order_no) into iv_minNo from td_b_compcond where cond_id = iv_compcond_id;
     select distinct and_or_tag into iv_andortag from td_b_compcond where cond_id = iv_compcond_id;

     iv_conds:='';
     iv_index:=0;

       OPEN iv_subcursor FOR select order_no,sub_cond_id from td_b_compcond where cond_id = iv_compcond_id order by order_no;
         LOOP
         FETCH iv_subcursor INTO iv_orderNo,iv_subcondId;
         EXIT WHEN iv_subcursor%NOTFOUND;
         select policy_id into iv_subcondId from zhangjt_cond where cond_id = iv_subcondId;
         iv_index:=iv_index+1;
            iv_conds:=iv_conds||'local cond'||iv_index||' = _'||iv_subcondId||'(p)
';
     if (iv_andortag = '0') then
            if (iv_orderNo = iv_minNo) then
               iv_judge:='(cond1 == 1 ';
            else
               iv_judge:=iv_judge||' and cond'||iv_index||' == 1';
            end if;

            if (iv_orderNo = iv_maxNo) then
               iv_judge:=iv_judge||' )';
            end if;
     else
            if (iv_orderNo = iv_minNo) then
               iv_judge:='(cond1 == 1 ';
            else
               iv_judge:=iv_judge||' or cond'||iv_index||' == 1';
            end if;

            if (iv_orderNo = iv_maxNo) then
               iv_judge:=iv_judge||' )';
            end if;
     end if;

         END LOOP;
       CLOSE iv_subcursor;

            iv_lua:=iv_conds||'
if '||iv_judge||' then
    return 1
else
    return 0
end
            ';

UPDATE ZHANGJT_COND SET POLICY_EXPR = iv_lua where cond_id = iv_compcond_id;
commit;

     END LOOP;
   CLOSE iv_cursor;



EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       v_resulterrinfo:='p_zhangjt_compcond_lua err:'||substr(sqlerrm,1,200);
       v_resultcode:='-1';
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
       commit;
END;
/

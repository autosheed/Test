CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_SERV_PRE
(
    v_errcode           OUT NUMBER,
    v_errmsg            OUT VARCHAR2
)
-----------------------------------------------------
--VerisBilling参数割接使用
--服务费参数倒换预处理,包含固定类参数、资费生成中间表
-----------------------------------------------------
AS
BEGIN
    v_errcode := 0;
    v_errmsg := 'P_NG_TMP_PARAM_SERV_PRE 过程执行成功！';
  
    --NG_TMP_FEEPOLOICY  TYPE: 1产品默认资费-固费   2与优惠捆绑在一起-固费
    BEGIN
    --1--产品默认资费
      delete from NG_TMP_FEEPOLOICY where type in ('1','2');
      insert into NG_TMP_FEEPOLOICY
      (product_offering_id,feepolicy_id,FEEPOLICY_COMP_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,DISCNT_TYPE,REPEAT_TYPE,FIRST_EFFECT,
       EVENT_TYPE_ID,SERV_ID,CYCLE_TYPE_ID,COND_ID,PRICE_ID,event_type_name,SUMTOINT_TYPE,sumtoint_fee,TYPE)
      SELECT DISTINCT a.feepolicy_id,a.feepolicy_id,a.feepolicy_comp_id,a.event_priority,A.EFFECT_ROLE_CODE,
             NVL(D.RSRV_STR5,'0'),NVL(D.RSRV_STR4,'0'),NVL(D.RSRV_STR3,'0'),
             a.event_type_id,e.serv_id,e.cycle_type_id,NVL(e.cond_id,0),C.price_id,e.event_type_name,
             decode(c.sumtoint_type,'0','00',c.sumtoint_type), --'0'调整为'00'
             to_number(c.sumtoint_fee),'1'
       FROM NG_TD_B_FEEPOLICY_COMP a,NG_TD_B_EVENT_FEEPOLICY b,NG_TD_B_PRICE c,
            NG_TD_B_DISCNT D,NG_TD_B_EVENTTYPE e,td_b_default_feepolicy f
      WHERE a.feepolicy_id = f.default_feepolicy_id
        and a.event_type_id between 100 AND 400
        AND a.event_feepolicy_id=b.event_feepolicy_id
        AND b.price_id=c.PRICE_ID
        AND a.feepolicy_id=d.B_DISCNT_CODE
        AND a.event_type_id=e.event_type_id 
        AND d.End_Date>SYSDATE-90  --只倒换生效的资费
      ORDER BY 1,2; 
    --2--与优惠捆绑在一起
      insert into NG_TMP_FEEPOLOICY
      (product_offering_id,feepolicy_id,FEEPOLICY_COMP_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,DISCNT_TYPE,REPEAT_TYPE,FIRST_EFFECT,
       EVENT_TYPE_ID,SERV_ID,CYCLE_TYPE_ID,COND_ID,PRICE_ID,event_type_name,SUMTOINT_TYPE,sumtoint_fee,TYPE)
      SELECT DISTINCT a.feepolicy_id,a.feepolicy_id,a.feepolicy_comp_id,a.event_priority,A.EFFECT_ROLE_CODE,
             NVL(D.RSRV_STR5,'0'),NVL(D.RSRV_STR4,'0'),NVL(D.RSRV_STR3,'0'),
             a.event_type_id,e.serv_id,e.cycle_type_id,NVL(e.cond_id,0),C.price_id,e.event_type_name,
             decode(c.sumtoint_type,'0','00',c.sumtoint_type), --'0'调整为'00'
             to_number(c.sumtoint_fee),'2'
       FROM NG_TD_B_FEEPOLICY_COMP a,NG_TD_B_EVENT_FEEPOLICY b,NG_TD_B_PRICE c,
            NG_TD_B_DISCNT D,NG_TD_B_EVENTTYPE e
      WHERE a.feepolicy_id not in (select feepolicy_id from NG_TMP_FEEPOLOICY where type in ('1','2'))
        and a.event_type_id between 100 AND 400
        AND a.event_feepolicy_id=b.event_feepolicy_id
        AND b.price_id=c.PRICE_ID
        AND a.feepolicy_id=d.B_DISCNT_CODE
        AND a.event_type_id=e.event_type_id 
        AND d.End_Date>SYSDATE-90  --只倒换生效的资费
      ORDER BY 1,2; 
     COMMIT;
    --合并首月按天折算标记--
    update NG_TMP_FEEPOLOICY set FIRST_EFFECT = 0 where CYCLE_TYPE_ID = 4; --按天收费的固费，当然不需要判什么折算了~~
    COMMIT;
     
    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_errcode:=SQLCODE;
           v_errmsg:='NG_TMP_FEEPOLOICY err!:'||substr(SQLERRM,1,200);
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_errcode,v_errmsg,sysdate);
           RETURN;
    END; 
    COMMIT;

    BEGIN
        p_zhangjt_getServPrice(v_errcode,v_errmsg);  --解析PRICE_COMP   时耗较长  insert into NG_TMP_PRICE_SERV
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errcode := SQLCODE;
            v_errmsg := 'p_zhangjt_getServPrice err!:'||substr(SQLERRM,1,200);
            insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_errcode,v_errmsg,sysdate);
            RETURN;
    END;

      --整理0资费
      /*update NG_TMP_PRICE_SERV a set type ='3'  where a.price_id in (
      select b.price_id from NG_TMP_PRICE_SERV b,ng_td_b_price c where b.price_id=c.price_id and c.sumtoint_fee=0
      );
      update NG_TMP_PRICE_SERV a set type ='1'  where type ='3' and order_no =1 and unit_ratio !=0;
      COMMIT;*/
      delete from NG_TMP_COND_DESC where cond_type = '1';
      commit;
      INSERT INTO NG_TMP_COND_DESC(cond_ids,cond_names,cond_type) select cond_ids,sys_connect_by_path(cond_name,'&') cond_names , '1' 
       from 
         (select cond_ids,cond_name,row_number() over(partition by cond_ids order by cond_name)rn,count(*) over(partition by cond_ids ) cnt from 
           ng_td_b_cond a,(select distinct cond_ids cond_ids from NG_TMP_PRICE_SERV) b
          where instr(b.cond_ids,a.cond_id) > 0 ) a  
       where 
          level=cnt start with rn=1 connect by prior cond_ids=cond_ids and prior rn=rn-1;
      COMMIT;
      UPDATE NG_TMP_COND_DESC SET COND_NAMES = SUBSTR(COND_NAMES, 2) WHERE COND_TYPE = '1';
      COMMIT;

      UPDATE NG_TMP_PRICE_SERV a SET a.COND_NAMES = 
      (select cond_names from NG_TMP_COND_DESC b where a.cond_ids = b.cond_ids and b.cond_type = '1');
      COMMIT;

      update NG_TMP_PRICE_SERV 
         set status_cond_id = substr(cond_ids,1,8),
             status_cond_name = decode(instr(cond_names, '&', 1, 1),0,cond_names,substr(cond_names,1,instr(cond_names, '&', 1, 1)-1)),
             other_cond_id = substr(cond_ids,10),
             other_cond_name = decode(instr(cond_names, '&', 1, 1),0,null,substr(cond_names,instr(cond_names, '&', 1, 1)+1));
      update NG_TMP_PRICE_SERV set status = substr(status_cond_name,8,1);
      update NG_TMP_PRICE_SERV set type = '2' where other_cond_id is not null;
      --信管确认服务状态有映射，这边强制修改掉(主服务映射)
      update NG_TMP_PRICE_SERV a set trans_status = (select new_state_code from TMP_NG2VB_SERVSTATE b where a.status = b.old_state_code);
      commit;
------
      EXECUTE IMMEDIATE 'truncate table NG_TMP_RENTFEE_COND';
      INSERT INTO NG_TMP_RENTFEE_COND(PRICE_ID,UNIT_RATIO,STATUS_DESC,OTHER_DESC)
      select price_id,unit_ratio,substr(sys_connect_by_path(trans_status,','),2),other_cond_name
         from 
             (select price_id,trans_status,other_cond_name,unit_ratio,
                     row_number() over(partition by price_id,other_cond_name,unit_ratio order by trans_status)rn,
                     count(*) over(partition by price_id,other_cond_name,unit_ratio) cnt 
                from (select DISTINCT price_id,trans_status,other_cond_name,unit_ratio FROM NG_TMP_PRICE_SERV/* where unit_ratio <> 0*/) ) a   --暂不处理0费用
         where 
             level=cnt start with rn=1 connect by prior price_id=price_id 
         and prior nvl(other_cond_name,0) = nvl(other_cond_name,0) 
         and prior unit_ratio = unit_ratio
         and prior rn=rn-1
         order by 1; 
      update NG_TMP_RENTFEE_COND a set a.STATUS_DESC = replace(STATUS_DESC,',','|');

      update NG_TMP_RENTFEE_COND set mark_flag = '1';--MARK1
      update NG_TMP_RENTFEE_COND set mark_flag = '2' where other_desc like '%状态在本账期之内开始%';  
      
      --生成状态表达式
      EXECUTE IMMEDIATE 'truncate table NG_TMP_RC_FEEDTL';
insert into NG_TMP_RC_FEEDTL(PRICE_ID,UNIT_RATIO,OPENDATE_TAG,VALID_CHANGE_FLAG,STATUS_DESC1,STATUS_DESC2,STATUS_DESC3)
  SELECT price_id,unit_ratio,opendate_tag,valid_change_flag,
         list(status_desc1) status_desc1,
         list(status_desc2) status_desc2,
         list(status_desc3) status_desc3
  FROM
  (SELECT price_id,unit_ratio,valid_change_flag,opendate_tag,
         decode(mark_flag,1,status_desc) status_desc1,
         decode(mark_flag,2,status_desc) status_desc2,
         decode(mark_flag,3,status_desc) status_desc3
  FROM NG_TMP_RENTFEE_COND )
  GROUP BY price_id,unit_ratio,opendate_tag,valid_change_flag
  order by 1,2;
COMMIT;
      EXECUTE IMMEDIATE 'truncate table VB_TMP_POLICY_RENTFEE_COND';
INSERT INTO VB_TMP_POLICY_RENTFEE_COND(VALID_CHANGE_FLAG,STATUS_DESC1,STATUS_DESC2,STATUS_DESC3)
  SELECT DISTINCT VALID_CHANGE_FLAG,STATUS_DESC1,STATUS_DESC2,STATUS_DESC3 FROM NG_TMP_RC_FEEDTL;
DELETE FROM VB_TMP_POLICY_RENTFEE_COND WHERE STATUS_DESC1 IS NULL AND STATUS_DESC2 IS NULL AND STATUS_DESC3 IS NULL;
UPDATE VB_TMP_POLICY_RENTFEE_COND SET POLICY_ID = 810101000 + ROWNUM;
COMMIT;

-----------------------------------------1-------------------------------------------
UPDATE VB_TMP_POLICY_RENTFEE_COND SET POLICY_NAME = '--1. 服务状态为'||STATUS_DESC1||'
--2. 状态在本账期开始之后,服务状态为'||STATUS_DESC2
 WHERE STATUS_DESC1 IS NOT NULL AND STATUS_DESC2 IS NOT NULL;
UPDATE VB_TMP_POLICY_RENTFEE_COND SET POLICY_EXPR = POLICY_NAME||'
  local m_userStateMarker1 = RC_USER_STATES_MARKER(p,"'|| STATUS_DESC1 ||'")
  local m_userStateMarker2 = RC_USER_STATES_MARKER2(p,"'|| STATUS_DESC2 ||'")
  local m_calc_marker = RC_STS_OR_MARKER(p,m_userStateMarker1,m_userStateMarker2)
  local m_calc_day=RC_MARKER_DAY(p,m_calc_marker)
  return m_calc_day

' WHERE STATUS_DESC1 IS NOT NULL AND STATUS_DESC2 IS NOT NULL;
-----------------------------------------2-------------------------------------------
UPDATE VB_TMP_POLICY_RENTFEE_COND SET POLICY_NAME = '--服务状态为'||STATUS_DESC1
 WHERE STATUS_DESC1 IS NOT NULL AND STATUS_DESC2 IS NULL;
UPDATE VB_TMP_POLICY_RENTFEE_COND SET POLICY_EXPR = POLICY_NAME||'
  local m_userStateMarker1 = RC_USER_STATES_MARKER(p,"'|| STATUS_DESC1 ||'")
  local m_calc_day=RC_MARKER_DAY(p,m_userStateMarker1)
  return m_calc_day

' WHERE STATUS_DESC1 IS NOT NULL AND STATUS_DESC2 IS NULL;

--------------停机保号费补刀----------------
insert into VB_TMP_POLICY_RENTFEE_COND (POLICY_NAME,POLICY_ID,POLICY_EXPR)
  select '停机保号状态条件',max(policy_id)+1,'
--0\6\9三个状态的优先级高于1状态   当前子账期处于1状态时才收取停机保号费
local mark_sts0 = RC_USER_STATES_MARKER(p,"1000000000")  --开通
local mark_sts6 = RC_USER_STATES_MARKER(p,"1200000006")  --申请销号
local mark_sts9 = RC_USER_STATES_MARKER(p,"1200000009")  --欠费销号
local mark_sts1 = RC_USER_STATES_MARKER(p,"1200000001")  --申请停机
if RC_MARKER_DAY(p,mark_sts0) > 0 or RC_MARKER_DAY(p,mark_sts6) > 0 or RC_MARKER_DAY(p,mark_sts9) > 0 then
	return 0
end
if RC_MARKER_DAY(p,mark_sts1) > 0 then
	return 1
end
return 0
  ' from VB_TMP_POLICY_RENTFEE_COND;

--两种policy_id填值
update NG_TMP_RC_FEEDTL a set policy_status_id = 
(select policy_id from VB_TMP_POLICY_RENTFEE_COND b
  where nvl(a.valid_change_flag,0) = nvl(b.valid_change_flag,0)
    and nvl(a.status_desc1,0) = nvl(b.status_desc1,0)
    and nvl(a.status_desc2,0) = nvl(b.status_desc2,0)
    and nvl(a.status_desc3,0) = nvl(b.status_desc3,0)
);

   BEGIN
        --NG2VB固费中间表
        EXECUTE IMMEDIATE 'truncate table VB_PM_PRODUCT_OFFERING';
        insert into VB_PM_PRODUCT_OFFERING
                  (PRODUCT_OFFERING_ID,FEEPOLICY_ID,FIRST_EFFECT,SERV_ID,EVENT_PRIORITY,EVENT_TYPE_ID,
                   COND_ID,CYCLE_TYPE_ID,ITEM_CODE,PRICE_ID,PRICE_NAME,
                   RATE_ID,RATE_NAME,SUMTOINT_TYPE,DAY_FEE,CYCLE_FEE,OFFERING_NAME,USER_MARKER_ID,EXPR_ID)
        select distinct a.product_offering_id,a.feepolicy_id,a.first_effect,a.serv_id,a.event_priority,a.event_type_id,
               a.cond_id,a.cycle_type_id,c.item_code,a.price_id,e.price_name,
               '','',a.sumtoint_type,b.unit_ratio,a.sumtoint_fee,d.discnt_name,b.policy_status_id,b.policy_cond_id
          from NG_TMP_FEEPOLOICY a,NG_TMP_RC_FEEDTL b,NG_TD_B_CYCLEFEE_RULE c,td_b_discnt d,td_b_price e
         where a.price_id=b.price_id and c.event_type_id=a.event_type_id and a.feepolicy_id = d.discnt_code and a.price_id = e.price_id
        order by 1;
        update VB_PM_PRODUCT_OFFERING set new_price_id = 600000000+ROWNUM;
        --按月收费 00/05 的   是从FEECOUNT表里取到的费用作为整月费用   这里强制更新一下--
        update VB_PM_PRODUCT_OFFERING set CYCLE_FEE = DAY_FEE where cycle_type_id = 8 and sumtoint_type in ('00','05');
        COMMIT;
        --压缩固定费收费规则
        EXECUTE IMMEDIATE 'truncate table VB_FEECOUNT_DEF';
        insert into VB_FEECOUNT_DEF 
        select 70000000+ROWNUM,decode(cycle_type_id,4,'按天收取'||day_fee/1000||'元',7,'按半月收取'||day_fee/1000||'元',8,'按月收取'||cycle_fee/1000||'元'),first_effect,
               cycle_type_id,sumtoint_type,day_fee,cycle_fee 
          from (select distinct cycle_type_id,sumtoint_type,first_effect,day_fee,cycle_fee from VB_PM_PRODUCT_OFFERING);
        COMMIT;
        --RATE_ID填值，类似FEECOUNT_ID
        update VB_PM_PRODUCT_OFFERING a set rate_id = 
        (select vb_rate_id from VB_FEECOUNT_DEF b 
          where a.cycle_type_id = b.cycle_type_id and a.sumtoint_type = b.sumtoint_type
            and a.day_fee = b.day_fee and a.cycle_fee = b.cycle_fee and a.first_effect = b.first_effect);
        --RATE_NAME填值
        update VB_PM_PRODUCT_OFFERING a set rate_name = 
        (select vb_rate_name from VB_FEECOUNT_DEF b 
          where a.rate_id = b.vb_rate_id);
        COMMIT;
        
        --停机保号费按月收取  特殊处理
        update VB_PM_PRODUCT_OFFERING set rate_id = rate_id+1000 where item_code = 10004;
        
        --从固费临时表中删除不判状态的0资费  99999993需要收费，要配置成优惠--
        insert into VB_PM_PRODUCT_OFFERING_invalid select * from VB_PM_PRODUCT_OFFERING where user_marker_id is null;
        delete from VB_PM_PRODUCT_OFFERING where user_marker_id is null;
        COMMIT;
        
        --删除0费用
        delete from VB_PM_PRODUCT_OFFERING a 
         where a.day_fee='0' and (a.feepolicy_id,a.price_id,a.event_type_id) in 
          (select feepolicy_id,price_id,event_type_id from VB_PM_PRODUCT_OFFERING group by feepolicy_id,price_id,event_type_id having count(1) > 1 );
        commit;

    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
		       v_errcode := SQLCODE;
		       v_errmsg := 'VB_PM_PRODUCT_OFFERING err!:'||substr(SQLERRM,1,200);
		       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_errcode,v_errmsg,sysdate);
           RETURN;
    END; 
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       v_errcode := SQLCODE;
       v_errmsg := 'P_NG_TMP_PARAM_SERV_PRE err!:'||substr(SQLERRM,1,200);
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_errcode,v_errmsg,sysdate);
END;
/


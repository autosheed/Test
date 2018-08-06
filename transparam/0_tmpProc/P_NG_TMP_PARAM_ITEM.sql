CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_ITEM
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
-----------------------------------------------------
--VerisBilling参数割接使用
--倒换科目信息
-----------------------------------------------------
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_ITEM 过程执行成功!';

--NG                          VB
--td_b_item                   pm_price_event 
--td_b_compitem               pm_accumulate_item_rel ,pm_accumulate_item_def(组合定义)
--td_b_detailitem             pm_price_event
    BEGIN
      delete from pd.pm_price_event where item_id between 10000 and 100000;
      delete from pd.pm_accumulate_item_def where accumulate_item between 10000 and 100000;
      delete from pd.pm_accumulate_item_rel where accumulate_item between 10000 and 100000;
      delete from tmp_valid_compitem4deduct;
      commit;
      
      --在临时表里补上
      insert into NG_TD_B_COMPITEM(ITEM_ID,SUB_ITEM_ID,SUB_ITEM_NO,REMARK)
       select 49999,item_id,0,'总费用科目缺失子科目' from ng_td_b_detailitem
        where item_use_type = '0' and item_id not in (select sub_item_id from ng_td_b_compitem where item_id = 49999) and item_id like '1%';

      insert into NG_TD_B_ITEM(ITEM_ID,ITEM_NAME,ITEM_TYPE,ITEM_USE_TYPE,START_CYCLE_ID,END_CYCLE_ID)
      select distinct item_id,'组合科目(未配置在NG_TD_B_ITEM里)','0','0','198001','205001' from td_b_compitem
       where item_id not in (select item_id from td_b_item);
      update NG_td_b_item set item_type = '0' where item_type = '4';  --配置不规范，修改临时表
      --组合科目被定义为明细科目，在临时表中修改。
      update ng_td_b_item set item_type = '0'         
       where item_id in 
      (
      select distinct item_id from td_b_compitem 
       where item_id in (select item_id from td_b_item where item_type = '1')
      );
      
      DELETE FROM  ucr_param.NG_TD_B_COMPITEM a
			WHERE NOT EXISTS 
			(SELECT 1 FROM ucr_param.NG_TD_B_DETAILITEM b
			WHERE b.ITEM_ID=a.sub_ITEM_ID AND b.ITEM_USE_TYPE='0' );
			commit;
      
      --导入优惠使用的科目
      insert into tmp_valid_compitem4deduct
        select item_id from NG_td_b_item where item_type = '0';-- and item_use_type = '0';  青海该表配置不规范

         --科目定义（总）
         --虚科目导入(NG无校验从组合科目表导入导入)
      MERGE INTO  pd.pm_price_event  a
      USING (SELECT distinct item_id,item_name from NG_TD_B_ITEM 
               where item_type = '0' 
                 and item_id in (select item_id from tmp_valid_compitem4deduct)  ) b    --跟勇哥确认，以item表为准
      ON(a.ITEM_ID = b.ITEM_ID ) 
      WHEN NOT MATCHED THEN 
      INSERT(a.ITEM_ID, a.NAME, a.SERVICE_SPEC_ID, a.ITEM_TYPE, a.SUB_TYPE, a.PRIORITY, a.DESCRIPTION)             
      VALUES (b.ITEM_ID,b.item_name,0,7,0,0,'VB组合科目导入');

         --实科目导入（只导入有效的费用科目）
      MERGE INTO  pd.pm_price_event  a
      USING (select distinct j.item_id item_id,j.item_name item_name
         from ng_td_b_item j            
         where j.item_type='1'     
         and EXISTS(SELECT 1 FROM NG_TD_B_DETAILITEM k WHERE j.item_id=k.item_id and k.item_use_type = 0)) b   --仅导需要下账的科目
      ON(a.ITEM_ID = b.ITEM_ID ) 
      WHEN NOT MATCHED THEN 
      INSERT(a.ITEM_ID, a.NAME, a.SERVICE_SPEC_ID, a.ITEM_TYPE, a.SUB_TYPE, a.PRIORITY, a.DESCRIPTION)             
      VALUES (b.ITEM_ID,b.item_name,0,9,0,0,b.item_name);  --默认为  9 - 账务科目（国内使用，与计费科目映射）
      
      MERGE INTO  pd.pm_price_event  a
      USING (SELECT item_id,item_name FROM ucr_param.NG_TD_B_DETAILITEM t 
             WHERE item_use_type='0' AND NOT EXISTS 
							(SELECT 1 FROM NG_TD_B_ITEM j
							WHERE t.ITEM_ID=j.ITEM_ID)) b   --仅导需要下账的科目
      ON(a.ITEM_ID = b.ITEM_ID ) 
      WHEN NOT MATCHED THEN 
      INSERT(a.ITEM_ID, a.NAME, a.SERVICE_SPEC_ID, a.ITEM_TYPE, a.SUB_TYPE, a.PRIORITY, a.DESCRIPTION)             
      VALUES (b.ITEM_ID,nvl(b.item_name,'无名~'),0,9,0,0,b.item_name); 
      
      --更新固费科目标记  2－周期费事件科目;(Recurring Usage)
      update pd.pm_price_event a set ITEM_TYPE = 2
      where item_id in (select distinct item_code from td_b_cyclefee_rule)
        and item_id between 10000 and 100000;

      --资费选取方式(全选) 青海没有，不需要执行。
/*      update pd.pm_price_event set rc_price_type = '1'
       where item_id in (
      select item_code from td_b_cyclefee_rule where event_type_id in (
      select value_n from td_b_sysparam where sys_param_code like 'RENTFEE_POLICY_SORTTAG')
      );*/
      
      --虚科目定义
      MERGE INTO pd.pm_accumulate_item_def  a
      USING (select distinct item_id,item_name from NG_TD_B_ITEM 
               where item_type = '0'
                 and item_id in (select item_id from tmp_valid_compitem4deduct)) b 
      ON(a.ACCUMULATE_ITEM = b.ITEM_ID ) 
      WHEN NOT MATCHED THEN 
      INSERT(a.ACCUMULATE_ITEM, a.NAME, a.ACCUMULATE_CLASS, a.ACCUMULATE_TYPE, a.ACCUMULATE_USE, a.DEPEND_FREERES_ITEM, a.DEPEND_PROD_FLAG, a.MULTIPLEX_FLAG, a.MEASURE_ID, a.SEG_ID, a.DESCRIPTION)             
      VALUES (b.ITEM_ID,b.item_name,-1,2,0,'',0,0,10403,0,'VB组合科目导入');

       --虚实科目关联
      MERGE INTO pd.pm_accumulate_item_rel  a
      USING (select item_id item_id,sub_item_id sub_item_id,sub_item_no sub_item_no from NG_TD_B_COMPITEM
                 where item_id in (select item_id from tmp_valid_compitem4deduct) ) b 
      ON(a.ACCUMULATE_ITEM = b.ITEM_ID ) 
      WHEN NOT MATCHED THEN 
      INSERT(a.ACCUMULATE_ITEM, a.ITEM_ID, a.POLICY_ID, a.CAL_TYPE, a.EXT_BILL_ITEM, a.PRIORITY)             
      VALUES (b.item_id,b.sub_item_id,0,0,b.sub_item_id,1000-b.sub_item_no);
         
      EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='P_NG_TMP_PARAM_ITEM err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;    
    COMMIT;
    
    --删除流量科目
    --先不删除，青海捞出来的effect_object_id有费用科目，等比对时再确认！！！@20170705
/*    DELETE FROM pd.pm_accumulate_item_rel a
		WHERE ACCUMULATE_ITEM IN 
		(SELECT DISTINCT effect_object_id FROM ucr_param.td_b_feediscnt WHERE compute_method='8');
    
    DELETE FROM pd.pm_accumulate_item_def a
		WHERE ACCUMULATE_ITEM IN 
		(SELECT DISTINCT effect_object_id FROM ucr_param.td_b_feediscnt WHERE compute_method='8');
		
    DELETE FROM pd.PM_PRICE_EVENT a
    WHERE item_id IN 
    (SELECT DISTINCT effect_object_id FROM ucr_param.td_b_feediscnt WHERE compute_method='8');
    COMMIT;*/
    
    --add by liyu6
    update pd.PM_PRICE_EVENT a set a.owe_tag = 0;
    update pd.PM_PRICE_EVENT a set a.owe_tag = 1
      where a.item_id in (select c.item_id from pd.PM_PRICE_EVENT b, ucr_param.NG_TD_B_DETAILITEM c where b.item_id = c.item_id and c.owe_tag = 1);   
    
    --根据账管提供的付费规则，配置18个集团分账科目
    delete from tmp_detach_item;
    COMMIT;
    insert into tmp_detach_item (compitem_id,subitem_id)
    SELECT a.NOTE_ITEM_CODE payitem,c.NOTE_ITEM_CODE subitem FROM
    (SELECT note_item_code,parent_item_code FROM ucr_param.TD_B_NOTEITEM WHERE templet_code=80000000 AND print_level=0) a,
    (SELECT note_item_code,parent_item_code FROM ucr_param.TD_B_NOTEITEM WHERE templet_code=80000000 AND print_level=1) b,
    (SELECT note_item_code,parent_item_code FROM ucr_param.TD_B_NOTEITEM WHERE templet_code=80000000 AND print_level=2) c
    WHERE a.NOTE_ITEM_CODE=b.PARENT_ITEM_CODE AND b.NOTE_ITEM_CODE=c.PARENT_ITEM_CODE
    ORDER BY 1,2;
    COMMIT;
    --删除不下账的明细科目
    delete from tmp_detach_item 
     where subitem_id not in (select item_id from NG_TD_B_DETAILITEM a where a.item_use_type = '0');
    COMMIT;

    --分账强制补足科目(与局方确认)
    insert into pd.pm_price_event (item_id,name,service_spec_id,item_type,sub_type,priority,description,owe_tag,rc_price_type)
    values (10388,'分账强制补足',0,9,0,0,'分账强制补足',1,0);
    --负费用调零科目
    insert into pd.pm_price_event (item_id,name,service_spec_id,item_type,sub_type,priority,description,owe_tag,rc_price_type)
    values (80000,'负费用调零科目',0,9,0,0,'负费用调零科目',1,0);
    
    --省内流量统付
    insert into pd.pm_price_event (item_id,name,service_spec_id,item_type,sub_type,priority,description,owe_tag,rc_price_type)
    values (16401,'省内流量统付',0,9,0,0,'省内流量统付',1,0);
    COMMIT;
    
    -----新增不下账科目-----
    INSERT INTO pd.pm_price_event
    (item_id,name,service_spec_id,item_type,
    sub_type,priority,description,owe_tag,rc_price_type,fee_type)
    SELECT item_id,'计费不下账科目',0,'1',
           0,0,'计费不下账科目','1','0','1'
     FROM 
    (select distinct a.child_item item_id from pd.pm_bill_items_cvt_rule a 
    minus
    select b.item_id from pd.pm_price_event b);
    
    delete from pd.pm_price_event where item_id = 20000;
    delete from pd.pm_accumulate_item_def a where a.accumulate_item = 20000;
    INSERT INTO pd.pm_price_event
    (item_id,name,service_spec_id,item_type,
    sub_type,priority,description,owe_tag,rc_price_type,fee_type)
    SELECT 20000,'计费不下账科目',0,'1',
           0,0,'计费不下账科目','1','0','1'
    FROM DUAL;
    update pd.pm_price_event set item_type = '1' where fee_type = '1';
    COMMIT;
    
    --notify by gaojf
     update pd.pm_price_event a
        set event_type =
            (select max(eventype)
               from ucr_param.td_b_sumbill b
              where a.item_id = b.item_id)
      where exists
      (select 1 from ucr_param.td_b_sumbill c where a.item_id = c.item_id);
    
EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:='ITEM err !!!'||substr(SQLERRM,1,200);
       v_resultcode:='-1';
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
END;
/


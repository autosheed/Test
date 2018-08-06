CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_ITEM
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
-----------------------------------------------------
--VerisBilling�������ʹ��
--������Ŀ��Ϣ
-----------------------------------------------------
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_ITEM ����ִ�гɹ�!';

--NG                          VB
--td_b_item                   pm_price_event 
--td_b_compitem               pm_accumulate_item_rel ,pm_accumulate_item_def(��϶���)
--td_b_detailitem             pm_price_event
    BEGIN
      delete from pd.pm_price_event where item_id between 10000 and 100000;
      delete from pd.pm_accumulate_item_def where accumulate_item between 10000 and 100000;
      delete from pd.pm_accumulate_item_rel where accumulate_item between 10000 and 100000;
      delete from tmp_valid_compitem4deduct;
      commit;
      
      --����ʱ���ﲹ��
      insert into NG_TD_B_COMPITEM(ITEM_ID,SUB_ITEM_ID,SUB_ITEM_NO,REMARK)
       select 49999,item_id,0,'�ܷ��ÿ�Ŀȱʧ�ӿ�Ŀ' from ng_td_b_detailitem
        where item_use_type = '0' and item_id not in (select sub_item_id from ng_td_b_compitem where item_id = 49999) and item_id like '1%';

      insert into NG_TD_B_ITEM(ITEM_ID,ITEM_NAME,ITEM_TYPE,ITEM_USE_TYPE,START_CYCLE_ID,END_CYCLE_ID)
      select distinct item_id,'��Ͽ�Ŀ(δ������NG_TD_B_ITEM��)','0','0','198001','205001' from td_b_compitem
       where item_id not in (select item_id from td_b_item);
      update NG_td_b_item set item_type = '0' where item_type = '4';  --���ò��淶���޸���ʱ��
      --��Ͽ�Ŀ������Ϊ��ϸ��Ŀ������ʱ�����޸ġ�
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
      
      --�����Ż�ʹ�õĿ�Ŀ
      insert into tmp_valid_compitem4deduct
        select item_id from NG_td_b_item where item_type = '0';-- and item_use_type = '0';  �ຣ�ñ����ò��淶

         --��Ŀ���壨�ܣ�
         --���Ŀ����(NG��У�����Ͽ�Ŀ���뵼��)
      MERGE INTO  pd.pm_price_event  a
      USING (SELECT distinct item_id,item_name from NG_TD_B_ITEM 
               where item_type = '0' 
                 and item_id in (select item_id from tmp_valid_compitem4deduct)  ) b    --���¸�ȷ�ϣ���item��Ϊ׼
      ON(a.ITEM_ID = b.ITEM_ID ) 
      WHEN NOT MATCHED THEN 
      INSERT(a.ITEM_ID, a.NAME, a.SERVICE_SPEC_ID, a.ITEM_TYPE, a.SUB_TYPE, a.PRIORITY, a.DESCRIPTION)             
      VALUES (b.ITEM_ID,b.item_name,0,7,0,0,'VB��Ͽ�Ŀ����');

         --ʵ��Ŀ���루ֻ������Ч�ķ��ÿ�Ŀ��
      MERGE INTO  pd.pm_price_event  a
      USING (select distinct j.item_id item_id,j.item_name item_name
         from ng_td_b_item j            
         where j.item_type='1'     
         and EXISTS(SELECT 1 FROM NG_TD_B_DETAILITEM k WHERE j.item_id=k.item_id and k.item_use_type = 0)) b   --������Ҫ���˵Ŀ�Ŀ
      ON(a.ITEM_ID = b.ITEM_ID ) 
      WHEN NOT MATCHED THEN 
      INSERT(a.ITEM_ID, a.NAME, a.SERVICE_SPEC_ID, a.ITEM_TYPE, a.SUB_TYPE, a.PRIORITY, a.DESCRIPTION)             
      VALUES (b.ITEM_ID,b.item_name,0,9,0,0,b.item_name);  --Ĭ��Ϊ  9 - �����Ŀ������ʹ�ã���Ʒѿ�Ŀӳ�䣩
      
      MERGE INTO  pd.pm_price_event  a
      USING (SELECT item_id,item_name FROM ucr_param.NG_TD_B_DETAILITEM t 
             WHERE item_use_type='0' AND NOT EXISTS 
							(SELECT 1 FROM NG_TD_B_ITEM j
							WHERE t.ITEM_ID=j.ITEM_ID)) b   --������Ҫ���˵Ŀ�Ŀ
      ON(a.ITEM_ID = b.ITEM_ID ) 
      WHEN NOT MATCHED THEN 
      INSERT(a.ITEM_ID, a.NAME, a.SERVICE_SPEC_ID, a.ITEM_TYPE, a.SUB_TYPE, a.PRIORITY, a.DESCRIPTION)             
      VALUES (b.ITEM_ID,nvl(b.item_name,'����~'),0,9,0,0,b.item_name); 
      
      --���¹̷ѿ�Ŀ���  2�����ڷ��¼���Ŀ;(Recurring Usage)
      update pd.pm_price_event a set ITEM_TYPE = 2
      where item_id in (select distinct item_code from td_b_cyclefee_rule)
        and item_id between 10000 and 100000;

      --�ʷ�ѡȡ��ʽ(ȫѡ) �ຣû�У�����Ҫִ�С�
/*      update pd.pm_price_event set rc_price_type = '1'
       where item_id in (
      select item_code from td_b_cyclefee_rule where event_type_id in (
      select value_n from td_b_sysparam where sys_param_code like 'RENTFEE_POLICY_SORTTAG')
      );*/
      
      --���Ŀ����
      MERGE INTO pd.pm_accumulate_item_def  a
      USING (select distinct item_id,item_name from NG_TD_B_ITEM 
               where item_type = '0'
                 and item_id in (select item_id from tmp_valid_compitem4deduct)) b 
      ON(a.ACCUMULATE_ITEM = b.ITEM_ID ) 
      WHEN NOT MATCHED THEN 
      INSERT(a.ACCUMULATE_ITEM, a.NAME, a.ACCUMULATE_CLASS, a.ACCUMULATE_TYPE, a.ACCUMULATE_USE, a.DEPEND_FREERES_ITEM, a.DEPEND_PROD_FLAG, a.MULTIPLEX_FLAG, a.MEASURE_ID, a.SEG_ID, a.DESCRIPTION)             
      VALUES (b.ITEM_ID,b.item_name,-1,2,0,'',0,0,10403,0,'VB��Ͽ�Ŀ����');

       --��ʵ��Ŀ����
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
    
    --ɾ��������Ŀ
    --�Ȳ�ɾ�����ຣ�̳�����effect_object_id�з��ÿ�Ŀ���ȱȶ�ʱ��ȷ�ϣ�����@20170705
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
    
    --�����˹��ṩ�ĸ��ѹ�������18�����ŷ��˿�Ŀ
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
    --ɾ�������˵���ϸ��Ŀ
    delete from tmp_detach_item 
     where subitem_id not in (select item_id from NG_TD_B_DETAILITEM a where a.item_use_type = '0');
    COMMIT;

    --����ǿ�Ʋ����Ŀ(��ַ�ȷ��)
    insert into pd.pm_price_event (item_id,name,service_spec_id,item_type,sub_type,priority,description,owe_tag,rc_price_type)
    values (10388,'����ǿ�Ʋ���',0,9,0,0,'����ǿ�Ʋ���',1,0);
    --�����õ����Ŀ
    insert into pd.pm_price_event (item_id,name,service_spec_id,item_type,sub_type,priority,description,owe_tag,rc_price_type)
    values (80000,'�����õ����Ŀ',0,9,0,0,'�����õ����Ŀ',1,0);
    
    --ʡ������ͳ��
    insert into pd.pm_price_event (item_id,name,service_spec_id,item_type,sub_type,priority,description,owe_tag,rc_price_type)
    values (16401,'ʡ������ͳ��',0,9,0,0,'ʡ������ͳ��',1,0);
    COMMIT;
    
    -----���������˿�Ŀ-----
    INSERT INTO pd.pm_price_event
    (item_id,name,service_spec_id,item_type,
    sub_type,priority,description,owe_tag,rc_price_type,fee_type)
    SELECT item_id,'�ƷѲ����˿�Ŀ',0,'1',
           0,0,'�ƷѲ����˿�Ŀ','1','0','1'
     FROM 
    (select distinct a.child_item item_id from pd.pm_bill_items_cvt_rule a 
    minus
    select b.item_id from pd.pm_price_event b);
    
    delete from pd.pm_price_event where item_id = 20000;
    delete from pd.pm_accumulate_item_def a where a.accumulate_item = 20000;
    INSERT INTO pd.pm_price_event
    (item_id,name,service_spec_id,item_type,
    sub_type,priority,description,owe_tag,rc_price_type,fee_type)
    SELECT 20000,'�ƷѲ����˿�Ŀ',0,'1',
           0,0,'�ƷѲ����˿�Ŀ','1','0','1'
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


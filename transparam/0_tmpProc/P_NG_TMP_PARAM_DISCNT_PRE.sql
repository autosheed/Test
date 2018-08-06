CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_DISCNT_PRE
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
-----------------------------------------------------
--VerisBilling参数割接使用
--优惠参数倒换预处理,包含资费生成中间表
-----------------------------------------------------
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_DISCNT_PRE 过程执行成功！';

    --NG_TMP_FEEPOLOICY
    BEGIN
      update NG_TD_B_DISCNT set rsrv_str5 = '1' where discnt_code = 99941710;  --一卡多号业务上线以后要通过优惠收取。  lipf
      delete from NG_TMP_FEEPOLOICY where type  = '3';
      insert into NG_TMP_FEEPOLOICY
      (product_offering_id,feepolicy_id,FEEPOLICY_COMP_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,DISCNT_TYPE,REPEAT_TYPE,FIRST_EFFECT,
       EVENT_TYPE_ID,PRICE_ID,TYPE)
      SELECT DISTINCT d.discnt_code,a.feepolicy_id,a.feepolicy_comp_id,a.event_priority,A.EFFECT_ROLE_CODE,
             '0',NVL(D.RSRV_STR4,'0'),NVL(D.RSRV_STR3,'0'),
             a.EVENT_TYPE_ID,C.PRICE_ID,'3'
       FROM NG_TD_B_FEEPOLICY_COMP a,NG_TD_B_EVENT_FEEPOLICY b,NG_TD_B_PRICE_COMP c,
            NG_TD_B_DISCNT D
      WHERE a.event_type_id IN(22,23)--只提取用户优惠
        AND a.event_feepolicy_id=b.event_feepolicy_id
        AND b.price_id=c.PRICE_ID
        AND a.feepolicy_id=d.B_DISCNT_CODE
        AND d.End_Date>SYSDATE-90  --只倒换生效的资费
        AND d.rsrv_str5 in ('1','3')
      ORDER BY 1,2;

    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='NG_TMP_FEEPOLOICY err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;
    commit;
    
    /*流量日租包处理  由于流量日租包资费包含普通的补收处理，所以需要提前整理*/
    delete from NG_TMP_DAYGPRS_TP;
    COMMIT;
    --参考免费资源收费
    --feepolicy_type 6:用户订购日租卡，未使用不收费，使用后，循环叠加收费。
    -----------------8:只要用户订购日租卡，不管是否使用，要收取基础档的费用，超过500M以后，循环叠加收费。
    insert into NG_TMP_DAYGPRS_TP
    select a.discnt_name,a.discnt_code,decode(e.compute_method,'27',6,'28',8),810001000+rownum,810001000+rownum,50000482,e.compute_object_id,16015,e.discnt_fee,e.base_fee
     from td_b_discnt a , td_b_feepolicy_comp b , td_b_event_feepolicy c , td_b_price_comp d , td_b_feediscnt e 
    where a.discnt_code = b.feepolicy_id and b.event_feepolicy_id = c.event_feepolicy_id
      and c.price_id = d.price_id and d.exec_type = '3'
      and d.exec_id = e.feediscnt_id and e.compute_object_id = 59354;
    --update NG_TMP_DAYGPRS_TP a set expr_id = (select policy_id from zhangjt_cond b where a.expr_id = b.cond_id);
    update NG_TMP_DAYGPRS_TP a set a.addup_item = 
     (select b.item_code from pd.jf_discnt_exp_rela b where a.feepolicy_id = b.feepolicy_id and a.addup_item = b.addup_id);
    commit;
    --标记出所有流量日租包资费
    update NG_TMP_FEEPOLOICY set is_daygprstp = '1' where feepolicy_id in (select feepolicy_id from NG_TMP_DAYGPRS_TP);
    COMMIT;

    BEGIN
        p_zhangjt_getDiscntPrice(v_resultCode,v_resultErrInfo);  --解析PRICE_COMP   时耗较长  insert into NG_TMP_PRICE_DISCNT
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_zhangjt_getDiscntPrice call error'||SQLERRM;
            insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
            RETURN;
    END;
----青海资费树中，作用节点并非叶子节点(作用节点下挂了条件节点)，以下几个price_id，手工梳理  BEGIN
delete from NG_TMP_PRICE_DISCNT where price_id in (60019357,60022913,60022921,60021071);   --60022913,60022921  现网已修复
--1--
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60019357,1,'50000482|50000003|50000465',60020478);
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60019357,2,'50000482|50000003|50000465|50000525',60020479);
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60019357,3,'50000482|50000003|50000466',60019358);
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60019357,4,'50000482|50000004',60019358);
--2--
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60022913,1,'50000482|50000003',60022915);
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60022913,2,'50000482|50000004',60022916);
--3--
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60022921,1,'50000482|50000003',60022919);
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60022921,2,'50000482|50000004',60022920);
--4--
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60021071,1,'50000482',60021072);
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60021071,2,'50000482',60021073);
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60021071,3,'50000482|50001033',60022936);
insert into NG_TMP_PRICE_DISCNT(PRICE_ID,ORDER_NO,COND_IDS,EXEC_ID) values (60021071,4,'50000482|50001034',60022936);
----青海资费树中，作用节点并非叶子节点，以下几个price_id，手工梳理  END    

/*--梳理铁通宽带年包及跨月保底资费信息
ng_tmp_tpinfo_addupbaodi
ng_tmp_tpinfo_ttlan
*/    
    BEGIN
        P_NG_TMP_PARAM_ADDUPSPEC(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_ADDUPSPEC call error'||SQLERRM;
            insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
            RETURN;
    END;
/*--解析条件
zhangjt_cond
zhangjt_simplecond
*/
    BEGIN
        p_zhangjt_updateparam_cond(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_zhangjt_updateparam_cond call error'||SQLERRM;
            insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
            RETURN;
    END;
    --条件解析完以后才能更新
    update NG_TMP_DAYGPRS_TP a set expr_id = (select policy_id from zhangjt_cond b where a.expr_id = b.cond_id);

/*--解析FEEDISCNT  按优惠类型归类
GEYF_FEEDISCNT_free_fee     按金额减免
geyf_feediscnt_freelimit    费用全免，但不能超过限定额度
GEYF_FEEDISCNT_free_per     按比例减免
GEYF_FEEDISCNT_fengding     封顶
GEYF_FEEDISCNT_bs           补收
GEYF_FEEDISCNT_baodi        保底
GEYF_FEEDISCNT_SMS          扣费提醒
GEYF_FEEDISCNT_bs_group     根据群下用户数收费
GEYF_FEEDISCNT_REFEE_LIMIT    超过参考值的部分进行限定减免
GEYF_FEEDISCNT_FIXED
*/
    BEGIN
        p_geyf_userdiscnt_price(v_resultCode,v_resultErrInfo);  
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:p_geyf_userdiscnt_price call error'||SQLERRM;
            insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
            RETURN;
    END;

    --------------设置优惠方式标签-----------
/*    update NG_TMP_PRICE_DISCNT set remark = '按金额减免' , type = 'A' WHERE EXEC_ID IN (SELECT FEEDISCNT_ID FROM GEYF_FEEDISCNT_free_fee);
    update NG_TMP_PRICE_DISCNT set remark = '按比例减免' , type = 'B' WHERE EXEC_ID IN (SELECT FEEDISCNT_ID FROM GEYF_FEEDISCNT_free_per);
    update NG_TMP_PRICE_DISCNT set remark = '按配置金额补收' , type = 'C' WHERE EXEC_ID IN (SELECT FEEDISCNT_ID FROM GEYF_FEEDISCNT_bs);
    update NG_TMP_PRICE_DISCNT set remark = '按群组成员个数补收（CRM传参）' , type = 'D' WHERE EXEC_ID IN (SELECT FEEDISCNT_ID FROM GEYF_FEEDISCNT_bs_num);
    update NG_TMP_PRICE_DISCNT set remark = '按群组成员个数补收（UU关系）' , type = 'E' WHERE EXEC_ID IN (SELECT FEEDISCNT_ID FROM GEYF_FEEDISCNT_bs_group);
    update NG_TMP_PRICE_DISCNT set remark = '普通保底' , type = 'F' WHERE EXEC_ID IN (SELECT FEEDISCNT_ID FROM GEYF_FEEDISCNT_baodi);
    update NG_TMP_PRICE_DISCNT set remark = '封顶' , type = 'H' WHERE EXEC_ID IN (SELECT FEEDISCNT_ID FROM GEYF_FEEDISCNT_fengding);
    update NG_TMP_PRICE_DISCNT set remark = '费用全免，但不能超过限定额度' , type = 'I' WHERE EXEC_ID IN (SELECT FEEDISCNT_ID FROM geyf_feediscnt_freelimit);
    delete from NG_TMP_PRICE_DISCNT where EXEC_ID IN (SELECT FEEDISCNT_ID FROM GEYF_FEEDISCNT_SMS);
    commit;*/

    --把条件的名称填上
    delete from NG_TMP_COND_DESC where cond_type = '2';
    INSERT INTO NG_TMP_COND_DESC select cond_ids,sys_connect_by_path(policy_id,'&'),sys_connect_by_path(cond_name,'[&]'),'2'
    from
     (select b.cond_ids,a.policy_id,a.cond_name,row_number() over(partition by cond_ids order by a.cond_id,a.cond_name)rn,count(*) over(partition by b.cond_ids ) cnt from
       ZHANGJT_COND a,(select distinct cond_ids cond_ids from NG_TMP_PRICE_DISCNT) b
      where instr(b.cond_ids,a.cond_id) > 0) a
    where
      level=cnt start with rn=1 connect by prior cond_ids=cond_ids and prior rn=rn-1;
    COMMIT;

    UPDATE NG_TMP_PRICE_DISCNT a SET a.TRANS_COND_IDS =
    (select TRANS_COND_ID from NG_TMP_COND_DESC b where a.cond_ids = b.cond_ids and b.cond_type = '2');
    COMMIT;
    UPDATE NG_TMP_PRICE_DISCNT a SET a.COND_NAMES =
    (select b.cond_names from NG_TMP_COND_DESC b where a.cond_ids = b.cond_ids and b.cond_type = '2');
    COMMIT;
    UPDATE NG_TMP_PRICE_DISCNT
       SET TRANS_COND_IDS = SUBSTR(TRANS_COND_IDS, 2)
     WHERE TRANS_COND_IDS LIKE '&%';
    COMMIT;
    UPDATE NG_TMP_PRICE_DISCNT
       SET COND_NAMES = SUBSTR(COND_NAMES, 4)
     WHERE COND_NAMES LIKE '[&]%';
    COMMIT;

    -------*************生成NG_TMP_TP_DISCNT*************-------
    BEGIN
    DELETE FROM NG_TMP_TP_DISCNT;
    COMMIT;
/*
按金额减免
delete from GEYF_FEEDISCNT_free_fee;
按比例减免
DELETE FROM GEYF_FEEDISCNT_free_per;
--补收--
delete from GEYF_FEEDISCNT_bs;
--封顶--
delete from GEYF_FEEDISCNT_fengding;
--保底--
delete from GEYF_FEEDISCNT_baodi;
--扣费提醒--
delete from GEYF_FEEDISCNT_SMS;
--SPEC收费--
delete from GEYF_FEEDISCNT_bs_group;
费用全免，但不能超过限定额度
delete from geyf_feediscnt_freelimit;
超过参考值的部分进行限定减免
GEYF_FEEDISCNT_REFEE_LIMIT    
*/
    --按金额减免
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,FEE)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 B.ORDER_NO,B.TRANS_COND_IDS,B.COND_NAMES,B.EXEC_ID,'按金额减免','A',
                 C.ITEM_ID,C.FEE
            FROM NG_TMP_FEEPOLOICY A,NG_TMP_PRICE_DISCNT B,GEYF_FEEDISCNT_free_fee C
           WHERE a.TYPE='3'
             AND a.price_id=b.PRICE_ID AND b.EXEC_ID =c.FEEDISCNT_ID
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority,b.order_no;
    COMMIT;
    --按比例减免
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,DIVIED_CHILD_VALUE,DIVIED_PARENT_VALUE)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 B.ORDER_NO,B.TRANS_COND_IDS,B.COND_NAMES,B.EXEC_ID,'按比例减免','B',
                 C.ITEM_ID,C.DIVIED_CHILD_VALUE,C.DIVIED_PARENT_VALUE
            FROM NG_TMP_FEEPOLOICY A,NG_TMP_PRICE_DISCNT B,GEYF_FEEDISCNT_free_per C
           WHERE a.TYPE='3'
             AND a.price_id=b.PRICE_ID AND b.EXEC_ID =c.FEEDISCNT_ID
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority,b.order_no;
    COMMIT;
    --按配置金额补收
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,FEE)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 B.ORDER_NO,B.TRANS_COND_IDS,B.COND_NAMES,B.EXEC_ID,'按配置金额补收','C',
                 C.ITEM_ID,C.FEE
            FROM NG_TMP_FEEPOLOICY A,NG_TMP_PRICE_DISCNT B,GEYF_FEEDISCNT_bs C
           WHERE a.TYPE='3'
             AND a.price_id=b.PRICE_ID AND b.EXEC_ID =c.FEEDISCNT_ID
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority,b.order_no;
    COMMIT;
    --封顶
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,FEE)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 B.ORDER_NO,B.TRANS_COND_IDS,B.COND_NAMES,B.EXEC_ID,'封顶','D',
                 C.ITEM_ID,C.FEE
            FROM NG_TMP_FEEPOLOICY A,NG_TMP_PRICE_DISCNT B,GEYF_FEEDISCNT_FENGDING C
           WHERE a.TYPE='3'
             AND a.price_id=b.PRICE_ID AND b.EXEC_ID =c.FEEDISCNT_ID
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority,b.order_no;
    COMMIT;
    --普通保底
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,COMPUTE_OBJECT_ID,FEE)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 B.ORDER_NO,B.TRANS_COND_IDS,B.COND_NAMES,B.EXEC_ID,'按金额保底','E',
                 C.ITEM_ID,C.CANKAO_ITEM_ID,C.FEE
            FROM NG_TMP_FEEPOLOICY A,NG_TMP_PRICE_DISCNT B,GEYF_FEEDISCNT_baodi C
           WHERE a.TYPE='3'
             AND a.price_id=b.PRICE_ID AND b.EXEC_ID =c.FEEDISCNT_ID
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority,b.order_no;
    COMMIT;
    --按群组成员个数补收（UU关系）   (成员个数-BASE_NUM)*SINGLE_FEE+BASE_FEE
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,COMPUTE_OBJECT_ID,FEE,BASE_NUM,SINGLE_FEE)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 B.ORDER_NO,B.TRANS_COND_IDS,B.COND_NAMES,B.EXEC_ID,'LUA收费','F',
                 C.ITEM_ID,C.COMPUTE_OBJECT_ID,C.BASE_FEE FEE,C.BASE_NUM,C.SINGLE_FEE
            FROM NG_TMP_FEEPOLOICY A,NG_TMP_PRICE_DISCNT B,GEYF_FEEDISCNT_bs_group C
           WHERE a.TYPE='3'
             AND a.price_id=b.PRICE_ID AND b.EXEC_ID =c.FEEDISCNT_ID
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority,b.order_no;
    COMMIT;
    --累积保底
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,COMPUTE_OBJECT_ID,FEE,CYC_NUMS)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 '0',c.policy_id||'&'||d.policy_id,c.cond_name||'&'||d.cond_name,B.feediscnt_id,cycle_num||'个月最低消费','G' DISCNT_TYPE,
                 B.ITEM_ID,'49999',B.FEE,B.CYCLE_NUM
            FROM NG_TMP_FEEPOLOICY A,ng_tmp_tpinfo_addupbaodi b,zhangjt_cond c,zhangjt_cond d
           WHERE a.TYPE='3' and a.feepolicy_id = b.discnt_code
             AND a.price_id=b.PRICE_ID and b.cond_id1 = c.cond_id and b.cond_id2 = d.cond_id
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority;
     COMMIT;
    --费用全免，但不能超过限定额度   分析了一下，这个东西就是按金额减免，太绕了  向正式表灌的时候跟'A'合并
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,FEE)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 B.ORDER_NO,B.TRANS_COND_IDS,B.COND_NAMES,B.EXEC_ID,'费用全免，但不能超过限定额度','H',
                 C.ITEM_ID,C.limit_fee
            FROM NG_TMP_FEEPOLOICY A,NG_TMP_PRICE_DISCNT B,geyf_feediscnt_freelimit C
           WHERE a.TYPE='3'
             AND a.price_id=b.PRICE_ID AND b.EXEC_ID =c.FEEDISCNT_ID
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority,b.order_no;
    COMMIT;
    --宽带年包
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,FEE,SINGLE_FEE,CYC_NUMS)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 '0',C.POLICY_ID,C.Cond_Name,B.Yearfee_Exec,'宽带包年套餐','I' DISCNT_TYPE,
                 B.ITEM_ID,B.Year_Fee,b.day_fee,b.cycle_num
            FROM NG_TMP_FEEPOLOICY A,ng_tmp_tpinfo_ttlan B,zhangjt_cond C
           WHERE a.TYPE='3' and a.feepolicy_id = b.discnt_code 
             AND B.cond_id = C.cond_id
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority;
    COMMIT;
    --超过参考值的部分进行限定减免
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,COMPUTE_OBJECT_ID,DIVIED_CHILD_VALUE,DIVIED_PARENT_VALUE,SINGLE_FEE,FEE)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 B.ORDER_NO,B.TRANS_COND_IDS,B.COND_NAMES,B.EXEC_ID,'超过参考值的部分进行限定减免','Q' DISCNT_TYPE,
                 C.BASE_ITEM,C.EFFECT_ITEM,C.DIVIED_CHILD_VALUE,C.DIVIED_PARENT_VALUE,C.DISCNT_FEE,C.BASE_FEE
            FROM NG_TMP_FEEPOLOICY A,NG_TMP_PRICE_DISCNT B,GEYF_FEEDISCNT_REFEE_LIMIT C
           WHERE a.TYPE='3'
             AND a.price_id=b.PRICE_ID
             AND b.EXEC_ID =c.FEEDISCNT_ID
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority,b.order_no;
    COMMIT;
    --固定金额收费，多退少补
    INSERT INTO NG_TMP_TP_DISCNT
       (product_offering_id,FEEPOLICY_ID,EVENT_PRIORITY,EFFECT_ROLE_CODE,REPEAT_TYPE,FIRST_EFFECT,PRICE_ID,
        ORDER_NO,COND_IDS,COND_NAMES,EXEC_ID,REMARK,DISCNT_TYPE,
        ITEM_ID,FEE)
          SELECT A.product_offering_id,A.FEEPOLICY_ID,A.EVENT_PRIORITY,A.EFFECT_ROLE_CODE,A.REPEAT_TYPE,A.FIRST_EFFECT,A.PRICE_ID,
                 B.ORDER_NO,B.TRANS_COND_IDS,B.COND_NAMES,B.EXEC_ID,'固定金额收费，多退少补','R',
                 C.ITEM_ID,C.FEE
            FROM NG_TMP_FEEPOLOICY A,NG_TMP_PRICE_DISCNT B,GEYF_FEEDISCNT_FIXED C
           WHERE a.TYPE='3'
             AND a.price_id=b.PRICE_ID AND b.EXEC_ID =c.FEEDISCNT_ID
           ORDER BY a.feepolicy_id,A.PRICE_ID,a.event_priority,b.order_no;
    COMMIT;
    
    ---------区分出参数实例化-------
    update NG_TMP_TP_DISCNT set isparam = '0';
    update NG_TMP_TP_DISCNT set isparam = '1',param_id = substr(fee,2) where fee like '?%';
    update NG_TMP_TP_DISCNT set isparam = '1',param_id = substr(base_num,2) where base_num like '?%';

    -----------二次议价处理-----------
    --原值导入，不再映射--
/*    update NG_TMP_TP_DISCNT a set new_param_id =
      (select b.billing_param from pd.pm_billing_param_rela b 
        where b.param_type = '9' and a.feepolicy_id = trim(b.param_code) and a.param_id = trim(b.param_code_ext))
     where isparam = '1';*/
    update NG_TMP_TP_DISCNT a set new_param_id = param_id where isparam = '1';
     
    --二次议价实现
    update NG_TMP_TP_DISCNT set policy_expr = '--[按议价补收] KEY = ['||new_param_id||']
    function get_Numerator(_in_para1)
      if CALC_EXIST_PROD_PARAM(p,_in_para1) == 1 then
         return (CALC_PRODUCT_PARAM(p,_in_para1))
      else
         return 0
      end
    end

    return -get_Numerator('||new_param_id||')
    '
    where isparam = '1' and discnt_type = 'C';

    update NG_TMP_TP_DISCNT set policy_expr = '--[按议价保底] KEY = ['||new_param_id||']
    function get_Numerator(_in_para1)
      if CALC_EXIST_PROD_PARAM(p,_in_para1) == 1 then
         return (CALC_PRODUCT_PARAM(p,_in_para1))
      else
         return 0
      end
    end
    local discntFee = get_Numerator('||new_param_id||')
    local baseFee = PROM_BASE_FEE(p)

    if(baseFee < discntFee) then
       return baseFee-discntFee
    end
    return 0
    '
    where isparam = '1' and discnt_type = 'E';
    
    update NG_TMP_TP_DISCNT set policy_expr = '--[按议价定额收费，多退少补] KEY = ['||new_param_id||']
    function get_Numerator(_in_para1)
      if CALC_EXIST_PROD_PARAM(p,_in_para1) == 1 then
         return (CALC_PRODUCT_PARAM(p,_in_para1))
      else
         return 0
      end
    end
    local discntFee = get_Numerator('||new_param_id||')
    local baseFee = PROM_BASE_FEE(p)

    return baseFee - discntFee
    '
    where isparam = '1' and discnt_type = 'R';
    
    update NG_TMP_TP_DISCNT set policy_expr = '--[特殊议价] KEY = ['||new_param_id||']
    function get_Numerator(_in_para1)
      if CALC_EXIST_PROD_PARAM(p,_in_para1) == 1 then
         return (CALC_PRODUCT_PARAM(p,_in_para1))
      else
         return 0
      end
    end
    local num = get_Numerator('||new_param_id||')
    local baseFee = PROM_NUMERATOR(p)
    local singleFee = PROM_START_VAL(p)
    
    return -1*(num*singleFee - baseFee)
    '
    where isparam = '1' and discnt_type = 'F';

/*-----------暂时没有实现方案，挂起--------   TB已在陕西修改！
    update NG_TMP_TP_DISCNT set policy_expr = '--[按议价累积保底] KEY = ['||new_param_id||']
    function get_Numerator(_in_para1)
      if CALC_EXIST_PROD_PARAM(p,_in_para1) == 1 then
         return (CALC_PRODUCT_PARAM(p,_in_para1))
      else
         return 0
      end
    end
    local discntFee = get_Numerator('||new_param_id||')
    local baseFee = PROM_BASE_FEE(p)

    if(baseFee < discntFee) then
       return baseFee-discntFee
    end
    return 0
    '
    where isparam = '1' and discnt_type = 'G';
*/

/* OBJECTUSER实现 */
    update NG_TMP_TP_DISCNT set policy_expr = '--[按成员个数补收]
    local t_groupMemberNum = CALC_GOURP_MEMBER_BY_ROLEID(p,-1,-1)
    local t_baseNum = PROM_DENOMINATOR(p)
    local t_single_fee = PROM_START_VAL(p)
    local t_baseFee = PROM_NUMERATOR(p)

    return -1*((t_groupMemberNum-t_baseNum)*t_single_fee+t_baseFee)
    ' where isparam = '0' and discnt_type = 'F' and compute_object_id = 1031;

    --一卡多号业务，M201类型关系会导入UUREL中
    update NG_TMP_TP_DISCNT set policy_expr = '--[按成员个数补收]
    local t_groupMemberNum = CALC_GET_SHARE_MEMBERS(p,29,1)
    local t_baseNum = PROM_DENOMINATOR(p)
    local t_single_fee = PROM_START_VAL(p)
    local t_baseFee = PROM_NUMERATOR(p)

    return -1*((t_groupMemberNum-t_baseNum)*t_single_fee+t_baseFee)
    ' where compute_object_id = '1058';
    
    --个人多终端共享功能费收取（参考share_rel记录数收取的）--
    update NG_TMP_TP_DISCNT set cond_ids = (select policy_id from zhangjt_cond where cond_id = 50000482) , 
                                cond_names = (select cond_name from zhangjt_cond where cond_id = 50000482) , 
                                remark = '按共享关系补收功能费' , policy_expr = '
    return -1*CALC_GET_SHARE_MEMBERS(p,1502,0)*PROM_START_VAL(p)
    '
     where compute_object_id = '1057';

    --当月存在开机状态天数 0、N
    update NG_TMP_TP_DISCNT set policy_expr = '--[按当月存在开机状态天数补收，NG的0/N状态]
    local t_thisCycleValidDays = GET_VALIDDAYS_BYSTS(p,1000000000)
    local t_single_fee = PROM_START_VAL(p)
    return -1*(t_single_fee*t_thisCycleValidDays)
    ' where compute_object_id = '42210';

    --宽带年包
    update NG_TMP_TP_DISCNT set policy_expr = '--[宽带年包收费]
    local lastCycleAddupFee = GET_LAST_ADDUPSEPC_FEE(p)
    local yearFee = PROM_DENOMINATOR(p)
    local dayFee = PROM_NUMERATOR(p)
    local thisCycleValidDays = GET_VALIDDAYS_BYSTS(p,1000000000)
    local cycleDays = CALC_CYCLE_DAYS(p)

    local currFee = thisCycleValidDays * dayFee
    local remainFee = yearFee - lastCycleAddupFee
    if remainFee / dayFee > cycleDays then   --剩余费用这个月用不完
      return -currFee
    else
      if remainFee > currFee then
        return -currFee
      else
        return -remainFee-1   --最后一天多收一分钱，信控停机
      end
    end' where discnt_type = 'I';

    --生成二次议价表达式临时表
    delete from VB_TMP_POLICY_FEEDISCNT;
    COMMIT;
    insert into VB_TMP_POLICY_FEEDISCNT(policy_expr) select distinct policy_expr from NG_TMP_TP_DISCNT where policy_expr is not null;
    update VB_TMP_POLICY_FEEDISCNT set policy_id = 820200000 + ROWNUM;

    --
    --update NG_TMP_TP_DISCNT set product_offering_id = feepolicy_id;      discnt_code <> b_discnt_code
/*    select * from td_b_discnt where discnt_code in
    (select discnt_code from td_b_discnt where discnt_code in (select feepolicy_id from NG_TMP_TP_DISCNT) group by discnt_code having count(*) > 1);*/
    update NG_TMP_TP_DISCNT set product_offering_name = (select min(discnt_name) from td_b_discnt where discnt_code = feepolicy_id); --资费主表里存在 同一个tp有多个名称
    update NG_TMP_TP_DISCNT a set policy_id = (select policy_id from VB_TMP_POLICY_FEEDISCNT b where a.policy_expr = b.policy_expr);
    commit;
    
    /* --首月折算 
     * C 补收  
     * E 保底  
     * A 减免  
     * R 固定金额多退少补 
     */  
    --------优惠按天折算特殊处理@20161004------------
    update NG_TMP_TP_DISCNT set policy_id = '820209999' , policy_expr = '
    --首月订购，补收按天折算
            local discntFee = PROM_NUMERATOR(p)
            local tpBeginDate = CALC_PROD_VALID_DATE(p)/1000000
            local cycleBeginDate = CALC_BILL_BEGIN_DATE(p)
            local cycleEndDate = CALC_BILL_END_DATE(p)

            function calc_marker_hms(_inParam1,_inParam2)
              local t_CalcDays = CALC_GET_DAYS(p,_inParam1,_inParam2)
              if t_CalcDays>0 then
                return t_CalcDays
              else
                return 0
              end
            end

            if(tpBeginDate > cycleBeginDate and tpBeginDate < cycleEndDate) then
              local duringDays = calc_marker_hms(tpBeginDate*1000000+1,cycleEndDate*1000000)
              return -(1.0 * (discntFee*10) * 12 * duringDays / 365 + 5)/10
            else
              return -discntFee
            end'
    where first_effect <> '0' and discnt_type in ('C');
    
    update NG_TMP_TP_DISCNT set policy_id = '820209998' , policy_expr = '
    --首月订购，保底按天折算
            local discntFee = PROM_NUMERATOR(p)
            local tpBeginDate = CALC_PROD_VALID_DATE(p)/1000000
            local cycleBeginDate = CALC_BILL_BEGIN_DATE(p)
            local cycleEndDate = CALC_BILL_END_DATE(p)
            local baseFee = PROM_BASE_FEE(p)

            function calc_marker_hms(_inParam1,_inParam2)
              local t_CalcDays = CALC_GET_DAYS(p,_inParam1,_inParam2)
              if t_CalcDays>0 then
                return t_CalcDays
              else
                return 0
              end
            end

            if(tpBeginDate > cycleBeginDate and tpBeginDate < cycleEndDate) then
              local duringDays = calc_marker_hms(tpBeginDate*1000000+1,cycleEndDate*1000000)
              discntFee = (1.0 * (discntFee*10) * 12 * duringDays / 365 + 5)/10
            end
            
            if(baseFee < discntFee) then
               return baseFee-discntFee
            end
            return 0
            '
    where first_effect <> '0' and discnt_type in ('E');
    
    update NG_TMP_TP_DISCNT set policy_id = '820209997' , policy_expr = '
    --首月订购，减免按天折算
            local discntFee = PROM_NUMERATOR(p)
            local promBaseFee = PROM_BASE_FEE(p)
            local tpBeginDate = CALC_PROD_VALID_DATE(p)/1000000
            local cycleBeginDate = CALC_BILL_BEGIN_DATE(p)
            local cycleEndDate = CALC_BILL_END_DATE(p)

            function calc_marker_hms(_inParam1,_inParam2)
              local t_CalcDays = CALC_GET_DAYS(p,_inParam1,_inParam2)
              if t_CalcDays>0 then
                return t_CalcDays
              else
                return 0
              end
            end

            if(tpBeginDate > cycleBeginDate and tpBeginDate < cycleEndDate) then
              local duringDays = calc_marker_hms(tpBeginDate*1000000+1,cycleEndDate*1000000)
              discntFee = (1.0 * (discntFee*10) * 12 * duringDays / 365 + 5)/10
            end
            
            if (promBaseFee < discntFee) then
               return promBaseFee
            end
            return discntFee
            '
    where first_effect <> '0' and discnt_type in ('A');

    update NG_TMP_TP_DISCNT set policy_id = '820209996' , policy_expr = '
    --首月订购，固定金额多退少补 按天折算
            local discntFee = PROM_NUMERATOR(p)
            local promBaseFee = PROM_BASE_FEE(p)
            local tpBeginDate = CALC_PROD_VALID_DATE(p)/1000000
            local cycleBeginDate = CALC_BILL_BEGIN_DATE(p)
            local cycleEndDate = CALC_BILL_END_DATE(p)

            function calc_marker_hms(_inParam1,_inParam2)
              local t_CalcDays = CALC_GET_DAYS(p,_inParam1,_inParam2)
              if t_CalcDays>0 then
                return t_CalcDays
              else
                return 0
              end
            end

            if(tpBeginDate > cycleBeginDate and tpBeginDate < cycleEndDate) then
              local duringDays = calc_marker_hms(tpBeginDate*1000000+1,cycleEndDate*1000000)
              discntFee = (1.0 * (discntFee*10) * 12 * duringDays / 365 + 5)/10
            end
            
            return promBaseFee-discntFee
            '
    where first_effect <> '0' and discnt_type in ('R');

    --套餐费按天分摊
    --fee_adjust_method=5   按本账期内套餐实际生效天数收费
    --fee_adjust_mehtod=8   按本账期内套餐实际生效天数(若当天未有开机，不收费)收费
    update NG_TMP_TP_DISCNT set policy_id = '820209995' , policy_expr = '
    --套餐费按天分摊fee_adjust_method=5   按本账期内套餐实际生效天数收费  没有首月折算规则
            function calc_marker_hms(_inParam1,_inParam2)
              local t_CalcDays = CALC_GET_DAYS(p,_inParam1,_inParam2)
              if t_CalcDays>0 then
                return t_CalcDays
              else
                return 0
              end
            end
            
            local discntFee 			=   PROM_NUMERATOR(p)
            local tpBeginTime 		=   CALC_PROD_VALID_DATE(p)
            local tpEndTime 			=   CALC_PROD_EXPIRE_DATE(p)
            local cycleBeginTime 	=   CALC_BILL_BEGIN_DATE(p)*1000000+1
            local cycleEndTime 		=   CALC_BILL_END_DATE(p)*1000000+235959
            local currDate				=   PROM_CAL_DAY(p)*1000000+1
            local cycleDays 			=   CALC_CYCLE_DAYS(p)
            local duringDays      =   0
            local _in_beginTime   =   0
            local _in_endTime     =   0
            
            if (tpBeginTime < cycleBeginTime) then
            	_in_beginTime = cycleBeginTime
            else
            	_in_beginTime = tpBeginTime
            end
            
            _in_endTime = currDate
            if (_in_endTime > cycleEndTime) then
            	_in_endTime = cycleEndTime
            end
            
            if (tpEndTime < _in_endTime) then
            	_in_endTime = tpEndTime
            end
            
						duringDays = calc_marker_hms(_in_beginTime,_in_endTime)

            return -(1.0 * (discntFee*10) * duringDays / cycleDays + 5)/10 
            '
    where discnt_type = 'C' and exec_id in (select feediscnt_id from td_b_feediscnt where fee_adjust_method = '5');
    
    update NG_TMP_TP_DISCNT set policy_id = '820209994' , policy_expr = '
    --减免金额按天分摊fee_adjust_method=5   按本账期内套餐实际生效天数收费
            function calc_marker_hms(_inParam1,_inParam2)
              local t_CalcDays = CALC_GET_DAYS(p,_inParam1,_inParam2)
              if t_CalcDays>0 then
                return t_CalcDays
              else
                return 0
              end
            end
            
            local promBaseFee     = PROM_BASE_FEE(p)
            local discntFee       =   PROM_NUMERATOR(p)
            local tpBeginTime     =   CALC_PROD_VALID_DATE(p)
            local tpEndTime       =   CALC_PROD_EXPIRE_DATE(p)
            local cycleBeginTime   =   CALC_BILL_BEGIN_DATE(p)*1000000+1
            local cycleEndTime     =   CALC_BILL_END_DATE(p)*1000000+235959
            local currDate        =   PROM_CAL_DAY(p)*1000000+1
            local cycleDays       =   CALC_CYCLE_DAYS(p)
            local duringDays      =   0
            local _in_beginTime   =   0
            local _in_endTime     =   0
            
            if (tpBeginTime < cycleBeginTime) then
              _in_beginTime = cycleBeginTime
            else
              _in_beginTime = tpBeginTime
            end
            
            _in_endTime = currDate
            if (_in_endTime > cycleEndTime) then
              _in_endTime = cycleEndTime
            end
            
            if (tpEndTime < _in_endTime) then
              _in_endTime = tpEndTime
            end
            
            duringDays = calc_marker_hms(_in_beginTime,_in_endTime)
            discntFee = (1.0 * (discntFee*10) * duringDays / cycleDays + 5)/10 
            
            if (promBaseFee < discntFee) then
               return promBaseFee
            end
            return discntFee
            
            '
    where discnt_type = 'A' and exec_id in (select feediscnt_id from td_b_feediscnt where fee_adjust_method = '5');
    
    update NG_TMP_TP_DISCNT set policy_id = '820209993' , policy_expr = '
    --套餐费按天分摊fee_adjust_method=8   按本账期内套餐实际生效天数(若当天未有开机，不收费)收费
            local discntFee 			=   PROM_NUMERATOR(p)
            local cycleDays 			=   CALC_CYCLE_DAYS(p)
						local validDays       =   GET_VALIDDAYS_BYSTS(p,1000000000)

            return -(1.0 * (discntFee*10) * validDays / cycleDays + 5)/10 
            '
    where exec_id in (select feediscnt_id from td_b_feediscnt where fee_adjust_method = '8');

    --插入作用LUA中间表
    insert into VB_TMP_POLICY_FEEDISCNT select distinct policy_id,policy_expr from NG_TMP_TP_DISCNT where policy_id between 820209990 and 820209999;
    
    --修改账户优惠资费  设置账户优惠标记
    update NG_TMP_TP_DISCNT a set a.account_share_flag=0;
    update NG_TMP_TP_DISCNT a set a.account_share_flag=1 where feepolicy_id in (select feepolicy_id from td_b_feepolicy_comp where event_type_id = '23');
    --剔除掉账户优惠判用户状态的条件。比对时要关注下是否有影响。
    update NG_TMP_TP_DISCNT a set cond_ids = substr(cond_ids,11)
     where feepolicy_id in (select feepolicy_id from td_b_feepolicy_comp where event_type_id = '23')
       and cond_ids like '%820100038%';
       
    --PRICE_COMP互斥特殊处理
    --1. 小时包，忙闲时判断
    update ng_tmp_tp_discnt set cond_ids = cond_ids||'&'||820109000 , cond_names = cond_names||'&'||'小时包忙时条件时间段（07：00-23：00）'
      where feepolicy_id in (32485,32486) and order_no ='2';
    COMMIT;
    --互斥特殊处理，条件ID为手工新增  @1206
    update ng_tmp_tp_discnt set cond_ids = cond_ids||'&'||'820109002'
     where feepolicy_id in (34148,34139,34138,34140,34137,34136,34141,34146,34089) and cond_ids = '820100038';
                                         
    --更新优惠作用编码
    delete from TMP_MK_ADJUSTRATE_ID;
    COMMIT;
    insert into TMP_MK_ADJUSTRATE_ID
    select distinct '',cond_ids,discnt_type,compute_object_id,item_id,account_share_flag,fee,divied_parent_value,divied_child_value,
                    base_num,single_fee,num_param,cyc_nums,isparam,param_id,new_param_id,policy_id,policy_expr
     from NG_TMP_TP_DISCNT;
    update TMP_MK_ADJUSTRATE_ID set id = 800000000+ROWNUM;
    update NG_TMP_TP_DISCNT a set adjustrate_id =
    (select id from TMP_MK_ADJUSTRATE_ID b where
    nvl(a.cond_ids           ,0)  = nvl(b.cond_ids           ,0) and
    nvl(a.discnt_type        ,0)  = nvl(b.discnt_type        ,0) and
    nvl(a.compute_object_id  ,0)  = nvl(b.compute_object_id  ,0) and
    nvl(a.item_id            ,0)  = nvl(b.item_id            ,0) and
    nvl(a.fee                ,0)  = nvl(b.fee                ,0) and
    nvl(a.divied_parent_value,0)  = nvl(b.divied_parent_value,0) and
    nvl(a.divied_child_value ,0)  = nvl(b.divied_child_value ,0) and
    nvl(a.base_num           ,0)  = nvl(b.base_num           ,0) and
    nvl(a.single_fee         ,0)  = nvl(b.single_fee         ,0) and
    nvl(a.num_param          ,0)  = nvl(b.num_param          ,0) and
    nvl(a.cyc_nums           ,0)  = nvl(b.cyc_nums           ,0) and
    nvl(a.isparam            ,0)  = nvl(b.isparam            ,0) and
    nvl(a.param_id           ,0)  = nvl(b.param_id           ,0) and
    nvl(a.new_param_id       ,0)  = nvl(b.new_param_id       ,0) and
    nvl(a.policy_id          ,0)  = nvl(b.policy_id          ,0) and
    nvl(a.account_share_flag ,0)  = nvl(b.account_share_flag ,0) and
    nvl(a.policy_expr        ,0)  = nvl(b.policy_expr        ,0)
    );
    COMMIT;
    --设置一下PRICE_NAME
    update NG_TMP_TP_DISCNT a set price_name = (select min(price_name) from ng_td_b_price b where a.price_id = b.price_id);
    
    --补收--组合科目转换
    update NG_TMP_TP_DISCNT a set trans_item_id = (select min(sub_item_id) from td_b_compitem b where a.item_id = b.item_id)
     where discnt_type in ('C','E','F','G','I');
    update NG_TMP_TP_DISCNT a set item_id = trans_item_id where trans_item_id is not null;
    
    --分摊规则填值，导入ITEM_SHARE_FLAG字段        dispatch_method:(0)->10   (1,3)->20   item_share_flag 
    update NG_TMP_TP_DISCNT a set a.dispatch_method=(select distinct b.dispatch_method from td_b_feediscnt b where b.feediscnt_id=a.exec_id);
    commit;
        
    --手工更改首月折算资费的price_id，避免同一个price_id既要首月折算又不要首月折算
    delete from TMP_MK_PRICE_ID;
    COMMIT;
    insert into TMP_MK_PRICE_ID(feepolicy_id,price_id_old) 
    select distinct feepolicy_id,price_id from ucr_param.NG_TMP_TP_DISCNT where 
     (feepolicy_id,price_id) in (select distinct feepolicy_id,price_id from ucr_param.NG_TMP_TP_DISCNT where policy_id in (820209999,820209998))
     order by feepolicy_id , price_id;
    update TMP_MK_PRICE_ID set price_id_new = 61002000 + ROWNUM;
    update NG_TMP_TP_DISCNT a set price_id = 
      (select distinct price_id_new from TMP_MK_PRICE_ID b where a.price_id = b.price_id_old and a.feepolicy_id = b.feepolicy_id)
      where (feepolicy_id,price_id) in (select distinct feepolicy_id,price_id from ucr_param.NG_TMP_TP_DISCNT where policy_id in (820209999,820209998));  
    COMMIT;
  
    --删除账务累计科目   select * from ucr_param.td_b_detailitem where item_use_type = '2';
/*    update ucr_param.NG_TMP_TP_DISCNT set cond_ids = substr(cond_ids,11,9) 
     where feepolicy_id in (select feepolicy_id from ucr_param.NG_TMP_TP_DISCNT where item_id = 11111);
    delete from NG_TMP_TP_DISCNT where item_id = 11111; 
    COMMIT;*/
    
    --因NG资费树互斥机制，而VB不具备这种机制，需要将以下资费调整优惠作用顺序。
    --判科目费用时先判低费用区间，后判高费用区间。防止后面作用参考的费用被前面作用参考的费用修改
    --资费列表参见 transparam/《因NG资费树互斥机制，需要调整作用顺序的资费.xlsx》
/*    update ng_tmp_tp_discnt set order_no = 5-order_no where feepolicy_id in 
    (80023034,80023035,80023036,80023039,80023044,80023100,80023102,80023110,80023116,80023122,
    80023127,80023136,80023138,80023139,80023144,80023148,80023152,80023164,80023165,80023168,
    80023169,80023175,80023176,80023187,80023190,80023191,80023224);*/--解析PRICE_COMP的过程里已经修改了。
    
    --分账强制补足销售品，手工插入
    insert into NG_TMP_TP_DISCNT(product_offering_id,Product_Offering_Name,price_id,price_name,order_no,adjustrate_id,account_share_flag,remark,discnt_type,item_id)
    values (486100001,'强制补足消费',41234567,'分账强制补足',1,809999999,0,'强制补足消费','X',10388);
    COMMIT;
    
    --总量优惠只能加载集团上     effect_role_id = '0' + effect_mode = 'A'  需要倒换成-1
    update ng_tmp_tp_discnt a set effect_role_code = '-1'
     where exists 
    (
      select 1 from td_b_feepolicy_comp b 
       where a.feepolicy_id = b.feepolicy_id and a.effect_role_code = b.effect_role_code
         and b.effect_role_code = '0' and b.event_type_id in ('22','23') and b.exec_mode = 'A' 
    );
    
    --总量优惠的优先级调整
    --1. 先把大的优先级ID往下降一波
    update ng_tmp_tp_discnt set event_priority = event_priority - 100 where event_priority > 9900;
    --2. 再把群总量优惠的优先手工调整上去   select * from td_b_feepolicy_comp where event_type_id = '22' and effect_role_code = '0' and exec_mode = 'A';
    update ng_tmp_tp_discnt set event_priority = 9901 where feepolicy_id = 99999001 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9902 where feepolicy_id = 32386 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9903 where feepolicy_id = 32388 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9904 where feepolicy_id = 32389 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9905 where feepolicy_id = 32387 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9906 where feepolicy_id = 32462 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9907 where feepolicy_id = 32465 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9908 where feepolicy_id = 32464 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9909 where feepolicy_id = 32463 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9910 where feepolicy_id = 90010956 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9911 where feepolicy_id = 99410257 and effect_role_code = '-1';
    update ng_tmp_tp_discnt set event_priority = 9912 where feepolicy_id = 99410256 and effect_role_code = '-1';
    COMMIT;
    
    --多终端共享资费的收费方式迟迟未确认，先手工置为不收费。  可能涉及修改UUREL分析
    update ng_tmp_tp_discnt set single_fee = 0 where price_id = 60040104;
    COMMIT;

------99410257资费拆分（KD问题）及角色编码调整（KD00->-2）  九工确认信管不再给我们拆分，我们在代码中直接按角色判断
/*insert into ng_tmp_tp_discnt
select 
  99411257              , --由99410257拆分出给订购者成员使用的销售品，CRM进行绑定
  PRODUCT_OFFERING_NAME ,
  FEEPOLICY_ID          ,
  EVENT_PRIORITY        ,
  -2                    ,
  REPEAT_TYPE           ,
  FIRST_EFFECT          ,
  PRICE_ID              ,
  PRICE_NAME            ,
  ORDER_NO              ,
  COND_IDS              ,
  COND_NAMES            ,
  EXEC_ID               ,
  ADJUSTRATE_ID         ,
  ACCOUNT_SHARE_FLAG    ,
  DISPATCH_METHOD       ,
  REMARK                ,
  DISCNT_TYPE           ,
  COMPUTE_OBJECT_ID     ,
  ITEM_ID               ,
  TRANS_ITEM_ID         ,
  FEE                   ,
  DIVIED_PARENT_VALUE   ,
  DIVIED_CHILD_VALUE    ,
  BASE_NUM              ,
  SINGLE_FEE            ,
  NUM_PARAM             ,
  CYC_NUMS              ,
  ISPARAM               ,
  PARAM_ID              ,
  NEW_PARAM_ID          ,
  POLICY_ID             ,
  POLICY_EXPR           
 from ng_tmp_tp_discnt where feepolicy_id = 99410257 and effect_role_code = '0';
update ng_tmp_tp_discnt set effect_role_code = '-2' where feepolicy_id = 99410257 and effect_role_code = '0';
COMMIT;*/


    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='NG_TMP_TP_DISCNT_PRE 111111 err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;
    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:='NG_TMP_TP_DISCNT_PRE err!:'||substr(SQLERRM,1,200);
       v_resultcode:='-1';
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
END;

/

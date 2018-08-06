CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_DISCNT
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_DISCNT����ִ�гɹ�!';

    --������  ��ID����Լ������--
    --������ֻ�����Żݶ����������   ���ۼƻ��Ķ��塢����Ʒ���������Ʒ��̶��������ɾ��
    DELETE FROM PD.PM_ADJUST_SEGMENT;
    DELETE FROM PD.PM_BILLING_DISCOUNT_DTL;
    DELETE FROM PD.PM_ADJUST_RATES WHERE ADJUSTRATE_ID between 800000000 and 899999999;
    DELETE FROM PD.PM_COMPOSITE_OFFER_PRICE WHERE PRICE_ID between 800000000 and 999999999;
    DELETE FROM PD.PM_COMPONENT_PRODOFFER_PRICE WHERE PRICE_ID between 800000000 and 999999999;
    COMMIT;

		BEGIN
----------------------------------------1--����Ʒ������ر�-----------------------------------------------
      --����Ʒ����
      insert into PD.PM_PRODUCT_OFFERING(PRODUCT_OFFERING_ID,OFFER_TYPE_ID,NAME,BRAND_SEGMENT_ID,IS_MAIN,LIFECYCLE_STATUS_ID,OPERATOR_ID,PROD_SPEC_ID,OFFER_CLASS,
              PRIORITY,BILLING_PRIORITY,IS_GLOBAL,VALID_DATE,EXPIRE_DATE,DESCRIPTION,SPEC_TYPE_FLAG)
      select distinct PRODUCT_OFFERING_ID,
             0,                          --OFFER_TYPE_ID
             PRODUCT_OFFERING_NAME,
             -1,                         --BRAND_SEGMENT_ID
             0,                          --IS_MAIN
             1,                          --LIFECYCLE_STATUS_ID
             0,                          --OPERATOR_ID
             10180000,                   --PROD_SPEC_ID
             111,                        --OFFER_CLASS
             0,                          --PRIORITY
             0,                          --BILLING_PRIORITY ������ʹ�á�
             0,                          --IS_GLOBAL��APS_XCδ����
             to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss'),
             'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss'),
             0
        from NG_TMP_TP_DISCNT
        where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFERING);
      update PD.PM_PRODUCT_OFFERING set PROD_SPEC_ID = 12880000 where PRODUCT_OFFERING_ID = 486100001;----xuetao Ҫ��  ��������Ʒ����128
      --����Ʒ����
      insert into PD.PM_PRODUCT_OFFER_ATTRIBUTE
			select distinct PRODUCT_OFFERING_ID,0,1,-1,0,-999,-999,'','',0,
             0,                          --DISCOUNT_EXPIRE_MODE������ʹ�á�
             '',0 from NG_TMP_TP_DISCNT
       where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFER_ATTRIBUTE);
      --����Ʒ�۷ѹ��򣨶���APS���ԣ�ò��ûɶ���ã�
      insert into PD.PM_COMPOSITE_DEDUCT_RULE
      select distinct PRODUCT_OFFERING_ID,
             1,                --BILLING_TYPE
             0,1,              --DEDUCT_FLAG
             -1,1002,-1,1,0,   --NEGATIVE_FLAG
             0,                --IS_CHANGE_BILL_CYCLE
             0,                --IS_PER_BILL
             0,0,0,'','',-999,-999,0,-1 from NG_TMP_TP_DISCNT
         where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from PD.PM_COMPOSITE_DEDUCT_RULE where billing_type = '1');
      --ϵͳ������Ʒ
      insert into pd.PM_GLOBAL_OFFER_AVAILABLE
      select distinct PRODUCT_OFFERING_ID,-1, to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss'),sysdate
        from NG_TMP_TP_DISCNT
       where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID in (select feepolicy_id from td_base_tariff where biz_type = '22')
         and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from pd.PM_GLOBAL_OFFER_AVAILABLE);
      --ϵͳ������Ʒ
      insert into pd.PM_PRODUCT_OFFER_AVAILABLE
      select distinct PRODUCT_OFFERING_ID,'-1','-1',0,0,to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss')
        from NG_TMP_TP_DISCNT
       where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and PRODUCT_OFFERING_ID in (select feepolicy_id from td_base_tariff where biz_type = '22')
         and PRODUCT_OFFERING_ID not in (select PRODUCT_OFFERING_ID from pd.PM_PRODUCT_OFFER_AVAILABLE);
      --ʧЧ���
      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = '0'
       where a.product_offering_id in (select b.DISCNT_CODE from NG_TD_B_DISCNT b where b.enable_tag = '0')
         and exists (select 1 from NG_TD_B_DISCNT b where a.product_offering_id = b.DISCNT_CODE);

      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = '1'
       where a.product_offering_id in (select b.DISCNT_CODE from NG_TD_B_DISCNT b where b.enable_tag in ('1'))
         and exists (select 1 from NG_TD_B_DISCNT b where a.product_offering_id = b.DISCNT_CODE);
         
      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = '2'
       where a.product_offering_id in (select b.DISCNT_CODE from NG_TD_B_DISCNT b where b.enable_tag in ('2'))
         and exists (select 1 from NG_TD_B_DISCNT b where a.product_offering_id = b.DISCNT_CODE);
         
      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = '3'
       where a.product_offering_id in (select b.DISCNT_CODE from NG_TD_B_DISCNT b where b.enable_tag in ('3'))
         and exists (select 1 from NG_TD_B_DISCNT b where a.product_offering_id = b.DISCNT_CODE);
       
      --PM_PRODUCT_OFFER_SPEC_CHAR
      --PM_PRODUCT_OFFERING_CENPAY   ͳ���μ�������ҵ����
      --PM_ITEM_SPLIT_RATE;  ???????

			EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='����Ʒ����-1 err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;
    commit;

    BEGIN
------------------------------------------2--���ۼƻ�-------------------------------------------
     --���ۼƻ�����
     insert into PD.PM_PRICING_PLAN
      select distinct PRODUCT_OFFERING_ID,PRODUCT_OFFERING_NAME,B.DISCNT_EXPLAIN,'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_TP_DISCNT A , (select discnt_code,min(discnt_explain) DISCNT_EXPLAIN from NG_TD_B_DISCNT group by discnt_code) B
       where a.DISCNT_TYPE <> 'Z' and a.remark <> 'invalid tp'
          and A.PRODUCT_OFFERING_ID = B.DISCNT_CODE
         and A.PRODUCT_OFFERING_ID not in (select pricing_plan_id from PD.PM_PRICING_PLAN);
     --����Ʒ�붨�ۼƻ�������ϵ   Ĭ��1��1   ���ȼ�����1  ����Ч
     insert into PD.PM_PRODUCT_PRICING_PLAN
      select distinct product_offering_id,0,product_offering_id,1,-1,0
        from NG_TMP_TP_DISCNT
       where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
          and product_offering_id not in (select product_offering_id from PD.PM_PRODUCT_PRICING_PLAN);
     --��������
     insert into PD.PM_COMPONENT_PRODOFFER_PRICE
      select distinct decode(a.account_share_flag,0,a.price_id+800000000,1,a.price_id+900000000),nvl(a.price_name,'�Żݶ���-û����~'),8,0,'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_TP_DISCNT a
       where a.DISCNT_TYPE <> 'Z' and a.remark <> 'invalid tp'
        order by 1;
     --���ۼƻ�_���۹�����ϵ
     insert into PD.PM_COMPOSITE_OFFER_PRICE (PRICING_PLAN_ID,PRICE_ID,BILLING_TYPE,OFFER_STS,VALID_DATE,EXPIRE_DATE,SERV_ID,PRIORITY)
      select distinct product_offering_id,decode(a.account_share_flag,0,a.price_id+800000000,1,a.price_id+900000000),'1','-1',to_date('01-01-2001', 'dd-mm-yyyy'), to_date('01-01-2100', 'dd-mm-yyyy'),'-1',a.event_priority
        from NG_TMP_TP_DISCNT a
        where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp'
       order by 1;
       
    --�Ż����߶���
    INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
      SELECT DISTINCT a.ADJUSTRATE_ID,0,'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss')
        FROM NG_TMP_TP_DISCNT a
        where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp';
    --�������Ż����߹�ϵ
    INSERT INTO PD.PM_BILLING_DISCOUNT_DTL (PRICE_ID, CALC_SERIAL, ADJUSTRATE_ID,VALID_DATE, EXPIRE_DATE, USE_TYPE, MEASURE_ID, DESCRIPTION)
    SELECT DISTINCT
      decode(a.account_share_flag,0,a.price_id+800000000,1,a.price_id+900000000),100-a.ORDER_NO,a.ADJUSTRATE_ID,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --�����˶���Ч
      10403,'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss')
      FROM NG_TMP_TP_DISCNT a
      where DISCNT_TYPE <> 'Z' and remark <> 'invalid tp' ORDER BY 1 , 2;

    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='�ʷ�������-1 err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;
    commit;

    BEGIN
--------------------------------------------�Żݶ���ʵ��---------------------------------------------
/* PRIORITY   ���feediscnt����feediscnt_idΨһ��VB�и��ֶ���дĬ��ֵ��1�� */
--��������--���õ�������   PROM_TYPE=4
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id,1,a.item_id,1,a.item_id,
            1,1 PRIORITY,0,-1,a.fee,10,0,
            3,0,1 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,4 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type in ('A','H');

--����������--llBaseFee * llNumerator / llDenominator   PROM_TYPE=1
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id,1,a.item_id,1,a.item_id,
            1,1 PRIORITY,0,-1,a.divied_child_value,a.divied_parent_value,0,
            3,0,1 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,1 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'B';
    
--�����ý���-- lNumerator;  PROM_TYPE = 8
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id,1,a.item_id,1,0,
            1,1 PRIORITY,nvl(a.single_fee,0),-1,decode(isparam,0,a.fee,1,0),1,0,
            3,0,0 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,8 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    where discnt_type = 'C';
    
--�ⶥ--     llPromFee = llBaseFee - llNumerator;  PROM_TYPE = 3
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id BASE_ITEM,1,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,0,-1,a.fee,10,0,
            3,0,1 ITEM_SHARE_FLAG,0,0,                   --֮ǰ��20���ⶥʱ�����ǰ����ȼ�����ģ���Ϊ1���ȴ���֤
            policy_id,-1,0,3 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'D';
    
--��ͨ����  llPromFee = llBaseFee - llNumerator;  PROM_TYPE = 5
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.compute_object_id BASE_ITEM,1,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,0,-1,decode(policy_id,820209998,a.fee,null,a.fee,0),10,0,
            3,0,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,5 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'E';
    
--LUA�շ�  Ⱥ�����
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.compute_object_id BASE_ITEM,1,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,a.single_fee,-1,fee,decode(isparam,0,a.base_num,1,0),0,
            3,0,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,8,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'F';
    
--�ۼƱ���   --PROM_TYPE = 5  �ۼ�����REF_CYCLES  StartValue��ʾ������ID�����׽��������
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.compute_object_id BASE_ITEM,a.cyc_nums,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,decode(isparam,1,nvl(new_param_id,0),0,0),-1,decode(isparam,0,a.fee,0),10,0,  --!!!!!!!!!!!!!!!!!!!!!!
            3,0,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,5 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'G';
    
----�����ο�ֵ�Ĳ��ֽ����޶�����
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id BASE_ITEM,1,a.compute_object_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,a.fee,a.single_fee,a.divied_child_value NUMERATOR,a.DIVIED_PARENT_VALUE DENOMINATOR,0,
            3,a.account_share_flag,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,14,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'Q';   
    
--�̶��������ٲ�-- lNumerator;  PROM_TYPE = 2
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id,1,a.item_id,1,0,
            1,1 PRIORITY,0,-1,decode(isparam,0,a.fee,1,0),1,0,
            3,0,0 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,2 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    where discnt_type = 'R';
    
/*������   prom_type = 20
 *1.	������ü�¼��DENOMINATOR�ֶ��
 *2.	������ü�¼��NUMERATOR�ֶ��
 *3.	��������·ݼ�¼��REF_CYCLES�ֶ��
 */
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id BASE_ITEM,a.cyc_nums,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,0,-1,a.single_fee,a.fee,0,
            3,0,20 ITEM_SHARE_FLAG,0,0,
            policy_id,-1,0,20 PROM_TYPE,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'I';

--����ǿ�Ʋ���--�ο�����
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.ADJUSTRATE_ID,nvl(a.cond_ids,0),2 REF_TYPE,0,
            0,a.item_id BASE_ITEM,1,a.item_id ADJUST_ITEM,1,a.item_id FILL_ITEM,
            1,1 PRIORITY,0,-1,0,0,0,
            3,0,20 ITEM_SHARE_FLAG,0,0,
            0,-1,0,2,0,0,a.REMARK,
            1,-1,0
    FROM NG_TMP_TP_DISCNT a
    WHERE discnt_type = 'X';
    
--�˻��Żݱ��ͳһ����
    UPDATE PD.PM_ADJUST_SEGMENT SET ACCOUNT_SHARE_FLAG = 1
     WHERE ADJUSTRATE_ID IN (SELECT ADJUSTRATE_ID FROM NG_TMP_TP_DISCNT WHERE ACCOUNT_SHARE_FLAG = '1');
--��̯������ͳһ����
    --1--��Ŀ��̯
    UPDATE PD.PM_ADJUST_SEGMENT SET ITEM_SHARE_FLAG = 10
     WHERE ADJUSTRATE_ID IN (SELECT ADJUSTRATE_ID FROM NG_TMP_TP_DISCNT WHERE dispatch_method = '0');
    --2--��Ŀ����
    UPDATE PD.PM_ADJUST_SEGMENT SET ITEM_SHARE_FLAG = 20
     WHERE ADJUSTRATE_ID IN (SELECT ADJUSTRATE_ID FROM NG_TMP_TP_DISCNT WHERE dispatch_method in ('1','3'));
         
    ------------Ⱥ��������Ʒ-------
    DELETE FROM PD.PM_PRODUCT_OFFER_SPEC_CHAR where SPEC_CHAR_ID = '13511';
    INSERT INTO PD.PM_PRODUCT_OFFER_SPEC_CHAR (PRODUCT_OFFERING_ID,SPEC_CHAR_ID,VALUE_TYPE,VALUE,VALUE_MAX,DESCRIPTION,GROUP_ID)
      SELECT distinct feepolicy_id,13511,'1','1',NULL,NULL,0
        FROM UCR_PARAM.td_b_feepolicy_comp
       WHERE effect_role_code IN ('-1') and (event_type_id>=100 or event_type_id in (22,23));
    COMMIT;
    ---------�ظ�����������Ʒ����--------����ֱ�ӽ������ظ�����������Ʒ����ñ�
    delete from PD.PM_PRODUCT_OFFER_SPEC_CHAR  where SPEC_CHAR_ID = '13512';
    insert into PD.PM_PRODUCT_OFFER_SPEC_CHAR 
      select distinct feepolicy_id,13512,'1','1','','',0 from NG_TMP_FEEPOLOICY where REPEAT_TYPE = '0' and type = '3';  --�����ظ��������Ż��ʷ�
    ---------KD00�����ʷѣ�ͨ��UUREL�̳�----------
    DELETE FROM PD.PM_PRODUCT_OFFER_SPEC_CHAR where SPEC_CHAR_ID = '13513';
    INSERT INTO PD.PM_PRODUCT_OFFER_SPEC_CHAR (PRODUCT_OFFERING_ID,SPEC_CHAR_ID,VALUE_TYPE,VALUE,VALUE_MAX,DESCRIPTION,GROUP_ID)
      SELECT distinct feepolicy_id,13513,'1','1',NULL,NULL,0
        FROM UCR_PARAM.td_b_feepolicy_comp
       WHERE (effect_role_code IN ('KD00') and (event_type_id>=100 or event_type_id in (22,23))) or feepolicy_id in (90010956,99410257);
    COMMIT;

    --����ǿ�Ʋ�������Ʒ--
    DELETE FROM PD.PM_PRODUCT_OFFER_SPEC_CHAR WHERE PRODUCT_OFFERING_ID = 486100001;
    insert into PD.PM_PRODUCT_OFFER_SPEC_CHAR values(486100001, 1000, 1, 491234567, '', 'ǿ�Ʋ�������ƷID', 0);
            
    --�̷�����Ʒ�����޸�(����޹̷�Ⱥ����)
    update pd.PM_PRODUCT_OFFER_SPEC_CHAR a set PRODUCT_OFFERING_ID =
    (select distinct b.PRODUCT_OFFERING_ID from VB_PM_PRODUCT_OFFERING b where a.product_offering_id = b.feepolicy_id)
    where exists (select 1 from VB_PM_PRODUCT_OFFERING c where a.product_offering_id = c.feepolicy_id);
    COMMIT;
    
    --��ɫ����
    update NG_TMP_TP_DISCNT set effect_role_code = '-1' where effect_role_code not in ('-1','-2','0');--!!!�н�ɫ����Ķ��ȸ�Ϊ-1��˵
    UPDATE pd.PM_COMPOSITE_OFFER_PRICE a SET a.ROLE_CODE=
    (SELECT DISTINCT effect_role_code FROM NG_TMP_TP_DISCNT b
    WHERE b.PRODUCT_OFFERING_ID=a.PRICING_PLAN_ID AND '8'||b.PRICE_ID=a.PRICE_ID  ) 
    WHERE (PRICING_PLAN_ID,price_id) IN 
    (SELECT product_offering_id,'8'||price_id
      FROM ucr_param.NG_TMP_TP_DISCNT 
     WHERE effect_role_code<>'-2');
     
    --��PM_PRODUCT_OFFERING�����prod_object_type�ֶΣ����������û��ʷѺ��˻��ʷѣ���crm��
    update pd.pm_product_offering a set a.prod_object_type = 0;--Ĭ��Ϊ�û�
    update pd.pm_product_offering a
       set a.prod_object_type = 1  --�˻�
     where a.product_offering_id in
           (select discnt_code
              from td_b_discnt
             where b_discnt_code in (select feepolicy_id
                                       from td_b_feepolicy_comp
                                      where event_type_id = 23
                                        and exec_mode = 'A'));
    commit;
     
    EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='�ʷ���(�Ż�)����-2 err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;
    commit;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:='P_NG_TMP_PARAM_DISCNT err !'||substr(SQLERRM,1,200);
       v_resultcode:='-1';
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
END;
/

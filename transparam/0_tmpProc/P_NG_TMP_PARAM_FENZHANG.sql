CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_FENZHANG
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
-----------------------------------------------------
--VerisBilling�������ʹ��
--�߼��������˹���
-----------------------------------------------------
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_FENZHANG ����ִ�гɹ�!';
--PD.PM_PAYFOR_REGULATION 
--PD.PM_PAYFOR_ITEM_LIMIT
--PD.PM_PAYFOR_SPEC
/*
pd.PM_BILLING_PARAM_RELA��PARAM_TYPE='7'�ļ�¼

PARAM_CODE        -- NGϵͳ���ѿ�Ŀ
BILLING_PARAM     -- VB�е�PAY_RULE_ID
BILLING_PARAM_EXT -- VB�е�product_offering_id

���ڹ��������ļ�¼��ȫ��ӳ�䵽 
PAY_RULE_ID = 99999
product_offering_id = 486199999
*/
   
    BEGIN
           delete from PD.PM_PAYFOR_REGULATION;
           delete from PD.PM_PAYFOR_ITEM_LIMIT;
           delete from PD.PM_PAYFOR_SPEC;
           commit;
           
           delete from tmp_valid_compitem4deduct;
           commit;
           --�ñ�����1922�����˹������������٣�����ȫ������VB���˹�����У���ֹ�������к�ǰ���ؿ����˹���ѡ�񲻵���  @20170826
           insert into tmp_valid_compitem4deduct select item_id from ng_td_b_item where item_use_type = '1';
          
           insert into PD.PM_PAYFOR_REGULATION (PRICE_RULE_ID, REGULATION_SPEC_ID, PAYFOR_TYPE, USE_MODE, STATE, VALID_MODE, EXPIRE_MODE, PAYMENT_TYPE, VALID_DATE, EXPIRE_DATE)
           select distinct a.item_id,12850001,2,1,0,0,0,0,to_date('10-01-2010', 'dd-mm-yyyy'), to_date('01-01-2050', 'dd-mm-yyyy')
           from NG_TD_B_COMPITEM a where item_id in (select ITEM_ID from tmp_valid_compitem4deduct);
         
           insert into PD.PM_PAYFOR_ITEM_LIMIT (PRICE_RULE_ID, ITEM_ID, PRIORITY, MAX_LIM, NUMERATOR, DENOMINATOR)
           select a.item_id,a.sub_item_id,100, 0, 100, 100
           from NG_TD_B_COMPITEM a where item_id in (select ITEM_ID from tmp_valid_compitem4deduct);
      
           delete from PD.PM_PAYFOR_ITEM_LIMIT a
						where not EXISTS 
						(SELECT 1 FROM ucr_param.NG_TD_B_DETAILITEM b
						 WHERE b.ITEM_ID=a.ITEM_ID AND b.ITEM_USE_TYPE='0');

           insert into PD.PM_PAYFOR_SPEC (REGULATION_SPEC_ID, NAME, PRECISION_ROUND)
           values (12850001, '���', 3);
           
           --49999Ϊ�������п�Ŀ����������
           insert into PD.PM_PAYFOR_REGULATION (PRICE_RULE_ID, REGULATION_SPEC_ID, PAYFOR_TYPE, USE_MODE, STATE, VALID_MODE, EXPIRE_MODE, PAYMENT_TYPE, VALID_DATE, EXPIRE_DATE)
           select distinct a.item_id,12850001,2,1,0,0,0,0,to_date('10-01-2010', 'dd-mm-yyyy'), to_date('01-01-2050', 'dd-mm-yyyy')
           from NG_TD_B_COMPITEM a where item_id = 49999;
         
           insert into PD.PM_PAYFOR_ITEM_LIMIT (PRICE_RULE_ID, ITEM_ID, PRIORITY, MAX_LIM, NUMERATOR, DENOMINATOR)
           select a.item_id,a.sub_item_id,100, 0, 100, 100
             from NG_TD_B_COMPITEM a where item_id = 49999 
              and sub_item_id in (select item_id from NG_td_b_detailitem where item_use_type = '0');
           
           --���뼯�ŷ��˵�18����Ŀ for ACCTMGR   �ຣӦ���ǲ���Ҫ��
/*           insert into PD.PM_PAYFOR_REGULATION (PRICE_RULE_ID, REGULATION_SPEC_ID, PAYFOR_TYPE, USE_MODE, STATE, VALID_MODE, EXPIRE_MODE, PAYMENT_TYPE, VALID_DATE, EXPIRE_DATE)
           select distinct a.accumulate_item,12850001,2,1,0,0,0,0,to_date('10-01-2010', 'dd-mm-yyyy'), to_date('01-01-2050', 'dd-mm-yyyy')
           from PD.PM_ACCUMULATE_ITEM_REL a where a.accumulate_item between 41001 and 41018;
         
           insert into PD.PM_PAYFOR_ITEM_LIMIT (PRICE_RULE_ID, ITEM_ID, PRIORITY, MAX_LIM, NUMERATOR, DENOMINATOR)
           select a.accumulate_item,a.item_id,100, 0, 100, 100
             from PD.PM_ACCUMULATE_ITEM_REL a where a.accumulate_item between 41001 and 41018;*/
           
           --add by infoMgr @20160918
          delete from pd.PM_PRODUCT_SPEC_TYPE where spec_type_id = 128;
          DELETE FROM pd.PM_PRODUCT_SPEC_TYPE_GROUPS WHERE PROD_SPEC_ID = 12880000;
          delete from pd.PM_PRODUCT_SPEC where PROD_SPEC_ID = 10180000;
          delete from pd.PM_PRODUCT_SPEC_REL where PROD_SPEC_ID = 10180000;

          insert into pd.PM_PRODUCT_SPEC_TYPE(SPEC_TYPE_ID,group_method_id,NAME,description) values(128,1,'����','����');
          insert into pd.PM_PRODUCT_SPEC_TYPE_GROUPS(PROD_SPEC_ID,spec_type_id) values(12880000,128);
          insert into pd.PM_PRODUCT_SPEC(PROD_SPEC_ID,type_id,lifecycle_status,name,description,VALID_DATE,expire_date)
            values (10180000,0,1,'��ͨ�ʷѲ�Ʒ_ͨ��','��ͨ�ʷѲ�Ʒ_ͨ��',to_date('20000101','yyyymmdd'),to_date('20991231','yyyymmdd'));
          insert into pd.PM_PRODUCT_SPEC_REL(PROD_SPEC_ID,rel_prod_spec_id,relation_type_id,valid_date,expire_date)
            VALUES (10180000,10180000,1,to_date('20000101','yyyymmdd'),to_date('20991231','yyyymmdd'));

          --��������Ʒ
          delete from  pd.PM_PRODUCT_OFFERING where product_offering_id=486100000;
          delete from  pd.PM_PRODUCT_OFFER_ATTRIBUTE where product_offering_id=486100000;
          delete from  pd.PM_COMPOSITE_DEDUCT_RULE where product_offering_id=486100000;
          delete from  pd.PM_OFFERING_BRAND_REL where product_offering_id=486100000;
          delete from  pd.pm_product_offer_lifecycle where product_offering_id=486100000;
          delete from  pd.PM_PRICING_PLAN where PRICING_PLAN_ID=486100000;
          delete from  pd.PM_PRODUCT_PRICING_PLAN where product_offering_id=486100000;
          
          INSERT INTO pd.PM_PRODUCT_OFFERING
					(product_offering_id,offer_type_id,name,brand_segment_id,is_main,
					lifecycle_status_id,operator_id,prod_spec_id,offer_class,priority,
					billing_priority,is_global,valid_date,expire_date,description,spec_type_flag)
					VALUES(486100000,0,'0',-1,0,1,0,12880000,111,0,0,0,to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss'),0,0);
					
					INSERT INTO pd.PM_PRODUCT_OFFER_ATTRIBUTE
					(product_offering_id,policy_id,billing_type,suitable_net,probation_effect_mod,
					probation_cycle_unit,probation_cycle_type,offset_cycle_type,offset_cycle_unit,is_refund,
					discount_expire_mode,depend_freeres_item,available_seg_id)
					VALUES(486100000,0,1,-1,0,-999,-999,'','',0,0,'',0);
					
					INSERT INTO pd.PM_COMPOSITE_DEDUCT_RULE
					(product_offering_id,billing_type,resource_flag,deduct_flag,rent_deduct_rule_id,
					prorate_deduct_rule_id,failure_rule_id,redo_af_topup,negative_flag,is_change_bill_cycle,
					is_per_bill,retry_mode,retry_time,retry_cycles,interval_cycle_type,
					interval_cycle_unit,cycle_type,cycle_unit,need_auth,main_promotion)
					VALUES(486100000,1,0,1,-1,1002,-1,1,0,0,0,0,0,0,'','',-999,-999,0,-1);
					
					INSERT INTO pd.PM_OFFERING_BRAND_REL
					(PRODUCT_OFFERING_ID,BRAND_ID,VALID_DATE,EXPIRE_DATE)      
					VALUES (486100000,0,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2099', 'dd-mm-yyyy'));
					
					INSERT INTO pd.pm_product_offer_lifecycle a
					(PRODUCT_OFFERING_ID, HALF_CYCLE_FLAG, CYCLE_UNIT, CYCLE_TYPE, CYCLE_SYNC_FLAG, SUB_EFFECT_MODE, SUB_DELAY_UNIT, SUB_DELAY_CYCLE, UNSUB_EFFECT_MODE, UNSUB_DELAY_UNIT, UNSUB_DELAY_CYCLE, VALID_UNIT, VALID_TYPE, FIXED_EXPIRE_DATE, MODIFY_DATE)
					VALUES (486100000, 0, -999, -999, 1, 0, 0, 1, 0, 0, 1, 1, 1, null, to_date('06-11-2015 20:48:37', 'dd-mm-yyyy hh24:mi:ss'));
					
					
					INSERT INTO pd.PM_PRICING_PLAN
					(PRICING_PLAN_ID, PRICING_PLAN_NAME, PRICING_PLAN_DESC, REMARKS)
					VALUES (486100000,'VB��ӵ���','VB��ӵ���','');
					
					INSERT INTO pd.PM_PRODUCT_PRICING_PLAN
					(PRODUCT_OFFERING_ID, POLICY_ID, PRICING_PLAN_ID, PRIORITY, MAIN_PROMOTION, DISP_FLAG)
					VALUES (486100000,0,486100000,1,-1,0);
          COMMIT;
           
-------------------ϵͳ���������ľӴ˵�------------------------          
            --sd.sys_parameter 0:Ĭ��,�����Σ�1:ֻ����һ��
            update sd.sys_parameter set param_value ='0' where param_code = 'BS_MULTI_PROM';
            --��λС����5����
            update sd.sys_parameter set param_value ='5' where param_code = 'BS_DISP_ROUND';
            --���충������ȡ���Ĳ�Ʒ��Ϊ������
            update sd.sys_parameter set param_value ='FALSE' where param_code = 'BS_DAYOPENSTOP';
            --��ѯMDBʱ������ƫ��ʱ�䣨������
            update sd.sys_parameter set param_value = 45 where param_code = 'BS_DATESHIFT';
            --���˹�������ϻ�ȡ
            update SD.SYS_PARAMETER set param_value = '0', param_data_type = '2' where PARAM_CLASS = 5 and param_code = 'USE_PAY_INDEX';
            --�˵����÷���Լ��
            delete from SD.SYS_PARAMETER where param_code = 'PROM_DETACH_FLAG';
            insert into SD.SYS_PARAMETER values ('PROM_DETACH_FLAG', '�˵����÷���Լ��', 5, 2, 2, '2', '0:��֧�����õ���0,������;1:��֧�����õ��ڷ��˷���,ȫ����;2:�Żݷ��ò�����', '-999');
            --ɾ������Ⱥ�黯��Ʒ���û�����
            delete from sd.sys_parameter a where a.param_code ='BS_FVIRTUALOFFER_USERTYPE';
            --�̷Ѱ汾
            UPDATE sd.sys_parameter a SET a.param_value='0' where a.param_code='BS_VERSION';
            commit;
            --˰�ѵ�λ���֣�
            update sd.sys_parameter set param_value = '10403' where param_code = 'BS_TAX_MEASURE_ID';
            COMMIT;
			      --��������--
			      update SD.SYS_PARAMETER set param_value=0 where param_code='BS_RC_SAME_ITEM_CONTROL';--��ΰΰ�ṩ
			      commit;
            --��ѯ����ʱ��ƫ��ʱ���޸�
            update SD.SYS_PARAMETER set param_value = 365 where param_code = 'BS_DATESHIFT';
            COMMIT;
            --gprs�����շѣ��Ʒ��ṩ���ۻ�������
            delete from SD.SYS_PARAMETER where param_code = 'GPRS_ADDUP_ITEM';
            insert into SD.SYS_PARAMETER values (
'GPRS_ADDUP_ITEM',
'gprs�����շѣ��Ʒ��ṩ���ۻ�������',
5,2,2,
'500000001;500000009;500000121',
'gprs�����շѣ��Ʒ��ṩ���ۻ�������','-999');
            --���ʻ�ҵ�����������
            delete from SD.SYS_PARAMETER where param_code = 'BS_TAX_MEASURE_METHOD';
            insert into SD.SYS_PARAMETER values ('BS_TAX_MEASURE_METHOD', '���ʻ�ҵ�����������', 5, 2, 2, '0', 'ȡ�᷽����0-����ȡ�� 1-�������� 2-����ȡ��', '-999');
            
            delete from sd.sys_parameter where param_code = 'BS_NEGFEEADJUSTITEM';--�����õ��㣬����Ҫ��ֱ��ɾ��
            
            --�����õ���
            delete from sd.sys_parameter where param_code = 'BS_NEGFEEADJUSTITEM';
            insert into SD.SYS_PARAMETER values ('BS_NEGFEEADJUSTITEM', 'BS_NEGFEEADJUSTITEM', 5, 0, 0, '80000', '���ʵ������õ����Ŀ0��ʾ�������ܷ��õ������Ǳ�ʾ�����ĿID', '-999');

      EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='P_NG_TMP_PARAM_FENZHANG err!:'||substr(SQLERRM,1,200);
           v_resultcode:='-1';
           insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
           RETURN;
    END;    
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:=substr(SQLERRM,1,200);
       v_resultcode:='-1';
       insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
END;
/


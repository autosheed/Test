CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_GRPSTP
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_GRPSTP����ִ�гɹ�!';

delete from NG_TMP_GRPS_TP;
COMMIT;
insert into NG_TMP_GRPS_TP(DISCNT_CODE,DISCNT_NAME,COND_ID,Base_Item,Adjust_Item)
select distinct a.discnt_code,a.discnt_name,50000482,e.compute_object_id,e.effect_object_id 
  from td_b_discnt a,td_b_feepolicy_comp b,td_b_event_feepolicy c,td_b_price_comp d,td_b_feediscnt e
 where a.discnt_code = b.feepolicy_id and b.event_feepolicy_id = c.event_feepolicy_id
   and c.price_id = d.price_id and d.exec_type = '3'
   and d.exec_id = e.feediscnt_id
   and e.compute_method in (16,19,23) 
 order by 2;

update NG_TMP_GRPS_TP a set a.TYPE = (select b.addup_type from pd.jf_discnt_exp_rela b where a.discnt_code = b.feepolicy_id and a.base_item = b.addup_id);
update NG_TMP_GRPS_TP a set a.base_item = (select b.item_code from pd.jf_discnt_exp_rela b where a.discnt_code = b.feepolicy_id and a.base_item = b.addup_id);
update NG_TMP_GRPS_TP a set a.adjust_item = (select min(sub_item_id) from td_b_compitem b where a.adjust_item = b.item_id group by item_id)
 where adjust_item in (select item_id from td_b_compitem c where a.adjust_item = c.item_id);

insert into NG_TMP_GRPS_TP (DISCNT_CODE,DISCNT_NAME,TYPE,COND_ID,Base_Item,Adjust_Item)
 values (94100102,'ʡ��IDCҵ���ֵ�Ʒ��ʷ�','3',50000482,500060011,10276);
insert into NG_TMP_GRPS_TP (DISCNT_CODE,DISCNT_NAME,TYPE,COND_ID,Base_Item,Adjust_Item)
 values (94100103,'ʡ��IDCҵ��95����Ʒ��ʷ�','3',50000482,500060012,10276);

update NG_TMP_GRPS_TP a set cond_id = (select policy_id from zhangjt_cond b where a.cond_id = b.cond_id) where cond_id is not null;
update NG_TMP_GRPS_TP a set price_id = 810002000+rownum , Adjustrate_Id = 810002000+rownum;
COMMIT;

      --����Ʒ����
      insert into PD.PM_PRODUCT_OFFERING(PRODUCT_OFFERING_ID,OFFER_TYPE_ID,NAME,BRAND_SEGMENT_ID,IS_MAIN,LIFECYCLE_STATUS_ID,OPERATOR_ID,PROD_SPEC_ID,OFFER_CLASS,
              PRIORITY,BILLING_PRIORITY,IS_GLOBAL,VALID_DATE,EXPIRE_DATE,DESCRIPTION,SPEC_TYPE_FLAG)
      select distinct DISCNT_CODE,
             0,                          --OFFER_TYPE_ID
             DISCNT_NAME,                        
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
             'VB��ӵ���(GPRS) -- '||to_char(sysdate,'yyyymmddhh24miss'),
             0
        from NG_TMP_GRPS_TP
        where type is not null and DISCNT_CODE not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFERING);
      --����Ʒ����
      insert into PD.PM_PRODUCT_OFFER_ATTRIBUTE   
      select distinct DISCNT_CODE,0,1,-1,0,-999,-999,'','',0,
             1,                          --DISCOUNT_EXPIRE_MODE������ʹ�á�
             '',0 from NG_TMP_GRPS_TP
       where type is not null and DISCNT_CODE not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFER_ATTRIBUTE);
      --����Ʒ�۷ѹ��򣨶���APS���ԣ�ò��ûɶ���ã�
      insert into PD.PM_COMPOSITE_DEDUCT_RULE 
      select distinct DISCNT_CODE,
             1,                --BILLING_TYPE
             0,1,              --DEDUCT_FLAG
             -1,1002,-1,1,0,   --NEGATIVE_FLAG
             0,                --IS_CHANGE_BILL_CYCLE
             0,                --IS_PER_BILL
             0,0,0,'','',-999,-999,0,-1 from NG_TMP_GRPS_TP
         where type is not null and DISCNT_CODE not in (select PRODUCT_OFFERING_ID from PD.PM_COMPOSITE_DEDUCT_RULE);
      --ʧЧ���
      UPDATE pd.PM_PRODUCT_OFFER_ATTRIBUTE a set a.DISCOUNT_EXPIRE_MODE = 0
       where a.product_offering_id in (select DISCNT_CODE from NG_TMP_GRPS_TP where type is not null);
     --ϵͳ������Ʒ
      insert into pd.PM_GLOBAL_OFFER_AVAILABLE
      select distinct DISCNT_CODE,-1, to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss'),sysdate
        from NG_TMP_GRPS_TP
       where DISCNT_CODE in (select feepolicy_id from td_base_tariff where biz_type = '22') and type is not null
         and DISCNT_CODE not in (select PRODUCT_OFFERING_ID from pd.PM_GLOBAL_OFFER_AVAILABLE);
      --ϵͳ������Ʒ
      insert into pd.PM_PRODUCT_OFFER_AVAILABLE
      select distinct DISCNT_CODE,'-1','-1',0,0,to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss')
        from NG_TMP_GRPS_TP
       where DISCNT_CODE in (select feepolicy_id from td_base_tariff where biz_type = '22') and type is not null
         and DISCNT_CODE not in (select PRODUCT_OFFERING_ID from pd.PM_PRODUCT_OFFER_AVAILABLE);

------------------------------------------2--���ۼƻ�-------------------------------------------
     --���ۼƻ�����
     insert into PD.PM_PRICING_PLAN
      select distinct A.DISCNT_CODE,A.DISCNT_NAME,B.DISCNT_EXPLAIN,'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_GRPS_TP A , NG_TD_B_DISCNT B
       where a.type is not null and A.DISCNT_CODE = B.DISCNT_CODE
         and A.DISCNT_CODE not in (select pricing_plan_id from PD.PM_PRICING_PLAN);
     --����Ʒ�붨�ۼƻ�������ϵ   Ĭ��1��1   ���ȼ�����1  ����Ч
     insert into PD.PM_PRODUCT_PRICING_PLAN
      select distinct DISCNT_CODE,0,DISCNT_CODE,1,-1,0
        from NG_TMP_GRPS_TP
       where type is not null and DISCNT_CODE not in (select product_offering_id from PD.PM_PRODUCT_PRICING_PLAN);
     --��������
     insert into PD.PM_COMPONENT_PRODOFFER_PRICE
      select distinct a.price_id,'GRPS�����շ�',8,0,'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss')
        from NG_TMP_GRPS_TP a where type is not null
        order by 1;
     --���ۼƻ�_���۹�����ϵ
     insert into PD.PM_COMPOSITE_OFFER_PRICE (PRICING_PLAN_ID,PRICE_ID,BILLING_TYPE,OFFER_STS,VALID_DATE,EXPIRE_DATE,SERV_ID,PRIORITY)
      select distinct DISCNT_CODE,price_id,'1','-1',to_date('01-01-2001', 'dd-mm-yyyy'), to_date('01-01-2100', 'dd-mm-yyyy'),'-1',0
        from NG_TMP_GRPS_TP a where type is not null
       order by 1;
    --�Ż����߶���
    INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
      SELECT distinct ADJUSTRATE_ID,0,'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss')
        FROM NG_TMP_GRPS_TP a where type is not null;
    --�������Ż����߹�ϵ  
    INSERT INTO PD.PM_BILLING_DISCOUNT_DTL (PRICE_ID, CALC_SERIAL, ADJUSTRATE_ID,VALID_DATE, EXPIRE_DATE, USE_TYPE, MEASURE_ID, DESCRIPTION)
    SELECT DISTINCT
      a.PRICE_ID,1,ADJUSTRATE_ID,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --�����˶���Ч
      10403,'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss')
      FROM NG_TMP_GRPS_TP a where type is not null ORDER BY 1 , 2;

----PROM_TYPE=11-------
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.adjustrate_id,nvl(a.cond_id,0),2 REF_TYPE,0,
            0,a.base_item,1,a.adjust_item,1,0,
            1,1 PRIORITY,0,-1,a.DISCNT_CODE RULE_ID,0,0,
            3,0,0 ITEM_SHARE_FLAG,0,0,
            0,-1,0,11 PROM_TYPE,0,0,'GRPSҵ���շ�',
            1,-1,0
    FROM NG_TMP_GRPS_TP a 
    WHERE TYPE in ('1','2');
		COMMIT;
----IDC��������--------
    INSERT INTO PD.PM_ADJUST_SEGMENT
           (ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE,
            EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM,
            ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID,
            PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE,
            FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION,
            FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
    SELECT  DISTINCT
            a.adjustrate_id,nvl(a.cond_id,0),2 REF_TYPE,0,
            0,a.base_item,1,a.adjust_item,1,0,
            1,1 PRIORITY,0,-1,0,0,0,
            3,0,0 ITEM_SHARE_FLAG,0,0,
            820200100,-1,0,8 PROM_TYPE,0,0,'IDCҵ���շ�',
            1,-1,0
    FROM NG_TMP_GRPS_TP a 
    WHERE TYPE in ('3');
		COMMIT;
insert into VB_TMP_POLICY_FEEDISCNT values (820200100,'--IDC�շ�
    function get_Numerator(_in_para1)
      if CALC_EXIST_PROD_PARAM(p,_in_para1) == 1 then
         return (CALC_PRODUCT_PARAM(p,_in_para1))
      else
         return 0
      end
    end

    local t_bandWidth   = get_Numerator(10015127);      --IDC-����  ��λΪM
	  local t_price       = get_Numerator(10015128)*100;  --IDC-����  CRM��Ԫ��ת�ɷִ���
	  local t_num         = get_Numerator(10015129);      --IDC-����  
	  local t_percentM    = get_Numerator(10015098);      --�ϸ��ٷֱ�-���� ,20%Ϊ
	  local t_percentD    = 100;                          --�ϸ��ٷֱ�-��ĸ,Ĭ��100
    local t_addupId     = PROM_BASE_ITEM(p)             --�������õļƷ��ۻ�ID
    local t_addupValue  = CALC_ADDUP_VALUE(p,t_addupId) --��ȡ�Ʒѿ��
    if t_bandWidth == 0 then
       return 0
    end
	  
    --������ֵ(M)    ����(M)*����*50%
	  local t_bandWidthLimit = ( t_bandWidth*t_num*50/t_percentD + 5) / 10 * 10;                                             
    --���״����       ������ֵ*�����ۣ�Ԫ/Mbps/�£�*��1+�ϸ�������
	  local t_limitFee       = ( t_bandWidthLimit*t_price/t_bandWidth*(100+t_percentM)/t_percentD    + 5) / 10 * 10;         
    --��ֵ����ѻ���95����ƷѴ���Byte��*�����ۣ�Ԫ/Mbps��*��1+�ϸ�������
	  local t_computeFee     = ( (t_addupValue/1024/1024)*(t_price/t_bandWidth)*(100+t_percentM)/t_percentD + 5) / 10 * 10   

		--ȡ���ֵ
		if t_limitFee > t_computeFee then
			return -1*t_limitFee
		else
			return -1*t_computeFee
		end
');

--------------------GRPS�շѹ�������-----------------------
/*568 �ο������Դ��
  ����ο��ۻ���
*/
delete from PD.PM_ADJUST_FLUX;
COMMIT;
--���þ�ȷ����
/*1-3 �ο��ۻ���*/
--1-- �ο��ۻ���   �������շ�
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (32230,'1',1,0,0,10,0,0,300,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (32235,'1',1,0,0,30,0,0,500,0,1048576);
--11--  �ο������Դ  �������շ�
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (1644,'11',1,0,0,500,0,0,200,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (1645,'11',1,0,0,500,0,0,200,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (1719,'11',1,0,0,1024,0,0,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (32643,'11',1,0,0,1024,0,0,2000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (32687,'11',1,0,0,1024,0,0,3000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (34064,'11',1,0,0,1024,0,0,5000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (34065,'11',1,0,0,1024,0,0,6900,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (34066,'11',1,0,0,1024,0,0,5000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (34067,'11',1,0,0,1024,0,0,6900,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238991,'11',1,0,0,1024,0,0,4830,0,1048576);
--2-- �ο��ۻ���   �����ײ�(Сѭ��)
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (615,'2',1,0,0,1024,0,29,6000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (1504,'2',1,0,0,1024,0,29,1000,0,1048576);
--12-- �ο������Դ  �����ײ�(Сѭ��)
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410445,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410446,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410447,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410448,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410449,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410450,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410451,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410452,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410453,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410454,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410455,'12',1,0,0,1024,0,29,1000,0,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (99410456,'12',1,0,0,1024,0,29,1000,0,1048576);
--3--�����ײ�(��ѭ��)
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (32236,'3',1,0,0,1024,100,29,6000,1000,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (32347,'3',1,0,0,1024,100,29,6000,1000,1048576);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (34013,'3',1,0,0,1024,100,29,1500,1000,1048576);
--11--�ⶥ15G�����ٰ���׼�ʷ���ȡ
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (300001,'11',1,0,0,1,0,0,29,0,1048576);
--9--�ֶ��ײ�(�л������ײͷ�)
--9238870--
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238870,'9',1 ,0,0,0     ,200   ,4830,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238870,'9',2 ,0,0,200   ,500   ,4550,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238870,'9',3 ,0,0,500   ,1024  ,4340,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238870,'9',4 ,0,0,1024  ,2028  ,4060,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238870,'9',5 ,0,0,2048  ,10240 ,3780,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238870,'9',6 ,0,0,10240 ,-1    ,3500,-1,1073741824,1073741824);
--9238871--
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238871,'9',1 ,0,0,0     ,200   ,4830,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238871,'9',2 ,0,0,200   ,500   ,4550,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238871,'9',3 ,0,0,500   ,1024  ,4340,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238871,'9',4 ,0,0,1024  ,2028  ,4060,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238871,'9',5 ,0,0,2048  ,10240 ,3780,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238871,'9',6 ,0,0,10240 ,-1    ,3500,-1,1073741824,1073741824);
--9238872
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238872,'9',1 ,0,0,0     ,200   ,6900,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238872,'9',2 ,0,0,200   ,500   ,6500,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238872,'9',3 ,0,0,500   ,1024  ,6200,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238872,'9',4 ,0,0,1024  ,2028  ,5800,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238872,'9',5 ,0,0,2048  ,10240 ,5400,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238872,'9',6 ,0,0,10240 ,-1    ,5000,-1,1073741824,1073741824);
--9238873
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238873,'9',1 ,0,0,0     ,200   ,6900,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238873,'9',2 ,0,0,200   ,500   ,6500,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238873,'9',3 ,0,0,500   ,1024  ,6200,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238873,'9',4 ,0,0,1024  ,2028  ,5800,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238873,'9',5 ,0,0,2048  ,10240 ,5400,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238873,'9',6 ,0,0,10240 ,-1    ,5000,-1,1073741824,1073741824);
--9238874
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238874,'9',1 ,0,0,0     ,200   ,1932,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238874,'9',2 ,0,0,200   ,500   ,1820,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238874,'9',3 ,0,0,500   ,1024  ,1736,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238874,'9',4 ,0,0,1024  ,2028  ,1624,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238874,'9',5 ,0,0,2048  ,10240 ,1512,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238874,'9',6 ,0,0,10240 ,-1    ,1400,-1,1073741824,1073741824);
--9238875
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238875,'9',1 ,0,0,0     ,200   ,1932,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238875,'9',2 ,0,0,200   ,500   ,1820,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238875,'9',3 ,0,0,500   ,1024  ,1736,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238875,'9',4 ,0,0,1024  ,2028  ,1624,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238875,'9',5 ,0,0,2048  ,10240 ,1512,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238875,'9',6 ,0,0,10240 ,-1    ,1400,-1,1073741824,1073741824);
--9238876
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238876,'9',1 ,0,0,0     ,200   ,2760,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238876,'9',2 ,0,0,200   ,500   ,2600,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238876,'9',3 ,0,0,500   ,1024  ,2480,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238876,'9',4 ,0,0,1024  ,2028  ,2320,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238876,'9',5 ,0,0,2048  ,10240 ,2160,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238876,'9',6 ,0,0,10240 ,-1    ,2000,-1,1073741824,1073741824);
--9238877
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238877,'9',1 ,0,0,0     ,200   ,2760,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238877,'9',2 ,0,0,200   ,500   ,2600,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238877,'9',3 ,0,0,500   ,1024  ,2480,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238877,'9',4 ,0,0,1024  ,2028  ,2320,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238877,'9',5 ,0,0,2048  ,10240 ,2160,-1,1073741824,1073741824);
insert into PD.PM_ADJUST_FLUX(RULE_ID,TYPE,ORDER_NO,DATA_ID,ITEM_ID,DATA_NUM1,DATA_NUM2,SINGLE_FEE,FEE1,FEE2,MEASURE) values (9238877,'9',6 ,0,0,10240 ,-1    ,2000,-1,1073741824,1073741824);

--check--
--select * from NG_TMP_GRPS_TP where discnt_code not in (select distinct rule_id from PD.PM_ADJUST_FLUX);


--�������⿨
    BEGIN
        P_NG_TMP_PARAM_DAYGPRS(v_resultCode,v_resultErrInfo);
    EXCEPTION
        WHEN OTHERS THEN
            v_resultCode:=-1;
            v_resultErrInfo:='error_888:P_NG_TMP_PARAM_DAYGPRS call error'||SQLERRM;
            insert into zhangjt_errorlog values(seq_zhangjterrorlog_id.nextval,v_resultcode,v_resulterrinfo,sysdate);
            RETURN;
    END;

EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:=substr(SQLERRM,1,200);
       v_resultcode:='-1';
END;
/


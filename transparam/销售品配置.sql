/*�������ʽ lua�ű�
RC        22,26,28
PROM      23,27
*/
select a.*,a.rowid from sd.SYS_POLICY a where a.policy_id between 800000000 and 900000000;
/*������λ����*/
select a.*,a.rowid from sd.SYS_MEASURE a where a.measure_id=10403; 


--����Ʒ
/*����Ʒ����-������Ϣ
PRODUCT_OFFERING_ID
BILLING_PRIORITY
VALID_DATE
EXPIRE_DATE
*/
select * from pd.pm_product_offering a where a.product_offering_id in (100000374);
/*
����Ʒ�۷ѹ���
PRODUCT_OFFERING_ID
NEGATIVE_FLAG
�󸶷ѹ̶����ò�Ʒ���öȡ�Ԥ��۷ѱ�ʶ��
00:��Ȩ��֪ͨ�۷Ѳ������Ϊ������������Ҳ�������Ϊ����
01:��Ȩ��֪ͨ�۷Ѳ������Ϊ�����������������Ϊ����
10:��Ȩ��֪ͨ�۷������Ϊ�������������������Ϊ����
11:��Ȩ��֪ͨ�۷������Ϊ������������Ҳ�����Ϊ����

��Ԥ���ѣ�ͬ����00��
BILLING_TYPE:       0:  Ԥ���� 1:  �󸶷�
DEDUCT_FLAG:        ������ÿ۷ѷ�ʽ  0--Ԥ��   1--���   2--����
ע�⣺
    ��Deduct_flag����Ϊ2ʱ����Ʒ�������ع̷��ʷѵ����ã������Դ�ɼƷѲ������������Ʒ�������̷��ʷѣ�
    ��Deduct_flag����Ϊ0��Pre-deductʱ����Ʒ������Ҫ������У�飬У���߼�Ϊһ�����ۼƻ��£�ֻ���������˹̶����ã��������������Դ�������������Դ������ҲҪ�й̶��ʷѣ�
IS_PER_BILL,            ��ʾ�Ƿ�Ԥ�������ڵķ���
IS_CHANGE_BILL_CYCLE    �۷�ʧ�ܺ��Ƿ�Ҫ�����Ʒ����
*/
select a.*,a.rowid from pd.PM_COMPOSITE_DEDUCT_RULE a where a.product_offering_id=486100001;
--���ۼƻ�
/*   --FORCED_MAKE_UP_PREFERENTIAL(ǿ�Ʋ����Ż�)
     --FLOOR_PROD_XMULTIMAP(���׵��ӵĲ�Ʒ�飬ͬ��Ĳ�Ʒ��Ҫ���б���ֵ�ĵ��Ӵ���)
     --CALC_GLOBAL_OFFER_XMULTIMAP
     --ALLOT_OFFERING_PRICING_PLAN(�ʱ��Żݲ�Ʒ�Ķ��ۼƻ�,����������δ��ʹ�ø�XC)
PRODUCT_OFFERING_ID  ����Ʒ�붨�ۼƻ�����������ϵ
POLICY_ID       (�������������0)
PRICING_PLAN_ID
PRIORITY        (����������δ��ʹ�ø��ֶ�)
MAIN_PROMOTION  (����������δ��ʹ�ø��ֶ�)
DISP_FLAG       (����������δ��ʹ�ø��ֶ�)
*/
select a.*,a.rowid from pd.PM_PRODUCT_PRICING_PLAN a where a.product_offering_id in (100000374);-----���ۼƻ�-����Ʒ�붨�ۼƻ�����
/*���򲻶��ñ����ݣ�������̨չʾ*/
select a.*,a.rowid from pd.PM_PRICING_PLAN a where a.pricing_plan_id=100000024;-----���ۼƻ�-��������
/*�������Ʒ����������Ʒ���۹�ϵ��
PRICING_PLAN_ID  �ƻ�ID
BILLING_TYPE     Ԥ�󸶱�ʶ  -1(ALL)  0(Ԥ��)  1(��)
PRICE_ID         ����ID
VALID_DATE
EXPIRE_DATE
*/
select a.*,a.rowid from pd.PM_COMPOSITE_OFFER_PRICE a where a.pricing_plan_id=5003;--630001438,630001288
/*����Ʒ���۵Ļ�����Ϣ
TAX_INCLUDED  ��˰��ʶ   0(��˰�޹�) 1(����) 2(��˰)   Ŀǰ�̷ѡ�һ���Է��á������ʷ���Ҫ��ע��˰��ʾ������PRICE��0
PRICE_TYPE  7(�̷�)  8(�Ż�)  9(һ���Է��ã����Ϸ���.ȫ�ִ�����Ʒ??)  13(Ⱥ���Ż�)  14(Ѻ�𻮰�-����)
PRICE_ID
*/
select a.*,a.rowid from pd.PM_COMPONENT_PRODOFFER_PRICE a where price_id in (5003);
select a.*,a.rowid from pd.PM_COMPONENT_PRODOFFER_PRICE a where price_id in 
  (select price_id from pd.PM_COMPOSITE_OFFER_PRICE a where a.pricing_plan_id=34079);--52103
select * from PD.PM_COMPOSITE_OFFER_PRICE where pricing_plan_id = 52103 for update;
--�Żݶ��� 
/*�����Ż���ϸ��(ʱ����Ч�����벻��ȡ)
PRICE_ID
ADJUSTRATE_ID  У������ID�����������У������
CALC_SERIAL    ������������д��ڶ�μƷѣ��Żݣ����㣬���������ǵݽ���ʽ�ģ����ü���֮������Ⱥ����
               ������Ҫ���������Ⱥ��ϵ���ܹ��ڼƷ���ʵ�֡�
               ͬһpricing_plan_id�µļ������ȼ�˳������Խ��Խ����
USE_TYPE    ��ʾ����״̬���Ƿ������Żݵױ�־   0(�����˶���Ч��Ĭ�ϣ�)   1(������Ч)   2(������Ч)
MEASURE_ID  ������λ  10402(��)  10403(��)  10404(Ԫ)
*/
select a.*,a.rowid from pd.PM_BILLING_DISCOUNT_DTL a where a.price_id in(810001003);
/*
calc_type    
У�����ʼ��㷽ʽ��
0:��ѡ�ʷѶε�����������������㣬���ο���Ŀ����ĳһ���У���ʹ�øöε������ʽ��м��㡣
1:����ۼƵ�����������������㣬�ο���Ŀ��Խ��εķ��ʼ��������ۼơ�
2:�����ڼƷ�У���ʷ�
*/
select a.*,a.rowid from pd.PM_ADJUST_RATES a where a.adjustrate_id in (810001003) ;
/*�����Ż�У�����߶α�    
ADJUSTRATE_ID
ADJUST_ITEM         --����ҵ��Ʒѣ�������ֱ�Ӽ������۽��������Ҫ���ɵ����ĵ�����Ŀ��
                    --�ÿ�ĿΪ0��ֱ�Ӽ��롰У��������ϸ���п�ĿID��Ӧ�Ļ�����ʵ��Ŀ��
                    --������ʵ��Ŀ���Żݿ�Ŀ
BASE_ITEM           --�ο���Ŀ��
EXPR_ID             --У����Ч������,ֻ�������������ʱУ���Ż���Ч
REF_TYPE            --�ο���Ŀ�ο�������  1(ԭʼ����) 2(�Żݺ����) 3(�Żݺ��Ұ���Ԥ��ķ���) 
                                          4(�Ʒѱ�׼���۵ķ���) 5(�����Żݷ���) 6(�Ʒ��ۻ���)
REF_CYCLES          --Ĭ��ֵ��1
ADJUST_CYCLE_TYPE   --�Ż���������  1(��ǰ) 2(�ο�)
FILL_ITEM           --��̯��Ŀ����   Ĭ���������0����ʾ���÷�̯��Ŀ
ADJUST_TYPE         -- 1(��ǰ���ڽ��е���)  2(��һ���ڽ��е���)
PRIORITY            --�����Żݶεļ���˳��
START_VAL           --��START_VAL��END_VAL����0ʱ����ʾ�Գ����ò��ֵķ��ý����Żݡ�
                    --���磺start_val(100)-end_val(400)��ʾ�Գ���100��С��400�ķ��ý����Żݡ�
END_VAL
NUMERATOR           --�ۿ۷���
DENOMINATOR         --�ۿ۷�ĸ
PRECISION_ROUND     --������ʽ  1(���Ϲ���)  2(���¹���)  3(��������)
ACCOUNT_SHARE_FLAG  --�˻�����̯��ʽ��  0������̯   1�������ױ�����̯   2�������ȼ���̯
ITEM_SHARE_FLAG     --��Ŀ����̯��ʽ��
                        0������̯
                        1�������ױ�����̯
                        2�������ȼ���̯
                        3�����չ��ױ�����̯(������) ��дadjust_item
                        4���������ȼ���̯ (������) ��дadjust_item
                        10������չ��Ŀ���ܷ��õĹ��ױ�����̯
                        20������չ��Ŀ���ܷ��ð����ȼ���̯
DISC_TYPE           --�Ż���������
                        00:�޶���
                        01:�����Żݿ�Ŀ
                        02:����ԭʼ����
PARA_USE_RULE       --1��ʾʹ��(i_user_sprom.sprom_param),0��ʾ��ʹ�� ����
FORMULA_ID          --�Żݵļ��㹫ʽ
MAXIMUM             --�Ż����ֵ
DONATE_USE_RULE     --����ʹ�ù���???
PROM_TYPE           --�Ż�����
                      1�����ۣ������� 
                      2��ָ�����̶��� 
                      3���ⶥ        
                      4������        
                      5������        
                      6������        
                      7�������Ż�
                      8. �Żݲ���     ADJUST_ITEM,NUMERATOR
REF_ROLE            --��0����NULL��ʾ�����ƽ�ɫ
RESULT_ROLE         --��0����NULL��ʾ�����ƽ�ɫ
REWARD_ID           --���ͱ�ʶ��Ĭ��ֵ��0
FILL_USER_MODE
                    0����ʹ���û���̯��ʽ
                    1�����û����ױ�
                    2����������������
                    3����Ⱥ֧���ʻ����û��ʵ��Ĺ��ױ��� 
                    4����Ⱥ֧���ʻ����û��ʵ���������������
FILL_USER_TOP
                    ��ʾ�Żݵ�������������ǰ�������û�
                    Ϊ-1��ʱ�򣬱�ʾû�����ƣ��������û��������ѴӴ�С��̯
TAIL_MODE
                      ���ڷ�̯���Żݵ�Ǯ���ж������Ĵ���ʽ
                      0�����ϣ�1�����������������η�̯
*/
select a.*,a.rowid from pd.PM_ADJUST_SEGMENT a where a.adjustrate_id in (810001003) ;
select a.*,a.rowid from pd.PM_ADJUST_SEGMENT a where prom_type = '10';
860000008
860000009
select * from pd.pm_adjust_flux where rule_id = 34079;
select * from sd.sys_policy where policy_id in (820100719);
select adjustrate_id,count(*) from pd.PM_ADJUST_SEGMENT a group by adjustrate_id having count(*) >1;
select * from pd.pm_adjust_flux where rule_id = 52103;
--��Ŀ����
/*�ʷѿ�Ŀ�����
ITEM_ID
ITEM_TYPE
                          0������
                          1������ʹ���¼���Ŀ����Ӧ�Ʒ���Ԫ�������¼�;(Service Usage)
                          2�����ڷ��¼���Ŀ;(Recurring Usage)
                          3��һ���Է����¼���Ŀ����Ӧҵ��ѣ��翨�ѡ���װ�ѵ�;(One Time Charge)
                          4--˰��Ŀ
                          5���Żݿ�Ŀ
                          6�����տ�Ŀ
                          7 - �������Ŀ
                          8 - �ⲿ����
                          9 - �����Ŀ������ʹ�ã���Ʒѿ�Ŀӳ�䣩
                          10 - �����ۻ����Ŀ������ʹ�ã�
PRIORITY                    --��Ŀ�������ȼ�����ֵԽ�����ȼ�Խ��(�����ͨ����������ȡԽ��Խ���Ȼ���ԽСԽ����)
*/
select a.*,a.rowid from pd.pm_price_event a where a.item_id in(19015) ;--��Ŀ�����
/*�ۻ��������Ŀ��ϵ��??
ACCUMULATE_ITEM           --�ۻ���Ŀ
ITEM_ID
POLICY_ID
PRIORITY                  --ֻ�Ǹ��������Ŀʹ��
CAL_TYPE                  0-����    1-��ӡ�+=��    2-�����-=��
EXT_BILL_ITEM             --�Żݲ��շ�̯��չ��Ŀ       
*/
select a.*,a.rowid from pd.PM_ACCUMULATE_ITEM_REL a where a.accumulate_item in(39999) and item_id = 19015;--���Ŀ������ 
/*���Ŀ�����   --���򲻶��ñ����ݣ�������̨չʾ*/
select a.*,a.rowid from pd.PM_ACCUMULATE_ITEM_DEF a where a.accumulate_item in(87001143,87009999);---���Ŀ�����
select count(*) from pd.PM_ACCUMULATE_ITEM_REL;


--�̷Ѷ���
/*  �̶������ʷѰ���ϸ
PRICE_ID,
ITEM_CODE,
RATE_ID,                 --�ʷѱ��
ACCOUNT_TYPE,            --���ʷ�ʽ  1(����)  2(����)  3(ͨ��)
VALID_CYCLE,             --0����ǰ������Ч��1����������Ч
VALID_COUNT,             --ȡֵ-1��ʾ�޶���
PRE_PAY_TYPE,            --Ԥ�����͡�0(�յ�ǰ��)  1(������-aps)  2(������-crm)   ֵ1ʱ���̶����÷���ֻ�ܰ������ã����ڰ������úͰ��������������塣
CAL_INDI,
                          1���ۼ�������ȫ����ã�
                          2�����ݱ����ڵ�ʣ���������������ۼ���
                          3������ʹ��״̬�������������ۼ�
                          4: ��Сʱ����
EXPR_ID,                 --�ο�����
PRIORITY,                --��ֵԽ�����ȼ�Խ��
USE_MARKER_ID,           --�������ʽ������Ϊ���ʷѵ�ʹ������marker    0����ʾ���û�״̬�޹�   ��ͨ�䣬���ж�����״̬�����޵���˼·
SEG_INDI,                --1:��ʾ���ײ͵�marker����μ��㣿����
SEG_REP,                 --������SEG_INDIһ�����ʹ��
                          00����ѡ�ʷѶε��������ο���Ŀ����ĳһ���У���ʹ�øöε������ʽ��м��㡣
                          01������ۼƵ�����������������㣬��Խ��εķ��ʼ��������ۼơ�
PARAM_MODE,            
                          0:ѭ������ÿ�����Ի��������ʷ��ۼ�
                          1:ȡ��Чʱ��������Ի���������
                          2:ѭ������ֻȡ��������
*/
select a.*,rowid from pd.PM_RECURRING_FEE_DTL a where price_id = 642661669;
/*�̶����÷��ʶ����
RATE_ID
SERVICE_ID            --����ı�ʶ��   ��ɶ�ã���
MAXIMUM               --��������С�ڴ�ֵ�����ش�ֵ��Ϊ�����       -1��ʾ�²�����
MINIMUM               --�����������ڴ�ֵ����Ϊ-1�������ش�ֵ��Ϊ�����    -1��ʾ�ϲ��ⶥ
MEASURE_ID
RATE_PRECISION        --����ʹ��  �����Զ�ȡ����������
PRECISION_ROUND       --1:���Ϲ���  2;���¹���  3����������
CURVE_ID              --��������ID�������̶����õķ�����ϸ
*/
select a.*,a.rowid from pd.PM_RATES a where a.rate_id =70000056;
/*�������ߵĻ�����Ϣ,��ʵ����;,��������,�������*/
select a.*,a.rowid from pd.PM_CURVE a where a.curve_id=3300033;
/*�����������ÿһ�ε�����   Դ��Ŀ???ʲô��
CURVE_ID
START_VAL          --Դ��Ŀ������ʼ�㶨�壬     ��end_val-start_val+1��������cycle_unit��������
END_VAL            --Դ��Ŀ�ı��ν����㶨��  end_valΪ-1ʱ��ʾ�����
BASE_VAL           --�ڼ��㿪ʼǰ�ͱ������յķ��á�
TAIL_RATE          --һ��أ�base_val,rate_val���õķ��õ�λΪ�֣�
                     ���ֶζ���billing��XC����ʱ��base_val,rate_val����ֵ������
                     �����ص�XCʱ��base_val=base_val*tail_rate,rate_val*tail_rate��
                     ���ڽ�����������ѹ����У���Ҫ��ȷ������������յ��շ�formula_id���ʽ�У�
                     ��Ҫ���õ��ķ��ó��Դ�ϵ�����ó��Է�Ϊ��λ����ֵ
RATE_VAL           --���ð�����ȡ�ķ���
TAIL_UNIT          --Դ��Ŀβ����λ
TAIL_ROUND         --Դ��Ŀβ����    0<=tail_round<=tail_unit
FORMULA_ID         --���㹫ʽ�ı��ʽID, from sys_policy
SHARE_NUM          --��Ʒ�����û���
*/
select a.*,a.rowid from pd.PM_CURVE_SEGMENTS a where a.curve_id=70000161;
select * from sd.sys_policy where policy_id in (810200007,810200008);
---------
/*
��Ŀ˰�ʱ����Ͽ�Ŀȷ��ӳ���ֱ�Ӹ��¼���
*/
select a.*,a.rowid from PD.PM_ITEM_TAX_RATE a;

select a.*,a.rowid from PD.PM_ITEM_SPLIT_RATE a;
select a.*,a.rowid from PD.PM_PROD_TRANSFER_GROUP_DTL a;
select a.*,a.rowid from PD.PM_PROD_TRANSFER_GROUP a;























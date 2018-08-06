delete from pd.PM_COMPONENT_PRODOFFER_PRICE where price_id between 303000001 and 303000011;
delete from pd.PM_ADJUST_RATES where adjustrate_id between 889900001 and 889900011;
delete from pd.PM_ADJUST_SEGMENT where adjustrate_id between 889900001 and 889900011;
delete from pd.PM_BILLING_DISCOUNT_DTL where price_id between 303000001 and 303000011;
COMMIT;

--(PRICE_ID, NAME, PRICE_TYPE, TAX_INCLUDED, DESCRIPTION)
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000001','����-�ײͷѰ�ʵ���������������̯�����޳�ȫ��ͣ��','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000002','����-�ײͷѰ�ʵ���������������̯��Ҫ�޳�ȫ��ͣ��','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000003','����-�ײͷѰ���һ������ȡ','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000004','����-���°������㣬��������ȡȫ�·��ã�����һ����ȡ','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000005','����-ָ����Ŀ����̶����','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000006','����-�˵����ܷ��ô���','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000007','�ⶥ-�˵����ܷ��÷ⶥ','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000008','����-�˵����ܷ��ñ���','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000009','�˻��Ż�-�˵����ܷ��ô���','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000010','�˻��Ż�-�˵����ܷ��ñ���','8','0','VB��ӵ���__'||sysdate);
insert into pd.PM_COMPONENT_PRODOFFER_PRICE values ('303000011','�˻��Ż�-ָ����Ŀ����̶����','8','0','VB��ӵ���__'||sysdate);

--(ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
insert into pd.PM_ADJUST_RATES values ('889900001','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900002','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900003','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900004','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900005','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900006','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900007','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900008','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900009','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900010','0','VB��ӵ���__'||sysdate);
insert into pd.PM_ADJUST_RATES values ('889900011','0','VB��ӵ���__'||sysdate);

--(ADJUSTRATE_ID, EXPR_ID, REF_TYPE, VALID_CYCLE, EXPIRE_CYCLE, BASE_ITEM, REF_CYCLES, ADJUST_ITEM, ADJUST_CYCLE_TYPE, FILL_ITEM, ADJUST_TYPE, PRIORITY, START_VAL, END_VAL, NUMERATOR, DENOMINATOR, REWARD_ID, PRECISION_ROUND, ACCOUNT_SHARE_FLAG, ITEM_SHARE_FLAG, DISC_TYPE, PARA_USE_RULE, FORMULA_ID, MAXIMUM, DONATE_USE_RULE, PROM_TYPE, REF_ROLE, RESULT_ROLE, DESCRIPTION, FILL_USER_MODE, FILL_USER_TOP, TAIL_MODE)
--���ʣ����� �����Ŀ��δ��룿������
insert into pd.PM_ADJUST_SEGMENT values ('889900001','0','2','0','0','10959','1','10959','1','10959','1','1','0','-1','0','0','0','3','0','20','0','0','0','-1','0','0','0','0','����-�ײͷѰ�ʵ���������������̯�����޳�ȫ��ͣ��','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900002','0','2','0','0','10959','1','10959','1','10959','1','1','0','-1','0','0','0','3','0','20','0','0','0','-1','0','0','0','0','����-�ײͷѰ�ʵ���������������̯��Ҫ�޳�ȫ��ͣ��','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900003','0','2','0','0','80001','1','80001','1','80001','1','1','0','-1','0','0','0','3','0','20','0','0','0','-1','0','4','0','0','����-���°������㣬��������ȡȫ�·��ã�����һ����ȡ','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900004','0','2','0','0','10148','1','10148','1','10148','1','1','0','-1','0','0','0','3','0','20','0','0','0','-1','0','0','0','0','����-�ײͷѰ���һ������ȡ','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900005','0','2','0','0','10505','1','10505','1','10505','1','1','0','-1','0','0','0','3','0','20','0','0','0','-1','0','0','0','0','����-ָ����Ŀ����̶����','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900006','0','2','0','0','10505','1','10505','1','10505','1','1','0','-1','0','0','0','3','0','20','0','0','0','-1','0','0','0','0','����-�˵����ܷ��ô���','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900007','0','2','0','0','80001','1','80001','1','80001','1','1','0','-1','0','0','0','3','0','20','0','0','0','-1','0','1','0','0','�ⶥ-�˵����ܷ��÷ⶥ','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900008','0','2','0','0','80001','1','80001','1','80001','1','1','0','-1','0','0','0','3','0','20','0','0','0','-1','0','3','0','0','����-�˵����ܷ��ñ���','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900009','0','2','0','0','80001','1','80001','1','80001','1','1','0','-1','0','0','0','3','1','20','0','0','0','-1','0','5','0','0','�˻��Ż�-�˵����ܷ��ô���','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900010','0','2','0','0','80001','1','80001','1','80001','1','1','0','-1','0','0','0','3','1','20','0','0','0','-1','0','1','0','0','�˻��Ż�-�˵����ܷ��ñ���','1','-1','0');
insert into pd.PM_ADJUST_SEGMENT values ('889900011','0','2','0','0','80001','1','80001','1','80001','1','1','0','-1','0','0','0','3','1','20','0','0','0','-1','0','5','0','0','�˻��Ż�-ָ����Ŀ����̶����','1','-1','0');
update pd.PM_ADJUST_SEGMENT set expr_id = (select policy_id from ucr_param.zhangjt_cond where cond_id = 50000482) where adjustrate_id between 889900001 and 889900011;

--(PRICE_ID, CALC_SERIAL, ADJUSTRATE_ID, VALID_DATE, EXPIRE_DATE, USE_TYPE, MEASURE_ID, DESCRIPTION)
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000001','1','889900001', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000002','1','889900002', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000003','1','889900003', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000004','1','889900004', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000005','1','889900005', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000006','1','889900006', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000007','1','889900007', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000008','1','889900008', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000009','1','889900009', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000010','1','889900010', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);
insert into pd.PM_BILLING_DISCOUNT_DTL values ('303000011','1','889900011', to_date('01-01-2002','dd-mm-yyyy'), to_date('01-01-2100','dd-mm-yyyy'), '0','10403','VB��ӵ���__'||sysdate);

COMMIT;

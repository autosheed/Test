delete from pd.PMP_PRICE_PARAM_DEF where priceid between 303000001 and 303000011;
delete from pd.PMP_OFFER_TMP_DETAIL where priceid between 303000001 and 303000011;
delete from pd.PMP_PRICE_PRIORITY_DEF where SERVICE_SPEC_ID = 80000;
COMMIT;

--1. (PRICEID, SERVICE_SPEC_ID, PRICE_NAME, DESCRIPTION, PRICE_TYPE, BOSSPARAM_ID, PARAM_TYPE, UNIT_TYPE, VALUE_METHOD, VALUE_PARAM)
insert into pd.PMP_PRICE_PARAM_DEF values ('303000001','80000','�ײͷѰ�ʵ���������������̯�����޳�ȫ��ͣ��','�ײͷ�X��/��','8','820003','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000001','80000','�ײͷѰ�ʵ���������������̯�����޳�ȫ��ͣ��','��ĿID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000002','80000','�ײͷѰ�ʵ���������������̯��Ҫ�޳�ȫ��ͣ��','�ײͷ�X��/��','8','820015','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000002','80000','�ײͷѰ�ʵ���������������̯��Ҫ�޳�ȫ��ͣ��','��ĿID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000003','80000','ȫ��һ������ȡ','�ײͷ�X��/��','8','820004','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000003','80000','ȫ��һ������ȡ','��ĿID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000004','80000','���°������㣬��������ȡȫ�·��ã�����һ����ȡ','�ײͷ�X��/��','8','820013','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000004','80000','���°������㣬��������ȡȫ�·��ã�����һ����ȡ','��ĿID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000005','80000','ָ����Ŀ����̶����','����̶����X��/��','8','820005','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000005','80000','ָ����Ŀ����̶����','��ĿID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000006','80000','�˵����ܷ��ô���','1.�ܷ����ۿۣ�x%','8','820002','5','5','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000006','80000','�˵����ܷ��ô���','��ĿID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000007','80000','�˵����ܷ��÷ⶥ','1.�û��ܷ��÷ⶥX��','8','820001','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000008','80000','�˵����ܷ��ñ���','1.�û��ܷ��ñ���X��','8','820001','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000008','80000','�˵����ܷ��ñ���','���ײο���ĿID','8','821004','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000008','80000','�˵����ܷ��ñ���','�������ÿ�ĿID','8','821001','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000009','80000','�˻��Ż�-�˵����ܷ��ô���','1.�ܷ����ۿۣ�x%','8','820002','5','5','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000009','80000','�˻��Ż�-�˵����ܷ��ô���','��ĿID','8','821003','5','5','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000010','80000','�˻��Ż�-�˵����ܷ��ñ���','1.�û��ܷ��ñ���X��','8','820001','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000010','80000','�˻��Ż�-�˵����ܷ��ñ���','���ײο���Ŀ','8','821004','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000010','80000','�˻��Ż�-�˵����ܷ��ñ���','�������ÿ�Ŀ','8','821001','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000011','80000','�˻��Ż�-ָ����Ŀ����̶����','����̶����X��/��','8','820005','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000011','80000','�˻��Ż�-ָ����Ŀ����̶����','��ĿID','8','821003','6','6','0','','0','0','0','0');

--2. 
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000001','303000001','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000001','303000002','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000001','303000003','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000001','303000004','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000001','303000005','-2','7100','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000001','303000006','-2','7280','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000001','303000007','-2','7280','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000001','303000008','-2','8540','0');

insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000002','303000001','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000002','303000002','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000002','303000003','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000002','303000004','-2','7000','0');

insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000003','303000001','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000003','303000002','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000003','303000003','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000003','303000004','-2','7000','0');

insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000004','303000001','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000004','303000002','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000004','303000003','-2','7000','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000004','303000004','-2','7000','0');

insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000005','303000009','-2','101','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000005','303000010','-2','8540','0');
insert into pd.PMP_OFFER_TMP_DETAIL (OFFER_TMP_ID, PRICEID, SERVID, PRIORITY, FORWARD_PRIORITY) values ('810000005','303000011','-2','7100','0');

--3. ���ȼ�  (SERVICE_SPEC_ID, PRICE_TYPE, PRIORITY, FORWARD_PRIORITY, REMARK)
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','7000','0','���������Ż� 7000-7099');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','7100','0','���������Ż� 7100-7300');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','8050','0','���ⲹ�����Ż� 7550-8100');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','8410','0','���ⲹ�շ�ʽʵ����������� 8401-8420');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','8460','0','������������� 8430-8500');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','8540','0','����������� 8511-8599');

COMMIT;

--��Ʒ����ʹ��
delete from pd.PM_PRICE_PARAM;
commit;
insert into pd.PM_PRICE_PARAM (ID, NAME, CODE) values ('1', '�ں�ͨ�ż������ײͲ�����-���׷�', '20002001');
insert into pd.PM_PRICE_PARAM (ID, NAME, CODE) values ('2', 'һ�廯��Լ������Ѳ�������', '2101');
insert into pd.PM_PRICE_PARAM (ID, NAME, CODE) values ('3', 'ʡ������ͳ���ʷ�', '5017036');
commit;
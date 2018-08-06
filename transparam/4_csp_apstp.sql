delete from pd.PMP_PRICE_PARAM_DEF where priceid between 303000001 and 303000011;
delete from pd.PMP_OFFER_TMP_DETAIL where priceid between 303000001 and 303000011;
delete from pd.PMP_PRICE_PRIORITY_DEF where SERVICE_SPEC_ID = 80000;
COMMIT;

--1. (PRICEID, SERVICE_SPEC_ID, PRICE_NAME, DESCRIPTION, PRICE_TYPE, BOSSPARAM_ID, PARAM_TYPE, UNIT_TYPE, VALUE_METHOD, VALUE_PARAM)
insert into pd.PMP_PRICE_PARAM_DEF values ('303000001','80000','套餐费按实际作用天数按天分摊，不剔除全天停机','套餐费X厘/月','8','820003','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000001','80000','套餐费按实际作用天数按天分摊，不剔除全天停机','科目ID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000002','80000','套餐费按实际作用天数按天分摊，要剔除全天停机','套餐费X厘/月','8','820015','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000002','80000','套餐费按实际作用天数按天分摊，要剔除全天停机','科目ID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000003','80000','全月一次性收取','套餐费X厘/月','8','820004','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000003','80000','全月一次性收取','科目ID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000004','80000','首月按天折算，非首月收取全月费用，费用一次收取','套餐费X厘/月','8','820013','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000004','80000','首月按天折算，非首月收取全月费用，费用一次收取','科目ID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000005','80000','指定科目减免固定金额','减免固定金额X厘/月','8','820005','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000005','80000','指定科目减免固定金额','科目ID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000006','80000','账单级总费用打折','1.总费用折扣：x%','8','820002','5','5','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000006','80000','账单级总费用打折','科目ID','8','821003','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000007','80000','账单级总费用封顶','1.用户总费用封顶X厘','8','820001','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000008','80000','账单级总费用保底','1.用户总费用保底X厘','8','820001','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000008','80000','账单级总费用保底','保底参考科目ID','8','821004','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000008','80000','账单级总费用保底','保底作用科目ID','8','821001','6','6','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000009','80000','账户优惠-账单级总费用打折','1.总费用折扣：x%','8','820002','5','5','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000009','80000','账户优惠-账单级总费用打折','科目ID','8','821003','5','5','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000010','80000','账户优惠-账单级总费用保底','1.用户总费用保底X厘','8','820001','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000010','80000','账户优惠-账单级总费用保底','保底参考科目','8','821004','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000010','80000','账户优惠-账单级总费用保底','保底作用科目','8','821001','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000011','80000','账户优惠-指定科目减免固定金额','减免固定金额X厘/月','8','820005','4','4','0','','0','0','0','0');
insert into pd.PMP_PRICE_PARAM_DEF values ('303000011','80000','账户优惠-指定科目减免固定金额','科目ID','8','821003','6','6','0','','0','0','0','0');

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

--3. 优先级  (SERVICE_SPEC_ID, PRICE_TYPE, PRIORITY, FORWARD_PRIORITY, REMARK)
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','7000','0','纯补收类优惠 7000-7099');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','7100','0','纯减免类优惠 7100-7300');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','8050','0','减免补收类优惠 7550-8100');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','8410','0','减免补收方式实现最低消费类 8401-8420');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','8460','0','减免最低消费类 8430-8500');
insert into pd.PMP_PRICE_PRIORITY_DEF values ('80000','8','8540','0','纯最低消费类 8511-8599');

COMMIT;

--产品管理使用
delete from pd.PM_PRICE_PARAM;
commit;
insert into pd.PM_PRICE_PARAM (ID, NAME, CODE) values ('1', '融合通信集团年套餐参数版-保底费', '20002001');
insert into pd.PM_PRICE_PARAM (ID, NAME, CODE) values ('2', '一体化合约最低消费参数配置', '2101');
insert into pd.PM_PRICE_PARAM (ID, NAME, CODE) values ('3', '省内流量统付资费', '5017036');
commit;
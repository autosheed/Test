drop table zhangjt_tp_modify;
create table zhangjt_tp_modify as
select * from ng_tmp_tp_discnt where feepolicy_id in (34148,34139,34138,34140,34137,34136,34141,34146,34089);

--backup
create table PM_ADJUST_SEGMENT_bak0103 as select * from pd.PM_ADJUST_SEGMENT;
create table PM_COMPOSITE_OFFER_PRICE as select * from pd.PM_COMPOSITE_OFFER_PRICE;
create table PM_COMPONENT_PRODOFFER_PRICE as select * from PD.PM_COMPONENT_PRODOFFER_PRICE;
create table PM_BILLING_DISCOUNT_DTL as select * from pd.PM_BILLING_DISCOUNT_DTL;

--del   先删除列表资费的所有费率曲线
delete from pd.PM_ADJUST_SEGMENT a
 where exists (select 1 from zhangjt_tp_modify b where a.adjustrate_id = b.adjustrate_id and a.expr_id = b.cond_ids);

--check
select a.*,a.rowid from pd.PM_ADJUST_SEGMENT a where adjustrate_id like '81001%';
update zhangjt_tp_modify set adjustrate_id = adjustrate_id + 10000;
--check
select * from PD.PM_COMPOSITE_OFFER_PRICE a where price_id = 862017702;
update zhangjt_tp_modify set price_id = 62017702;

select * from zhangjt_tp_modify;


--新增定价声明
insert into PD.PM_COMPONENT_PRODOFFER_PRICE select 862017702,'优惠定价-没名字~',8,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss') from dual;
--直接修改定价计划与定价的关联，切断资费与原定价的关系 ??
update PD.PM_COMPOSITE_OFFER_PRICE a set a.price_id = 862017702 
 where pricing_plan_id in (34148,34139,34138,34140,34137,34136,34141,34146,34089) and price_id = 861017702;
--插入定价与费率曲线的关联
insert into PD.PM_BILLING_DISCOUNT_DTL (PRICE_ID, CALC_SERIAL, ADJUSTRATE_ID,VALID_DATE, EXPIRE_DATE, USE_TYPE, MEASURE_ID, DESCRIPTION)
  SELECT distinct price_id+800000000,100-a.ORDER_NO,a.ADJUSTRATE_ID,to_date('01-01-2002', 'dd-mm-yyyy'),to_date('01-01-2100', 'dd-mm-yyyy'),0,  --日月账都有效
    10403,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
    FROM zhangjt_tp_modify a
--插入费率曲线
INSERT INTO PD.PM_ADJUST_RATES (ADJUSTRATE_ID, CALC_TYPE, DESCRIPTION)
  SELECT DISTINCT a.ADJUSTRATE_ID,0,'VB割接导入 -- '||to_char(sysdate,'yyyymmddhh24miss')
    FROM zhangjt_tp_modify a;
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
FROM zhangjt_tp_modify a
WHERE discnt_type = 'B';

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
FROM zhangjt_tp_modify a
where discnt_type = 'C';
    
    

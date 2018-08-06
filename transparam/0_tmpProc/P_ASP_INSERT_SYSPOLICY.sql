CREATE OR REPLACE PROCEDURE P_ASP_INSERT_SYSPOLICY
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
-----------------------------------------------------
--VerisBilling参数割接使用
-----------------------------------------------------
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_ASP_INSERT_SYSPOLICY 过程执行成功!';

    BEGIN
/*
22:    固定费用计算公式
23:    账务优惠计算公式
26:    固费资费生效条件
27:    账务优惠生效条件
28:    固费状态条件
*/
        --清理之前导入的数据
        delete from sd.sys_policy where policy_id between 800000000 and 899999999;
        --固费生效条件
        insert into sd.sys_policy(POLICY_ID,NAME,use_trigger,policy_expr,description)
        select policy_id,policy_name,'28',policy_expr,'APS固费状态条件' from VB_TMP_POLICY_RENTFEE_COND where policy_id like '%810101%';

        --优惠生效条件
        insert into sd.sys_policy(POLICY_ID,NAME,use_trigger,policy_expr,description)
        select policy_id,nvl(remark,0),27,nvl(policy_expr,0),'APS优惠条件' from zhangjt_cond;
        --优惠作用条件
        insert into  sd.sys_policy(POLICY_ID,NAME,use_trigger,policy_expr,description)
        select policy_id,'优惠作用',23,policy_expr,'APS优惠作用' from VB_TMP_POLICY_FEEDISCNT;
        --一次性费用
        insert into  sd.sys_policy(POLICY_ID,NAME,use_trigger,policy_expr,description)
        select distinct policy_id,'一次性费用',23,policy_expr,'一次性费用' from NG_TMP_OTPFEE;


        --固费作用条件
        -----1-----
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values ('810200001', '固费按天收取 不规整', '22',
        'local t_RcMarkerDays=RC_MARKER_DAYS(p)
        local t_RcRateValue=RC_RATE_VALUE(p)
        local t_fee=t_RcRateValue * t_RcMarkerDays

        return t_fee','按天收取cycle_type_id = 4	不规整 sumtoint_type = ‘00’');

        -----2-----
        --状态天数
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values (810200002,'固费按天收取  子帐期费用相同规整',22,
        'local t_RcMarkerDays=RC_MARKER_DAYS(p)
        local t_RcBaseValue=RC_BASE_FEE(p)
        local t_RcRateValue=RC_RATE_VALUE(p)
        local cycleDays = CALC_CYCLE_DAYS(p)
        local currDate = RC_CALC_DAY(p)

        function if_expr(_inP1,_inP2,_inP3)
          if (_inP1==1) or (_inP1==true) then
            return _inP2
          else
            return _inP3
          end
        end
        --月末 全月费用相同 进行规整
          if(currDate%100 == cycleDays and cycleDays==t_RcMarkerDays and t_RcRateValue>0 ) then
              return t_RcBaseValue
          else
              return (if_expr( t_RcMarkerDays > 0 , t_RcRateValue * t_RcMarkerDays , 0 ))
          end','按天收取cycle_type_id = 4	全月费用相同规整 sumtoint_type = ‘10’');
          
        -----------3----------return ((((t_cnt * t_RcRateValue + 5) / 10) + 5) / 10)
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values (810200003,'固费上下半月收取',22,
        'local t_cnt = RC_MARKER_HALF_MONTHS(p)
         local t_RcRateValue = RC_RATE_VALUE(p)
         
         return t_cnt*t_RcRateValue','按上下半月收取 cycle_type_id = 7');
        

        -----------4--------
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values ('810200004', '按月收取 月初显示 首月不按天折算', '22',
        '--按月收取，月初显示
return RC_BASE_FEE(p)', '按月收取 cycle_type_id = 8  月初显示 sumtoint_type = ‘00’  首月不按天折算');

        -----------5--------
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values ('810200005', '按月收取 月初显示 首月按天折算', '22',
        '--按月收取，月初显示
        local cycle_fee = RC_BASE_FEE(p)
        local tpBeginDate = RC_PROD_VALID_DATE(p)/1000000
        local cycleBeginDate = CALC_BILL_BEGIN_DATE(p)
        local cycleEndDate = CALC_BILL_END_DATE(p)
        local cycleHalfDate = CALC_HALF_MONTH_TIME(p)/1000000
        local currDate = RC_CALC_DAY(p)

        function calc_marker_hms(_inParam1,_inParam2)
          local t_CalcDays = CALC_GET_DAYS(p,_inParam1,_inParam2)
          if t_CalcDays>0 then
            return t_CalcDays
          else
            return 0
          end
        end

        if(tpBeginDate > cycleBeginDate and tpBeginDate < cycleEndDate and tpBeginDate <= currDate) then
          local duringDays = calc_marker_hms(tpBeginDate*1000000,currDate*1000000+235959)
          return  (1.0 * (cycle_fee*10) * 12 * duringDays / 365 + 5)/10
        else
          return cycle_fee
        end ', '按月收取 cycle_type_id = 8  月初显示 sumtoint_type = ‘00’  首月按天折算');

        -----------6--------停机保号费，按月收取，月初显示
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values ('810200006', '停机保号费，按月收取，月初显示', '22',
        '--按月收取，月初显示
        local cycle_fee = RC_BASE_FEE(p)
        local currDays = RC_CALC_DAY(p)%100
        local t_RcMarkerDays = RC_MARKER_DAYS(p)

        if currDays == t_RcMarkerDays then
          return cycle_fee
        end
        return 0', '停机保号费，按月收取，月初显示');

      EXCEPTION
      WHEN OTHERS THEN
           ROLLBACK;
           v_resulterrinfo:='P_NG_TMP_PARAM_ITEM err!:'||substr(SQLERRM,1,200);
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

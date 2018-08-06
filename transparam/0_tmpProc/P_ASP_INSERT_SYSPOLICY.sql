CREATE OR REPLACE PROCEDURE P_ASP_INSERT_SYSPOLICY
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
-----------------------------------------------------
--VerisBilling�������ʹ��
-----------------------------------------------------
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_ASP_INSERT_SYSPOLICY ����ִ�гɹ�!';

    BEGIN
/*
22:    �̶����ü��㹫ʽ
23:    �����Żݼ��㹫ʽ
26:    �̷��ʷ���Ч����
27:    �����Ż���Ч����
28:    �̷�״̬����
*/
        --����֮ǰ���������
        delete from sd.sys_policy where policy_id between 800000000 and 899999999;
        --�̷���Ч����
        insert into sd.sys_policy(POLICY_ID,NAME,use_trigger,policy_expr,description)
        select policy_id,policy_name,'28',policy_expr,'APS�̷�״̬����' from VB_TMP_POLICY_RENTFEE_COND where policy_id like '%810101%';

        --�Ż���Ч����
        insert into sd.sys_policy(POLICY_ID,NAME,use_trigger,policy_expr,description)
        select policy_id,nvl(remark,0),27,nvl(policy_expr,0),'APS�Ż�����' from zhangjt_cond;
        --�Ż���������
        insert into  sd.sys_policy(POLICY_ID,NAME,use_trigger,policy_expr,description)
        select policy_id,'�Ż�����',23,policy_expr,'APS�Ż�����' from VB_TMP_POLICY_FEEDISCNT;
        --һ���Է���
        insert into  sd.sys_policy(POLICY_ID,NAME,use_trigger,policy_expr,description)
        select distinct policy_id,'һ���Է���',23,policy_expr,'һ���Է���' from NG_TMP_OTPFEE;


        --�̷���������
        -----1-----
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values ('810200001', '�̷Ѱ�����ȡ ������', '22',
        'local t_RcMarkerDays=RC_MARKER_DAYS(p)
        local t_RcRateValue=RC_RATE_VALUE(p)
        local t_fee=t_RcRateValue * t_RcMarkerDays

        return t_fee','������ȡcycle_type_id = 4	������ sumtoint_type = ��00��');

        -----2-----
        --״̬����
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values (810200002,'�̷Ѱ�����ȡ  �����ڷ�����ͬ����',22,
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
        --��ĩ ȫ�·�����ͬ ���й���
          if(currDate%100 == cycleDays and cycleDays==t_RcMarkerDays and t_RcRateValue>0 ) then
              return t_RcBaseValue
          else
              return (if_expr( t_RcMarkerDays > 0 , t_RcRateValue * t_RcMarkerDays , 0 ))
          end','������ȡcycle_type_id = 4	ȫ�·�����ͬ���� sumtoint_type = ��10��');
          
        -----------3----------return ((((t_cnt * t_RcRateValue + 5) / 10) + 5) / 10)
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values (810200003,'�̷����°�����ȡ',22,
        'local t_cnt = RC_MARKER_HALF_MONTHS(p)
         local t_RcRateValue = RC_RATE_VALUE(p)
         
         return t_cnt*t_RcRateValue','�����°�����ȡ cycle_type_id = 7');
        

        -----------4--------
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values ('810200004', '������ȡ �³���ʾ ���²���������', '22',
        '--������ȡ���³���ʾ
return RC_BASE_FEE(p)', '������ȡ cycle_type_id = 8  �³���ʾ sumtoint_type = ��00��  ���²���������');

        -----------5--------
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values ('810200005', '������ȡ �³���ʾ ���°�������', '22',
        '--������ȡ���³���ʾ
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
        end ', '������ȡ cycle_type_id = 8  �³���ʾ sumtoint_type = ��00��  ���°�������');

        -----------6--------ͣ�����ŷѣ�������ȡ���³���ʾ
        insert into sd.SYS_POLICY (POLICY_ID, NAME, USE_TRIGGER, POLICY_EXPR, DESCRIPTION)
        values ('810200006', 'ͣ�����ŷѣ�������ȡ���³���ʾ', '22',
        '--������ȡ���³���ʾ
        local cycle_fee = RC_BASE_FEE(p)
        local currDays = RC_CALC_DAY(p)%100
        local t_RcMarkerDays = RC_MARKER_DAYS(p)

        if currDays == t_RcMarkerDays then
          return cycle_fee
        end
        return 0', 'ͣ�����ŷѣ�������ȡ���³���ʾ');

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

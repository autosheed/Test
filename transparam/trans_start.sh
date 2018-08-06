#!/bin/bash
work_path="/sngrp/billbm/user/zhangjt/transparam"
if [ "0$1" = "0" ]
then
  echo "input param error !!!"
  echo case:: "trans_start 1 : 导入测试环境"
  echo case:: "trans_start 2 : 导入开发环境"
  echo case:: "trans_start 3 : 导入准生产环境"
  echo case:: "trans_start 4 : 导入并行环境"
  echo case:: "trans_start 5 : 导入生产环境"
  exit;
fi

mode=$1
if [ ${mode} -eq "1" ]
then
	db_info="ucr_param/ucr_param_acttst_3!@VBACTTST1"
	echo "--开始倒换测试环境参数--"
elif [ ${mode} -eq "2" ]
then
	db_info="ucr_param/ucr_param@boss"
	echo "--开始倒换开发环境参数--"
elif [ ${mode} -eq "3" ]
then
	db_info="ucr_param/1qazwsxparam@ACTYL1"
	echo "--开始倒换准生产环境参数--"
elif [ ${mode} -eq "4" ]
then
	db_info="UCR_PARAM/Ff#*dfcd5@ACTPAR1"
	echo "--开始倒换并行环境参数--"
elif [ ${mode} -eq "5" ]
then
	db_info="UCR_PARAM/IW375CQI@Ngactdb1"
	echo "--开始倒换生产环境参数--"
fi

cat << !!! > ${work_path}/procedure_create.sql
set serveroutput on
connect ${db_info};
exec dbms_output.put_line('----${db_info}-----');
exec dbms_output.put_line('----1_ng2vb_tmpTab_create-----');
@1_ng2vb_tmpTab_create
exec dbms_output.put_line('----tmpProc create-----');
@${work_path}/0_tmpProc/p_geyf_userdiscnt_price
@${work_path}/0_tmpProc/p_zhangjt_getDiscntPrice
@${work_path}/0_tmpProc/p_zhangjt_getServPrice
@${work_path}/0_tmpProc/p_zhangjt_deal_stateset
@${work_path}/0_tmpProc/p_zhangjt_updateparam_cond
@${work_path}/0_tmpProc/p_xuqk_compcond_name
@${work_path}/0_tmpProc/p_zhangjt_compcond_lua
@${work_path}/0_tmpProc/p_zhangjt_deal_compcond
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_DAYGPRS
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_ADDUPSPEC
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_SERV_PRE
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_DISCNT_PRE
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_SERV
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_DISCNT
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_OTPFEE
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_GRPSTP
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_SPECIAL_TP
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_ITEM
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_FENZHANG
@${work_path}/0_tmpProc/P_NG_TMP_PARAM_YGZ
@${work_path}/0_tmpProc/P_ASP_INSERT_SYSPOLICY
@${work_path}/0_tmpProc/P_ASP_INSERT_USERSTATUS

exec dbms_output.put_line('----2_loadNGparam-----');
@2_loadNGparam

PROMPT ============================  开始倒换  ============================ 
PROMPT ====================== 1 P_NG_TMP_PARAM_SERV_PRE ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_SERV_PRE(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 2 P_NG_TMP_PARAM_DISCNT_PRE ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_DISCNT_PRE(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 3 P_NG_TMP_PARAM_SERV ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_SERV(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 4 P_NG_TMP_PARAM_DISCNT ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_DISCNT(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 5 P_NG_TMP_PARAM_GRPSTP ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_GRPSTP(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 6 P_NG_TMP_PARAM_SPECIAL_TP ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_SPECIAL_TP(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 7 P_NG_TMP_PARAM_OTPFEE ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_OTPFEE(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 9 P_NG_TMP_PARAM_ITEM ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_ITEM(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 10 P_NG_TMP_PARAM_FENZHANG ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_FENZHANG(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 11 P_NG_TMP_PARAM_YGZ ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_NG_TMP_PARAM_YGZ(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 12 P_ASP_INSERT_SYSPOLICY ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_ASP_INSERT_SYSPOLICY(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
PROMPT ====================== 13 P_ASP_INSERT_USERSTATUS ===================
DECLARE
 v_resultcode      NUMBER(8);
 v_resulterrinfo   VARCHAR2(100);
BEGIN
  P_ASP_INSERT_USERSTATUS(v_resultcode,v_resulterrinfo);
  dbms_output.put_line(v_resulterrinfo);
END; 
/
exec dbms_output.put_line('----3_csp_apstemplate-----');
@3_csp_apstemplate
exec dbms_output.put_line('----4_csp_apstp-----');
@4_csp_apstp
		quit;
!!!
sqlplus -S /nolog @${work_path}/procedure_create.sql;
rm -f ${work_path}/procedure_create.sql;

echo "over"

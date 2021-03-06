--1 NG参数导入
--  zhangjt@20160429
SET TIMING OFF;
set HEADING OFF;
set ECHO OFF;
SET FEEDBACK OFF;

--1.1清理NG版本参数表
PROMPT .
PROMPT .
PROMPT ============================ 1.1 DROP TABLE: 清理NG版本参数表 ============================

--系统级参数
DROP TABLE NG_TD_B_SYSPARAM;
--流量统付
DROP TABLE NG_TD_B_CENPAY_TP;
--系统级资费
DROP TABLE NG_TD_BASE_TARIFF;

--固定费
DROP TABLE NG_TD_B_PRODUCT;
DROP TABLE NG_TD_B_SERVICE;         
DROP TABLE NG_TD_S_SERVICESTATE;
DROP TABLE NG_TD_B_DEFAULT_FEEPOLICY;
DROP TABLE NG_TD_B_CYCLEFEE_RULE;
DROP TABLE NG_TD_B_EVENTTYPE;

--资费树
DROP TABLE NG_TD_B_DISCNT;
DROP TABLE NG_TD_B_FEEPOLICY_COMP;
DROP TABLE NG_TD_B_FEEPOLICY_PARAM;
DROP TABLE NG_TD_B_EVENT_FEEPOLICY;
DROP TABLE NG_TD_B_PRICE;
DROP TABLE NG_TD_B_PRICE_COMP;
DROP TABLE NG_TD_B_PRICE_PARAM;
DROP TABLE NG_TD_B_PRICE_PARAMIMPL;
DROP TABLE NG_TD_B_FEECOUNT;
DROP TABLE NG_TD_B_FEEDISCNT;

--累积量
DROP TABLE NG_TD_B_ADDUP;
DROP TABLE NG_TD_B_ADDUPITEM;
DROP TABLE NG_TD_B_ADDUP_CYCLERULE;

--条件
DROP TABLE NG_TD_B_COND;
DROP TABLE NG_TD_B_COMPCOND;
DROP TABLE NG_TD_B_SIMPLECOND;
DROP TABLE NG_TD_B_ENUMPARAM;

--对象
DROP TABLE NG_TD_B_OBJECT;
DROP TABLE NG_TD_B_EVENTELEM;
DROP TABLE NG_TD_B_INFOELEM;

--科目
DROP TABLE NG_TD_B_ITEM;
DROP TABLE NG_TD_B_COMPITEM;
DROP TABLE NG_TD_B_DETAILITEM;
DROP TABLE NG_TD_B_FEETRANSRULE;
DROP TABLE NG_TD_B_SUMBILL;

--免费资源
DROP TABLE NG_TD_B_QUERYFEESET;

--1.2导入NG版本参数表
PROMPT .
PROMPT .
PROMPT ============================ 1.2 CREATE TABLE: 导入NG版本参数表 ============================

--系统级参数
PROMPT CREATE TABLE: 系统级参数
CREATE TABLE NG_TD_B_SYSPARAM           AS SELECT * FROM TD_B_SYSPARAM;

--流量统付
PROMPT CREATE TABLE: 流量统付
CREATE TABLE NG_TD_B_CENPAY_TP          AS SELECT * FROM TD_B_CENPAY_TP;

--系统级资费
PROMPT CREATE TABLE: 系统级资费
CREATE TABLE NG_TD_BASE_TARIFF          AS SELECT * FROM TD_BASE_TARIFF;

--固定费
PROMPT CREATE TABLE: 固定费
CREATE TABLE NG_TD_B_PRODUCT            AS SELECT * FROM TD_B_PRODUCT;
CREATE TABLE NG_TD_B_SERVICE            AS SELECT * FROM td_b_service;
CREATE TABLE NG_TD_S_SERVICESTATE       AS SELECT * FROM TD_S_SERVICESTATE;
CREATE TABLE NG_TD_B_DEFAULT_FEEPOLICY  AS SELECT * FROM TD_B_DEFAULT_FEEPOLICY;
CREATE TABLE NG_TD_B_CYCLEFEE_RULE      AS SELECT * FROM TD_B_CYCLEFEE_RULE;
CREATE TABLE NG_TD_B_EVENTTYPE          AS SELECT * FROM TD_B_EVENTTYPE;

--资费树
PROMPT CREATE TABLE: 资费树
CREATE TABLE NG_TD_B_DISCNT              AS SELECT * FROM TD_B_DISCNT;
update NG_TD_B_DISCNT set RSRV_STR3=replace(RSRV_STR3,' ');
CREATE TABLE NG_TD_B_FEEPOLICY_COMP      AS SELECT * FROM TD_B_FEEPOLICY_COMP;
CREATE TABLE NG_TD_B_FEEPOLICY_PARAM     AS SELECT * FROM TD_B_FEEPOLICY_PARAM;
CREATE TABLE NG_TD_B_EVENT_FEEPOLICY     AS SELECT * FROM TD_B_EVENT_FEEPOLICY;
CREATE TABLE NG_TD_B_PRICE               AS SELECT * FROM TD_B_PRICE;
CREATE TABLE NG_TD_B_PRICE_COMP          AS SELECT * FROM TD_B_PRICE_COMP;
CREATE TABLE NG_TD_B_PRICE_PARAM         AS SELECT * FROM TD_B_PRICE_PARAM;
CREATE TABLE NG_TD_B_PRICE_PARAMIMPL     AS SELECT * FROM TD_B_PRICE_PARAMIMPL;
CREATE TABLE NG_TD_B_FEECOUNT            AS SELECT * FROM TD_B_FEECOUNT;
CREATE TABLE NG_TD_B_FEEDISCNT           AS SELECT * FROM TD_B_FEEDISCNT;


--累积量
PROMPT CREATE TABLE: 累积量
CREATE TABLE NG_TD_B_ADDUP               AS SELECT * FROM TD_B_ADDUP;
CREATE TABLE NG_TD_B_ADDUPITEM           AS SELECT * FROM TD_B_ADDUPITEM;
CREATE TABLE NG_TD_B_ADDUP_CYCLERULE     AS SELECT * FROM TD_B_ADDUP_CYCLERULE;

--条件
PROMPT CREATE TABLE: 条件
CREATE TABLE NG_TD_B_COND                AS SELECT * FROM TD_B_COND;
CREATE TABLE NG_TD_B_COMPCOND            AS SELECT * FROM TD_B_COMPCOND;
CREATE TABLE NG_TD_B_SIMPLECOND          AS SELECT * FROM TD_B_SIMPLECOND;
CREATE TABLE NG_TD_B_ENUMPARAM           AS SELECT * FROM TD_B_ENUMPARAM;

--对象
PROMPT CREATE TABLE: 对象
CREATE TABLE NG_TD_B_OBJECT              AS SELECT * FROM TD_B_OBJECT;
CREATE TABLE NG_TD_B_EVENTELEM           AS SELECT * FROM TD_B_EVENTELEM;
CREATE TABLE NG_TD_B_INFOELEM            AS SELECT * FROM TD_B_INFOELEM;

--科目
PROMPT CREATE TABLE: 科目
CREATE TABLE NG_TD_B_ITEM                AS SELECT * FROM TD_B_ITEM;
CREATE TABLE NG_TD_B_COMPITEM            AS SELECT * FROM TD_B_COMPITEM;
CREATE TABLE NG_TD_B_DETAILITEM          AS SELECT * FROM TD_B_DETAILITEM;
CREATE TABLE NG_TD_B_FEETRANSRULE        AS SELECT * FROM TD_B_FEETRANSRULE;
CREATE TABLE NG_TD_B_SUMBILL             AS SELECT * FROM TD_B_SUMBILL;

--免费资源
PROMPT CREATE TABLE: 免费资源
CREATE TABLE NG_TD_B_QUERYFEESET         AS SELECT * FROM TD_B_QUERYFEESET;

--1.3 创建NG版本参数表索引
PROMPT .
PROMPT .
PROMPT ============================ 1.3 CREATE INDEX: 创建NG版本参数表索引 ============================

CREATE INDEX IDX_NG_TD_B_PRICE_COMP    ON NG_TD_B_PRICE_COMP(PRICE_ID,P_NODE_ID);
alter table NG_TD_B_PRICE_COMP add constraint PK_NG_TD_B_PRICE_COMP primary key (NODE_ID, PRICE_ID);
CREATE INDEX IDX_NG_TMP_FEEPOLOICY ON NG_TMP_FEEPOLOICY(PRICE_ID);

--1.4 统计NG版本参数表记录
PROMPT .
PROMPT .
PROMPT ============================ 1.4 COUNT TABLE: 统计NG版本参数表记录 ============================
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_SYSPARAM'         ,COUNT(*),SYSDATE FROM NG_TD_B_SYSPARAM;

INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_CENPAY_TP'        ,COUNT(*),SYSDATE FROM NG_TD_B_CENPAY_TP;

INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_BASE_TARIFF'        ,COUNT(*),SYSDATE FROM NG_TD_BASE_TARIFF;

INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_PRODUCT'          ,COUNT(*),SYSDATE FROM NG_TD_B_PRODUCT;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_SERVICE'          ,COUNT(*),SYSDATE FROM NG_TD_B_SERVICE;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_S_SERVICESTATE'     ,COUNT(*),SYSDATE FROM NG_TD_S_SERVICESTATE;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_DEFAULT_FEEPOLICY',COUNT(*),SYSDATE FROM NG_TD_B_DEFAULT_FEEPOLICY;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_CYCLEFEE_RULE'    ,COUNT(*),SYSDATE FROM NG_TD_B_CYCLEFEE_RULE;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_EVENTTYPE'        ,COUNT(*),SYSDATE FROM NG_TD_B_EVENTTYPE;

INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_DISCNT'           ,COUNT(*),SYSDATE FROM NG_TD_B_DISCNT;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_FEEPOLICY_COMP'   ,COUNT(*),SYSDATE FROM NG_TD_B_FEEPOLICY_COMP;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_FEEPOLICY_PARAM'  ,COUNT(*),SYSDATE FROM NG_TD_B_FEEPOLICY_PARAM;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_EVENT_FEEPOLICY'  ,COUNT(*),SYSDATE FROM NG_TD_B_EVENT_FEEPOLICY;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_PRICE'            ,COUNT(*),SYSDATE FROM NG_TD_B_PRICE;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_PRICE_COMP'       ,COUNT(*),SYSDATE FROM NG_TD_B_PRICE_COMP;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_PRICE_PARAM'      ,COUNT(*),SYSDATE FROM NG_TD_B_PRICE_PARAM;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_PRICE_PARAMIMPL'  ,COUNT(*),SYSDATE FROM NG_TD_B_PRICE_PARAMIMPL;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_FEECOUNT'         ,COUNT(*),SYSDATE FROM NG_TD_B_FEECOUNT;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_FEEDISCNT'        ,COUNT(*),SYSDATE FROM NG_TD_B_FEEDISCNT;

INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_ADDUP'            ,COUNT(*),SYSDATE FROM NG_TD_B_ADDUP;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_ADDUPITEM'        ,COUNT(*),SYSDATE FROM NG_TD_B_ADDUPITEM;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_ADDUP_CYCLERULE'  ,COUNT(*),SYSDATE FROM NG_TD_B_ADDUP_CYCLERULE;

INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_COND'             ,COUNT(*),SYSDATE FROM NG_TD_B_COND;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_COMPCOND'         ,COUNT(*),SYSDATE FROM NG_TD_B_COMPCOND;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_SIMPLECOND'       ,COUNT(*),SYSDATE FROM NG_TD_B_SIMPLECOND;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_ENUMPARAM'        ,COUNT(*),SYSDATE FROM NG_TD_B_ENUMPARAM;

INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_OBJECT'           ,COUNT(*),SYSDATE FROM NG_TD_B_OBJECT;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_EVENTELEM'        ,COUNT(*),SYSDATE FROM NG_TD_B_EVENTELEM;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_INFOELEM'         ,COUNT(*),SYSDATE FROM NG_TD_B_INFOELEM;

INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_ITEM'             ,COUNT(*),SYSDATE FROM NG_TD_B_ITEM;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_COMPITEM'         ,COUNT(*),SYSDATE FROM NG_TD_B_COMPITEM;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_DETAILITEM'       ,COUNT(*),SYSDATE FROM NG_TD_B_DETAILITEM;
INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_FEETRANSRULE'     ,COUNT(*),SYSDATE FROM NG_TD_B_FEETRANSRULE;



INSERT INTO NG_TMP_TABLE_INFO SELECT '0','NG_TD_B_QUERYFEESET'      ,COUNT(*),SYSDATE FROM NG_TD_B_QUERYFEESET;

COMMIT;

select a.table_name,a.table_count,a.insert_time from NG_TMP_TABLE_INFO A WHERE a.TYPE='0' ORDER by 1,3 desc;

--1.5 特殊处理
--部分数据可能需要调整,根据各省情况不同分别进行处理
PROMPT .
PROMPT .
PROMPT ============================ 1.5 特殊数据处理 ============================

--1.5.1 TD_B_PRICE_COMP特殊处理,把NODE_GROUP_ID *10
PROMPT .
PROMPT .
PROMPT NG_TD_B_PRICE_COMP特殊处理,把NODE_GROUP *10
UPDATE NG_TD_B_PRICE_COMP SET NODE_GROUP = NODE_GROUP * 10;
COMMIT;

--PROMPT .
--PROMPT .
--PROMPT ============================ 1.6 清理上次倒换的VB资费树 ============================
--PROMPT .
--PROMPT .
--prompt EXEC PROC P_NG_TMP_DELETE... 
--DECLARE
-- v_resultcode      NUMBER(8);
-- v_resulterrinfo   VARCHAR2(100);
--BEGIN
--  P_NG_TMP_DELETE(v_resultcode,v_resulterrinfo);
--  dbms_output.put_line(v_resulterrinfo);
--END; 
--/
PROMPT .
PROMPT .


COMMIT;


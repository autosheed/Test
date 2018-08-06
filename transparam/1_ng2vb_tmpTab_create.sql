SET TIMING OFF;
set HEADING OFF;
set ECHO OFF;
SET FEEDBACK OFF;

PROMPT .
PROMPT .
PROMPT ============================ 0 CREATE TABLE: 创建中间临时表 ============================

--NG_TMP_TABLE_INFO
PROMPT CREATE TABLE:NG_TMP_TABLE_INFO
DROP TABLE NG_TMP_TABLE_INFO;
create table NG_TMP_TABLE_INFO
(
  TYPE        CHAR(1),
  table_name  varchar2(30),
  table_count number(8),
  insert_time date
);
comment on table NG_TMP_TABLE_INFO
  is 'VerisBilling参数割接帐务处理临时表,上线后可删除';

--NG_TMP_FEEPOLOICY
PROMPT CREATE TABLE:NG_TMP_FEEPOLOICY 
DROP TABLE NG_TMP_FEEPOLOICY;
create TABLE NG_TMP_FEEPOLOICY
(
product_offering_id number(9),
feepolicy_id        number(8),
FEEPOLICY_COMP_ID   number(8),
EVENT_PRIORITY      NUMBER(4),
EFFECT_ROLE_CODE    VARCHAR2(4),
DISCNT_TYPE         CHAR(1),
REPEAT_TYPE         CHAR(1),
FIRST_EFFECT        CHAR(1),
EVENT_TYPE_ID       NUMBER(4),
SERV_ID             number(8),
CYCLE_TYPE_ID       NUMBER(2),
COND_ID             number(8),
event_type_name    VARCHAR2(500),
price_id            number(8),
sumtoint_type       varchar2(10),
sumtoint_fee        NUMBER(8),
TYPE                CHAR(1),
is_daygprstp        CHAR(1)  default '0'
); 

comment on table NG_TMP_FEEPOLOICY
  is 'VerisBilling参数割接帐务处理临时表,上线后可删除';

COMMENT ON COLUMN NG_TMP_FEEPOLOICY.DISCNT_TYPE IS
'1:批价
2:包月费
3:共用';

COMMENT ON COLUMN NG_TMP_FEEPOLOICY.REPEAT_TYPE IS
'0:不可重复订购
1:可重复订购
2:分级';

COMMENT ON COLUMN NG_TMP_FEEPOLOICY.FIRST_EFFECT IS
'1:表示为基础套餐,订购首月需要折算免费资源
2:分散调整
3:分散及首月都调整
0:表示不需要折算';

COMMENT ON COLUMN NG_TMP_FEEPOLOICY.TYPE IS
'1:固定费计算
3:优惠处理
4:累积量计算
5:纯账务资费';

--PRICE_ID_SYS_CONNECT_BY_PATH_SERV
PROMPT CREATE TABLE:NG_SYS_CONNECT_BY_PATH_SERV 
DROP   TABLE NG_SYS_CONNECT_BY_PATH_SERV;  
create table NG_SYS_CONNECT_BY_PATH_SERV
(
  price_id NUMBER(8),
  type_id  NUMBER(2)
);
CREATE INDEX IDX_NG_PATH_SERV ON NG_SYS_CONNECT_BY_PATH_SERV(PRICE_ID);
--PRICE_ID_SYS_CONNECT_BY_PATH_DIS
PROMPT CREATE TABLE:NG_SYS_CONNECT_BY_PATH_DIS 
DROP   TABLE NG_SYS_CONNECT_BY_PATH_DIS;  
create table NG_SYS_CONNECT_BY_PATH_DIS
(
  price_id NUMBER(8),
  type_id  NUMBER(2)
);
CREATE INDEX IDX_NG_PATH_DIS ON NG_SYS_CONNECT_BY_PATH_DIS(PRICE_ID);

--NG_TMP_PRICE_SERV
PROMPT CREATE TABLE:NG_TMP_PRICE_SERV 
DROP   TABLE NG_TMP_PRICE_SERV;  
create table NG_TMP_PRICE_SERV
(
PRICE_ID      NUMBER(8),
ORDER_NO      NUMBER(3),
PATH_INFO     VARCHAR2(80),
COND_IDS      VARCHAR2(80),
COND_NAMES    VARCHAR2(4000),
STATUS_COND_ID   VARCHAR2(8),
STATUS_COND_NAME VARCHAR2(50),
OTHER_COND_ID    VARCHAR2(80),
OTHER_COND_NAME  VARCHAR2(80),
STATUS        CHAR(1),
trans_status  VARCHAR2(30),
EXEC_ID       NUMBER(8),
UNIT_RATIO    number(8),
PARAM_ID      VARCHAR2(8),
TYPE          CHAR(1),
REMARK        VARCHAR2(50)
);    

comment on table NG_TMP_PRICE_SERV
  is 'VerisBilling参数割接帐务处理临时表,上线后可删除';
  
COMMENT ON COLUMN NG_TMP_PRICE_SERV.TYPE IS
'1:固定费
2:条件特殊处理
3:0费用特殊处理';

PROMPT CREATE TABLE:NG_TMP_COND_DESC 
DROP TABLE NG_TMP_COND_DESC;
CREATE TABLE NG_TMP_COND_DESC
(
  COND_IDS   VARCHAR2(80),
  TRANS_COND_ID  VARCHAR2(80),
  COND_NAMES VARCHAR2(4000),
  COND_TYPE  CHAR(1)
);
COMMENT ON COLUMN NG_TMP_COND_DESC.COND_TYPE IS
'1:固定费条件
2:优惠条件
';

--固费收费规则定义
drop table VB_FEECOUNT_DEF;
create table VB_FEECOUNT_DEF
(
    VB_RATE_ID      NUMBER(8),
    VB_RATE_NAME    varchar2(50),
    first_effect    CHAR(1),
    CYCLE_TYPE_ID   CHAR(1),
    SUMTOINT_TYPE   VARCHAR(2),
    DAY_FEE         NUMBER(8),
    CYCLE_FEE       NUMBER(8)
);

--VB_PM_PRODUCT_OFFERING
PROMPT CREATE TABLE:VB_PM_PRODUCT_OFFERING 
DROP TABLE VB_PM_PRODUCT_OFFERING;
create TABLE VB_PM_PRODUCT_OFFERING
(
PRODUCT_OFFERING_ID        number(9),
FEEPOLICY_ID               NUMBER(8),
FIRST_EFFECT               CHAR(1),   
SERV_ID                    number(8),
EVENT_PRIORITY             NUMBER(4),
EVENT_TYPE_ID              NUMBER(4),
COND_ID                    number(8),
CYCLE_TYPE_ID              NUMBER(2),
ITEM_CODE                  number(5),
PRICE_ID                   number(9),
NEW_PRICE_ID               number(9),
PRICE_NAME                 varchar2(256),
RATE_ID                    number(9),
RATE_NAME                  varchar2(50),
SUMTOINT_TYPE              varCHAR2(10),
DAY_FEE                    number(8),
CYCLE_FEE                  number(8),
OFFERING_NAME              varCHAR2(256),
USER_MARKER_ID             VARCHAR2(200),
EXPR_ID                    VARCHAR2(200)
);
DROP TABLE VB_PM_PRODUCT_OFFERING_invalid;
create TABLE VB_PM_PRODUCT_OFFERING_invalid
(
PRODUCT_OFFERING_ID        number(9),
FEEPOLICY_ID               NUMBER(8),
FIRST_EFFECT               CHAR(1),   
SERV_ID                    number(8),
EVENT_PRIORITY             NUMBER(4),
EVENT_TYPE_ID              NUMBER(4),
COND_ID                    number(8),
CYCLE_TYPE_ID              NUMBER(2),
ITEM_CODE                  number(5),
PRICE_ID                   number(9),
NEW_PRICE_ID               number(9),
PRICE_NAME                 varchar2(256),
RATE_ID                    number(9),
RATE_NAME                  varchar2(50),
SUMTOINT_TYPE              varCHAR2(10),
DAY_FEE                    number(8),
CYCLE_FEE                  number(8),
OFFERING_NAME              varCHAR2(256),
USER_MARKER_ID             VARCHAR2(200),
EXPR_ID                    VARCHAR2(200)
);

--NG_TMP_RENTFEE_COND
PROMPT CREATE TABLE:NG_TMP_RENTFEE_COND
DROP TABLE NG_TMP_RENTFEE_COND;
CREATE TABLE NG_TMP_RENTFEE_COND
(
   PRICE_ID         NUMBER(8),
   UNIT_RATIO       NUMBER(8),
   POLICY_STATUS_ID NUMBER(9),        
   STATUS_DESC      VARCHAR2(400),
   POLICY_OTHER_ID  NUMBER(9),
   OTHER_DESC       VARCHAR2(1000),
   mark_flag        CHAR(1),
   VALID_CHANGE_FLAG CHAR(1),
   opendate_tag     CHAR(1)
);

DROP TABLE NG_TMP_RC_FEEDTL;
CREATE TABLE NG_TMP_RC_FEEDTL
(
   PRICE_ID              NUMBER(8),
   UNIT_RATIO            NUMBER(10),
   POLICY_COND_ID        NUMBER(9),
   OPENDATE_TAG          CHAR(1),
   POLICY_STATUS_ID      NUMBER(9),
   VALID_CHANGE_FLAG     CHAR(1),
   STATUS_DESC1          VARCHAR(400),
   STATUS_DESC2          VARCHAR(400),
   STATUS_DESC3          VARCHAR(400)
);
DROP TABLE VB_TMP_POLICY_RENTFEE_COND;
CREATE TABLE VB_TMP_POLICY_RENTFEE_COND
(
 POLICY_NAME         VARCHAR(1000),
 POLICY_ID           NUMBER(9),
 POLICY_EXPR         VARCHAR(4000),
 VALID_CHANGE_FLAG   CHAR(1),
 STATUS_DESC1        VARCHAR(400),
 STATUS_DESC2        VARCHAR(400),
 STATUS_DESC3        VARCHAR(400)
);


--PM_FIXSTATE_DEF
PROMPT CREATE TABLE:PM_FIXSTATE_DEF 
DROP TABLE PM_FIXSTATE_DEF;
create table PM_FIXSTATE_DEF  (
   feepolicy_id         number(8),
   PRICE_ID             number(9),
   SERV_ID              number(8),
   EVENT_TYPE_ID        NUMBER(4),
   BOSS_STATES          VARCHAR2(2000),
   REMARK               VARCHAR2(2000)
);
comment on column PM_FIXSTATE_DEF.feepolicy_id is
'对应NG系统用户订购的资费';
comment on column PM_FIXSTATE_DEF.SERV_ID is
'对应NG系统用户订购的服务';
comment on column PM_FIXSTATE_DEF.EVENT_TYPE_ID is
'对应NG系统用户订购服务需要收费的事件';
comment on column PM_FIXSTATE_DEF.BOSS_STATES is
'多个状态间,分隔
若为空则不需要判断服务状态';

--PM_PRODUCT_OFFERING_DISCNT
PROMPT CREATE TABLE:PM_PRODUCT_OFFERING_DISCNT 
DROP TABLE PM_PRODUCT_OFFERING_DISCNT;
create table PM_PRODUCT_OFFERING_DISCNT
(
  INFO_ID             NUMBER(9),
  FEEPOLICY_ID        NUMBER(9),
  PRODUCT_OFFERING_ID NUMBER(9),
  SERV_ID             NUMBER(8),
  EVENT_TYPE_ID       NUMBER(4),
  TYPE                NUMBER(2),
  EVENT_TYPE_NAME     VARCHAR2(50)
);
COMMENT ON COLUMN PM_PRODUCT_OFFERING_DISCNT.INFO_ID IS
'对应NG.TF_F_USER_IMPORTINFO.PRODUCT_ID';
COMMENT ON COLUMN PM_PRODUCT_OFFERING_DISCNT.FEEPOLICY_ID IS
'对应NG.TF_F_FEEPOLICY.FEEPOLICY_ID';
COMMENT ON COLUMN PM_PRODUCT_OFFERING_DISCNT.SERV_ID IS
'对应NG.TF_F_USER_SERV.SERV_ID';
COMMENT ON COLUMN PM_PRODUCT_OFFERING_DISCNT.TYPE IS
'1:普通优惠编码,对应PRODUCT_ID为0 优先级最高
2:默认资费编码,不存在普通资费,走默认资费,INFO_ID取对应值 优先级其次
3:系统级默认资费 优先级最低';

--NG_TMP_PRICE_DISCNT
PROMPT CREATE TABLE:NG_TMP_PRICE_DISCNT 
DROP   TABLE NG_TMP_PRICE_DISCNT;  
create table NG_TMP_PRICE_DISCNT
(
PRICE_ID         NUMBER(8),
ORDER_NO         NUMBER(3),
COND_IDS         VARCHAR2(200),
TRANS_COND_IDS   VARCHAR2(200),
COND_NAMES       VARCHAR2(200),
EXEC_ID          NUMBER(8),
TYPE             CHAR(1),
REMARK           VARCHAR2(50)
);    

comment on table NG_TMP_PRICE_DISCNT
  is 'VerisBilling参数割接帐务处理临时表,上线后可删除';

COMMENT ON COLUMN NG_TMP_PRICE_DISCNT.TYPE IS
'1:原始记录
2:拆分后记录
3:特殊处理:转套餐费
4:拆分后记录:转套餐费
M:特殊情况:暂不支持
N:废弃原始记录';


--NG_TMP_FEEDISCNT
PROMPT CREATE TABLE:NG_TMP_FEEDISCNT
DROP   TABLE NG_TMP_FEEDISCNT;  
create table NG_TMP_FEEDISCNT
(
  FEEDISCNT_ID           NUMBER(8),
  ORDER_NO               NUMBER(4),
  TYPE                   CHAR(1),
  COMPUTE_OBJECT_ID      NUMBER(5),
  VALUE_SRC              CHAR(1),
  COMPUTE_METHOD         NUMBER(4),
  DIVIED_CHILD_VALUE     VARCHAR2(20),
  DIVIED_PARENT_VALUE    VARCHAR2(20),
  DISCNT_FEE             VARCHAR2(20),
  BASE_FEE               VARCHAR2(20),
  BASE_OBJECT_ID         NUMBER(8),
  BASE_ADJUST_METHOD     CHAR(1),
  FEE_ADJUST_METHOD      CHAR(1),
  EFFECT_OBJECT_ID       NUMBER(5),
  DISPATCH_METHOD        CHAR(1),
  ADDUP_ID               NUMBER(8),
  METHOD                 NUMBER(4),
  MIN_BIZ                NUMBER(5),
  STAGE_ID               NUMBER(4),           
  REFER_ITEM_CODE        VARCHAR2(50),
  EFFECT_ITEM_CODE       VARCHAR2(50),
  LIMIT_VALUE            VARCHAR2(50),
  DISC_VALUE             VARCHAR2(50),
  MAX_VALUE              VARCHAR2(50),
  RSRV_NUM1              NUMBER(10,2),
  REMARK                 VARCHAR2(100)
);
comment on table NG_TMP_FEEDISCNT
  is 'VerisBilling参数割接帐务处理临时表,上线后可删除';  

COMMENT ON COLUMN NG_TMP_FEEDISCNT.TYPE IS
'1:原始记录
2:根据资料元素收取
3:按照累积量使用量收取,月末补收完整的
7：CRM外部实例化
N:废弃原始记录';

COMMENT ON COLUMN NG_TMP_FEEDISCNT.METHOD IS
'新系统收费类型,特殊：
1:保底
2:封顶
3:减免类特殊处理
4:整体打折
5:费用转移(湖南多用于先转移 后保底)
6:超过参考值的部分进行限定减免
7:CRM外部实例化
8:减免值封顶
9:补收类特殊处理
11:定为固定值
12:费用转移
13:按使用量补收
14:根据资料元素收取
16:全业务融合包年套餐';


--NG_TMP_PRICE_PARAM
PROMPT CREATE TABLE:NG_TMP_PRICE_PARAM 
DROP   TABLE NG_TMP_PRICE_PARAM;  
create table NG_TMP_PRICE_PARAM
(
FEEPOLICY_ID       NUMBER(8),
FEEPOLICY_COMP_ID  NUMBER(8),
EVENT_TYPE_ID      NUMBER(8),
FEEPOLICY_PARAM_ID NUMBER(8), 
PRICE_ID           NUMBER(8),
EXEC_TYPE          CHAR(1),
EXEC_ID            NUMBER(8),
PRICE_PARAM_ID     NUMBER(8),
FIX_VALUE          NUMBER(8)
);   

comment on table NG_TMP_PRICE_PARAM
  is 'VerisBilling参数割接帐务处理临时表,上线后可删除';
 
COMMENT ON COLUMN NG_TMP_PRICE_PARAM.EXEC_TYPE IS
'1:固定费计算
3:优惠处理
4:累积量计算'; 

--NG_TMP_TP_DISCNT
PROMPT CREATE TABLE:NG_TMP_TP_DISCNT 
DROP TABLE NG_TMP_TP_DISCNT;
create table NG_TMP_TP_DISCNT
(
  PRODUCT_OFFERING_ID   NUMBER(9),
  PRODUCT_OFFERING_NAME VARCHAR2(100),
  FEEPOLICY_ID         NUMBER(8),
  EVENT_PRIORITY       NUMBER(4),
  EFFECT_ROLE_CODE     VARCHAR2(4),
  REPEAT_TYPE          CHAR(1),
  FIRST_EFFECT         CHAR(1),
  PRICE_ID             NUMBER(8),
  PRICE_NAME           VARCHAR2(200),
  ORDER_NO             NUMBER(3),
  COND_IDS             VARCHAR2(200),
  COND_NAMES           VARCHAR2(200),
  EXEC_ID              NUMBER(9),
  ADJUSTRATE_ID        NUMBER(9),
  account_share_flag   NUMBER(4),
  dispatch_method      char(1),
  REMARK               VARCHAR2(50),
  DISCNT_TYPE          CHAR(1),
  COMPUTE_OBJECT_ID    NUMBER(8),
  ITEM_ID              NUMBER(8),
  TRANS_ITEM_ID        NUMBER(8),
  FEE                  VARCHAR2(20),
  DIVIED_PARENT_VALUE  VARCHAR2(20),
  DIVIED_CHILD_VALUE   VARCHAR2(20),
  BASE_NUM             VARCHAR2(20),
  SINGLE_FEE           VARCHAR2(20),
  NUM_PARAM            VARCHAR2(20),
  CYC_NUMS             NUMBER(3),
  isparam              char(1),
  PARAM_ID             varchar2(100),
  NEW_PARAM_ID         varchar2(100),
  policy_id            number(9),
  POLICY_EXPR          varchar2(4000)
);
comment on table NG_TMP_TP_DISCNT
  is 'VerisBilling参数割接帐务处理临时表,上线后可删除';

drop table TMP_MK_PRICE_ID;
create table TMP_MK_PRICE_ID
(
  feepolicy_id         number(9),
  price_id_old         number(8),
  price_id_new         number(8)
);  

--参数实例化作用表达式临时表
drop table VB_TMP_POLICY_FEEDISCNT;    
create table VB_TMP_POLICY_FEEDISCNT
(
   policy_id    number(9),
   policy_expr  varchar2(4000)
);

--NG_TMP_PRICE_PARAM_CRM
PROMPT CREATE TABLE:NG_TMP_PRICE_PARAM_CRM 
DROP   TABLE NG_TMP_PRICE_PARAM_CRM;  
create table NG_TMP_PRICE_PARAM_CRM
(
FEEPOLICY_ID            NUMBER(8),
FEEPOLICY_PARAM_ID      NUMBER(8),
EXEC_ID                 NUMBER(9),
PRICE_PARAM_ID          NUMBER(8),
DISCNT_FEE              VARCHAR2(20),
BASE_FEE                VARCHAR2(20),
VB_KEY                  NUMBER(8),
REMARK                  VARCHAR2(200)
);    

comment on table NG_TMP_PRICE_PARAM_CRM
  is 'VerisBilling参数割接帐务处理临时表,上线后可删除';
  
COMMENT ON COLUMN NG_TMP_PRICE_PARAM_CRM.VB_KEY IS
'820503:个数
 820051:百分比
 820001:金额';
 
  
--NG_TMP_COMPCOND
PROMPT CREATE TABLE:NG_TMP_COMPCOND 
DROP   TABLE NG_TMP_COMPCOND;  
create TABLE NG_TMP_COMPCOND
(
  COND_IDS       VARCHAR2(80),
  COND_ID     NUMBER(9),
  ORDER_NO    NUMBER(2),
  type          NUMBER(1),
  REMARK       VARCHAR2(200)
); 

COMMENT ON COLUMN NG_TMP_COMPCOND.TYPE IS
'1:固定费
2:优惠
';

PROMPT CREATE TABLE:VB_TMP_SUB_COND 
DROP TABLE VB_TMP_SUB_COND;
create table VB_TMP_SUB_COND
(
   SIMPLE_COND_ID     NUMBER(8),
   SUB_POLICY_ID      NUMBER(8),
   SUB_DESC           VARCHAR2(50),
   SUB_LUA            VARCHAR2(200)
);

PROMPT CREATE TABLE:tm_a_smsdiscount
drop table tm_a_smsdiscount;
Create Global Temporary Table tm_a_smsdiscount
(
USER_ID      NUMBER(16),
pre_value_n1 NUMBER(16),
pre_value_n2 NUMBER(16),
pre_value_n3 NUMBER(16),
pre_value_n4 NUMBER(16),
pre_value_n5 NUMBER(16)
)
On Commit Delete Rows;

PROMPT CREATE TABLE:GEYF_USERDISCNT_1
drop table GEYF_USERDISCNT_1;
create table GEYF_USERDISCNT_1
(
  FEEPOLICY_ID       NUMBER(8) not null,
  EFFECT_ROLE_CODE   VARCHAR2(4) not null,
  EVENT_FEEPOLICY_ID NUMBER(8),
  PRICE_ID           NUMBER(8) not null
);
PROMPT CREATE TABLE:GEYF_FEEDISCNT_0
drop table GEYF_FEEDISCNT_0;
create table GEYF_FEEDISCNT_0
(
  FEEDISCNT_ID NUMBER(8) not null,
  ORDER_NO     NUMBER(4) not null,
  TAG          CHAR(1) default '0'
);




--按金额减免
DROP TABLE GEYF_FEEDISCNT_free_fee;
create table GEYF_FEEDISCNT_free_fee
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  FEE                varchar2(20)
);

--按比列减免
DROP TABLE GEYF_FEEDISCNT_free_per;
create table GEYF_FEEDISCNT_free_per
(
  FEEDISCNT_ID        NUMBER(8),
  ITEM_ID             NUMBER(8),
  divied_child_Value  varchar2(20),
  divied_parent_Value varchar2(20)
);

--费用补收
DROP TABLE GEYF_FEEDISCNT_bs;
create table GEYF_FEEDISCNT_bs
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  trans_item_id      number(5),
  FEE                varchar2(20)
);

--固定额度收费，多退少补
DROP TABLE GEYF_FEEDISCNT_FIXED;
create table GEYF_FEEDISCNT_FIXED
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  trans_item_id      number(5),
  FEE                varchar2(20)
);

--按数量乘以单价
DROP TABLE GEYF_FEEDISCNT_bs_num;
create table GEYF_FEEDISCNT_bs_num
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  trans_item_id      number(5),
  SINGLE_FEE         varchar2(20),
  NUM_PARAM          varchar2(20)
);

--按crm传入的比例补收费用
DROP TABLE geyf_feediscnt_bs_per;
create table geyf_feediscnt_bs_per
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  trans_item_id      number(5),
  SINGLE_FEE         varchar2(20),
  NUM_PARAM          varchar2(20)
);

--
DROP TABLE GEYF_FEEDISCNT_bs_group;
create table GEYF_FEEDISCNT_bs_group
(
  FEEDISCNT_ID       NUMBER(8),
  compute_object_id  NUMBER(20),
  ITEM_ID            NUMBER(8),
  trans_item_id      number(5),
  BASE_FEE           varchar2(20),
  BASE_NUM           varchar2(20),
  SINGLE_FEE         varchar2(20)
);

--费用保底
DROP TABLE GEYF_FEEDISCNT_baodi;
create table GEYF_FEEDISCNT_baodi
(
  FEEDISCNT_ID       NUMBER(8),
  CANKAO_ITEM_ID  NUMBER(8),
  ITEM_ID            NUMBER(8),
  FEE                varchar2(20)
);

DROP TABLE GEYF_FEEDISCNT_addup_baodi;
create table GEYF_FEEDISCNT_addup_baodi
(
  FEEDISCNT_ID       NUMBER(8),
  CANKAO_ITEM_ID     NUMBER(8),
  ITEM_ID            NUMBER(8),
  cyc_nums					 NUMBER(3),
  FEE                varchar2(20)
);

--封顶
DROP TABLE GEYF_FEEDISCNT_fengding;
create table GEYF_FEEDISCNT_fengding
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  FEE                varchar2(20)
);

--账目转换
DROP TABLE GEYF_FEEDISCNT_ITEM2ITEM;
create table GEYF_FEEDISCNT_ITEM2ITEM
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID1           NUMBER(8),
  ITEM_ID2           NUMBER(8)
);

--扣费提醒
DROP TABLE GEYF_FEEDISCNT_SMS;
create table GEYF_FEEDISCNT_SMS
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  FEE                NUMBER(20)
);

drop table  zhangjt_feediscnt;
create table ZHANGJT_FEEDISCNT
(
  FEEDISCNT_ID NUMBER(8) not null,
  ORDER_NO     NUMBER(4) not null,
  TAG          CHAR(1) default '0',
  remark       varchar2(200)
);

drop table GEYF_FEEDISCNT_basefree_per;
create table GEYF_FEEDISCNT_basefree_per
(
   feediscnt_id    number(8),
   item_id         number(5),
   divied_child_value  number(4),
   divied_parent_value number(4),
   base_fee        number(8)
);

DROP TABLE GEYF_FEEDISCNT_REFEE_LIMIT;
create table GEYF_FEEDISCNT_REFEE_LIMIT
(
  feediscnt_id           number(8),
  base_item              number(5),
  effect_item            number(5),
  divied_child_value     number(5),
  divied_parent_value    number(5),
  discnt_fee             varchar2(50),
  base_fee               varchar2(50)
);

DROP TABLE GEYF_FEEDISCNT_DERATE_XY;
create table GEYF_FEEDISCNT_DERATE_XY
(
  feediscnt_id           number(8),
  base_item              number(5),
  effect_item            number(5),
  divied_child_value     number(5),
  divied_parent_value    number(5),
  discnt_fee             number(5),
  base_fee               number(5)
);
--费用全免但不能超过限定的值
drop table geyf_feediscnt_freelimit;
create table geyf_feediscnt_freelimit
(
  feediscnt_id     number(8),
  item_id          number(5),
  limit_fee        number(8)
);
--
		drop table ZHANGJT_COND;
		create table ZHANGJT_COND
		(
		  COND_ID          NUMBER(8) not null,
      COND_NAME        VARCHAR2(400),
		  COND_TYPE        CHAR(1),
		  POLICY_ID        NUMBER(9),
      POLICY_EXPR      VARCHAR2(2000),
      ISDEAL           CHAR(1),
      REMARK           VARCHAR2(40)
		);
--
    drop table ZHANGJT_SIMPLECOND;
    create table ZHANGJT_SIMPLECOND
    (
      policy_id       number(9),
      COND_ID         NUMBER(8) not null,
      yes_or_no       char(1),
      tag             char(1),
      remark          varchar2(200),
      judge_item_id   number(5),
      judge_fee       varchar2(20),
      servstate       varchar2(20),
      state_set       varchar2(400),
      cycle_num       varchar2(50)，
      valid_region    varchar2(30),
      policy_expr     varchar2(4000)
    );
--新老服务状态映射临时表（主服务）
drop table TMP_NG2VB_SERVSTATE;
create table TMP_NG2VB_SERVSTATE
(
   state_name       varchar2(100),
   old_state_code   varchar2(2),
   new_state_code   varchar2(30),
   os_sts           number(2),
   os_sts_dtl       number(8)
);
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('0','开通','10','0');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('1','申请停机','12','1');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('2','挂失停机','12','2');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('3','并机停机','12','3');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('4','局方停机','12','42');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('5','欠费停机','12','5');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('6','申请销号','12','6');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('7','高额停机','12','7');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('8','欠费预销号','12','8');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('9','欠费销号','12','9');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('A','欠费半停机','11','5');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('B','高额半停机','11','7');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('E','转网销号停机','12','10');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('F','申请预销停机','12','11');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('G','申请半停机','11','12');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('I','申请停机','12','12');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('J','初始停机','12','13');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('K','代理商停机','12','14');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('L','特殊停机','12','40');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('M','黑名单停机','12','16');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('N','人工开机','10','0');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('O','过期停机','12','17');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('P','电话开通停机','12','18');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('Q','无权停机','12','19');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('T','骚扰电话半停','11','20');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('U','不良信息停机','12','41');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('W','垃圾短信封停','12','22');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('X','携出销号','12','23');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('Y','携出方欠费停','12','24');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('Z','携出欠费销号','12','25');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('C','半停（缺失）','11','97');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('D','半停（缺失）','11','98');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('H','半停（缺失）','11','99');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('g','实名制停机','11','42');
update TMP_NG2VB_SERVSTATE set new_state_code = os_sts*100000000+os_sts_dtl;
update TMP_NG2VB_SERVSTATE set new_state_code = '1200000042|1200000043' where old_state_code = '4';
commit;

--提取出现网付费关系用到的组合账目,压缩组合账目倒换
drop table tmp_valid_compitem4deduct;
create table tmp_valid_compitem4deduct
(
   item_id   number(5)
);

--作用表达式编码生成
drop table TMP_MK_ADJUSTRATE_ID;
create table TMP_MK_ADJUSTRATE_ID
(
  ID                  NUMBER(9),
  COND_IDS            VARCHAR2(200),
  DISCNT_TYPE         CHAR(1),
  COMPUTE_OBJECT_ID   NUMBER(8),
  ITEM_ID             NUMBER(8),
  account_share_flag  NUMBER(4),
  FEE                 VARCHAR2(20),
  DIVIED_PARENT_VALUE VARCHAR2(20),
  DIVIED_CHILD_VALUE  VARCHAR2(20),
  BASE_NUM            VARCHAR2(20),
  SINGLE_FEE          VARCHAR2(20),
  NUM_PARAM           VARCHAR2(20),
  CYC_NUMS            NUMBER(3),
  ISPARAM             CHAR(1),
  PARAM_ID            VARCHAR2(100),
  NEW_PARAM_ID        VARCHAR2(100),
  POLICY_ID           NUMBER(9),
  POLICY_EXPR         VARCHAR2(4000)
);

--群组优惠，多终端共享
drop table NG_TMP_ACCT_DISCNT;
create table NG_TMP_ACCT_DISCNT
(
  discnt_name   varchar2(200),
	feepolicy_id  number(9),
	price_id      number(8),
	cond_id1      number(9),
	cond_id2      number(9),
	feediscnt_id  number(8),
	base_item     number(5),
	effect_item   number(5),
	fee           number(20),
  policy_id     number(9),
  policy_expr   varchar2(4000)
);

----提取固费计算方法为1003的定价
drop table ng_tmp_rentmethod1003_price;
create table ng_tmp_rentmethod1003_price
(
  price_id    number(9)
);

--条件组转换
drop table tmp_conds_trans;
create table tmp_conds_trans
(
  old_conds    varchar2(200),
  new_conds    varchar2(200)
);

--一次性费用
drop table NG_TMP_OTPFEE;
create table NG_TMP_OTPFEE
(
  tp_id           number(9),
  price_id        number(9),
  adjustrate_id   number(9),  
  cond_id         varchar2(50),
  item_id         number(5),
  policy_id       number(9),
  policy_expr     varchar2(4000)
);

--张毅昕提供的二次议价新老映射  begin
drop table tmp_feepolicy_param;
create table tmp_feepolicy_param
(
	feepolicy_id      number(8),
	old_param_id      number(8),
	new_param_id      number(8),
	remark            varchar2(200)
);

insert into tmp_feepolicy_param values ('17333','10000002','810301','企业手机报业务彩信上下行都计费');
insert into tmp_feepolicy_param values ('61000991','10000003','810301','个人流量红包个人兑换包');
insert into tmp_feepolicy_param values ('61000980','10000003','810301','流量红包');
insert into tmp_feepolicy_param values ('60030001','10000008','810301','公众停车流量池');
insert into tmp_feepolicy_param values ('100015','10015001','810001','400语音路由选择-下挂号码功能费');
insert into tmp_feepolicy_param values ('100018','10015001','810001','400语音路由选择-下挂号码功能费');
insert into tmp_feepolicy_param values ('150262','10015002','810001','设备安装费（单位：300元/台）');
insert into tmp_feepolicy_param values ('150263','10015003','810001','设备安装费（单位：1000元/机架）');
insert into tmp_feepolicy_param values ('150264','10015004','810001','端口调测费（单位：300元/端口/独享）');
insert into tmp_feepolicy_param values ('150265','10015005','810001','端口调测费（单位：200元/端口/共享）');
insert into tmp_feepolicy_param values ('150280','10015006','810001','装机工料费');
insert into tmp_feepolicy_param values ('150281','10015007','810001','移机工料费');
insert into tmp_feepolicy_param values ('150307','10015008','810001','KVM服务-端口费');
insert into tmp_feepolicy_param values ('150309','10015009','810001','防DDOS流量清洗-包月IP数<20');
insert into tmp_feepolicy_param values ('150310','10015010','810001','防DDOS流量清洗-包月20≤IP数<50');
insert into tmp_feepolicy_param values ('150311','10015011','810001','防DDOS流量清洗-包月50≤IP数<100');
insert into tmp_feepolicy_param values ('150312','10015012','810001','防DDOS流量清洗-包月100≤IP数<150（单位：元/月/IP）');
insert into tmp_feepolicy_param values ('150313','10015013','810001','防DDOS流量清洗-包月150≤IP数<200（单位：元/月/IP）');
insert into tmp_feepolicy_param values ('150314','10015014','810001','防DDOS流量清洗-包月IP数≥200（单位：元/月/IP）');
insert into tmp_feepolicy_param values ('150315','10015015','810001','防DDOS流量清洗-单次清洗费（单位：元/IP/次）');
insert into tmp_feepolicy_param values ('150316','10015016','810001','域名解析（单位：元/域名/次）');
insert into tmp_feepolicy_param values ('150308','10015017','810001','防DDOS流量清洗-一次性设置费');
insert into tmp_feepolicy_param values ('15341','10015018','810001','机架-SP');
insert into tmp_feepolicy_param values ('150269','10015019','810001','3.5KW机架42U（单位：9690元/月）（2013年）');
insert into tmp_feepolicy_param values ('150277','10015020','810001','IP地址（单位：100元/个/月） ');
insert into tmp_feepolicy_param values ('150303','10015021','810001','带宽-100M独享');
insert into tmp_feepolicy_param values ('150304','10015022','810001','带宽-1G独享');
insert into tmp_feepolicy_param values ('150305','10015023','810001','机架-5KW机架42U');
insert into tmp_feepolicy_param values ('150317','10015024','810001','集团IDC业务标准机柜包月4200');
insert into tmp_feepolicy_param values ('61000011','10015025','810001','托管式会议包月');
insert into tmp_feepolicy_param values ('150318','10015026','810001','集团IDC业务标准机柜包月9012');
insert into tmp_feepolicy_param values ('150319','10015027','810001','共享云-套餐1（单位：50 元/月）');
insert into tmp_feepolicy_param values ('150320','10015028','810001','移动云-共享云-套餐2（单位：260元/月）');
insert into tmp_feepolicy_param values ('150321','10015029','810001','共享云-套餐3（单位：150 元/月）');
insert into tmp_feepolicy_param values ('150322','10015030','810001','共享云-套餐4（单位：200 元/月）');
insert into tmp_feepolicy_param values ('150323','10015031','810001','共享云-套餐5（单位：300 元/月）');
insert into tmp_feepolicy_param values ('150324','10015032','810001','共享云-套餐6（单位：400 元/月）');
insert into tmp_feepolicy_param values ('150325','10015033','810001','共享云-套餐7（单位：600 元/月）');
insert into tmp_feepolicy_param values ('150326','10015034','810001','移动云-共享云-套餐8（单位：1739元/月）');
insert into tmp_feepolicy_param values ('150327','10015035','810001','共享云-套餐9（单位：1200元/月）');
insert into tmp_feepolicy_param values ('150328','10015036','810001','共享云-套餐10（单位：1600元/月）');
insert into tmp_feepolicy_param values ('150329','10015037','810001','移动云-专享云-套餐1（单位：6365元/月）');
insert into tmp_feepolicy_param values ('150330','10015038','810001','专享云-套餐2（单位：8256元/月）');
insert into tmp_feepolicy_param values ('150331','10015039','810001','专享云-套餐3（单位：33024元/月）');
insert into tmp_feepolicy_param values ('150332','10015040','810001','移动云-云存储-10G（单位：5元/月）');
insert into tmp_feepolicy_param values ('150333','10015041','810001','移动云-云存储-1T（单位：500元/月）');
insert into tmp_feepolicy_param values ('150334','10015042','810001','互联网接入-1M（单位：  40 元/月）');
insert into tmp_feepolicy_param values ('150335','10015043','810001','移动云-带宽-2M（单位：272元/月）');
insert into tmp_feepolicy_param values ('150336','10015044','810001','互联网接入-5M（单位：  200元/月）');
insert into tmp_feepolicy_param values ('150337','10015045','810001','移动云-带宽-10M（单位：1320元/月）');
insert into tmp_feepolicy_param values ('150338','10015046','810001','互联网接入-20M（单位： 800元/月）');
insert into tmp_feepolicy_param values ('150339','10015047','810001','互联网接入-50M（单位： 2000元/月）');
insert into tmp_feepolicy_param values ('150340','10015048','810001','互联网接入-100M（单位：4000元/月）');
insert into tmp_feepolicy_param values ('150341','10015049','810001','移动云-IP地址（单位：30元/月/个）');
insert into tmp_feepolicy_param values ('150342','10015050','810001','移动云-增值产品-快照-10G（单位：5元/月）');
insert into tmp_feepolicy_param values ('150343','10015051','810001','移动云-增值产品-快照-1T（单位：500元/月）');
insert into tmp_feepolicy_param values ('150344','10015052','810001','移动云-增值产品-主机保护（单位：10元/月/台）');
insert into tmp_feepolicy_param values ('150345','10015053','810001','移动云-增值产品-弹性负载均衡（单位：800元/月）');
insert into tmp_feepolicy_param values ('61000022','10015054','810001','企业阅读1元包');
insert into tmp_feepolicy_param values ('61000023','10015055','810001','企业阅读3元包');
insert into tmp_feepolicy_param values ('61000024','10015056','810001','企业阅读5元包');
insert into tmp_feepolicy_param values ('61000025','10015057','810001','企业阅读8元包');
insert into tmp_feepolicy_param values ('145100','10015058','810001','行车卫士-电动车版158元套餐');
insert into tmp_feepolicy_param values ('145101','10015059','810001','行车卫士-电动车版188元套餐');
insert into tmp_feepolicy_param values ('145102','10015060','810001','行车卫士-电动车版198元套餐');
insert into tmp_feepolicy_param values ('145103','10015061','810001','行车卫士5元包');
insert into tmp_feepolicy_param values ('15025','10015062','810001','IDC带宽租用2000标准机柜');
insert into tmp_feepolicy_param values ('15300','10015063','810001','集团IDC业务7000');
insert into tmp_feepolicy_param values ('15301','10015064','810001','集团IDC业务8800');
insert into tmp_feepolicy_param values ('15302','10015065','810001','集团IDC业务9400');
insert into tmp_feepolicy_param values ('15303','10015066','810001','集团IDC业务11000');
insert into tmp_feepolicy_param values ('15304','10015067','810001','集团IDC业务11000');
insert into tmp_feepolicy_param values ('15305','10015068','810001','集团IDC业务33000');
insert into tmp_feepolicy_param values ('15306','10015069','810001','集团IDC业务265000');
insert into tmp_feepolicy_param values ('15307','10015070','810001','集团IDC业务免年租');
insert into tmp_feepolicy_param values ('15308','10015071','810001','集团IDC业务26400');
insert into tmp_feepolicy_param values ('15309','10015072','810001','集团IDC业务2x8800');
insert into tmp_feepolicy_param values ('15310','10015073','810001','集团IDC业务3x8800');
insert into tmp_feepolicy_param values ('15311','10015074','810001','集团IDC业务4x8800');
insert into tmp_feepolicy_param values ('15312','10015075','810001','集团IDC业务5x8800');
insert into tmp_feepolicy_param values ('15313','10015076','810001','集团IDC业务6x8800');
insert into tmp_feepolicy_param values ('15314','10015077','810001','集团IDC业务7x8800');
insert into tmp_feepolicy_param values ('15315','10015078','810001','集团IDC业务8x8800');
insert into tmp_feepolicy_param values ('15316','10015079','810001','集团IDC业务9x8800');
insert into tmp_feepolicy_param values ('15317','10015080','810001','集团IDC业务10x8800');
insert into tmp_feepolicy_param values ('15319','10015081','810001','集团IDC业务20000');
insert into tmp_feepolicy_param values ('15320','10015082','810001','集团IDC业务6000');
insert into tmp_feepolicy_param values ('15321','10015083','810001','集团IDC业务13000');
insert into tmp_feepolicy_param values ('15322','10015084','810001','集团IDC业务4480');
insert into tmp_feepolicy_param values ('15325','10015085','810001','集团IDC业务5000');
insert into tmp_feepolicy_param values ('15326','10015086','810001','IDC机柜租用-1U标准机位  ');
insert into tmp_feepolicy_param values ('15327','10015087','810001','IDC机柜租用-4U标准机位  ');
insert into tmp_feepolicy_param values ('15328','10015088','810001','IDC机柜租用-10U标准机位 ');
insert into tmp_feepolicy_param values ('15329','10015089','810001','IDC机柜租用-20U标准机位 ');
insert into tmp_feepolicy_param values ('15330','10015090','810001','IDC机柜租用-一个标准机柜');
insert into tmp_feepolicy_param values ('15331','10015091','810001','IDC带宽租用-100M共享    ');
insert into tmp_feepolicy_param values ('15332','10015092','810001','IDC带宽租用-2M独享      ');
insert into tmp_feepolicy_param values ('15333','10015093','810001','IDC带宽租用-10M独享     ');
insert into tmp_feepolicy_param values ('15334','10015094','810001','IDC带宽租用-100M独享    ');
insert into tmp_feepolicy_param values ('15335','10015095','810001','IDC带宽租用-1G以上      ');
insert into tmp_feepolicy_param values ('15342','10015096','810001','工位出租-单间');
insert into tmp_feepolicy_param values ('15343','10015097','810001','工位出租-开放区');
insert into tmp_feepolicy_param values ('100260','10015098','810001','集团IDC业务7800');
insert into tmp_feepolicy_param values ('150251','10015099','810001','4U标准机位');
insert into tmp_feepolicy_param values ('150252','10015100','810001','100M共享带宽租用');
insert into tmp_feepolicy_param values ('150253','10015101','810001','IDC主机托管业务220万/年优惠包');
insert into tmp_feepolicy_param values ('150254','10015102','810001','IDC带宽租用180000标准机柜');
insert into tmp_feepolicy_param values ('150255','10015103','810001','IDC主机托管业务23450元/月优惠包');
insert into tmp_feepolicy_param values ('150256','10015104','810001','IDC机柜租用优惠包');
insert into tmp_feepolicy_param values ('150257','10015105','810001','IDC带宽租用优惠包');
insert into tmp_feepolicy_param values ('150266','10015106','810001','3.5KW机位4U（单位：1280元/月）（2013年）');
insert into tmp_feepolicy_param values ('150267','10015107','810001','3.5KW机位10U（单位：3070元/月）（2013年）');
insert into tmp_feepolicy_param values ('150268','10015108','810001','3.5KW机位20U（单位：5250元/月）（2013年） ');
insert into tmp_feepolicy_param values ('150270','10015109','810001','金联万家五个机柜（单位：21000元/月）');
insert into tmp_feepolicy_param values ('150271','10015110','810001','100M共享（单位：1500元/月）（2013年） ');
insert into tmp_feepolicy_param values ('150272','10015111','810001','2M独享（单位：2000元/月）（2013年）');
insert into tmp_feepolicy_param values ('150273','10015112','810001','10M独享（单位：6000元/月）（2013年）');
insert into tmp_feepolicy_param values ('150274','10015113','810001','100M独享（单位：45000元/月）（2013年）');
insert into tmp_feepolicy_param values ('150275','10015114','810001','金联万家100M独享（单位：10000元/月）');
insert into tmp_feepolicy_param values ('150276','10015115','810001','1G独享（单位：230000元/月）（2013年）');
insert into tmp_feepolicy_param values ('150300','10015116','810001','带宽-100M共享');
insert into tmp_feepolicy_param values ('150301','10015117','810001','带宽-2M独享');
insert into tmp_feepolicy_param values ('150302','10015118','810001','带宽-10M独享');
insert into tmp_feepolicy_param values ('150306','10015119','810001','KVM服务-基础费');
insert into tmp_feepolicy_param values ('151347','10015120','810001','移动云-专享云-ECU单价套餐（单位：260元/月）');
insert into tmp_feepolicy_param values ('151348','10015121','810001','移动云-专享云-增值服务套餐1（单位：100元/月）');
insert into tmp_feepolicy_param values ('151349','10015122','810001','移动云-专享云-增值服务套餐2（单位：1000元/月）');
insert into tmp_feepolicy_param values ('151350','10015123','810001','移动云-专享云-增值服务套餐3（单位：10000元/月）');
insert into tmp_feepolicy_param values ('150370','10015124','810001','集团IDC业务10U机柜1800元/月');
insert into tmp_feepolicy_param values ('150371','10015125','810001','集团IDC业务2M独享带宽1000元/月');
insert into tmp_feepolicy_param values ('150376','10015126','810001','集团IDC业务3700');
insert into tmp_feepolicy_param values ('150377','10015127','810001','5KW机位4U（单位：1830元/月）');
insert into tmp_feepolicy_param values ('150378','10015128','810001','5KW机位10U（单位：4400元/月）');
insert into tmp_feepolicy_param values ('150379','10015129','810001','5KW机位20U（单位：7500元/月）');
insert into tmp_feepolicy_param values ('150380','10015130','810001','机电分离（单位：3800元/月）');
insert into tmp_feepolicy_param values ('150381','10015131','810001','带宽-10M独享（单位：1300元/月）');
insert into tmp_feepolicy_param values ('150382','10015132','810001','带宽-100M独享（单位：11450元/月）');
insert into tmp_feepolicy_param values ('150383','10015133','810001','带宽-1G独享（单位：100000元/月）');
insert into tmp_feepolicy_param values ('150384','10015134','810001','带宽-10G独享（单位：700000元/月）');
insert into tmp_feepolicy_param values ('150385','10015135','810001','外线接入（单位：2000元/月）');
insert into tmp_feepolicy_param values ('150386','10015136','810001','工位出租（单位：1200元/月）');
insert into tmp_feepolicy_param values ('150387','10015137','810001','备品备件柜（单位：300元/月）');
insert into tmp_feepolicy_param values ('115481','10015138','810001','大数据—知行天津A套餐');
insert into tmp_feepolicy_param values ('115482','10015139','810001','大数据—知行天津B套餐');
insert into tmp_feepolicy_param values ('115483','10015140','810001','大数据—知行天津C套餐');
insert into tmp_feepolicy_param values ('115484','10015141','810001','大数据—知行天津D套餐');
insert into tmp_feepolicy_param values ('115485','10015142','810001','大数据—知行天津E套餐');
insert into tmp_feepolicy_param values ('115486','10015143','810001','大数据—知行天津F套餐');
insert into tmp_feepolicy_param values ('145104','10015144','810001','行车卫士点烟器套餐1');
insert into tmp_feepolicy_param values ('145105','10015145','810001','行车卫士点烟器套餐2');
insert into tmp_feepolicy_param values ('145106','10015146','810001','行车卫士10元包');
insert into tmp_feepolicy_param values ('15346','10015147','810001','集团IDC业务150M独享');
insert into tmp_feepolicy_param values ('15347','10015148','810001','集团通讯录客户端自助套餐');
insert into tmp_feepolicy_param values ('15356','10015148','810001','云桌面-套餐1（单位：50元/月）');
insert into tmp_feepolicy_param values ('15357','10015149','810001','云桌面-套餐2（单位：100元/月）');
insert into tmp_feepolicy_param values ('15358','10015150','810001','云桌面-套餐3（单位：150元/月）');
insert into tmp_feepolicy_param values ('15359','10015151','810001','云桌面-套餐4（单位：200元/月）');
insert into tmp_feepolicy_param values ('15360','10015152','810001','云桌面-套餐5（单位：300元/月）');
insert into tmp_feepolicy_param values ('15361','10015153','810001','云桌面-套餐6（单位：400元/月）');
insert into tmp_feepolicy_param values ('15362','10015154','810001','云桌面-套餐7（单位：600元/月）');
insert into tmp_feepolicy_param values ('15363','10015155','810001','云桌面-套餐8（单位：800元/月）');
insert into tmp_feepolicy_param values ('15364','10015156','810001','云桌面-套餐9（单位：1200元/月）');
insert into tmp_feepolicy_param values ('15365','10015157','810001','云桌面-套餐10（单位：1600元/月）');
insert into tmp_feepolicy_param values ('150388','10015158','810001','3.5KW机位1U（单位：260元/月）');
insert into tmp_feepolicy_param values ('150389','10015159','810001','3.5KW机架42U（单位：5000元/月）');
insert into tmp_feepolicy_param values ('150390','10015160','810001','5KW机位1U（单位：380元/月）');
insert into tmp_feepolicy_param values ('150391','10015161','810001','5KW机位42U（单位：7150元/月）');
insert into tmp_feepolicy_param values ('150394','10015162','810001','带宽加油包');
insert into tmp_feepolicy_param values ('15120811','12081145','810001','集团IDC业务20U机柜1575元');
insert into tmp_feepolicy_param values ('15092410','15092411','810001','集团IDC业务350M独享，月租14200元');
insert into tmp_feepolicy_param values ('16031621','16031623','810001','集团IDC业务100M独享1000元');
insert into tmp_feepolicy_param values ('16031622','16031624','810001','集团IDC业务2G独享20000元/月');
insert into tmp_feepolicy_param values ('16032800','16032802','810001','集团IDC业务50M独享带宽5725元/月');
insert into tmp_feepolicy_param values ('16032801','16032803','810001','150M独享带宽17175元/月');
insert into tmp_feepolicy_param values ('20160118','20160118','810001','集团IDC业务100M独享900元');
insert into tmp_feepolicy_param values ('20160119','20160119','810001','集团IDC业务100M独享2600元');
insert into tmp_feepolicy_param values ('20160120','20160120','810001','集团IDC业务20M独享5600元');
insert into tmp_feepolicy_param values ('16022201','22201001','810001','集团IDC业务100M独享3000元');
insert into tmp_feepolicy_param values ('16022202','22201002','810001','集团IDC业务3.5KW机位20U');
insert into tmp_feepolicy_param values ('16022203','22201003','810001','外线接入600元');
insert into tmp_feepolicy_param values ('40301','30104','810001','1元/月/成员');
insert into tmp_feepolicy_param values ('40302','30204','810001','3元/月/成员');
insert into tmp_feepolicy_param values ('40303','30304','810001','5元/月/成员');
insert into tmp_feepolicy_param values ('40304','30404','810001','6元/月/成员');
insert into tmp_feepolicy_param values ('40305','30504','810001','8元/月/成员');
insert into tmp_feepolicy_param values ('40306','30604','810001','10元/月/成员');
insert into tmp_feepolicy_param values ('40307','30704','810001','12元/月/成员');
insert into tmp_feepolicy_param values ('40308','30804','810001','15元/月/成员');
insert into tmp_feepolicy_param values ('40309','30904','810001','18元/月/成员');
insert into tmp_feepolicy_param values ('40310','31004','810001','20元/月/成员');
insert into tmp_feepolicy_param values ('16032901','32901001','810001','集团IDC业务200M独享21300元');
insert into tmp_feepolicy_param values ('91398','39801','810001','和对讲成员级资费');
insert into tmp_feepolicy_param values ('16041101','41100001','810001','3.5KW机柜(2016促销活动)');
insert into tmp_feepolicy_param values ('16041102','41100002','810001','5KW机柜(2016促销活动)');
insert into tmp_feepolicy_param values ('16041103','41100003','810001','独享10M(2016促销活动)');
insert into tmp_feepolicy_param values ('16041104','41100004','810001','独享100M(2016促销活动)');
insert into tmp_feepolicy_param values ('16041105','41100005','810001','独享200M(2016促销活动)');
insert into tmp_feepolicy_param values ('16041106','41100006','810001','独享500M(2016促销活动)');
insert into tmp_feepolicy_param values ('16041107','41100007','810001','独享1G(2016促销活动)');
insert into tmp_feepolicy_param values ('16041108','41100008','810001','独享10G(2016促销活动)');
insert into tmp_feepolicy_param values ('16041109','41100009','810001','10G-50G(2016促销活动)');
insert into tmp_feepolicy_param values ('16041110','41100010','810001','50G以上(2016促销活动)');
insert into tmp_feepolicy_param values ('8337','66600011','810001','APWLAN承诺手机累计最低消费168');
insert into tmp_feepolicy_param values ('8339','66600011','810001','APWLAN承诺手机累计最低消费58');
insert into tmp_feepolicy_param values ('8336','66600011','810001','APWLAN承诺手机累计最低消费88');
insert into tmp_feepolicy_param values ('8344','66600011','810001','测试共担保底消费');
insert into tmp_feepolicy_param values ('8345','66600011','810001','CPE_MIFI最低消费68');
insert into tmp_feepolicy_param values ('8343','66600011','810001','光宽带融合承诺手机累计最低消费168');
insert into tmp_feepolicy_param values ('5370','66600011','810001','光宽带融合承诺手机累计最低消费188');
insert into tmp_feepolicy_param values ('99999','66600011','810001','光宽带融合承诺手机累计最低消费208');
insert into tmp_feepolicy_param values ('8180','66600011','810001','光宽带融合承诺手机累计最低消费228');
insert into tmp_feepolicy_param values ('8346','66600011','810001','光宽带融合承诺手机累计最低消费58');
insert into tmp_feepolicy_param values ('8178','66600011','810001','光宽带融合承诺手机累计最低消费68');
insert into tmp_feepolicy_param values ('8179','66600011','810001','光宽带融合承诺手机累计最低消费88');
insert into tmp_feepolicy_param values ('8182','66600011','810001','光宽带融合承诺手机累计最低消费98');
insert into tmp_feepolicy_param values ('8338','66600011','810001','融合套餐-ADSL2M累计最低消费68');
insert into tmp_feepolicy_param values ('8340','66600011','810001','融合套餐-光纤10M累计最低消费188');
insert into tmp_feepolicy_param values ('8342','66600011','810001','融合套餐-光纤20M累计最低消费228');
insert into tmp_feepolicy_param values ('8341','66600011','810001','融合套餐-光纤4M累计最低消费68');
insert into tmp_feepolicy_param values ('8181','66600011','810001','融合套餐-光纤6M累计最低消费98');
insert into tmp_feepolicy_param values ('22011789','71010201','810001','云主机');
insert into tmp_feepolicy_param values ('22011789','71010202','810002','云主机');
insert into tmp_feepolicy_param values ('22011793','71610201','810001','带宽出租');
insert into tmp_feepolicy_param values ('22011793','71610202','810002','带宽出租');
insert into tmp_feepolicy_param values ('22011733','73210204','810001','短信能力');
insert into tmp_feepolicy_param values ('22011734','73210404','810001','短信能力');
insert into tmp_feepolicy_param values ('22011735','73210504','810001','短信能力');
insert into tmp_feepolicy_param values ('22011736','73210604','810001','短信能力');
insert into tmp_feepolicy_param values ('22011737','73210704','810001','短信能力');
insert into tmp_feepolicy_param values ('22011738','73210804','810001','短信能力');
insert into tmp_feepolicy_param values ('22011739','73210904','810001','短信能力');
insert into tmp_feepolicy_param values ('22011740','74010102','810001','老板签批');
insert into tmp_feepolicy_param values ('22011740','74010103','810002','老板签批');
insert into tmp_feepolicy_param values ('22011748','74810101','810001','连锁通');
insert into tmp_feepolicy_param values ('22011748','74810102','810002','连锁通');
insert into tmp_feepolicy_param values ('22011749','74910101','810001','快消通');
insert into tmp_feepolicy_param values ('22011749','74910102','810002','快消通');
insert into tmp_feepolicy_param values ('22011750','75010101','810001','SCM-供应链管理');
insert into tmp_feepolicy_param values ('22011750','75010102','810002','SCM-供应链管理');
insert into tmp_feepolicy_param values ('22011751','75110101','810001','ERP-大型贸易业管理');
insert into tmp_feepolicy_param values ('22011751','75110102','810002','ERP-大型贸易业管理');
insert into tmp_feepolicy_param values ('22011752','75210101','810001','ERP-大型制造业管理');
insert into tmp_feepolicy_param values ('22011752','75210102','810002','ERP-大型制造业管理');
insert into tmp_feepolicy_param values ('22011753','75310101','810001','ERP-零售连锁企业管理');
insert into tmp_feepolicy_param values ('22011753','75310102','810002','ERP-零售连锁企业管理');
insert into tmp_feepolicy_param values ('22011754','75410101','810001','ERP-旅游业管理');
insert into tmp_feepolicy_param values ('22011754','75410102','810002','ERP-旅游业管理');
insert into tmp_feepolicy_param values ('22011755','75510101','810001','ERP-美容美发服务业管理');
insert into tmp_feepolicy_param values ('22011755','75510102','810002','ERP-美容美发服务业管理');
insert into tmp_feepolicy_param values ('22011756','75610101','810001','ERP-门店管理');
insert into tmp_feepolicy_param values ('22011756','75610102','810002','ERP-门店管理');
insert into tmp_feepolicy_param values ('22011757','75710101','810001','ERP-小型服务业管理');
insert into tmp_feepolicy_param values ('22011757','75710102','810002','ERP-小型服务业管理');
insert into tmp_feepolicy_param values ('22011781','76310204','810001','企业短信');
insert into tmp_feepolicy_param values ('22011782','76310304','810001','企业短信');
insert into tmp_feepolicy_param values ('22011783','76310404','810001','企业短信');
insert into tmp_feepolicy_param values ('22011784','76310504','810001','企业短信');
insert into tmp_feepolicy_param values ('22011785','76310604','810001','企业短信');
insert into tmp_feepolicy_param values ('22011786','76310704','810001','企业短信');
insert into tmp_feepolicy_param values ('22011787','76310804','810001','企业短信');
insert into tmp_feepolicy_param values ('62300259','80000001','810001','跨省互联网199IP地址费');
insert into tmp_feepolicy_param values ('62300260','80000002','810001','呼叫中心直联');
insert into tmp_feepolicy_param values ('62300261','80000003','810001','行业应用卡X元资费包');
insert into tmp_feepolicy_param values ('8100','80000004','810001','承租厅必选优惠');
insert into tmp_feepolicy_param values ('90089008','90099009','810001','集团跨国专线月租费');
insert into tmp_feepolicy_param values ('62300251','90099009','810001','集团跨省专线月租费');
insert into tmp_feepolicy_param values ('16011201','91120100','810001','纷享网络单卡预付费版20元150兆');
insert into tmp_feepolicy_param values ('16011201','91120101','810002','纷享网络单卡预付费版20元150兆');
COMMIT;

drop table tmp_detach_item;
create table tmp_detach_item (compitem_id   number(5) , subitem_id   number(5));

--GRPS梳理临时表
drop table NG_TMP_GRPS_TP;
create table NG_TMP_GRPS_TP
(
	discnt_code      number(8),
  discnt_name      varchar2(200),
  type             char(1),
  price_id         number(9),
  cond_id          number(9),
  adjustrate_id    number(9),
  base_item        number(9),
  adjust_item      number(5)
);

--流量日租卡业务梳理
drop table NG_TMP_DAYGPRS_TP;
create table NG_TMP_DAYGPRS_TP
(
discnt_name       varchar2(200),
feepolicy_id      number(8),
feepolicy_TYPE    char(1),
price_id          number(9),
ADJUSTRATE_ID     number(9),
EXPR_ID           number(9),
ADDUP_ITEM        number(9),
EFFECT_ITEM       number(5),
DISCNT_FEE        number(5),
DISCNT_DATA       number(5)
);

--宽带包年套餐梳理
drop table 告诉你和bANF组XFng_tmp_tpinfo_ttlan;
create table ng_tmp_tpinfo_ttlan
(
  discnt_name    varchar2(100),
  discnt_code    number(8),
  price_id       number(8),
  cond_id        number(8),
  yearfee_exec   number(8),
  dayfee_exec    number(8),
  item_id        number(5),
  year_fee       number(10),
  day_fee        number(10),
  cycle_num      number(5)
);
drop table ng_tmp_tpinfo_ttlan_dayfee;
create table ng_tmp_tpinfo_ttlan_dayfee
(
   discnt_name      varchar2(100),
   discnt_code      number(8),
   feediscnt_id     number(8),
   day_fee          number(8)
);

--跨月保底优惠的信息
drop table ng_tmp_tpinfo_addupbaodi;
create table ng_tmp_tpinfo_addupbaodi
(
  discnt_name    varchar2(200),
  discnt_code    number(8),
  price_id       number(8),
  cond_id1       number(8),
  cond_id2       number(8),
  feediscnt_id   number(8),
  item_id        number(5),
  fee            varchar2(10),
  cycle_num      number(2)
);

--报错日志
drop table zhangjt_errorlog;
create table zhangjt_errorlog 
(
	id number primary key,
	errorcode number,
	errormsg varchar2(1024),
	errordate date	
);
drop sequence seq_zhangjterrorlog_id;
create sequence seq_zhangjterrorlog_id start with 1 increment by 1;

--抵扣通道
delete from sd.sys_drecv_citydbno;
delete from sd.sys_drecv_channelbatch;
INSERT INTO sd.sys_drecv_citydbno VALUES ('0970',1);
INSERT INTO sd.sys_drecv_citydbno VALUES ('0971',1);
INSERT INTO sd.sys_drecv_citydbno VALUES ('0972',1);
INSERT INTO sd.sys_drecv_citydbno VALUES ('0973',1);
INSERT INTO sd.sys_drecv_citydbno VALUES ('0974',1);
INSERT INTO sd.sys_drecv_citydbno VALUES ('0975',1);
INSERT INTO sd.sys_drecv_citydbno VALUES ('0976',1);
INSERT INTO sd.sys_drecv_citydbno VALUES ('0977',1);
INSERT INTO sd.sys_drecv_citydbno VALUES ('0979',1);
INSERT INTO sd.sys_drecv_channelbatch 
SELECT channel_no,start_id,end_id,db_no FROM ucr_param.TD_B_DRECV_CHANNEL 
WHERE task_code= 'Drecv' AND  step_code = 'DrecvCalc';
commit;






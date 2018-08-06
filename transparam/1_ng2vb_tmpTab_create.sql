SET TIMING OFF;
set HEADING OFF;
set ECHO OFF;
SET FEEDBACK OFF;

PROMPT .
PROMPT .
PROMPT ============================ 0 CREATE TABLE: �����м���ʱ�� ============================

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
  is 'VerisBilling���������������ʱ��,���ߺ��ɾ��';

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
  is 'VerisBilling���������������ʱ��,���ߺ��ɾ��';

COMMENT ON COLUMN NG_TMP_FEEPOLOICY.DISCNT_TYPE IS
'1:����
2:���·�
3:����';

COMMENT ON COLUMN NG_TMP_FEEPOLOICY.REPEAT_TYPE IS
'0:�����ظ�����
1:���ظ�����
2:�ּ�';

COMMENT ON COLUMN NG_TMP_FEEPOLOICY.FIRST_EFFECT IS
'1:��ʾΪ�����ײ�,����������Ҫ���������Դ
2:��ɢ����
3:��ɢ�����¶�����
0:��ʾ����Ҫ����';

COMMENT ON COLUMN NG_TMP_FEEPOLOICY.TYPE IS
'1:�̶��Ѽ���
3:�Żݴ���
4:�ۻ�������
5:�������ʷ�';

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
  is 'VerisBilling���������������ʱ��,���ߺ��ɾ��';
  
COMMENT ON COLUMN NG_TMP_PRICE_SERV.TYPE IS
'1:�̶���
2:�������⴦��
3:0�������⴦��';

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
'1:�̶�������
2:�Ż�����
';

--�̷��շѹ�����
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
'��ӦNGϵͳ�û��������ʷ�';
comment on column PM_FIXSTATE_DEF.SERV_ID is
'��ӦNGϵͳ�û������ķ���';
comment on column PM_FIXSTATE_DEF.EVENT_TYPE_ID is
'��ӦNGϵͳ�û�����������Ҫ�շѵ��¼�';
comment on column PM_FIXSTATE_DEF.BOSS_STATES is
'���״̬��,�ָ�
��Ϊ������Ҫ�жϷ���״̬';

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
'��ӦNG.TF_F_USER_IMPORTINFO.PRODUCT_ID';
COMMENT ON COLUMN PM_PRODUCT_OFFERING_DISCNT.FEEPOLICY_ID IS
'��ӦNG.TF_F_FEEPOLICY.FEEPOLICY_ID';
COMMENT ON COLUMN PM_PRODUCT_OFFERING_DISCNT.SERV_ID IS
'��ӦNG.TF_F_USER_SERV.SERV_ID';
COMMENT ON COLUMN PM_PRODUCT_OFFERING_DISCNT.TYPE IS
'1:��ͨ�Żݱ���,��ӦPRODUCT_IDΪ0 ���ȼ����
2:Ĭ���ʷѱ���,��������ͨ�ʷ�,��Ĭ���ʷ�,INFO_IDȡ��Ӧֵ ���ȼ����
3:ϵͳ��Ĭ���ʷ� ���ȼ����';

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
  is 'VerisBilling���������������ʱ��,���ߺ��ɾ��';

COMMENT ON COLUMN NG_TMP_PRICE_DISCNT.TYPE IS
'1:ԭʼ��¼
2:��ֺ��¼
3:���⴦��:ת�ײͷ�
4:��ֺ��¼:ת�ײͷ�
M:�������:�ݲ�֧��
N:����ԭʼ��¼';


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
  is 'VerisBilling���������������ʱ��,���ߺ��ɾ��';  

COMMENT ON COLUMN NG_TMP_FEEDISCNT.TYPE IS
'1:ԭʼ��¼
2:��������Ԫ����ȡ
3:�����ۻ���ʹ������ȡ,��ĩ����������
7��CRM�ⲿʵ����
N:����ԭʼ��¼';

COMMENT ON COLUMN NG_TMP_FEEDISCNT.METHOD IS
'��ϵͳ�շ�����,���⣺
1:����
2:�ⶥ
3:���������⴦��
4:�������
5:����ת��(���϶�������ת�� �󱣵�)
6:�����ο�ֵ�Ĳ��ֽ����޶�����
7:CRM�ⲿʵ����
8:����ֵ�ⶥ
9:���������⴦��
11:��Ϊ�̶�ֵ
12:����ת��
13:��ʹ��������
14:��������Ԫ����ȡ
16:ȫҵ���ںϰ����ײ�';


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
  is 'VerisBilling���������������ʱ��,���ߺ��ɾ��';
 
COMMENT ON COLUMN NG_TMP_PRICE_PARAM.EXEC_TYPE IS
'1:�̶��Ѽ���
3:�Żݴ���
4:�ۻ�������'; 

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
  is 'VerisBilling���������������ʱ��,���ߺ��ɾ��';

drop table TMP_MK_PRICE_ID;
create table TMP_MK_PRICE_ID
(
  feepolicy_id         number(9),
  price_id_old         number(8),
  price_id_new         number(8)
);  

--����ʵ�������ñ��ʽ��ʱ��
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
  is 'VerisBilling���������������ʱ��,���ߺ��ɾ��';
  
COMMENT ON COLUMN NG_TMP_PRICE_PARAM_CRM.VB_KEY IS
'820503:����
 820051:�ٷֱ�
 820001:���';
 
  
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
'1:�̶���
2:�Ż�
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




--��������
DROP TABLE GEYF_FEEDISCNT_free_fee;
create table GEYF_FEEDISCNT_free_fee
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  FEE                varchar2(20)
);

--�����м���
DROP TABLE GEYF_FEEDISCNT_free_per;
create table GEYF_FEEDISCNT_free_per
(
  FEEDISCNT_ID        NUMBER(8),
  ITEM_ID             NUMBER(8),
  divied_child_Value  varchar2(20),
  divied_parent_Value varchar2(20)
);

--���ò���
DROP TABLE GEYF_FEEDISCNT_bs;
create table GEYF_FEEDISCNT_bs
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  trans_item_id      number(5),
  FEE                varchar2(20)
);

--�̶�����շѣ������ٲ�
DROP TABLE GEYF_FEEDISCNT_FIXED;
create table GEYF_FEEDISCNT_FIXED
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  trans_item_id      number(5),
  FEE                varchar2(20)
);

--���������Ե���
DROP TABLE GEYF_FEEDISCNT_bs_num;
create table GEYF_FEEDISCNT_bs_num
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  trans_item_id      number(5),
  SINGLE_FEE         varchar2(20),
  NUM_PARAM          varchar2(20)
);

--��crm����ı������շ���
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

--���ñ���
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

--�ⶥ
DROP TABLE GEYF_FEEDISCNT_fengding;
create table GEYF_FEEDISCNT_fengding
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID            NUMBER(8),
  FEE                varchar2(20)
);

--��Ŀת��
DROP TABLE GEYF_FEEDISCNT_ITEM2ITEM;
create table GEYF_FEEDISCNT_ITEM2ITEM
(
  FEEDISCNT_ID       NUMBER(8),
  ITEM_ID1           NUMBER(8),
  ITEM_ID2           NUMBER(8)
);

--�۷�����
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
--����ȫ�⵫���ܳ����޶���ֵ
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
      cycle_num       varchar2(50)��
      valid_region    varchar2(30),
      policy_expr     varchar2(4000)
    );
--���Ϸ���״̬ӳ����ʱ��������
drop table TMP_NG2VB_SERVSTATE;
create table TMP_NG2VB_SERVSTATE
(
   state_name       varchar2(100),
   old_state_code   varchar2(2),
   new_state_code   varchar2(30),
   os_sts           number(2),
   os_sts_dtl       number(8)
);
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('0','��ͨ','10','0');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('1','����ͣ��','12','1');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('2','��ʧͣ��','12','2');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('3','����ͣ��','12','3');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('4','�ַ�ͣ��','12','42');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('5','Ƿ��ͣ��','12','5');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('6','��������','12','6');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('7','�߶�ͣ��','12','7');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('8','Ƿ��Ԥ����','12','8');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('9','Ƿ������','12','9');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('A','Ƿ�Ѱ�ͣ��','11','5');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('B','�߶��ͣ��','11','7');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('E','ת������ͣ��','12','10');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('F','����Ԥ��ͣ��','12','11');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('G','�����ͣ��','11','12');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('I','����ͣ��','12','12');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('J','��ʼͣ��','12','13');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('K','������ͣ��','12','14');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('L','����ͣ��','12','40');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('M','������ͣ��','12','16');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('N','�˹�����','10','0');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('O','����ͣ��','12','17');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('P','�绰��ͨͣ��','12','18');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('Q','��Ȩͣ��','12','19');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('T','ɧ�ŵ绰��ͣ','11','20');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('U','������Ϣͣ��','12','41');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('W','�������ŷ�ͣ','12','22');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('X','Я������','12','23');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('Y','Я����Ƿ��ͣ','12','24');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('Z','Я��Ƿ������','12','25');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('C','��ͣ��ȱʧ��','11','97');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('D','��ͣ��ȱʧ��','11','98');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('H','��ͣ��ȱʧ��','11','99');
insert into TMP_NG2VB_SERVSTATE (old_state_code,state_name,os_sts,os_sts_dtl) values ('g','ʵ����ͣ��','11','42');
update TMP_NG2VB_SERVSTATE set new_state_code = os_sts*100000000+os_sts_dtl;
update TMP_NG2VB_SERVSTATE set new_state_code = '1200000042|1200000043' where old_state_code = '4';
commit;

--��ȡ���������ѹ�ϵ�õ��������Ŀ,ѹ�������Ŀ����
drop table tmp_valid_compitem4deduct;
create table tmp_valid_compitem4deduct
(
   item_id   number(5)
);

--���ñ��ʽ��������
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

--Ⱥ���Żݣ����ն˹���
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

----��ȡ�̷Ѽ��㷽��Ϊ1003�Ķ���
drop table ng_tmp_rentmethod1003_price;
create table ng_tmp_rentmethod1003_price
(
  price_id    number(9)
);

--������ת��
drop table tmp_conds_trans;
create table tmp_conds_trans
(
  old_conds    varchar2(200),
  new_conds    varchar2(200)
);

--һ���Է���
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

--������ṩ�Ķ����������ӳ��  begin
drop table tmp_feepolicy_param;
create table tmp_feepolicy_param
(
	feepolicy_id      number(8),
	old_param_id      number(8),
	new_param_id      number(8),
	remark            varchar2(200)
);

insert into tmp_feepolicy_param values ('17333','10000002','810301','��ҵ�ֻ���ҵ����������ж��Ʒ�');
insert into tmp_feepolicy_param values ('61000991','10000003','810301','��������������˶һ���');
insert into tmp_feepolicy_param values ('61000980','10000003','810301','�������');
insert into tmp_feepolicy_param values ('60030001','10000008','810301','����ͣ��������');
insert into tmp_feepolicy_param values ('100015','10015001','810001','400����·��ѡ��-�¹Һ��빦�ܷ�');
insert into tmp_feepolicy_param values ('100018','10015001','810001','400����·��ѡ��-�¹Һ��빦�ܷ�');
insert into tmp_feepolicy_param values ('150262','10015002','810001','�豸��װ�ѣ���λ��300Ԫ/̨��');
insert into tmp_feepolicy_param values ('150263','10015003','810001','�豸��װ�ѣ���λ��1000Ԫ/���ܣ�');
insert into tmp_feepolicy_param values ('150264','10015004','810001','�˿ڵ���ѣ���λ��300Ԫ/�˿�/����');
insert into tmp_feepolicy_param values ('150265','10015005','810001','�˿ڵ���ѣ���λ��200Ԫ/�˿�/����');
insert into tmp_feepolicy_param values ('150280','10015006','810001','װ�����Ϸ�');
insert into tmp_feepolicy_param values ('150281','10015007','810001','�ƻ����Ϸ�');
insert into tmp_feepolicy_param values ('150307','10015008','810001','KVM����-�˿ڷ�');
insert into tmp_feepolicy_param values ('150309','10015009','810001','��DDOS������ϴ-����IP��<20');
insert into tmp_feepolicy_param values ('150310','10015010','810001','��DDOS������ϴ-����20��IP��<50');
insert into tmp_feepolicy_param values ('150311','10015011','810001','��DDOS������ϴ-����50��IP��<100');
insert into tmp_feepolicy_param values ('150312','10015012','810001','��DDOS������ϴ-����100��IP��<150����λ��Ԫ/��/IP��');
insert into tmp_feepolicy_param values ('150313','10015013','810001','��DDOS������ϴ-����150��IP��<200����λ��Ԫ/��/IP��');
insert into tmp_feepolicy_param values ('150314','10015014','810001','��DDOS������ϴ-����IP����200����λ��Ԫ/��/IP��');
insert into tmp_feepolicy_param values ('150315','10015015','810001','��DDOS������ϴ-������ϴ�ѣ���λ��Ԫ/IP/�Σ�');
insert into tmp_feepolicy_param values ('150316','10015016','810001','������������λ��Ԫ/����/�Σ�');
insert into tmp_feepolicy_param values ('150308','10015017','810001','��DDOS������ϴ-һ�������÷�');
insert into tmp_feepolicy_param values ('15341','10015018','810001','����-SP');
insert into tmp_feepolicy_param values ('150269','10015019','810001','3.5KW����42U����λ��9690Ԫ/�£���2013�꣩');
insert into tmp_feepolicy_param values ('150277','10015020','810001','IP��ַ����λ��100Ԫ/��/�£� ');
insert into tmp_feepolicy_param values ('150303','10015021','810001','����-100M����');
insert into tmp_feepolicy_param values ('150304','10015022','810001','����-1G����');
insert into tmp_feepolicy_param values ('150305','10015023','810001','����-5KW����42U');
insert into tmp_feepolicy_param values ('150317','10015024','810001','����IDCҵ���׼�������4200');
insert into tmp_feepolicy_param values ('61000011','10015025','810001','�й�ʽ�������');
insert into tmp_feepolicy_param values ('150318','10015026','810001','����IDCҵ���׼�������9012');
insert into tmp_feepolicy_param values ('150319','10015027','810001','������-�ײ�1����λ��50 Ԫ/�£�');
insert into tmp_feepolicy_param values ('150320','10015028','810001','�ƶ���-������-�ײ�2����λ��260Ԫ/�£�');
insert into tmp_feepolicy_param values ('150321','10015029','810001','������-�ײ�3����λ��150 Ԫ/�£�');
insert into tmp_feepolicy_param values ('150322','10015030','810001','������-�ײ�4����λ��200 Ԫ/�£�');
insert into tmp_feepolicy_param values ('150323','10015031','810001','������-�ײ�5����λ��300 Ԫ/�£�');
insert into tmp_feepolicy_param values ('150324','10015032','810001','������-�ײ�6����λ��400 Ԫ/�£�');
insert into tmp_feepolicy_param values ('150325','10015033','810001','������-�ײ�7����λ��600 Ԫ/�£�');
insert into tmp_feepolicy_param values ('150326','10015034','810001','�ƶ���-������-�ײ�8����λ��1739Ԫ/�£�');
insert into tmp_feepolicy_param values ('150327','10015035','810001','������-�ײ�9����λ��1200Ԫ/�£�');
insert into tmp_feepolicy_param values ('150328','10015036','810001','������-�ײ�10����λ��1600Ԫ/�£�');
insert into tmp_feepolicy_param values ('150329','10015037','810001','�ƶ���-ר����-�ײ�1����λ��6365Ԫ/�£�');
insert into tmp_feepolicy_param values ('150330','10015038','810001','ר����-�ײ�2����λ��8256Ԫ/�£�');
insert into tmp_feepolicy_param values ('150331','10015039','810001','ר����-�ײ�3����λ��33024Ԫ/�£�');
insert into tmp_feepolicy_param values ('150332','10015040','810001','�ƶ���-�ƴ洢-10G����λ��5Ԫ/�£�');
insert into tmp_feepolicy_param values ('150333','10015041','810001','�ƶ���-�ƴ洢-1T����λ��500Ԫ/�£�');
insert into tmp_feepolicy_param values ('150334','10015042','810001','����������-1M����λ��  40 Ԫ/�£�');
insert into tmp_feepolicy_param values ('150335','10015043','810001','�ƶ���-����-2M����λ��272Ԫ/�£�');
insert into tmp_feepolicy_param values ('150336','10015044','810001','����������-5M����λ��  200Ԫ/�£�');
insert into tmp_feepolicy_param values ('150337','10015045','810001','�ƶ���-����-10M����λ��1320Ԫ/�£�');
insert into tmp_feepolicy_param values ('150338','10015046','810001','����������-20M����λ�� 800Ԫ/�£�');
insert into tmp_feepolicy_param values ('150339','10015047','810001','����������-50M����λ�� 2000Ԫ/�£�');
insert into tmp_feepolicy_param values ('150340','10015048','810001','����������-100M����λ��4000Ԫ/�£�');
insert into tmp_feepolicy_param values ('150341','10015049','810001','�ƶ���-IP��ַ����λ��30Ԫ/��/����');
insert into tmp_feepolicy_param values ('150342','10015050','810001','�ƶ���-��ֵ��Ʒ-����-10G����λ��5Ԫ/�£�');
insert into tmp_feepolicy_param values ('150343','10015051','810001','�ƶ���-��ֵ��Ʒ-����-1T����λ��500Ԫ/�£�');
insert into tmp_feepolicy_param values ('150344','10015052','810001','�ƶ���-��ֵ��Ʒ-������������λ��10Ԫ/��/̨��');
insert into tmp_feepolicy_param values ('150345','10015053','810001','�ƶ���-��ֵ��Ʒ-���Ը��ؾ��⣨��λ��800Ԫ/�£�');
insert into tmp_feepolicy_param values ('61000022','10015054','810001','��ҵ�Ķ�1Ԫ��');
insert into tmp_feepolicy_param values ('61000023','10015055','810001','��ҵ�Ķ�3Ԫ��');
insert into tmp_feepolicy_param values ('61000024','10015056','810001','��ҵ�Ķ�5Ԫ��');
insert into tmp_feepolicy_param values ('61000025','10015057','810001','��ҵ�Ķ�8Ԫ��');
insert into tmp_feepolicy_param values ('145100','10015058','810001','�г���ʿ-�綯����158Ԫ�ײ�');
insert into tmp_feepolicy_param values ('145101','10015059','810001','�г���ʿ-�綯����188Ԫ�ײ�');
insert into tmp_feepolicy_param values ('145102','10015060','810001','�г���ʿ-�綯����198Ԫ�ײ�');
insert into tmp_feepolicy_param values ('145103','10015061','810001','�г���ʿ5Ԫ��');
insert into tmp_feepolicy_param values ('15025','10015062','810001','IDC��������2000��׼����');
insert into tmp_feepolicy_param values ('15300','10015063','810001','����IDCҵ��7000');
insert into tmp_feepolicy_param values ('15301','10015064','810001','����IDCҵ��8800');
insert into tmp_feepolicy_param values ('15302','10015065','810001','����IDCҵ��9400');
insert into tmp_feepolicy_param values ('15303','10015066','810001','����IDCҵ��11000');
insert into tmp_feepolicy_param values ('15304','10015067','810001','����IDCҵ��11000');
insert into tmp_feepolicy_param values ('15305','10015068','810001','����IDCҵ��33000');
insert into tmp_feepolicy_param values ('15306','10015069','810001','����IDCҵ��265000');
insert into tmp_feepolicy_param values ('15307','10015070','810001','����IDCҵ��������');
insert into tmp_feepolicy_param values ('15308','10015071','810001','����IDCҵ��26400');
insert into tmp_feepolicy_param values ('15309','10015072','810001','����IDCҵ��2x8800');
insert into tmp_feepolicy_param values ('15310','10015073','810001','����IDCҵ��3x8800');
insert into tmp_feepolicy_param values ('15311','10015074','810001','����IDCҵ��4x8800');
insert into tmp_feepolicy_param values ('15312','10015075','810001','����IDCҵ��5x8800');
insert into tmp_feepolicy_param values ('15313','10015076','810001','����IDCҵ��6x8800');
insert into tmp_feepolicy_param values ('15314','10015077','810001','����IDCҵ��7x8800');
insert into tmp_feepolicy_param values ('15315','10015078','810001','����IDCҵ��8x8800');
insert into tmp_feepolicy_param values ('15316','10015079','810001','����IDCҵ��9x8800');
insert into tmp_feepolicy_param values ('15317','10015080','810001','����IDCҵ��10x8800');
insert into tmp_feepolicy_param values ('15319','10015081','810001','����IDCҵ��20000');
insert into tmp_feepolicy_param values ('15320','10015082','810001','����IDCҵ��6000');
insert into tmp_feepolicy_param values ('15321','10015083','810001','����IDCҵ��13000');
insert into tmp_feepolicy_param values ('15322','10015084','810001','����IDCҵ��4480');
insert into tmp_feepolicy_param values ('15325','10015085','810001','����IDCҵ��5000');
insert into tmp_feepolicy_param values ('15326','10015086','810001','IDC��������-1U��׼��λ  ');
insert into tmp_feepolicy_param values ('15327','10015087','810001','IDC��������-4U��׼��λ  ');
insert into tmp_feepolicy_param values ('15328','10015088','810001','IDC��������-10U��׼��λ ');
insert into tmp_feepolicy_param values ('15329','10015089','810001','IDC��������-20U��׼��λ ');
insert into tmp_feepolicy_param values ('15330','10015090','810001','IDC��������-һ����׼����');
insert into tmp_feepolicy_param values ('15331','10015091','810001','IDC��������-100M����    ');
insert into tmp_feepolicy_param values ('15332','10015092','810001','IDC��������-2M����      ');
insert into tmp_feepolicy_param values ('15333','10015093','810001','IDC��������-10M����     ');
insert into tmp_feepolicy_param values ('15334','10015094','810001','IDC��������-100M����    ');
insert into tmp_feepolicy_param values ('15335','10015095','810001','IDC��������-1G����      ');
insert into tmp_feepolicy_param values ('15342','10015096','810001','��λ����-����');
insert into tmp_feepolicy_param values ('15343','10015097','810001','��λ����-������');
insert into tmp_feepolicy_param values ('100260','10015098','810001','����IDCҵ��7800');
insert into tmp_feepolicy_param values ('150251','10015099','810001','4U��׼��λ');
insert into tmp_feepolicy_param values ('150252','10015100','810001','100M�����������');
insert into tmp_feepolicy_param values ('150253','10015101','810001','IDC�����й�ҵ��220��/���Żݰ�');
insert into tmp_feepolicy_param values ('150254','10015102','810001','IDC��������180000��׼����');
insert into tmp_feepolicy_param values ('150255','10015103','810001','IDC�����й�ҵ��23450Ԫ/���Żݰ�');
insert into tmp_feepolicy_param values ('150256','10015104','810001','IDC���������Żݰ�');
insert into tmp_feepolicy_param values ('150257','10015105','810001','IDC���������Żݰ�');
insert into tmp_feepolicy_param values ('150266','10015106','810001','3.5KW��λ4U����λ��1280Ԫ/�£���2013�꣩');
insert into tmp_feepolicy_param values ('150267','10015107','810001','3.5KW��λ10U����λ��3070Ԫ/�£���2013�꣩');
insert into tmp_feepolicy_param values ('150268','10015108','810001','3.5KW��λ20U����λ��5250Ԫ/�£���2013�꣩ ');
insert into tmp_feepolicy_param values ('150270','10015109','810001','�������������񣨵�λ��21000Ԫ/�£�');
insert into tmp_feepolicy_param values ('150271','10015110','810001','100M������λ��1500Ԫ/�£���2013�꣩ ');
insert into tmp_feepolicy_param values ('150272','10015111','810001','2M������λ��2000Ԫ/�£���2013�꣩');
insert into tmp_feepolicy_param values ('150273','10015112','810001','10M������λ��6000Ԫ/�£���2013�꣩');
insert into tmp_feepolicy_param values ('150274','10015113','810001','100M������λ��45000Ԫ/�£���2013�꣩');
insert into tmp_feepolicy_param values ('150275','10015114','810001','�������100M������λ��10000Ԫ/�£�');
insert into tmp_feepolicy_param values ('150276','10015115','810001','1G������λ��230000Ԫ/�£���2013�꣩');
insert into tmp_feepolicy_param values ('150300','10015116','810001','����-100M����');
insert into tmp_feepolicy_param values ('150301','10015117','810001','����-2M����');
insert into tmp_feepolicy_param values ('150302','10015118','810001','����-10M����');
insert into tmp_feepolicy_param values ('150306','10015119','810001','KVM����-������');
insert into tmp_feepolicy_param values ('151347','10015120','810001','�ƶ���-ר����-ECU�����ײͣ���λ��260Ԫ/�£�');
insert into tmp_feepolicy_param values ('151348','10015121','810001','�ƶ���-ר����-��ֵ�����ײ�1����λ��100Ԫ/�£�');
insert into tmp_feepolicy_param values ('151349','10015122','810001','�ƶ���-ר����-��ֵ�����ײ�2����λ��1000Ԫ/�£�');
insert into tmp_feepolicy_param values ('151350','10015123','810001','�ƶ���-ר����-��ֵ�����ײ�3����λ��10000Ԫ/�£�');
insert into tmp_feepolicy_param values ('150370','10015124','810001','����IDCҵ��10U����1800Ԫ/��');
insert into tmp_feepolicy_param values ('150371','10015125','810001','����IDCҵ��2M�������1000Ԫ/��');
insert into tmp_feepolicy_param values ('150376','10015126','810001','����IDCҵ��3700');
insert into tmp_feepolicy_param values ('150377','10015127','810001','5KW��λ4U����λ��1830Ԫ/�£�');
insert into tmp_feepolicy_param values ('150378','10015128','810001','5KW��λ10U����λ��4400Ԫ/�£�');
insert into tmp_feepolicy_param values ('150379','10015129','810001','5KW��λ20U����λ��7500Ԫ/�£�');
insert into tmp_feepolicy_param values ('150380','10015130','810001','������루��λ��3800Ԫ/�£�');
insert into tmp_feepolicy_param values ('150381','10015131','810001','����-10M������λ��1300Ԫ/�£�');
insert into tmp_feepolicy_param values ('150382','10015132','810001','����-100M������λ��11450Ԫ/�£�');
insert into tmp_feepolicy_param values ('150383','10015133','810001','����-1G������λ��100000Ԫ/�£�');
insert into tmp_feepolicy_param values ('150384','10015134','810001','����-10G������λ��700000Ԫ/�£�');
insert into tmp_feepolicy_param values ('150385','10015135','810001','���߽��루��λ��2000Ԫ/�£�');
insert into tmp_feepolicy_param values ('150386','10015136','810001','��λ���⣨��λ��1200Ԫ/�£�');
insert into tmp_feepolicy_param values ('150387','10015137','810001','��Ʒ�����񣨵�λ��300Ԫ/�£�');
insert into tmp_feepolicy_param values ('115481','10015138','810001','�����ݡ�֪�����A�ײ�');
insert into tmp_feepolicy_param values ('115482','10015139','810001','�����ݡ�֪�����B�ײ�');
insert into tmp_feepolicy_param values ('115483','10015140','810001','�����ݡ�֪�����C�ײ�');
insert into tmp_feepolicy_param values ('115484','10015141','810001','�����ݡ�֪�����D�ײ�');
insert into tmp_feepolicy_param values ('115485','10015142','810001','�����ݡ�֪�����E�ײ�');
insert into tmp_feepolicy_param values ('115486','10015143','810001','�����ݡ�֪�����F�ײ�');
insert into tmp_feepolicy_param values ('145104','10015144','810001','�г���ʿ�������ײ�1');
insert into tmp_feepolicy_param values ('145105','10015145','810001','�г���ʿ�������ײ�2');
insert into tmp_feepolicy_param values ('145106','10015146','810001','�г���ʿ10Ԫ��');
insert into tmp_feepolicy_param values ('15346','10015147','810001','����IDCҵ��150M����');
insert into tmp_feepolicy_param values ('15347','10015148','810001','����ͨѶ¼�ͻ��������ײ�');
insert into tmp_feepolicy_param values ('15356','10015148','810001','������-�ײ�1����λ��50Ԫ/�£�');
insert into tmp_feepolicy_param values ('15357','10015149','810001','������-�ײ�2����λ��100Ԫ/�£�');
insert into tmp_feepolicy_param values ('15358','10015150','810001','������-�ײ�3����λ��150Ԫ/�£�');
insert into tmp_feepolicy_param values ('15359','10015151','810001','������-�ײ�4����λ��200Ԫ/�£�');
insert into tmp_feepolicy_param values ('15360','10015152','810001','������-�ײ�5����λ��300Ԫ/�£�');
insert into tmp_feepolicy_param values ('15361','10015153','810001','������-�ײ�6����λ��400Ԫ/�£�');
insert into tmp_feepolicy_param values ('15362','10015154','810001','������-�ײ�7����λ��600Ԫ/�£�');
insert into tmp_feepolicy_param values ('15363','10015155','810001','������-�ײ�8����λ��800Ԫ/�£�');
insert into tmp_feepolicy_param values ('15364','10015156','810001','������-�ײ�9����λ��1200Ԫ/�£�');
insert into tmp_feepolicy_param values ('15365','10015157','810001','������-�ײ�10����λ��1600Ԫ/�£�');
insert into tmp_feepolicy_param values ('150388','10015158','810001','3.5KW��λ1U����λ��260Ԫ/�£�');
insert into tmp_feepolicy_param values ('150389','10015159','810001','3.5KW����42U����λ��5000Ԫ/�£�');
insert into tmp_feepolicy_param values ('150390','10015160','810001','5KW��λ1U����λ��380Ԫ/�£�');
insert into tmp_feepolicy_param values ('150391','10015161','810001','5KW��λ42U����λ��7150Ԫ/�£�');
insert into tmp_feepolicy_param values ('150394','10015162','810001','������Ͱ�');
insert into tmp_feepolicy_param values ('15120811','12081145','810001','����IDCҵ��20U����1575Ԫ');
insert into tmp_feepolicy_param values ('15092410','15092411','810001','����IDCҵ��350M��������14200Ԫ');
insert into tmp_feepolicy_param values ('16031621','16031623','810001','����IDCҵ��100M����1000Ԫ');
insert into tmp_feepolicy_param values ('16031622','16031624','810001','����IDCҵ��2G����20000Ԫ/��');
insert into tmp_feepolicy_param values ('16032800','16032802','810001','����IDCҵ��50M�������5725Ԫ/��');
insert into tmp_feepolicy_param values ('16032801','16032803','810001','150M�������17175Ԫ/��');
insert into tmp_feepolicy_param values ('20160118','20160118','810001','����IDCҵ��100M����900Ԫ');
insert into tmp_feepolicy_param values ('20160119','20160119','810001','����IDCҵ��100M����2600Ԫ');
insert into tmp_feepolicy_param values ('20160120','20160120','810001','����IDCҵ��20M����5600Ԫ');
insert into tmp_feepolicy_param values ('16022201','22201001','810001','����IDCҵ��100M����3000Ԫ');
insert into tmp_feepolicy_param values ('16022202','22201002','810001','����IDCҵ��3.5KW��λ20U');
insert into tmp_feepolicy_param values ('16022203','22201003','810001','���߽���600Ԫ');
insert into tmp_feepolicy_param values ('40301','30104','810001','1Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('40302','30204','810001','3Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('40303','30304','810001','5Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('40304','30404','810001','6Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('40305','30504','810001','8Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('40306','30604','810001','10Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('40307','30704','810001','12Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('40308','30804','810001','15Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('40309','30904','810001','18Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('40310','31004','810001','20Ԫ/��/��Ա');
insert into tmp_feepolicy_param values ('16032901','32901001','810001','����IDCҵ��200M����21300Ԫ');
insert into tmp_feepolicy_param values ('91398','39801','810001','�ͶԽ���Ա���ʷ�');
insert into tmp_feepolicy_param values ('16041101','41100001','810001','3.5KW����(2016�����)');
insert into tmp_feepolicy_param values ('16041102','41100002','810001','5KW����(2016�����)');
insert into tmp_feepolicy_param values ('16041103','41100003','810001','����10M(2016�����)');
insert into tmp_feepolicy_param values ('16041104','41100004','810001','����100M(2016�����)');
insert into tmp_feepolicy_param values ('16041105','41100005','810001','����200M(2016�����)');
insert into tmp_feepolicy_param values ('16041106','41100006','810001','����500M(2016�����)');
insert into tmp_feepolicy_param values ('16041107','41100007','810001','����1G(2016�����)');
insert into tmp_feepolicy_param values ('16041108','41100008','810001','����10G(2016�����)');
insert into tmp_feepolicy_param values ('16041109','41100009','810001','10G-50G(2016�����)');
insert into tmp_feepolicy_param values ('16041110','41100010','810001','50G����(2016�����)');
insert into tmp_feepolicy_param values ('8337','66600011','810001','APWLAN��ŵ�ֻ��ۼ��������168');
insert into tmp_feepolicy_param values ('8339','66600011','810001','APWLAN��ŵ�ֻ��ۼ��������58');
insert into tmp_feepolicy_param values ('8336','66600011','810001','APWLAN��ŵ�ֻ��ۼ��������88');
insert into tmp_feepolicy_param values ('8344','66600011','810001','���Թ�����������');
insert into tmp_feepolicy_param values ('8345','66600011','810001','CPE_MIFI�������68');
insert into tmp_feepolicy_param values ('8343','66600011','810001','�����ںϳ�ŵ�ֻ��ۼ��������168');
insert into tmp_feepolicy_param values ('5370','66600011','810001','�����ںϳ�ŵ�ֻ��ۼ��������188');
insert into tmp_feepolicy_param values ('99999','66600011','810001','�����ںϳ�ŵ�ֻ��ۼ��������208');
insert into tmp_feepolicy_param values ('8180','66600011','810001','�����ںϳ�ŵ�ֻ��ۼ��������228');
insert into tmp_feepolicy_param values ('8346','66600011','810001','�����ںϳ�ŵ�ֻ��ۼ��������58');
insert into tmp_feepolicy_param values ('8178','66600011','810001','�����ںϳ�ŵ�ֻ��ۼ��������68');
insert into tmp_feepolicy_param values ('8179','66600011','810001','�����ںϳ�ŵ�ֻ��ۼ��������88');
insert into tmp_feepolicy_param values ('8182','66600011','810001','�����ںϳ�ŵ�ֻ��ۼ��������98');
insert into tmp_feepolicy_param values ('8338','66600011','810001','�ں��ײ�-ADSL2M�ۼ��������68');
insert into tmp_feepolicy_param values ('8340','66600011','810001','�ں��ײ�-����10M�ۼ��������188');
insert into tmp_feepolicy_param values ('8342','66600011','810001','�ں��ײ�-����20M�ۼ��������228');
insert into tmp_feepolicy_param values ('8341','66600011','810001','�ں��ײ�-����4M�ۼ��������68');
insert into tmp_feepolicy_param values ('8181','66600011','810001','�ں��ײ�-����6M�ۼ��������98');
insert into tmp_feepolicy_param values ('22011789','71010201','810001','������');
insert into tmp_feepolicy_param values ('22011789','71010202','810002','������');
insert into tmp_feepolicy_param values ('22011793','71610201','810001','�������');
insert into tmp_feepolicy_param values ('22011793','71610202','810002','�������');
insert into tmp_feepolicy_param values ('22011733','73210204','810001','��������');
insert into tmp_feepolicy_param values ('22011734','73210404','810001','��������');
insert into tmp_feepolicy_param values ('22011735','73210504','810001','��������');
insert into tmp_feepolicy_param values ('22011736','73210604','810001','��������');
insert into tmp_feepolicy_param values ('22011737','73210704','810001','��������');
insert into tmp_feepolicy_param values ('22011738','73210804','810001','��������');
insert into tmp_feepolicy_param values ('22011739','73210904','810001','��������');
insert into tmp_feepolicy_param values ('22011740','74010102','810001','�ϰ�ǩ��');
insert into tmp_feepolicy_param values ('22011740','74010103','810002','�ϰ�ǩ��');
insert into tmp_feepolicy_param values ('22011748','74810101','810001','����ͨ');
insert into tmp_feepolicy_param values ('22011748','74810102','810002','����ͨ');
insert into tmp_feepolicy_param values ('22011749','74910101','810001','����ͨ');
insert into tmp_feepolicy_param values ('22011749','74910102','810002','����ͨ');
insert into tmp_feepolicy_param values ('22011750','75010101','810001','SCM-��Ӧ������');
insert into tmp_feepolicy_param values ('22011750','75010102','810002','SCM-��Ӧ������');
insert into tmp_feepolicy_param values ('22011751','75110101','810001','ERP-����ó��ҵ����');
insert into tmp_feepolicy_param values ('22011751','75110102','810002','ERP-����ó��ҵ����');
insert into tmp_feepolicy_param values ('22011752','75210101','810001','ERP-��������ҵ����');
insert into tmp_feepolicy_param values ('22011752','75210102','810002','ERP-��������ҵ����');
insert into tmp_feepolicy_param values ('22011753','75310101','810001','ERP-����������ҵ����');
insert into tmp_feepolicy_param values ('22011753','75310102','810002','ERP-����������ҵ����');
insert into tmp_feepolicy_param values ('22011754','75410101','810001','ERP-����ҵ����');
insert into tmp_feepolicy_param values ('22011754','75410102','810002','ERP-����ҵ����');
insert into tmp_feepolicy_param values ('22011755','75510101','810001','ERP-������������ҵ����');
insert into tmp_feepolicy_param values ('22011755','75510102','810002','ERP-������������ҵ����');
insert into tmp_feepolicy_param values ('22011756','75610101','810001','ERP-�ŵ����');
insert into tmp_feepolicy_param values ('22011756','75610102','810002','ERP-�ŵ����');
insert into tmp_feepolicy_param values ('22011757','75710101','810001','ERP-С�ͷ���ҵ����');
insert into tmp_feepolicy_param values ('22011757','75710102','810002','ERP-С�ͷ���ҵ����');
insert into tmp_feepolicy_param values ('22011781','76310204','810001','��ҵ����');
insert into tmp_feepolicy_param values ('22011782','76310304','810001','��ҵ����');
insert into tmp_feepolicy_param values ('22011783','76310404','810001','��ҵ����');
insert into tmp_feepolicy_param values ('22011784','76310504','810001','��ҵ����');
insert into tmp_feepolicy_param values ('22011785','76310604','810001','��ҵ����');
insert into tmp_feepolicy_param values ('22011786','76310704','810001','��ҵ����');
insert into tmp_feepolicy_param values ('22011787','76310804','810001','��ҵ����');
insert into tmp_feepolicy_param values ('62300259','80000001','810001','��ʡ������199IP��ַ��');
insert into tmp_feepolicy_param values ('62300260','80000002','810001','��������ֱ��');
insert into tmp_feepolicy_param values ('62300261','80000003','810001','��ҵӦ�ÿ�XԪ�ʷѰ�');
insert into tmp_feepolicy_param values ('8100','80000004','810001','��������ѡ�Ż�');
insert into tmp_feepolicy_param values ('90089008','90099009','810001','���ſ��ר�������');
insert into tmp_feepolicy_param values ('62300251','90099009','810001','���ſ�ʡר�������');
insert into tmp_feepolicy_param values ('16011201','91120100','810001','�������絥��Ԥ���Ѱ�20Ԫ150��');
insert into tmp_feepolicy_param values ('16011201','91120101','810002','�������絥��Ԥ���Ѱ�20Ԫ150��');
COMMIT;

drop table tmp_detach_item;
create table tmp_detach_item (compitem_id   number(5) , subitem_id   number(5));

--GRPS������ʱ��
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

--�������⿨ҵ������
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

--��������ײ�����
drop table �������bANF��XFng_tmp_tpinfo_ttlan;
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

--���±����Żݵ���Ϣ
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

--������־
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

--�ֿ�ͨ��
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






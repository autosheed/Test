CREATE OR REPLACE PROCEDURE P_NG_TMP_PARAM_SPECIAL_TP
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'P_NG_TMP_PARAM_SPECIAL_TP����ִ�гɹ�!';

      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,DISCNT_NAME) values ('487100010','���������ⲿ����');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,Discnt_Name) values ('487100011','С��֧����Ʒ');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,Discnt_Name) values ('487100012','�û�����ҵ��');
      insert into NG_TMP_ACCT_DISCNT(feepolicy_id,Discnt_Name) values ('487100013','���ʻ���');
      COMMIT;
      
      delete from SD.SYS_PARAMETER where param_code in ('BS_PRODUCT_ID_EXT','BS_PRODUCT_ID_MIC','BS_PRODUCT_ID_HUNG','BS_PRODUCT_ID_BILLCDR_CHK','BS_DETACH_MERGE_ADJUST_FEE');
      COMMIT;
      --���������ⲿ����ID
      insert into SD.SYS_PARAMETER values('BS_PRODUCT_ID_EXT', '���������ⲿ����ID', 5, 0, 2, 487100010, '���������ⲿ����ID', -999);
      commit;
      --С��֧����ƷID
      insert into SD.SYS_PARAMETER values('BS_PRODUCT_ID_MIC', 'С��֧����ƷID', 5, 0, 2, 487100011, 'С��֧����ƷID', -999);
      commit;
      --�û�����ҵ��
      insert into SD.SYS_PARAMETER values('BS_PRODUCT_ID_HUNG', '�û�����ҵ��', 5, 0, 2, 487100012, '�û�����ҵ��', -999);
      commit;
      --���ʻ���
      insert into SD.SYS_PARAMETER values('BS_PRODUCT_ID_BILLCDR_CHK', '���ʻ���', 5, 0, 2, 487100013, '���ʻ���', -999);
      commit;
      --���˿�Ŀ�ϲ�����
      insert into SD.SYS_PARAMETER values('BS_DETACH_MERGE_ADJUST_FEE', '���˿�Ŀ�ϲ�����', 5, 0, 2, 0, '0:���ϲ� 1:�ϲ�', -999);
      commit;

      --����Ʒ����
      insert into PD.PM_PRODUCT_OFFERING(PRODUCT_OFFERING_ID,OFFER_TYPE_ID,NAME,BRAND_SEGMENT_ID,IS_MAIN,LIFECYCLE_STATUS_ID,OPERATOR_ID,PROD_SPEC_ID,OFFER_CLASS,
              PRIORITY,BILLING_PRIORITY,IS_GLOBAL,VALID_DATE,EXPIRE_DATE,DESCRIPTION,SPEC_TYPE_FLAG)
      select distinct FEEPOLICY_ID,
             0,                          --OFFER_TYPE_ID
             DISCNT_NAME,                        
             -1,                         --BRAND_SEGMENT_ID
             0,                          --IS_MAIN
             1,                          --LIFECYCLE_STATUS_ID
             0,                          --OPERATOR_ID
             10180000,                   --PROD_SPEC_ID
             111,                        --OFFER_CLASS
             0,                          --PRIORITY
             0,                          --BILLING_PRIORITY ������ʹ�á�
             0,                          --IS_GLOBAL��APS_XCδ����
             to_date('20100101000000','yyyymmddhh24miss'),to_date('20990101000000','yyyymmddhh24miss'),
             'VB��ӵ��� -- '||to_char(sysdate,'yyyymmddhh24miss'),
             0
        from NG_TMP_ACCT_DISCNT
        where FEEPOLICY_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFERING);
      --����Ʒ����
      insert into PD.PM_PRODUCT_OFFER_ATTRIBUTE   
      select distinct FEEPOLICY_ID,0,1,-1,0,-999,-999,'','',0,
             0,                          --DISCOUNT_EXPIRE_MODE������ʹ�á�
             '',0 from NG_TMP_ACCT_DISCNT
       where FEEPOLICY_ID not in (select PRODUCT_OFFERING_ID from PD.PM_PRODUCT_OFFER_ATTRIBUTE);
      --����Ʒ�۷ѹ��򣨶���APS���ԣ�ò��ûɶ���ã�
      insert into PD.PM_COMPOSITE_DEDUCT_RULE 
      select distinct FEEPOLICY_ID,
             1,                --BILLING_TYPE
             0,1,              --DEDUCT_FLAG
             -1,1002,-1,1,0,   --NEGATIVE_FLAG
             0,                --IS_CHANGE_BILL_CYCLE
             0,                --IS_PER_BILL
             0,0,0,'','',-999,-999,0,-1 from NG_TMP_ACCT_DISCNT
         where FEEPOLICY_ID not in (select PRODUCT_OFFERING_ID from PD.PM_COMPOSITE_DEDUCT_RULE);
      
EXCEPTION
  WHEN OTHERS THEN
       v_resulterrinfo:=substr(SQLERRM,1,200);
       v_resultcode:='-1';
END;
/

      
      
      

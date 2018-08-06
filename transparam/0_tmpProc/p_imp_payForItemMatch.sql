create or replace procedure p_imp_payForItemMatch
(
  v_channelno IN number, --取值从0到9
  v_res out number,
  v_err out varchar2
)
IS
  CURSOR iv_getItem IS SELECT PRICE_RULE_ID,ITEM_ID
                       FROM PD.PM_PAYFOR_ITEM_LIMIT
                       WHERE mod(price_rule_id,10) = v_channelno
                       ORDER BY PRICE_RULE_ID,ITEM_ID; 
  iv_priceRuleId       NUMBER(9);
  iv_itemId            NUMBER(9);
  
  iv_lastPriceRuleId  NUMBER(9);
  iv_itemIdSet1       VARCHAR2(4000);
  iv_itemIdSet2       VARCHAR2(4000);
  iv_itemIdSet3       VARCHAR2(4000);
  iv_itemIdSet4       VARCHAR2(4000);
  iv_itemIdSet5       VARCHAR2(4000);
  iv_itemCount        NUMBER(4);
BEGIN
  v_res:=0;
  v_err:='执行正确!';
  
  iv_lastPriceRuleId:=-9999;
  iv_itemIdSet1:='';
  iv_itemIdSet2:='';
  iv_itemIdSet3:='';
  iv_itemIdSet4:='';
  iv_itemIdSet5:='';
  iv_itemCount:=0;
        
  execute immediate 'delete from PD.PM_PAYFOR_ITEMMATCH where mod(price_rule_id,10)='||v_channelno;
  commit;
  
  OPEN iv_getItem;
  LOOP
    FETCH iv_getItem INTO iv_priceRuleId,iv_itemId;
    EXIT WHEN iv_getItem%NOTFOUND;
    
    IF iv_lastPriceRuleId = -9999 THEN
      iv_lastPriceRuleId := iv_priceRuleId;
      iv_itemIdSet1 := to_char(iv_itemId);
      iv_itemIdSet2:='';
      iv_itemIdSet3:='';
      iv_itemIdSet4:='';
      iv_itemIdSet5:='';
      iv_itemCount:=1;   
    ELSIF iv_priceRuleId = iv_lastPriceRuleId THEN
      iv_itemCount:=iv_itemCount+1;
      IF length(iv_itemIdSet1)>=3900 THEN
        IF length(iv_itemIdSet2)>=3900 THEN
          IF length(iv_itemIdSet3)>=3900 THEN
            IF length(iv_itemIdSet4)>=3900 THEN
              IF length(iv_itemIdSet5)>=3900 THEN
                ROLLBACK;
                v_res:=-1;
                v_err:='账单科目太多,导致超长';
                RETURN;
              ELSE
                iv_itemIdSet5 := iv_itemIdSet5||'|'||to_char(iv_itemId);
              END IF;
            ELSE
              iv_itemIdSet4 := iv_itemIdSet4||'|'||to_char(iv_itemId);
            END IF;
          ELSE
            iv_itemIdSet3 := iv_itemIdSet3||'|'||to_char(iv_itemId);
          END IF;
        ELSE
          iv_itemIdSet2 := iv_itemIdSet2||'|'||to_char(iv_itemId);
        END IF;
      ELSE
        iv_itemIdSet1 := iv_itemIdSet1||'|'||to_char(iv_itemId);
      END IF;
    ELSE
      INSERT INTO PD.PM_PAYFOR_ITEMMATCH 
        (PRICE_RULE_ID,ITEM_COUNT,ITEM_NAME,NORMAL_ITEM,DETAIL_ITEM_SET1,DETAIL_ITEM_SET2,DETAIL_ITEM_SET3,DETAIL_ITEM_SET4,DETAIL_ITEM_SET5)
      VALUES
        (iv_lastPriceRuleId,iv_itemCount,'新付费账目,请定义','0',iv_itemIdSet1,iv_itemIdSet2,iv_itemIdSet3,iv_itemIdSet4,iv_itemIdSet5);  
      COMMIT;
      iv_lastPriceRuleId := iv_priceRuleId;
      iv_itemIdSet1 := to_char(iv_itemId);
      iv_itemIdSet2:='';
      iv_itemIdSet3:='';
      iv_itemIdSet4:='';
      iv_itemIdSet5:='';
      iv_itemCount:=1; 
    END IF;
  END LOOP;
  CLOSE iv_getItem;
  IF iv_lastPriceRuleId != -9999 THEN
      INSERT INTO PD.PM_PAYFOR_ITEMMATCH 
        (PRICE_RULE_ID,ITEM_COUNT,ITEM_NAME,NORMAL_ITEM,DETAIL_ITEM_SET1,DETAIL_ITEM_SET2,DETAIL_ITEM_SET3,DETAIL_ITEM_SET4,DETAIL_ITEM_SET5)
      VALUES
        (iv_lastPriceRuleId,iv_itemCount,'新付费账目,请定义','0',iv_itemIdSet1,iv_itemIdSet2,iv_itemIdSet3,iv_itemIdSet4,iv_itemIdSet5);  
  END IF;
  COMMIT;
  
  RETURN;
  
  UPDATE PD.PM_PAYFOR_ITEMMATCH A SET ITEM_NAME = (SELECT ITEM_NAME FROM PD.PM_PRICE_EVENT B WHERE A.PRICE_RULE_ID = B.ITEM_ID) ,
                                      NORMAL_ITEM = '1'
   WHERE exists (select 1 from PD.PM_PRICE_EVENT B where A.PRICE_RULE_ID = B.ITEM_ID AND B.ITEM_ID BETWEEN 41001 AND 41018) ;
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    v_res:=-1;
    v_err:=sqlerrm;
    RETURN;
END;
/

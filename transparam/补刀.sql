
--½ÇÉ«±àÂë
UPDATE pd.PM_COMPOSITE_OFFER_PRICE a SET a.ROLE_CODE=
(SELECT DISTINCT effect_role_code FROM ucr_param.NG_TMP_TP_DISCNT b
WHERE b.PRODUCT_OFFERING_ID=a.PRICING_PLAN_ID AND '8'||b.PRICE_ID=a.PRICE_ID  ) 
WHERE (PRICING_PLAN_ID,price_id) IN 
(SELECT product_offering_id,'8'||price_id
  FROM ucr_param.NG_TMP_TP_DISCNT 
 WHERE effect_role_code<>-2);
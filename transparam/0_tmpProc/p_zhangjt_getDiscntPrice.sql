CREATE OR REPLACE PROCEDURE p_zhangjt_getdiscntprice
(
    v_resultcode        OUT NUMBER,
    v_resulterrinfo     OUT VARCHAR2
)
AS
  iv_price_comp1          td_b_price_comp%ROWTYPE;
  iv_price_comp2          td_b_price_comp%ROWTYPE;
  iv_price_comp3          td_b_price_comp%ROWTYPE;
  iv_price_comp4          td_b_price_comp%ROWTYPE;
  iv_price_comp5          td_b_price_comp%ROWTYPE;
  iv_price_comp6          td_b_price_comp%ROWTYPE;
  iv_price_comp7          td_b_price_comp%ROWTYPE;

  iv_orderNo              NUMBER(3);
  iv_countNum             NUMBER(3);

  iv_cond_ids1            VARCHAR2(40);
  iv_cond_ids2            VARCHAR2(40);
  iv_cond_ids3            VARCHAR2(40);
  iv_cond_ids4            VARCHAR2(40);
  iv_cond_ids5            VARCHAR2(40);
  iv_cond_ids6            VARCHAR2(40);
  iv_cond_ids7            VARCHAR2(40);
  iv_cond_ids8            VARCHAR2(40);
  iv_cond_ids9            VARCHAR2(40);

  type cursor_type is ref CURSOR;
  iv_cursor1 cursor_type;
  iv_cursor2 cursor_type;
  iv_cursor3 cursor_type;
  iv_cursor4 cursor_type;
  iv_cursor5 cursor_type;
  iv_cursor6 cursor_type;
  iv_cursor7 cursor_type;


BEGIN
    v_resultcode := 0;
    v_resulterrinfo := 'p_zhangjt_getDiscntPrice过程执行成功！';

   EXECUTE IMMEDIATE 'TRUNCATE TABLE NG_TMP_PRICE_DISCNT';

   FOR y IN (SELECT DISTINCT price_id FROM NG_TMP_FEEPOLOICY a where a.type in ('3') and a.is_daygprstp = '0' ORDER BY 1)  --提取优惠
   LOOP
       iv_orderNo:=1;
       iv_cond_ids1:=NULL;
       OPEN iv_cursor1 FOR SELECT * FROM td_b_price_comp
                           WHERE price_id =y.price_id AND p_node_id=0 ORDER BY node_group,node_no,node_id;
       LOOP
       FETCH iv_cursor1 INTO iv_price_comp1;
       EXIT WHEN iv_cursor1%NOTFOUND;
            IF (iv_price_comp1.exec_type<>'0') THEN
               INSERT INTO NG_TMP_PRICE_DISCNT
               (PRICE_ID,ORDER_NO,cond_ids,EXEC_ID)
               VALUES(y.price_id,iv_orderNo,NULL,iv_price_comp1.exec_id);
               iv_orderNo:=iv_orderNo+1;
            ELSE

               iv_cond_ids1:=iv_price_comp1.exec_id;
               OPEN iv_cursor2 FOR SELECT * FROM td_b_price_comp
                                   WHERE price_id =y.price_id AND p_node_id=iv_price_comp1.node_id ORDER BY node_group,node_no,node_id;
               LOOP
               FETCH iv_cursor2 INTO iv_price_comp2;
               EXIT WHEN iv_cursor2%NOTFOUND;

                    IF (iv_price_comp2.exec_type<>'0') THEN
                       INSERT INTO NG_TMP_PRICE_DISCNT
                       (PRICE_ID,ORDER_NO,cond_ids,EXEC_ID)
                       VALUES(y.price_id,iv_orderNo,iv_cond_ids1,iv_price_comp2.exec_id);
                       iv_orderNo:=iv_orderNo+1;

                       EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM td_b_price_comp where price_id =:1'  INTO iv_countNum USING y.price_id;
                       iv_cond_ids6:=iv_price_comp2.node_id;
                       iv_cond_ids7:=iv_cond_ids1;
                       LOOP
                       EXIT WHEN iv_countNum-2<=0;
                       OPEN iv_cursor6 FOR SELECT * FROM td_b_price_comp
                            WHERE price_id =y.price_id AND p_node_id=iv_cond_ids6 ORDER BY node_group,node_no,node_id;
                            LOOP
                            FETCH iv_cursor6 INTO iv_price_comp6;
                            EXIT WHEN iv_cursor6%NOTFOUND;
                            IF (iv_price_comp6.exec_type<>'0') THEN
                               INSERT INTO NG_TMP_PRICE_DISCNT
                               (PRICE_ID,ORDER_NO,cond_ids,EXEC_ID)
                               VALUES(y.price_id,iv_orderNo,iv_cond_ids7,iv_price_comp6.exec_id);
                               iv_orderNo:=iv_orderNo+1;
                            ELSE
                               iv_cond_ids7:=iv_cond_ids7||'|'||iv_price_comp6.exec_id;
                            END IF;
                            END LOOP;
                            CLOSE iv_cursor6;
                            iv_cond_ids6:=iv_price_comp6.node_id;
                            iv_countNum:=iv_countNum-1;
                        END LOOP;

                    ELSE
                       iv_cond_ids2:=iv_cond_ids1||'|'||iv_price_comp2.exec_id;

                       OPEN iv_cursor3 FOR SELECT * FROM td_b_price_comp
                                           WHERE price_id =y.price_id AND p_node_id=iv_price_comp2.node_id
                                           ORDER BY node_group,node_no,node_id;
                       LOOP
                       FETCH iv_cursor3 INTO iv_price_comp3;
                       EXIT WHEN iv_cursor3%NOTFOUND;

                         IF (iv_price_comp3.exec_type<>'0') THEN
                             INSERT INTO NG_TMP_PRICE_DISCNT
                             (PRICE_ID,ORDER_NO,cond_ids,EXEC_ID)
                             VALUES(y.price_id,iv_orderNo,iv_cond_ids2,iv_price_comp3.exec_id);
                             iv_orderNo:=iv_orderNo+1;
                             
                             EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM td_b_price_comp where price_id =:1'  INTO iv_countNum USING y.price_id;
                             iv_cond_ids8:=iv_price_comp3.node_id;
                             iv_cond_ids9:=iv_cond_ids2;
                             LOOP
                             EXIT WHEN iv_countNum-2<=0;
                             OPEN iv_cursor7 FOR SELECT * FROM td_b_price_comp
                                  WHERE price_id =y.price_id AND p_node_id=iv_cond_ids8 ORDER BY node_group,node_no,node_id;
                                  LOOP
                                  FETCH iv_cursor7 INTO iv_price_comp7;
                                  EXIT WHEN iv_cursor7%NOTFOUND;
                                  IF (iv_price_comp7.exec_type<>'0') THEN
                                     INSERT INTO NG_TMP_PRICE_DISCNT
                                     (PRICE_ID,ORDER_NO,cond_ids,EXEC_ID)
                                     VALUES(y.price_id,iv_orderNo,iv_cond_ids9,iv_price_comp7.exec_id);
                                     iv_orderNo:=iv_orderNo+1;
                                  ELSE
                                     iv_cond_ids9:=iv_cond_ids9||'|'||iv_price_comp7.exec_id;
                                  END IF;
                                  END LOOP;
                                  CLOSE iv_cursor7;
                                  iv_cond_ids8:=iv_price_comp7.node_id;
                                  iv_countNum:=iv_countNum-1;
                              END LOOP;
                             
                         ELSE

                             iv_cond_ids3:=iv_cond_ids2||'|'||iv_price_comp3.exec_id;
                             OPEN iv_cursor4 FOR SELECT * FROM td_b_price_comp
                                                 WHERE price_id =y.price_id AND p_node_id=iv_price_comp3.node_id
                                                 ORDER BY node_group,node_no,node_id;
                             LOOP
                             FETCH iv_cursor4 INTO iv_price_comp4;
                             EXIT WHEN iv_cursor4%NOTFOUND;

                               IF (iv_price_comp4.exec_type<>'0') THEN
                                   INSERT INTO NG_TMP_PRICE_DISCNT
                                   (PRICE_ID,ORDER_NO,cond_ids,EXEC_ID)
                                   VALUES(y.price_id,iv_orderNo,iv_cond_ids3,iv_price_comp4.exec_id);
                                   iv_orderNo:=iv_orderNo+1;
                               ELSE

                                   iv_cond_ids4:=iv_cond_ids3||'|'||iv_price_comp4.exec_id;
                                   OPEN iv_cursor5 FOR SELECT * FROM td_b_price_comp
                                                       WHERE price_id =y.price_id AND p_node_id=iv_price_comp4.node_id
                                                       ORDER BY node_group,node_no,node_id;
                                   LOOP
                                   FETCH iv_cursor5 INTO iv_price_comp5;
                                   EXIT WHEN iv_cursor5%NOTFOUND;

                                     IF (iv_price_comp5.exec_type<>'0') THEN
                                         INSERT INTO NG_TMP_PRICE_DISCNT
                                         (PRICE_ID,ORDER_NO,cond_ids,EXEC_ID)
                                         VALUES(y.price_id,iv_orderNo,iv_cond_ids4,iv_price_comp5.exec_id);
                                         iv_orderNo:=iv_orderNo+1;
                                     ELSE
                                       v_resulterrinfo:='price_id:'||y.price_id||' 层次太多';
                                       RETURN;
                                     END IF;

                                   END LOOP;
                                   CLOSE iv_cursor5;

                               END IF;

                             END LOOP;
                             CLOSE iv_cursor4;
                         END IF;

                       END LOOP;
                       CLOSE iv_cursor3;

                    END IF;
               END LOOP;
               CLOSE iv_cursor2;
            END IF;

       END LOOP;
       CLOSE iv_cursor1;
       COMMIT;
   END LOOP;



EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       v_resulterrinfo:=substr(sqlerrm,1,200);
       v_resultcode:='-1';
END;

/

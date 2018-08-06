/*条件表达式 lua脚本
RC        22,26,28
PROM      23,27
*/
select a.*,a.rowid from sd.SYS_POLICY a where a.policy_id between 800000000 and 900000000;
/*度量单位定义*/
select a.*,a.rowid from sd.SYS_MEASURE a where a.measure_id=10403; 


--销售品
/*销售品定义-基本信息
PRODUCT_OFFERING_ID
BILLING_PRIORITY
VALID_DATE
EXPIRE_DATE
*/
select * from pd.pm_product_offering a where a.product_offering_id in (100000374);
/*
销售品扣费规则
PRODUCT_OFFERING_ID
NEGATIVE_FLAG
后付费固定费用产品信用度、预算扣费标识。
00:鉴权、通知扣费不允许扣为负；其它场景也不允许扣为负；
01:鉴权、通知扣费不允许扣为负；其它场景允许扣为负；
10:鉴权、通知扣费允许扣为负；其它场景不允许扣为负；
11:鉴权、通知扣费允许扣为负；其它场景也允许扣为负；

对预付费，同意填00；
BILLING_TYPE:       0:  预付费 1:  后付费
DEDUCT_FLAG:        账务费用扣费方式  0--预扣   1--后扣   2--不扣
注意：
    当Deduct_flag配置为2时，产品管理隐藏固费资费的配置，免费资源由计费侧产生。（即产品不包含固费资费）
    当Deduct_flag配置为0：Pre-deduct时，产品管理需要做配置校验，校验逻辑为一个定价计划下，只有先配置了固定费用，才能配置免费资源。（即有免费资源，必须也要有固定资费）
IS_PER_BILL,            表示是否预收下周期的费用
IS_CHANGE_BILL_CYCLE    扣费失败后是否要变更产品周期
*/
select a.*,a.rowid from pd.PM_COMPOSITE_DEDUCT_RULE a where a.product_offering_id=486100001;
--定价计划
/*   --FORCED_MAKE_UP_PREFERENTIAL(强制补足优惠)
     --FLOOR_PROD_XMULTIMAP(保底叠加的产品组，同组的产品需要进行保底值的叠加处理)
     --CALC_GLOBAL_OFFER_XMULTIMAP
     --ALLOT_OFFERING_PRICING_PLAN(帐本优惠产品的定价计划,初步看代码未曾使用该XC)
PRODUCT_OFFERING_ID  销售品与定价计划建立关联关系
POLICY_ID       (初步看代码仅读0)
PRICING_PLAN_ID
PRIORITY        (初步看代码未曾使用改字段)
MAIN_PROMOTION  (初步看代码未曾使用改字段)
DISP_FLAG       (初步看代码未曾使用改字段)
*/
select a.*,a.rowid from pd.PM_PRODUCT_PRICING_PLAN a where a.product_offering_id in (100000374);-----定价计划-销售品与定价计划关联
/*程序不读该表数据，仅供后台展示*/
select a.*,a.rowid from pd.PM_PRICING_PLAN a where a.pricing_plan_id=100000024;-----定价计划-基本定义
/*组合销售品定价与销售品定价关系表
PRICING_PLAN_ID  计划ID
BILLING_TYPE     预后付标识  -1(ALL)  0(预付)  1(后付)
PRICE_ID         定价ID
VALID_DATE
EXPIRE_DATE
*/
select a.*,a.rowid from pd.PM_COMPOSITE_OFFER_PRICE a where a.pricing_plan_id=5003;--630001438,630001288
/*销售品定价的基本信息
TAX_INCLUDED  含税标识   0(含税无关) 1(不含) 2(含税)   目前固费、一次性费用、基本资费需要关注含税标示，其他PRICE填0
PRICE_TYPE  7(固费)  8(优惠)  9(一次性费用，资料分析.全局促销产品??)  13(群组优惠)  14(押金划拔-江西)
PRICE_ID
*/
select a.*,a.rowid from pd.PM_COMPONENT_PRODOFFER_PRICE a where price_id in (5003);
select a.*,a.rowid from pd.PM_COMPONENT_PRODOFFER_PRICE a where price_id in 
  (select price_id from pd.PM_COMPOSITE_OFFER_PRICE a where a.pricing_plan_id=34079);--52103
select * from PD.PM_COMPOSITE_OFFER_PRICE where pricing_plan_id = 52103 for update;
--优惠定价 
/*账务优惠明细表(时间无效，代码不读取)
PRICE_ID
ADJUSTRATE_ID  校正费率ID，关联具体的校正费率
CALC_SERIAL    由于帐务计算中存在多次计费（优惠）计算，其计算过程是递进方式的，费用计算之间存在先后次序，
               所以需要描述这种先后关系并能够在计费中实现。
               同一pricing_plan_id下的计算优先级顺序，数字越大越优先
USE_TYPE    表示各种状态下是否享受优惠底标志   0(日月账都有效（默认）)   1(日账有效)   2(月账有效)
MEASURE_ID  度量单位  10402(厘)  10403(分)  10404(元)
*/
select a.*,a.rowid from pd.PM_BILLING_DISCOUNT_DTL a where a.price_id in(810001003);
/*
calc_type    
校正费率计算方式：
0:单选资费段调整，适用于帐务计算，当参考科目落在某一段中，即使用该段调整费率进行计算。
1:多段累计调整，适用于帐务计算，参考科目跨越多段的费率计算结果的累计。
2:适用于计费校正资费
*/
select a.*,a.rowid from pd.PM_ADJUST_RATES a where a.adjustrate_id in (810001003) ;
/*帐务优惠校正曲线段表    
ADJUSTRATE_ID
ADJUST_ITEM         --对于业务计费，调整将直接计入批价结果，不需要生成单独的调整科目。
                    --该科目为0将直接计入“校正方案明细表”中科目ID对应的话单中实科目。
                    --可以是实科目和优惠科目
BASE_ITEM           --参考科目？
EXPR_ID             --校正生效的条件,只有在满足该条件时校正才会生效
REF_TYPE            --参考科目参考的类型  1(原始费用) 2(优惠后费用) 3(优惠后且包含预存的费用) 
                                          4(计费标准批价的费用) 5(增量优惠费用) 6(计费累积量)
REF_CYCLES          --默认值填1
ADJUST_CYCLE_TYPE   --优惠作用帐期  1(当前) 2(参考)
FILL_ITEM           --分摊科目？？   默认情况下填0，表示不用分摊科目
ADJUST_TYPE         -- 1(当前账期进行调整)  2(下一账期进行调整)
PRIORITY            --决定优惠段的计算顺序
START_VAL           --当START_VAL，END_VAL大于0时，表示对超出该部分的费用进行优惠。
                    --例如：start_val(100)-end_val(400)表示对超出100且小于400的费用进行优惠。
END_VAL
NUMERATOR           --折扣分子
DENOMINATOR         --折扣分母
PRECISION_ROUND     --规整方式  1(向上规则)  2(向下规整)  3(四舍五入)
ACCOUNT_SHARE_FLAG  --账户级分摊方式：  0：不分摊   1：按贡献比例分摊   2：按优先级分摊
ITEM_SHARE_FLAG     --科目级分摊方式：
                        0：不分摊
                        1：按贡献比例分摊
                        2：按优先级分摊
                        3：按照贡献比例分摊(不体现) 填写adjust_item
                        4：按照优先级分摊 (不体现) 填写adjust_item
                        10：按扩展科目汇总费用的贡献比例分摊
                        20：对扩展科目汇总费用按优先级分摊
DISC_TYPE           --优惠体现类型
                        00:无定义
                        01:产生优惠科目
                        02:减免原始费用
PARA_USE_RULE       --1表示使用(i_user_sprom.sprom_param),0表示不使用 ？？
FORMULA_ID          --优惠的计算公式
MAXIMUM             --优惠最大值
DONATE_USE_RULE     --赠送使用规则???
PROM_TYPE           --优惠类型
                      1：打折（比例） 
                      2：指定（固定） 
                      3：封顶        
                      4：减免        
                      5：保底        
                      6：包打        
                      7：赠送优惠
                      8. 优惠补收     ADJUST_ITEM,NUMERATOR
REF_ROLE            --填0或者NULL表示不限制角色
RESULT_ROLE         --填0或者NULL表示不限制角色
REWARD_ID           --赠送标识，默认值填0
FILL_USER_MODE
                    0：不使用用户分摊方式
                    1：按用户贡献比
                    2：按排名依次消耗
                    3：按群支付帐户下用户帐单的贡献比例 
                    4：按群支付帐户下用户帐单的排名依次消耗
FILL_USER_TOP
                    表示优惠的作用消费排名前几名的用户
                    为-1的时候，表示没有限制，对所有用户按照消费从大到小分摊
TAIL_MODE
                      对于分摊后，优惠的钱仍有多的情况的处理方式
                      0：作废；1：按消费排名，依次分摊
*/
select a.*,a.rowid from pd.PM_ADJUST_SEGMENT a where a.adjustrate_id in (810001003) ;
select a.*,a.rowid from pd.PM_ADJUST_SEGMENT a where prom_type = '10';
860000008
860000009
select * from pd.pm_adjust_flux where rule_id = 34079;
select * from sd.sys_policy where policy_id in (820100719);
select adjustrate_id,count(*) from pd.PM_ADJUST_SEGMENT a group by adjustrate_id having count(*) >1;
select * from pd.pm_adjust_flux where rule_id = 52103;
--科目定义
/*资费科目定义表
ITEM_ID
ITEM_TYPE
                          0－保留
                          1－服务使用事件科目，对应计费网元产生的事件;(Service Usage)
                          2－周期费事件科目;(Recurring Usage)
                          3－一次性费用事件科目，对应业务费，如卡费、初装费等;(One Time Charge)
                          4--税科目
                          5－优惠科目
                          6－代收科目
                          7 - 账务虚科目
                          8 - 外部费用
                          9 - 账务科目（国内使用，与计费科目映射）
                          10 - 帐务累积虚科目（国内使用）
PRIORITY                    --科目冲销优先级，数值越大优先级越大(账务可通过参数配置取越大越优先还是越小越优先)
*/
select a.*,a.rowid from pd.pm_price_event a where a.item_id in(19015) ;--科目定义表
/*累积量的虚科目关系表??
ACCUMULATE_ITEM           --累积科目
ITEM_ID
POLICY_ID
PRIORITY                  --只是给账务虚科目使用
CAL_TYPE                  0-保留    1-相加“+=”    2-相减“-=”
EXT_BILL_ITEM             --优惠补收分摊扩展科目       
*/
select a.*,a.rowid from pd.PM_ACCUMULATE_ITEM_REL a where a.accumulate_item in(39999) and item_id = 19015;--虚科目关联表 
/*虚科目定义表   --程序不读该表数据，仅供后台展示*/
select a.*,a.rowid from pd.PM_ACCUMULATE_ITEM_DEF a where a.accumulate_item in(87001143,87009999);---虚科目定义表
select count(*) from pd.PM_ACCUMULATE_ITEM_REL;


--固费定价
/*  固定费用资费包明细
PRICE_ID,
ITEM_CODE,
RATE_ID,                 --资费编号
ACCOUNT_TYPE,            --出帐方式  1(月账)  2(日账)  3(通用)
VALID_CYCLE,             --0：当前帐期生效，1：下帐期生效
VALID_COUNT,             --取值-1表示无定义
PRE_PAY_TYPE,            --预收类型。0(收当前月)  1(收下月-aps)  2(收下月-crm)   值1时，固定费用费率只能按月配置，对于按天配置和按半月配置无意义。
CAL_INDI,
                          1：扣减整周期全额费用，
                          2：根据本周期的剩余天数，按比例扣减，
                          3：根据使用状态天数，按比例扣减
                          4: 按小时折算
EXPR_ID,                 --参考条件
PRIORITY,                --数值越大，优先级越大
USE_MARKER_ID,           --条件表达式，配置为此资费的使用天数marker    0：表示与用户状态无关   非通配，含判断特殊状态，暂无倒换思路
SEG_INDI,                --1:表示按套餐的marker，多段计算？？？
SEG_REP,                 --？？和SEG_INDI一起配合使用
                          00－单选资费段调整，当参考科目落在某一段中，即使用该段调整费率进行计算。
                          01－多段累计调整，适用于帐务计算，跨越多段的费率计算结果的累计。
PARAM_MODE,            
                          0:循环处理每个个性化参数，资费累加
                          1:取生效时间最晚个性化参数计算
                          2:循环处理，只取费用最大的
*/
select a.*,rowid from pd.PM_RECURRING_FEE_DTL a where price_id = 642661669;
/*固定费用费率定义表
RATE_ID
SERVICE_ID            --服务的标识号   有啥用？？
MAXIMUM               --当计算结果小于此值，返回此值作为结果。       -1表示下不保底
MINIMUM               --当计算结果大于此值（不为-1），返回此值作为结果。    -1表示上不封顶
MEASURE_ID
RATE_PRECISION        --账务不使用  代码仍读取！后续分析
PRECISION_ROUND       --1:向上规则  2;向下规整  3：四舍五入
CURVE_ID              --费率曲线ID，关联固定费用的费率明细
*/
select a.*,a.rowid from pd.PM_RATES a where a.rate_id =70000056;
/*费率曲线的基本信息,无实际用途,关联作用,冗余代码*/
select a.*,a.rowid from pd.PM_CURVE a where a.curve_id=3300033;
/*定义费率曲线每一段的属性   源科目???什么鬼
CURVE_ID
START_VAL          --源科目本段起始点定义，     （end_val-start_val+1）必须是cycle_unit的整数倍
END_VAL            --源科目的本段结束点定义  end_val为-1时表示无穷大
BASE_VAL           --在计算开始前就必须征收的费用。
TAIL_RATE          --一般地，base_val,rate_val配置的费用单位为分，
                     此字段对于billing的XC加载时，base_val,rate_val的数值倍数，
                     即加载到XC时，base_val=base_val*tail_rate,rate_val*tail_rate，
                     用于解决在日租的算费过程中，需要精确到厘的需求，最终的收费formula_id表达式中，
                     需要将得到的费用除以此系数，得出以分为单位的数值
RATE_VAL           --配置按天收取的费率
TAIL_UNIT          --源科目尾数单位
TAIL_ROUND         --源科目尾数阈    0<=tail_round<=tail_unit
FORMULA_ID         --计算公式的表达式ID, from sys_policy
SHARE_NUM          --产品包的用户数
*/
select a.*,a.rowid from pd.PM_CURVE_SEGMENTS a where a.curve_id=70000161;
select * from sd.sys_policy where policy_id in (810200007,810200008);
---------
/*
科目税率表，新老科目确定映射后，直接更新即可
*/
select a.*,a.rowid from PD.PM_ITEM_TAX_RATE a;

select a.*,a.rowid from PD.PM_ITEM_SPLIT_RATE a;
select a.*,a.rowid from PD.PM_PROD_TRANSFER_GROUP_DTL a;
select a.*,a.rowid from PD.PM_PROD_TRANSFER_GROUP a;























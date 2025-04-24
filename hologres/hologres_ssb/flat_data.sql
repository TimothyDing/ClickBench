ANALYZE lineorder;
ANALYZE customer;
ANALYZE dates;
ANALYZE supplier;
ANALYZE part;
ANALYZE lineorder_flat;

INSERT INTO lineorder_flat
SELECT  to_date(LO_ORDERDATE::TEXT ,'YYYYMMDD')
        ,LO_ORDERKEY
        ,LO_LINENUMBER
        ,LO_CUSTKEY
        ,LO_PARTKEY
        ,LO_SUPPKEY
        ,LO_ORDERPRIORITY
        ,LO_SHIPPRIORITY
        ,LO_QUANTITY
        ,LO_EXTENDEDPRICE
        ,LO_ORDTOTALPRICE
        ,LO_DISCOUNT
        ,LO_REVENUE
        ,LO_SUPPLYCOST
        ,LO_TAX
        ,to_date(LO_COMMITDATE::TEXT ,'YYYYMMDD')
        ,LO_SHIPMODE
        ,C_NAME
        ,C_ADDRESS
        ,C_CITY
        ,C_NATION
        ,C_REGION
        ,C_PHONE
        ,C_MKTSEGMENT
        ,S_NAME
        ,S_ADDRESS
        ,S_CITY
        ,S_NATION
        ,S_REGION
        ,S_PHONE
        ,P_NAME
        ,P_MFGR
        ,P_CATEGORY
        ,P_BRAND
        ,P_COLOR
        ,P_TYPE
        ,P_SIZE
        ,P_CONTAINER
FROM    lineorder l 
INNER JOIN    customer c
ON      (c.C_CUSTKEY = l.LO_CUSTKEY)
INNER JOIN supplier s
ON      (s.S_SUPPKEY = l.LO_SUPPKEY) 
INNER JOIN    part p
ON      (p.P_PARTKEY = l.LO_PARTKEY);

VACUUM lineorder_flat;
ANALYZE lineorder_flat;
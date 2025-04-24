DROP TABLE IF EXISTS lineorder;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS dates;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS part;

BEGIN;
CREATE TABLE IF NOT EXISTS lineorder (
  lo_orderkey int NOT NULL ,
  lo_linenumber int NOT NULL ,
  lo_custkey int NOT NULL ,
  lo_partkey int NOT NULL ,
  lo_suppkey int NOT NULL ,
  lo_orderdate int NOT NULL ,
  lo_orderpriority TEXT NOT NULL ,
  lo_shippriority int NOT NULL ,
  lo_quantity int NOT NULL ,
  lo_extendedprice int NOT NULL ,
  lo_ordtotalprice int NOT NULL ,
  lo_discount int NOT NULL ,
  lo_revenue int NOT NULL ,
  lo_supplycost int NOT NULL ,
  lo_tax int NOT NULL ,
  lo_commitdate int NOT NULL ,
  lo_shipmode TEXT NOT NULL ,
  PRIMARY KEY (lo_orderkey,lo_linenumber)
);
CALL set_table_property('lineorder', 'distribution_key', 'lo_orderkey');
CALL set_table_property('lineorder', 'segment_key', 'lo_orderdate');
CALL set_table_property('lineorder', 'clustering_key', 'lo_orderdate');
CALL set_table_property('lineorder', 'time_to_live_in_seconds', '31536000');
COMMIT;


BEGIN;
CREATE TABLE IF NOT EXISTS customer (
  c_custkey int NOT NULL PRIMARY KEY,
  c_name TEXT NOT NULL ,
  c_address TEXT NOT NULL ,
  c_city TEXT NOT NULL ,
  c_nation TEXT NOT NULL ,
  c_region TEXT NOT NULL ,
  c_phone TEXT NOT NULL ,
  c_mktsegment TEXT NOT NULL 
);
CALL set_table_property('customer', 'distribution_key', 'c_custkey');
CALL set_table_property('customer', 'segment_key', 'c_custkey');
CALL set_table_property('customer', 'clustering_key', 'c_custkey');
CALL set_table_property('customer', 'time_to_live_in_seconds', '31536000');
COMMIT;

BEGIN;
CREATE TABLE IF NOT EXISTS dates (
  d_datekey int NOT NULL PRIMARY KEY,
  d_date TEXT NOT NULL ,
  d_dayofweek TEXT NOT NULL ,
  d_month TEXT NOT NULL ,
  d_year int NOT NULL ,
  d_yearmonthnum int NOT NULL ,
  d_yearmonth TEXT NOT NULL ,
  d_daynuminweek int NOT NULL ,
  d_daynuminmonth int NOT NULL ,
  d_daynuminyear int NOT NULL ,
  d_monthnuminyear int NOT NULL ,
  d_weeknuminyear int NOT NULL ,
  d_sellingseason TEXT NOT NULL ,
  d_lastdayinweekfl int NOT NULL ,
  d_lastdayinmonthfl int NOT NULL ,
  d_holidayfl int NOT NULL ,
  d_weekdayfl int NOT NULL 
);
CALL set_table_property('dates', 'distribution_key', 'd_datekey');
CALL set_table_property('dates', 'segment_key', 'd_year');
CALL set_table_property('dates', 'clustering_key', 'd_year');
CALL set_table_property('dates', 'bitmap_columns', 'd_yearmonthnum,d_weeknuminyear,d_year');
CALL set_table_property('dates', 'time_to_live_in_seconds', '31536000');
COMMIT;

BEGIN;
 CREATE TABLE IF NOT EXISTS supplier (
  s_suppkey int NOT NULL PRIMARY KEY,
  s_name TEXT NOT NULL ,
  s_address TEXT NOT NULL ,
  s_city TEXT NOT NULL ,
  s_nation TEXT NOT NULL ,
  s_region TEXT NOT NULL ,
  s_phone TEXT NOT NULL 
);
CALL set_table_property('supplier', 'distribution_key', 's_suppkey');
CALL set_table_property('supplier', 'segment_key', 's_suppkey');
CALL set_table_property('supplier', 'clustering_key', 's_suppkey');
CALL set_table_property('supplier', 'time_to_live_in_seconds', '31536000');
COMMIT;


BEGIN;
CREATE TABLE IF NOT EXISTS part (
  p_partkey int NOT NULL PRIMARY KEY,
  p_name TEXT NOT NULL ,
  p_mfgr TEXT NOT NULL ,
  p_category TEXT NOT NULL ,
  p_brand TEXT NOT NULL ,
  p_color TEXT NOT NULL ,
  p_type TEXT NOT NULL ,
  p_size int NOT NULL ,
  p_container TEXT NOT NULL 
);
CALL set_table_property('part', 'distribution_key', 'p_partkey');
CALL set_table_property('supplier', 'segment_key', 'p_partkey');
CALL set_table_property('supplier', 'clustering_key', 'p_partkey');
CALL set_table_property('part', 'time_to_live_in_seconds', '31536000');
COMMIT;

DROP TABLE IF EXISTS lineorder_flat;

BEGIN;
CREATE TABLE IF NOT EXISTS lineorder_flat (
  lo_orderdate     date NOT NULL ,
  lo_orderkey      int NOT NULL ,
  lo_linenumber    int NOT NULL ,
  lo_custkey       int NOT NULL ,
  lo_partkey       int NOT NULL ,
  lo_suppkey       int NOT NULL ,
  lo_orderpriority text NOT NULL ,
  lo_shippriority  int NOT NULL ,
  lo_quantity      int NOT NULL ,
  lo_extendedprice int NOT NULL ,
  lo_ordtotalprice int NOT NULL ,
  lo_discount      int NOT NULL ,
  lo_revenue       int NOT NULL ,
  lo_supplycost    int NOT NULL ,
  lo_tax           int NOT NULL ,
  lo_commitdate    date NOT NULL ,
  lo_shipmode      text NOT NULL ,
  c_name           text NOT NULL ,
  c_address text NOT NULL ,
  c_city text NOT NULL ,
  c_nation text NOT NULL ,
  c_region text NOT NULL ,
  c_phone text NOT NULL ,
  c_mktsegment text NOT NULL ,
  s_region text NOT NULL ,
  s_nation text NOT NULL ,
  s_city text NOT NULL ,
  s_name text NOT NULL ,
  s_address text NOT NULL ,
  s_phone text NOT NULL ,
  p_name text NOT NULL ,
  p_mfgr text NOT NULL ,
  p_category text NOT NULL ,
  p_brand text NOT NULL ,
  p_color text NOT NULL ,
  p_type text NOT NULL ,
  p_size int NOT NULL ,
  p_container text NOT NULL,
  PRIMARY KEY (lo_orderkey,lo_linenumber)
);
CALL set_table_property('lineorder_flat', 'distribution_key', 'lo_orderkey');
CALL set_table_property('lineorder_flat', 'segment_key', 'lo_orderdate');
CALL set_table_property('lineorder_flat', 'clustering_key', 'lo_orderdate');
CALL set_table_property('lineorder_flat', 'bitmap_columns', 'p_category,s_region,c_region,c_nation,s_nation,c_city,s_city,p_mfgr,p_brand');
CALL set_table_property('lineorder_flat', 'time_to_live_in_seconds', '31536000');
COMMIT;
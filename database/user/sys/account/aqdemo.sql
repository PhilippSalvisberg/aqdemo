-- User
CREATE USER aqdemo IDENTIFIED BY aqdemo 
DEFAULT TABLESPACE aqdemo
TEMPORARY TABLESPACE temp;

-- Access to tablespace
ALTER USER aqdemo QUOTA UNLIMITED ON aqdemo;

-- roles
GRANT connect TO aqdemo ;
GRANT resource TO aqdemo ;
ALTER USER aqdemo DEFAULT ROLE connect, resource;

-- system privileges
GRANT DEBUG CONNECT SESSION TO aqdemo ;
GRANT ALTER SESSION TO aqdemo ;
GRANT CREATE MATERIALIZED VIEW TO aqdemo ;
GRANT CREATE VIEW TO aqdemo ;
GRANT SELECT ANY DICTIONARY TO aqdemo ;
GRANT FLASHBACK ARCHIVE ADMINISTER TO aqdemo ;

-- object privileges
GRANT EXECUTE ON dbms_aqadm TO aqdemo;
GRANT EXECUTE ON dbms_aq TO aqdemo;
GRANT EXECUTE ON dbms_aqin to aqdemo;

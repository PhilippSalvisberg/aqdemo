SET ECHO ON TERMOUT ON SERVEROUTPUT ON SIZE 1000000 PAGESIZE 100 LINESIZE 250 FEEDBACK ON TIMING ON

COLUMN input_number FORMAT 99999999999999999999
COLUMN prime_factorization FORMAT A40

CLEAR SCREEN
REM ===========================================================================
REM 1. create function call the prime factorization service asynchronously
REM ===========================================================================

@../user/aqdemo/function/get_prime_fact.fnc

PAUSE
CLEAR SCREEN
REM ===========================================================================
REM 2. Synchronous prime factorization service calls (with/without timeout)
REM ===========================================================================
SET ARRAYSIZE 1
 SELECT rownum                           AS input_number,
        aqdemo.get_prime_fact(ROWNUM, 1) AS prime_factorization
   FROM dual
CONNECT BY rownum <= 100;


--DDL created by user SYS at 2020-10-01 03:38:12.429000

--Database Version: 6.2.10
ALTER SESSION SET PROFILE='ON';
SET DEFINE OFF;

--SYSTEM PARAMETERS --------------------------------------------------------------------
ALTER SYSTEM SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SYSTEM SET NLS_FIRST_DAY_OF_WEEK = 7;
ALTER SYSTEM SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF6';
ALTER SYSTEM SET NLS_NUMERIC_CHARACTERS = '.,';
ALTER SYSTEM SET NLS_DATE_LANGUAGE = 'ENG';
ALTER SYSTEM SET QUERY_TIMEOUT = '0';
ALTER SYSTEM SET CONSTRAINT_STATE_DEFAULT = 'ENABLE';
ALTER SYSTEM SET PROFILE = 'OFF';
ALTER SYSTEM SET TIME_ZONE = 'EUROPE/BERLIN';
ALTER SYSTEM SET TIME_ZONE_BEHAVIOR = 'INVALID SHIFT AMBIGUOUS ST';
ALTER SYSTEM SET DEFAULT_PRIORITY_GROUP = "MEDIUM";
ALTER SYSTEM SET QUERY_CACHE = 'ON';
ALTER SYSTEM SET DEFAULT_LIKE_ESCAPE_CHARACTER = '\';
ALTER SYSTEM SET TIMESTAMP_ARITHMETIC_BEHAVIOR = 'INTERVAL';
ALTER SYSTEM SET SCRIPT_LANGUAGES = 'PYTHON=builtin_python R=builtin_r JAVA=builtin_java PYTHON3=builtin_python3';
ALTER SYSTEM SET PASSWORD_EXPIRY_POLICY = 'OFF';
ALTER SYSTEM SET PASSWORD_SECURITY_POLICY = 'OFF';
--SESSION PARAMETERS --------------------------------------------------------------------
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_FIRST_DAY_OF_WEEK = 7;
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF6';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';
ALTER SESSION SET NLS_DATE_LANGUAGE = 'ENG';
ALTER SESSION SET CONSTRAINT_STATE_DEFAULT = 'ENABLE';
ALTER SESSION SET PROFILE = 'OFF';
ALTER SESSION SET TIME_ZONE = 'EUROPE/BERLIN';
ALTER SESSION SET TIME_ZONE_BEHAVIOR = 'INVALID SHIFT AMBIGUOUS ST';
ALTER SESSION SET NICE = 'OFF';
ALTER SESSION SET QUERY_CACHE = 'ON';
ALTER SESSION SET DEFAULT_LIKE_ESCAPE_CHARACTER = '\';
ALTER SESSION SET TIMESTAMP_ARITHMETIC_BEHAVIOR = 'INTERVAL';
ALTER SESSION SET SCRIPT_LANGUAGES = 'PYTHON=builtin_python R=builtin_r JAVA=builtin_java PYTHON3=builtin_python3';


-- PRIORITY GROUPS --------------------------------------------------------------------

	--no Priority Groups
-- ROLES --------------------------------------------------------------------

	-- only system roles defined.


-- USERS --------------------------------------------------------------------

	CREATE USER AUTHENTICATOR  identified by "start123";
	CREATE USER DVB_USER  IDENTIFIED BY KERBEROS PRINCIPAL 'dvb_user@does_not_exists';
	CREATE USER DVB_USER_READONLY  IDENTIFIED BY KERBEROS PRINCIPAL 'dvb_user_readonly@does_not_exists';
	CREATE USER DVB_ADMIN  IDENTIFIED BY KERBEROS PRINCIPAL 'dvb_admin@does_not_exists';
	CREATE USER DVB_OPERATIONS  IDENTIFIED BY KERBEROS PRINCIPAL 'dvb_operations@does_not_exists';
	CREATE USER DBADMIN  IDENTIFIED BY KERBEROS PRINCIPAL 'dbadmin@does_not_exists';
	CREATE USER PGAGENT  IDENTIFIED BY KERBEROS PRINCIPAL 'pgagent@does_not_exists';

--SCHEMA: DVB_CORE -------------------------------------------------------------------------------------------

CREATE SCHEMA "DVB_CORE";

--/ 
FUNCTION DVB_CORE."F_STRING_BETWEEN" (input_string in VARCHAR(2000000), first_delimiter in VARCHAR(2000), second_delimiter in VARCHAR(2000)) 
  RETURNS VARCHAR2 (2000000)
AS 
  from_pos int; 
  to_pos int;
BEGIN
  IF first_delimiter||'x' = 'x' THEN
    from_pos := 1;
  ELSE
    from_pos := INSTR(input_string,first_delimiter) + LENGTH(first_delimiter||'x')-1;
  END IF;

  IF (second_delimiter||'x' = 'x') THEN
    to_pos := LENGTH(input_string||'x');
  ELSE
    to_pos := INSTR(SUBSTR(input_string,from_pos), second_delimiter)+from_pos-1;
  END IF;

  IF ((from_pos <= LENGTH(first_delimiter||'x')-1 AND first_delimiter||'x' <> 'x') OR to_pos <= 0 OR to_pos < from_pos) THEN
    RETURN NULL;
  END IF;

  RETURN SUBSTR(input_string, from_pos, to_pos - from_pos);

END;
/


--/ 
FUNCTION "DVB_CORE"."F_GENERATE_HASH_KEY_CHAR" (business_key in NVARCHAR2(4000))
  RETURN CHAR(32) AS
BEGIN
  RETURN HASH_MD5(business_key);
END;
/


--/ 
FUNCTION DVB_CORE."F_GET_BK_FIELDS" (bk_string in VARCHAR2(2000000)) 
  RETURNS VARCHAR2 (2000000)
AS 
	loop_count int;
	field_string VARCHAR2(200000);
	bk_elem VARCHAR2(200000);
BEGIN
	field_string := REGEXP_REPLACE(REGEXP_SUBSTR(bk_string, '\.(\".*?\"|[^\",'']*?)\s*[\),]', 1, 1), '^\.\"?(.*?)\"?\s*[\),]$', '\1');
	loop_count := 2;
	bk_elem := REGEXP_REPLACE(REGEXP_SUBSTR(bk_string, '\.(\".*?\"|[^\",'']*?)\s*[\),]', 1, loop_count), '^\.\"?(.*?)\"?\s*[\),]$', '\1');
	WHILE (bk_elem IS NOT NULL) DO
		field_string := field_string || ', ' || bk_elem;
		loop_count := loop_count + 1;
		bk_elem := REGEXP_REPLACE(REGEXP_SUBSTR(bk_string, '\.(\".*?\"|[^\",'']*?)\s*[\),]', 1, loop_count), '^\.\"?(.*?)\"?\s*[\),]$', '\1');
	END WHILE;
	RETURN field_string;
END;
/


--/ 
FUNCTION "DVB_CORE"."F_GET_KEYS_ARE_UNIQUE" (DATAVAULT_STAGING_VIEW_CODE in VARCHAR2(20000))
  RETURNS BOOLEAN
AS 
BEGIN
	IF POSITION('DISTINCT' IN DATAVAULT_STAGING_VIEW_CODE) > 0 THEN
		RETURN FALSE;
	END IF;

	RETURN TRUE;

END;
/


--/ 
FUNCTION "DVB_CORE"."F_GET_SCHEMA_NAME" (schema_id in VARCHAR2(2000))
  RETURN VARCHAR2 (20000)
AS 
BEGIN
  RETURN CASE schema_id
    WHEN 'STAGING' THEN 'Staging'
    WHEN 'DATAVAULT_STAGING' THEN 'Staging to Datavault Mapping'
    WHEN 'DATAVAULT' THEN 'Datavault (Raw & Business)'
    WHEN 'BUSINESSOBJECTS' THEN 'Business Object Layer'
    WHEN 'BUSINESS_RULES' THEN 'Custom Business Rules Layer'
    WHEN 'ACCESSLAYER' THEN 'Access Layer'
    WHEN 'ACCESS_ERRORMART' THEN 'Access Errormart'
    ELSE schema_id END;
END;
/


--/ 
FUNCTION "DVB_CORE"."F_GET_TIME_INTERVAL_STRING" (start_date IN  TIMESTAMP, end_date IN TIMESTAMP ) 
  RETURNS varchar(100)
IS
  DAYS VARCHAR(100);
  HOURS VARCHAR(4);
  MINUTES VARCHAR(4);
  SECONDS VARCHAR(4);
  DATETIME_DIFF_SECONDS NUMBER(36,9);

BEGIN
  IF (start_date IS NULL OR end_date IS NULL) THEN
    RETURN NULL;
  END IF;
  DATETIME_DIFF_SECONDS := SECONDS_BETWEEN(end_date, start_date);
  IF (DATETIME_DIFF_SECONDS < 0) THEN
    DATETIME_DIFF_SECONDS := 0;
  END IF;
  
  DAYS := TO_CHAR(DIV(DATETIME_DIFF_SECONDS, 24*60*60)) || 'd ';
  DATETIME_DIFF_SECONDS := MOD(DATETIME_DIFF_SECONDS, 24*60*60);
  HOURS := TO_CHAR(DIV(DATETIME_DIFF_SECONDS, 60*60)) || 'h ';
  DATETIME_DIFF_SECONDS := MOD(DATETIME_DIFF_SECONDS, 60*60); 
  MINUTES := TO_CHAR(DIV(DATETIME_DIFF_SECONDS, 60)) || 'm ';
  SECONDS := TO_CHAR(FLOOR(MOD(DATETIME_DIFF_SECONDS, 60))) || 's';
  
  RETURN DAYS || HOURS || MINUTES || SECONDS;

END;
/


--/ 
FUNCTION "DVB_CORE".F_INITCAP ( v_inStr IN VARCHAR(200000) ) 
  RETURN VARCHAR(200000) 
AS
  v_char     CHAR(1);
  v_alphanum   INT;
  v_len		INT;
  v_pos		INT;
  v_outStr	VARCHAR(2000000);
BEGIN
  v_alphanum  := 0;
  v_len  := LENGTH(v_inStr);
  v_pos  := 1;
  v_outStr  := '';
  -- Iterate through all characters in the input string
  WHILE v_pos <= v_len DO
    -- Get the next character
    v_char := SUBSTR(v_inStr, v_pos, 1) ;
    -- If the previous characater is not alphanumeric
    -- convert the current character to upper case
    IF v_alphanum = 0 THEN
      v_outStr := CONCAT(v_outStr ,UPPER(v_char)) ;
	ELSE   
      v_outStr := CONCAT(v_outStr ,LOWER(v_char)) ;
    END IF;
    v_pos := v_pos + 1 ;
    -- Define if the current character is non-alphanumeric
    IF UNICODE(v_char) <= 47 OR
      (UNICODE(v_char) BETWEEN 58 AND 64) OR
      (UNICODE(v_char) BETWEEN 91 AND 96) OR
      (UNICODE(v_char) BETWEEN 123 AND 126)
      THEN
      v_alphanum := 0 ;
    ELSE
      v_alphanum := 1 ;
    END IF;
  END WHILE;
  RETURN v_outStr;
END;
/


--/ 
FUNCTION "DVB_CORE"."F_QUOTE_IDENT"( identifier VARCHAR(200000) ) 
  RETURN VARCHAR(200000) 
AS
  quoted_identifier VARCHAR(200000);
BEGIN
  if ((REGEXP_SUBSTR(identifier, '[^0-9_][A-Z0-9_]*', 1, 1) = identifier) 
    AND UPPER(identifier) NOT IN ('ABSOLUTE','ACTION','ADD','AFTER','ALL','ALLOCATE','ALTER','AND','ANY','APPEND','ARE','ARRAY','AS','ASC','ASENSITIVE','ASSERTION','AT','ATTRIBUTE','AUTHID','AUTHORIZATION','BEFORE','BEGIN','BETWEEN','BIGINT','BINARY','BIT','BLOB','BLOCKED','BOOL','BOOLEAN','BOTH','BY','BYTE','CALL','CALLED','CARDINALITY','CASCADE','CASCADED','CASE','CASESPECIFIC','CAST','CATALOG','CHAIN','CHAR','CHARACTER','CHARACTERISTICS','CHARACTER_SET_CATALOG','CHARACTER_SET_NAME','CHARACTER_SET_SCHEMA','CHECK','CHECKED','CLOB','CLOSE','COALESCE','COLLATE','COLLATION','COLLATION_CATALOG','COLLATION_NAME','COLLATION_SCHEMA','COLUMN','COMMIT','CONDITION','CONNECTION','CONNECT_BY_ISCYCLE','CONNECT_BY_ISLEAF','CONNECT_BY_ROOT','CONSTANT','CONSTRAINT','CONSTRAINTS','CONSTRAINT_STATE_DEFAULT','CONSTRUCTOR','CONTAINS','CONTINUE','CONTROL','CONVERT','CORRESPONDING','CREATE','CS','CSV','CUBE','CURRENT','CURRENT_DATE','CURRENT_PATH','CURRENT_ROLE','CURRENT_SCHEMA','CURRENT_SESSION','CURRENT_STATEMENT','CURRENT_TIME','CURRENT_TIMESTAMP','CURRENT_USER','CURSOR','CYCLE','DATA','DATALINK','DATE','DATETIME_INTERVAL_CODE','DATETIME_INTERVAL_PRECISION','DAY','DBTIMEZONE','DEALLOCATE','DEC','DECIMAL','DECLARE','DEFAULT','DEFAULT_LIKE_ESCAPE_CHARACTER','DEFERRABLE','DEFERRED','DEFINED','DEFINER','DELETE','DEREF','DERIVED','DESC','DESCRIBE','DESCRIPTOR','DETERMINISTIC','DISABLE','DISABLED','DISCONNECT','DISPATCH','DISTINCT','DLURLCOMPLETE','DLURLPATH','DLURLPATHONLY','DLURLSCHEME','DLURLSERVER','DLVALUE','DO','DOMAIN','DOUBLE','DROP','DYNAMIC','DYNAMIC_FUNCTION','DYNAMIC_FUNCTION_CODE','EACH','ELSE','ELSEIF','ELSIF','EMITS','ENABLE','ENABLED','END','END-EXEC','ENFORCE','EQUALS','ERRORS','ESCAPE','EXCEPT','EXCEPTION','EXEC','EXECUTE','EXISTS','EXIT','EXPORT','EXTERNAL','EXTRACT','FALSE','FBV','FETCH','FILE','FINAL','FIRST','FLOAT','FOLLOWING','FOR','FORALL','FORCE','FORMAT','FOUND','FREE','FROM','FS','FULL','FUNCTION','GENERAL','GENERATED','GEOMETRY','GET','GLOBAL','GO','GOTO','GRANT','GRANTED','GROUP','GROUPING','GROUP_CONCAT','HAVING','HIGH','HOLD','HOUR','IDENTITY','IF','IFNULL','IMMEDIATE','IMPLEMENTATION','IMPORT','IN','INDEX','INDICATOR','INNER','INOUT','INPUT','INSENSITIVE','INSERT','INSTANCE','INSTANTIABLE','INT','INTEGER','INTEGRITY','INTERSECT','INTERVAL','INTO','INVERSE','INVOKER','IS','ITERATE','JOIN','KEY_MEMBER','KEY_TYPE','LARGE','LAST','LATERAL','LDAP','LEADING','LEAVE','LEFT','LEVEL','LIKE','LIMIT','LOCAL','LOCALTIME','LOCALTIMESTAMP','LOCATOR','LOG','LONGVARCHAR','LOOP','LOW','MAP','MATCH','MATCHED','MERGE','METHOD','MINUS','MINUTE','MOD','MODIFIES','MODIFY','MODULE','MONTH','NAMES','NATIONAL','NATURAL','NCHAR','NCLOB','NEW','NEXT','NLS_DATE_FORMAT','NLS_DATE_LANGUAGE','NLS_FIRST_DAY_OF_WEEK','NLS_NUMERIC_CHARACTERS','NLS_TIMESTAMP_FORMAT','NO','NOCYCLE','NOLOGGING','NONE','NOT','NULL','NULLIF','NUMBER','NUMERIC','NVARCHAR','NVARCHAR2','OBJECT','OF','OFF','OLD','ON','ONLY','OPEN','OPTION','OPTIONS','OR','ORDER','ORDERING','ORDINALITY','OTHERS','OUT','OUTER','OUTPUT','OVER','OVERLAPS','OVERLAY','OVERRIDING','PAD','PARALLEL_ENABLE','PARAMETER','PARAMETER_SPECIFIC_CATALOG','PARAMETER_SPECIFIC_NAME','PARAMETER_SPECIFIC_SCHEMA','PARTIAL','PATH','PERMISSION','PLACING','PLUS','POSITION','PRECEDING','PREFERRING','PREPARE','PRESERVE','PRIOR','PRIVILEGES','PROCEDURE','PROFILE','RANDOM','RANGE','READ','READS','REAL','RECOVERY','RECURSIVE','REF','REFERENCES','REFERENCING','REFRESH','REGEXP_LIKE','RELATIVE','RELEASE','RENAME','REPEAT','REPLACE','RESTORE','RESTRICT','RESULT','RETURN','RETURNED_LENGTH','RETURNED_OCTET_LENGTH','RETURNS','REVOKE','RIGHT','ROLLBACK','ROLLUP','ROUTINE','ROW','ROWS','ROWTYPE','SAVEPOINT','SCHEMA','SCOPE','SCRIPT','SCROLL','SEARCH','SECOND','SECTION','SECURITY','SELECT','SELECTIVE','SELF','SENSITIVE','SEPARATOR','SEQUENCE','SESSION','SESSIONTIMEZONE','SESSION_USER','SET','SETS','SHORTINT','SIMILAR','SMALLINT','SOME','SOURCE','SPACE','SPECIFIC','SPECIFICTYPE','SQL','SQLEXCEPTION','SQLSTATE','SQLWARNING','SQL_BIGINT','SQL_BIT','SQL_CHAR','SQL_DATE','SQL_DECIMAL','SQL_DOUBLE','SQL_FLOAT','SQL_INTEGER','SQL_LONGVARCHAR','SQL_NUMERIC','SQL_PREPROCESSOR_SCRIPT','SQL_REAL','SQL_SMALLINT','SQL_TIMESTAMP','SQL_TINYINT','SQL_TYPE_DATE','SQL_TYPE_TIMESTAMP','SQL_VARCHAR','START','STATE','STATEMENT','STATIC','STRUCTURE','STYLE','SUBSTRING','SUBTYPE','SYSDATE','SYSTEM','SYSTEM_USER','SYSTIMESTAMP','TABLE','TEMPORARY','TEXT','THEN','TIME','TIMESTAMP','TIMEZONE_HOUR','TIMEZONE_MINUTE','TINYINT','TO','TRAILING','TRANSACTION','TRANSFORM','TRANSFORMS','TRANSLATION','TREAT','TRIGGER','TRIM','TRUE','TRUNCATE','UNDER','UNION','UNIQUE','UNKNOWN','UNLINK','UNNEST','UNTIL','UPDATE','USAGE','USER','USING','VALUE','VALUES','VARCHAR','VARCHAR2','VARRAY','VERIFY','VIEW','WHEN','WHENEVER','WHERE','WHILE','WINDOW','WITH','WITHIN','WITHOUT','WORK','YEAR','YES','ZONE'))
    then
		quoted_identifier := identifier;
	else
		quoted_identifier := '"' || REPLACE(identifier, '"', '""') || '"';
  end if;

  RETURN quoted_identifier;
END;
/



-- BEGIN OF SCRIPT: DVB_CORE.F_GET_VALUE_FROM_JSON ======================================================================================================

OPEN SCHEMA "DVB_CORE";
--/
CREATE PYTHON SCALAR SCRIPT "F_GET_VALUE_FROM_JSON" ("json_string" VARCHAR(2000000) UTF8, "json_key" VARCHAR(4000) UTF8) RETURNS VARCHAR(2000000) UTF8 AS
def run(ctx):
	import json
	try:
	  jsonthing = json.loads(ctx.json_string)
	  json_response = ''
	  json_key = ctx.json_key
	  json_response = jsonthing.get(json_key, '')
	  if not isinstance(json_response,basestring) and json_response is not None:
	    return json.dumps(json_response)
	  else:
	    return json_response
	except:
	  return None

/
CLOSE SCHEMA;
-- END OF SCRIPT: DVB_CORE.F_GET_VALUE_FROM_JSON ======================================================================================================


-- BEGIN OF SCRIPT: DVB_CORE.F_STRING_BETWEEN_CI ======================================================================================================

OPEN SCHEMA "DVB_CORE";
--/
CREATE LUA SCALAR SCRIPT "F_STRING_BETWEEN_CI" ("input_string" VARCHAR(2000000) UTF8, "first_delimiter" VARCHAR(2000) UTF8, "second_delimiter" VARCHAR(2000) UTF8) RETURNS VARCHAR(2000000) UTF8 AS
function run(ctx)
if string.sub(tostring(ctx.input_string),1,12)  ~= 'userdata: 0x' then  in_str = tostring(ctx.input_string) else return '' end 
if string.sub(tostring(ctx.first_delimiter),1,12)  ~= 'userdata: 0x' then	f_del = tostring(ctx.first_delimiter) else	f_del = nil end -- if input is null the tostring gives weird userdata answer
if string.sub(tostring(ctx.second_delimiter ),1,12)  ~= 'userdata: 0x' then	s_del = tostring(ctx.second_delimiter) else	s_del = nil end
                                       
	local from_pos = 0


-- search for start position: if not found return an empty string
	if f_del == nill
		then from_pos = 1
		else do
			from_pos = string.find(string.lower(in_str), string.lower(f_del))
			if from_pos ~= nil
				then from_pos = from_pos + string.len(f_del )
				else return ''
			end
		end
	end

-- search for end position: if not found return an empty string. if found deduct 2 : as 1. we don't want to have the first letter of the second search string+  one more as we are not startin with 0 but with one when extracting the string
	if s_del == nil
		then to_pos = string.len(string.lower(string.sub(in_str, from_pos))	)
		else do
			to_pos = string.find(string.lower(string.sub(in_str, from_pos)), string.lower(s_del))
			if to_pos ~= nil
				then to_pos = to_pos -2
				else return '' 
			end
		end
	end


	return string.sub(in_str, from_pos, to_pos+from_pos) -- cut out the right part of the string



end

/
CLOSE SCHEMA;
-- END OF SCRIPT: DVB_CORE.F_STRING_BETWEEN_CI ======================================================================================================


-- BEGIN OF SCRIPT: DVB_CORE.S_CREATE_TABLE_DDLS ======================================================================================================

OPEN SCHEMA "DVB_CORE";
--/
CREATE LUA SCRIPT "S_CREATE_TABLE_DDLS" (ARRAY schema_ids,replace_option) RETURNS TABLE AS
-- ############################ FUNCTIONS ############################

-- returns a table with columns: SCHEMA_NAME, TABLE_NAME, single column string (including identity and default)
function create_col_str(schema, table)
  res = query([[
                  with notnulls_constraints as
                  (
                     select * from EXA_ALL_CONSTRAINTS
                     where constraint_type = 'NOT NULL'
                  ),   notnulls_constraint_columns as
                  (
                    select * from EXA_ALL_CONSTRAINT_COLUMNS
                    where constraint_type = 'NOT NULL'
                  )
                  select '"'||COL.COLUMN_NAME||'" '||COLUMN_TYPE||
                         CASE WHEN COLUMN_IDENTITY IS NOT NULL THEN ' IDENTITY'
                                                               ELSE ''
                         END||
                         CASE WHEN COLUMN_DEFAULT IS NOT NULL THEN ' DEFAULT '||COLUMN_DEFAULT
                                                               ELSE ''
                         END||
                         CASE WHEN CC.CONSTRAINT_TYPE = 'NOT NULL' AND CON.CONSTRAINT_ENABLED     THEN ' NOT NULL ENABLE'
                              WHEN CC.CONSTRAINT_TYPE = 'NOT NULL' AND NOT CON.CONSTRAINT_ENABLED THEN ' NOT NULL DISABLE'
                                                                                                  ELSE ''
                         END
                         AS COLUMN_STR,
                         COLUMN_SCHEMA, COLUMN_TABLE, COLUMN_ORDINAL_POSITION, CC.CONSTRAINT_TYPE, CON.CONSTRAINT_ENABLED
                  from EXA_ALL_COLUMNS COL
                  left join notnulls_constraint_columns CC
                    on COL.COLUMN_SCHEMA = CC.CONSTRAINT_SCHEMA and COL.COLUMN_TABLE = CC.CONSTRAINT_TABLE and COL.COLUMN_NAME = CC.COLUMN_NAME
                  left JOIN notnulls_constraints CON
                    USING (constraint_schema, constraint_table, CONSTRAINT_NAME)
                  where COLUMN_SCHEMA = :sch
                    and COLUMN_TABLE  = :tab
                  order by COLUMN_ORDINAL_POSITION asc
                
              ]], {sch = schema, tab = table})
  if not (#res > 0) then
    error_str = "ERROR: column string query returned "..#res.." rows, expected more than 1."
    error_str = error_str.."Specified object might not exist" 
    error(error_str)
  end
  return res
end

-- creates DDL for primary key
-- returns bool(primary key exists), ddl(if pk exists)
function create_pk_str(src_schema, src_table, trgt_schema, trgt_table)
  res = query([[
                with pk_cols as (
                  SELECT constraint_schema, constraint_table, CONSTRAINT_NAME, CC.CONSTRAINT_TYPE, C.CONSTRAINT_ENABLED,
                         group_concat('"'||CC.column_name||'"' order by CC.ordinal_position) col_str
                  FROM EXA_ALL_CONSTRAINT_COLUMNS CC
                  JOIN EXA_ALL_CONSTRAINTS C
                    USING (constraint_schema, constraint_table, CONSTRAINT_NAME)
                  group by constraint_schema, constraint_table, CONSTRAINT_NAME, CC.CONSTRAINT_TYPE, C.CONSTRAINT_ENABLED
                )
                select 'ALTER TABLE '||:trgt_obj||' add constraint "'||CONSTRAINT_NAME||'" '||CONSTRAINT_TYPE||
                       '('||col_str||')'||
                       CASE WHEN CONSTRAINT_ENABLED THEN ' ENABLE'
                                                    ELSE ' DISABLE'
                       END||';'
                FROM pk_cols
                where CONSTRAINT_SCHEMA = :sch
                  and CONSTRAINT_TABLE  = :tab
                  and CONSTRAINT_TYPE   = 'PRIMARY KEY'
               ]], {sch = src_schema, tab = src_table, trgt_obj=join('.', quote(trgt_schema), quote(trgt_table))})
  -- there is a pk
  if (#res == 1) then
    return true, res[1][1]
  -- no pk
  else
    return false
  end  
end

-- creates an array containing DDLs for foreign keys
-- returns bool(at least 1 foreign key exists), array with ddl(if fks exists)
function create_fk_str(src_schema, src_table, trgt_schema, trgt_table)
  res = query([[
                with pk_cols as (
                  SELECT constraint_schema, constraint_table, CONSTRAINT_NAME, CC.CONSTRAINT_TYPE, C.CONSTRAINT_ENABLED, CC.REFERENCED_SCHEMA, CC.REFERENCED_TABLE,
                         group_concat('"'||CC.column_name||'"' order by CC.ordinal_position) col_str,
                         group_concat('"'||CC.REFERENCED_COLUMN||'"' order by CC.ordinal_position) ref_str
                  FROM EXA_ALL_CONSTRAINT_COLUMNS CC
                  JOIN EXA_ALL_CONSTRAINTS C
                    USING (constraint_schema, constraint_table, CONSTRAINT_NAME)
                  group by constraint_schema, constraint_table, CONSTRAINT_NAME, CC.CONSTRAINT_TYPE, C.CONSTRAINT_ENABLED, CC.REFERENCED_SCHEMA, CC.REFERENCED_TABLE
                )
                select 'ALTER TABLE '||:trgt_obj||' add constraint "'||CONSTRAINT_NAME||'" '||CONSTRAINT_TYPE||
                       '('||col_str||')'||
                       ' REFERENCES "'||REFERENCED_SCHEMA||'"."'||REFERENCED_TABLE||'"('||ref_str||')'||
                       CASE WHEN CONSTRAINT_ENABLED THEN ' ENABLE'
                                                    ELSE ' DISABLE'
                       END||';'
                FROM pk_cols
                where CONSTRAINT_SCHEMA = :sch
                  and CONSTRAINT_TABLE  = :tab
                  and CONSTRAINT_TYPE   = 'FOREIGN KEY'
               ]], {sch = src_schema, tab = src_table, trgt_obj=join('.', quote(trgt_schema), quote(trgt_table))})
  
  -- there are fks
  if (#res > 0) then
    return true, res
  -- no fk
  else
    return false
  end  
end

-- creates string for DISTRIBUTION KEY
-- returns false if no distribution key is specified, true and key string if distribution key is specified
function create_dist_key_str(src_schema, src_table, trgt_schema, trgt_table)
  res = query([[
                select 'ALTER TABLE '||:trgt_obj||' DISTRIBUTE BY '||GROUP_CONCAT('"'||column_name||'"' ORDER BY column_ordinal_position)||';'
                from exa_all_columns
                where column_schema = :sch
                  and column_table  = :tab
                  and COLUMN_IS_DISTRIBUTION_KEY
                group by column_schema, column_table
              ]], {sch = src_schema, tab = src_table, trgt_obj=join('.', quote(trgt_schema), quote(trgt_table))})
  if (#res == 0) then
    return false
  else     
    return true, res[1][1]
  end
end

-- creates ddl for table comments (table and columns)
-- returns false if no comment specified, true and ddl if comment is specified
function create_table_comments(src_schema, src_table, trgt_schema, trgt_table)
  res = query([[
                select 'COMMENT ON TABLE '||:trgt_obj||' is '''||TABLE_COMMENT||''''
                from EXA_ALL_TABLES
                where table_schema = :sch
                  and table_name   = :tab                  
              ]], {sch = src_schema, tab = src_table, trgt_obj=join('.', quote(trgt_schema), quote(trgt_table))})
  res2 = query([[
                select GROUP_CONCAT('"'||column_name||'" is '''||column_comment||'''')
                from EXA_ALL_COLUMNS
                where column_schema = :sch
                  and column_table  = :tab
                  and column_comment is not null
               ]], {sch=src_schema, tab=src_table})
  
  if(#res == 0 and res2[1][1] == null) then
    return false
  elseif (res2[1][1] ~= null) then
    res_str = res[1][1]..'('..res2[1][1]..');'
    return true, res_str    
  else 
    res_str = res[1][1]..';'
    return true, res_str
  end
end

-- creates ddl for column comment

function create_table_ddl(src_schema, src_table, replace_option)
	trgt_schema = src_schema
	trgt_table = src_table
	
	-- ##### create beginning ("CREATE [OR REPLACE] TABLE <<table_name>>")
	beg_str = "CREATE"
	if (replace_option) then
	  beg_str = beg_str.." OR REPLACE"
	end
	beg_str = beg_str.." TABLE "..join('.', quote(trgt_schema), quote(trgt_table)).."("
	ddl_str = beg_str
	
	-- ##### get columns and create a row for each column 
	col_strs = create_col_str(src_schema, src_table)
	
	for i=1, #col_strs do
	  -- last column: no comma
	  if (i == #col_strs) then
	    my_col_str = '    '..col_strs[i].COLUMN_STR
	  -- other columns: comma
	  else 
	    my_col_str = '    '..col_strs[i].COLUMN_STR..', '
	  end
	  ddl_str = ddl_str..'\n'..my_col_str  
	end
	
	-- ##### close statement
	ddl_str = ddl_str..'\n'..");"
	
	-- ##### primary key
	pk_exists, pk_str = create_pk_str(src_schema, src_table, trgt_schema, trgt_table)
	if (pk_exists) then 
	  ddl_str = ddl_str..'\n'..pk_str  
	end
	
	-- ##### foreign keys
	fk_exists, fk_strs = create_fk_str(src_schema, src_table, trgt_schema, trgt_table)
	if (fk_exists) then 
	  for i=1,#fk_strs do
	    ddl_str = ddl_str..'\n'..fk_strs[i][1]    
	  end
	end
	
	-- ##### distribution key
	dk_exists, dk_str = create_dist_key_str(src_schema, src_table, trgt_schema, trgt_table)
	if (dk_exists) then
	  ddl_str = ddl_str..'\n'..dk_str  
	end
	
	-- ##### comments
	comment_exists, comment_str = create_table_comments(src_schema, src_table, trgt_schema, trgt_table)
	if (comment_exists) then
	  ddl_str = ddl_str..'\n'..comment_str  
	end
	
	-- ##### Return results
	return ddl_str
end

-- ############################ SCRIPT BODY ############################
--return schema_ids
--/
--commit;
i=1
ret_table = {}
for sid=1,#schema_ids do
	tables_res = query([[
			select TABLE_SCHEMA, TABLE_NAME
			from EXA_ALL_TABLES
			where table_schema IN (:sch)
			order by TABLE_SCHEMA, TABLE_NAME               
		]], {sch = schema_ids[sid]})
	for row_num = 1, #tables_res do
		ddl = create_table_ddl(tables_res[row_num][1], tables_res[row_num][2], replace_option)
		ret_table[i] = {tables_res[row_num][1],tables_res[row_num][2],'TABLES',ddl}
	  i=i+1
	end
end
-- ##### Return results
return ret_table, "schema_name VARCHAR(256), object_name VARCHAR(256), object_type VARCHAR(256), ddl varchar(2000000)"

/
CLOSE SCHEMA;
-- END OF SCRIPT: DVB_CORE.S_CREATE_TABLE_DDLS ======================================================================================================


-- BEGIN OF SCRIPT: DVB_CORE.S_GENERATE_BUSINESS_KEY_BACKUP ======================================================================================================

OPEN SCHEMA "DVB_CORE";
--/
CREATE LUA SCALAR SCRIPT "S_GENERATE_BUSINESS_KEY_BACKUP" (...) RETURNS VARCHAR(2000) UTF8 AS
--date as input type not supported!
--null as input looks ulgy too :)
function run(ctx)
 local delimiters ,  business_key ,  columns_count ,  counter ,  column_data , column_data_type ,  empty_business_key 

delimiters = '*&#'
empty_business_key = true
business_key = ''

-- -- csv escaping to be built in
--for i=2, exa.meta.input_column_count do
--  if string.find(tostring(ctx[i]), '[,"]') then
--    ctx[i] = '"' .. string.gsub(s, '"', '""') .. '"'
--  end
--end


for i=1, exa.meta.input_column_count do
	if  not (tostring(ctx[i])== 'userdata: 0x7f4e58b4ad6c') then
	business_key = business_key..tostring(ctx[i])
	if i> 1 then empty_business_key = false end
	end

    if (i>1  or (i== 1 and not (tostring(ctx[1])== 'userdata: 0x7f4e58b4ad6c') ) ) 
	then business_key = business_key..delimiters	end
end

business_key = string.sub(business_key,1, string.len(business_key)-3)

if empty_business_key == false then
return business_key
else
return nil
end
end

/
CLOSE SCHEMA;
-- END OF SCRIPT: DVB_CORE.S_GENERATE_BUSINESS_KEY_BACKUP ======================================================================================================


-- BEGIN OF SCRIPT: DVB_CORE.S_GENERATE_HASH_CRC32_INT ======================================================================================================

OPEN SCHEMA "DVB_CORE";
--/
CREATE LUA SCALAR SCRIPT "S_GENERATE_HASH_CRC32_INT" ("stringvalue" VARCHAR(2000) UTF8) RETURNS DECIMAL(18,0) AS
--Copyright (c) 2007-2008 Neil Richardson (nrich@iinet.net.au)
--
--Permission is hereby granted, free of charge, to any person obtaining a copy 
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights 
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
--copies of the Software, and to permit persons to whom the Software is 
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
--IN THE SOFTWARE.
function run(ctx)
  return(CRC32.Hash(ctx[1]))
end

module('CRC32', package.seeall)
local max = 2^32 -1
local CRC32 = {
    0000000000, 1996959894, 3993919788, 2567524794, 0124634137, 1886057615, 3915621685, 2657392035,
0249268274, 2044508324, 3772115230, 2547177864, 0162941995, 2125561021, 3887607047, 2428444049,
0498536548, 1789927666, 4089016648, 2227061214, 0450548861, 1843258603, 4107580753, 2211677639,
0325883990, 1684777152, 4251122042, 2321926636, 0335633487, 1661365465, 4195302755, 2366115317,
0997073096, 1281953886, 3579855332, 2724688242, 1006888145, 1258607687, 3524101629, 2768942443,
0901097722, 1119000684, 3686517206, 2898065728, 0853044451, 1172266101, 3705015759, 2882616665,
0651767980, 1373503546, 3369554304, 3218104598, 0565507253, 1454621731, 3485111705, 3099436303,
0671266974, 1594198024, 3322730930, 2970347812, 0795835527, 1483230225, 3244367275, 3060149565,
1994146192, 0031158534, 2563907772, 4023717930, 1907459465, 0112637215, 2680153253, 3904427059,
2013776290, 0251722036, 2517215374, 3775830040, 2137656763, 0141376813, 2439277719, 3865271297,
1802195444, 0476864866, 2238001368, 4066508878, 1812370925, 0453092731, 2181625025, 4111451223,
1706088902, 0314042704, 2344532202, 4240017532, 1658658271, 0366619977, 2362670323, 4224994405,
1303535960, 0984961486, 2747007092, 3569037538, 1256170817, 1037604311, 2765210733, 3554079995,
1131014506, 0879679996, 2909243462, 3663771856, 1141124467, 0855842277, 2852801631, 3708648649,
1342533948, 0654459306, 3188396048, 3373015174, 1466479909, 0544179635, 3110523913, 3462522015,
1591671054, 0702138776, 2966460450, 3352799412, 1504918807, 0783551873, 3082640443, 3233442989,
3988292384, 2596254646, 0062317068, 1957810842, 3939845945, 2647816111, 0081470997, 1943803523,
3814918930, 2489596804, 0225274430, 2053790376, 3826175755, 2466906013, 0167816743, 2097651377,
4027552580, 2265490386, 0503444072, 1762050814, 4150417245, 2154129355, 0426522225, 1852507879,
4275313526, 2312317920, 0282753626, 1742555852, 4189708143, 2394877945, 0397917763, 1622183637,
3604390888, 2714866558, 0953729732, 1340076626, 3518719985, 2797360999, 1068828381, 1219638859,
3624741850, 2936675148, 0906185462, 1090812512, 3747672003, 2825379669, 0829329135, 1181335161,
3412177804, 3160834842, 0628085408, 1382605366, 3423369109, 3138078467, 0570562233, 1426400815,
3317316542, 2998733608, 0733239954, 1555261956, 3268935591, 3050360625, 0752459403, 1541320221,
2607071920, 3965973030, 1969922972, 0040735498, 2617837225, 3943577151, 1913087877, 0083908371,
2512341634, 3803740692, 2075208622, 0213261112, 2463272603, 3855990285, 2094854071, 0198958881,
2262029012, 4057260610, 1759359992, 0534414190, 2176718541, 4139329115, 1873836001, 0414664567,
2282248934, 4279200368, 1711684554, 0285281116, 2405801727, 4167216745, 1634467795, 0376229701,
2685067896, 3608007406, 1308918612, 0956543938, 2808555105, 3495958263, 1231636301, 1047427035,
2932959818, 3654703836, 1088359270, 0936918000, 2847714899, 3736837829, 1202900863, 0817233897,
3183342108, 3401237130, 1404277552, 0615818150, 3134207493, 3453421203, 1423857449, 0601450431,
3009837614, 3294710456, 1567103746, 0711928724, 3020668471, 3272380065, 1510334235, 0755167117,
}
local function xor(a, b)
    local calc = 0    
    for i = 32, 0, -1 do
			local val = 2 ^ i
			local aa = false
			local bb = false
		
			if a == 0 then
			    calc = calc + b
			    break
			end
		
			if b == 0 then
			    calc = calc + a
			    break
			end
		
			if a >= val then
			    aa = true
			    a = a - val
			end
		
			if b >= val then
			    bb = true
			    b = b - val
			end
		
			if not (aa and bb) and (aa or bb) then
			    calc = calc + val
			end
    end
    return calc
end
local function lshift(num, left)
    local res = num * (2 ^ left)
    return res % (2 ^ 32)
end
local function rshift(num, right)
    local res = num / (2 ^ right)
    return math.floor(res)
end
function Hash(str)
    local count = string.len(tostring(str))
    local crc = max
    
    local i = 1
    while count > 0 do
			local byte = string.byte(str, i)

			crc = xor(rshift(crc, 8), CRC32[xor(rshift(lshift(crc, 24),24), byte) + 1])
		
			i = i + 1
			count = count - 1
    end
    crc = xor(crc,max)
    if crc >= 2^31 then
        crc = crc - 2^32
    end
    return decimal(crc)
end
--
-- CRC32.lua
--
-- A pure Lua implementation of a CRC32 hashing algorithm. Slower than using a C implemtation,
-- but useful having no other dependencies.
--
--
-- Synopsis
--
-- require('CRC32')
--
-- crchash = CRC32.Hash('a string')
--
-- Methods:
--
-- hashval = CRC32.Hash(val)
--    Calculates and returns (as an integer) the CRC32 hash of the parameter 'val'. 

/
CLOSE SCHEMA;
-- END OF SCRIPT: DVB_CORE.S_GENERATE_HASH_CRC32_INT ======================================================================================================


-- BEGIN OF SCRIPT: DVB_CORE.S_TOUCH_VIEWS ======================================================================================================

OPEN SCHEMA "DVB_CORE";
--/
CREATE LUA SCRIPT "S_TOUCH_VIEWS" (ARRAY schema_list) RETURNS ROWCOUNT AS
if #schema_list==0 then
		exit()
	end
	local view_list_query = [[SELECT VIEW_SCHEMA, VIEW_NAME FROM EXA_DBA_VIEWS WHERE VIEW_SCHEMA IN (']]..schema_list[1]..[[']]

	for element_num = 2, #schema_list do
		view_list_query = view_list_query..[[,']]..schema_list[element_num]..[[']]
	end
	view_list_query = view_list_query..[[)
	MINUS 
	SELECT OBJECT_SCHEMA AS VIEW_SCHEMA, OBJECT_NAME AS VIEW_NAME FROM EXA_DBA_DEPENDENCIES_RECURSIVE 
	WHERE OBJECT_SCHEMA IN (']]..schema_list[1]..[[']]

	for element_num = 2, #schema_list do
		view_list_query = view_list_query..[[,']]..schema_list[element_num]..[[']]
	end
	view_list_query = view_list_query..[[)]]

  local view_res = query(view_list_query)
	
	output('touching '..#view_res..' views...')

	for row_num = 1, #view_res do
		output(join('.', quote(view_res[row_num][1]), quote(view_res[row_num][2])))
		pquery([[SELECT * FROM ::schema.::view WHERE FALSE]], {schema=quote(view_res[row_num][1]), view=quote(view_res[row_num][2])})
  end


/
CLOSE SCHEMA;
-- END OF SCRIPT: DVB_CORE.S_TOUCH_VIEWS ======================================================================================================


--SCHEMA: DVB_CONFIG -------------------------------------------------------------------------------------------

CREATE SCHEMA "DVB_CONFIG";

CREATE TABLE "DVB_CONFIG"."API_HOOK_TEMPLATES"(
		"DVB_API_ID" VARCHAR(256) UTF8 NOT NULL,
		"HOOK_POINT_ID" VARCHAR(32) UTF8 NOT NULL,
		"HOOK_TEMPLATE" VARCHAR(2000000) UTF8,
		"HOOK_COMMENT" VARCHAR(4000) UTF8 );

CREATE TABLE "DVB_CONFIG"."AUTH_USERS"(
		"USER_ID" DECIMAL(18,0) IDENTITY NOT NULL,
		"USERNAME" VARCHAR(4000) UTF8 NOT NULL,
		"EMAIL" VARCHAR(4000) UTF8 NOT NULL,
		"FULL_NAME" VARCHAR(4000) UTF8,
		"PASSWORD_HASH" VARCHAR(4000) UTF8,
		"PASSWORD_EXPIRATION" TIMESTAMP,
		"PG_USER" VARCHAR(4000) UTF8 NOT NULL,
		"NON_EXPIRING_TOKEN" BOOLEAN DEFAULT FALSE NOT NULL,
		"AUTHENTICATE_ON_CLIENT_DB" BOOLEAN DEFAULT FALSE NOT NULL );

CREATE TABLE "DVB_CONFIG"."CONFIG"(
		"CONFIG_KEY" VARCHAR(256) UTF8 NOT NULL,
		"CONFIG_VALUE" VARCHAR(4000) UTF8,
		"CONFIG_COMMENT" VARCHAR(4000) UTF8,
		"CONFIG_IN_DEPLOYMENT" BOOLEAN );

CREATE TABLE "DVB_CONFIG"."JOB_DATA"(
		"JOB_ID" VARCHAR(256) UTF8 NOT NULL,
		"JOB_NAME" VARCHAR(4000) UTF8,
		"JOB_TYPE" VARCHAR(4000) UTF8 NOT NULL,
		"PARALLEL_LOADS" DECIMAL(18,0),
		"JOB_ENABLED" BOOLEAN DEFAULT TRUE,
		"JOB_COMMENT" VARCHAR(4000) UTF8 DEFAULT NULL );

CREATE TABLE "DVB_CONFIG"."JOB_LOADS"(
		"JOB_ID" VARCHAR(256) UTF8 NOT NULL,
		"SOURCE_ID" VARCHAR(256) UTF8 NOT NULL,
		"TARGET_ID" VARCHAR(256) UTF8 NOT NULL );

CREATE TABLE "DVB_CONFIG"."JOB_SCHEDULES"(
		"JOB_ID" VARCHAR(256) UTF8 NOT NULL,
		"SCHEDULE_ID" VARCHAR(256) UTF8 NOT NULL,
		"IS_DELTA_LOAD" BOOLEAN DEFAULT FALSE,
		"WHERE_CLAUSE_PARAMETERS" VARCHAR(4000) UTF8,
		"SCHEDULE_NAME" VARCHAR(4000) UTF8 NOT NULL,
		"SCHEDULE_COMMENT" VARCHAR(4000) UTF8,
		"IS_ENABLED" BOOLEAN DEFAULT FALSE,
		"SCHEDULE_BEGIN" TIMESTAMP NOT NULL,
		"SCHEDULE_END" TIMESTAMP,
		"CRONTAB_STRING" VARCHAR(4000) UTF8 NOT NULL,
		"SCHEDULED_CODE" VARCHAR(4000) UTF8 NOT NULL,
		"INTERNAL_SCHEDULE_ID" DECIMAL(18,0) NOT NULL,
		"SCHEDULE_CREATED" TIMESTAMP DEFAULT SYSTIMESTAMP,
		"SCHEDULE_CHANGED" TIMESTAMP DEFAULT SYSTIMESTAMP,
		"SCHEDULE_LAST_RUN" TIMESTAMP,
		"SCHEDULE_NEXT_RUN" TIMESTAMP );

CREATE TABLE "DVB_CONFIG"."JOB_SQL_QUERIES"(
		"JOB_ID" VARCHAR(256) UTF8 NOT NULL,
		"JOB_SQL_QUERY_ID" VARCHAR(256) UTF8 NOT NULL,
		"JOB_SQL_QUERY_NAME" VARCHAR(4000) UTF8,
		"JOB_SQL_QUERY_ENABLED" BOOLEAN NOT NULL,
		"JOB_SQL_QUERY_CODE" VARCHAR(2000000) UTF8 );

CREATE TABLE "DVB_CONFIG"."JOB_TRIGGERS"(
		"TRIGGERED_BY_JOB_ID" VARCHAR(256) UTF8 NOT NULL,
		"TRIGGERED_JOB_ID" VARCHAR(256) UTF8 NOT NULL );

CREATE TABLE "DVB_CONFIG"."SYSTEM_COLORS"(
		"SYSTEM_COLOR" VARCHAR(7) UTF8 NOT NULL,
		"COLOR_ORDER" DECIMAL(18,0) IDENTITY,
		"SYSTEM_ID" VARCHAR(200) UTF8 );

CREATE TABLE "DVB_CONFIG"."SYSTEM_DATA"(
		"SYSTEM_ID" VARCHAR(200) UTF8 NOT NULL,
		"SYSTEM_NAME" VARCHAR(4000) UTF8,
		"SYSTEM_COMMENT" VARCHAR(4000) UTF8,
		"SOURCE_TYPE_ID" VARCHAR(4000) UTF8,
		"SOURCE_TYPE_URL" VARCHAR(4000) UTF8,
		"SOURCE_TYPE_PARAMETERS" VARCHAR(4000) UTF8 );

CREATE TABLE "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK"(
		"BOOKMARK_TYPE" VARCHAR(256) UTF8 DEFAULT 'datavault' NOT NULL,
		"BOOKMARK_NAME" VARCHAR(256) UTF8 NOT NULL,
		"OWNER_USERNAME" VARCHAR(256) UTF8 NOT NULL,
		"BOOKMARK_CATEGORY" VARCHAR(256) UTF8,
		"BOOKMARK_CONTENT" VARCHAR(2000000) UTF8 NOT NULL,
		"IS_SHARED" BOOLEAN DEFAULT FALSE NOT NULL,
		"CREATED_WITH_DVB_VERSION" VARCHAR(256) UTF8 NOT NULL,
		"MODIFIED_TIMESTAMP" TIMESTAMP DEFAULT SYSDATE NOT NULL );

CREATE TABLE "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION"(
		"DOCUMENTATION_NR" DECIMAL(18,0) NOT NULL,
		"GENERATED_WITH_DVB_VERSION" VARCHAR(256) UTF8 NOT NULL,
		"GENERATION_DATETIME" TIMESTAMP DEFAULT SYSDATE NOT NULL,
		"GENERATION_DURATION" INTERVAL DAY(2) TO SECOND(3) NOT NULL,
		"INITIATING_USERNAME" VARCHAR(256) UTF8 NOT NULL,
		"CONTENT" VARCHAR(2000000) UTF8 NOT NULL );


--SCHEMA: DVB_LOG -------------------------------------------------------------------------------------------

CREATE SCHEMA "DVB_LOG";

CREATE TABLE "DVB_LOG"."DATAVAULT_LOAD_LOG"(
		"LOAD_ENTRY_ID" DECIMAL(18,0) IDENTITY NOT NULL,
		"LOAD_ENTRY_TIME" TIMESTAMP DEFAULT SYSTIMESTAMP,
		"OBJECT_ID" VARCHAR(4000) UTF8 NOT NULL,
		"STAGING_TABLE_ID" VARCHAR(4000) UTF8 NOT NULL,
		"LOAD_START_TIME" TIMESTAMP,
		"LOAD_END_TIME" TIMESTAMP,
		"LOAD_STATE" VARCHAR(4000) UTF8 DEFAULT 'Waiting',
		"LOAD_RESULT" VARCHAR(2000000) UTF8,
		"LOAD_PROGRESS" DECIMAL(18,0),
		"LOAD_TOTAL_ROWS" DECIMAL(36,0),
		"LOGIN_USERNAME" VARCHAR(4000) UTF8,
		"PG_USERNAME" VARCHAR(4000) UTF8 DEFAULT CURRENT_USER,
		"PID" DECIMAL(18,0),
		"JOB_ID" VARCHAR(256) UTF8 );

CREATE TABLE "DVB_LOG"."DDL_LOG"(
		"LOG_ENTRY_ID" DECIMAL(18,0) IDENTITY NOT NULL,
		"LOG_TIMESTAMP" TIMESTAMP DEFAULT SYSTIMESTAMP,
		"SOURCE" VARCHAR(4000) UTF8 NOT NULL,
		"TYPE" VARCHAR(4000) UTF8,
		"OBJECT_ID" VARCHAR(4000) UTF8,
		"LOGIN_USERNAME" VARCHAR(4000) UTF8,
		"PG_USERNAME" VARCHAR(4000) UTF8 DEFAULT CURRENT_USER );

CREATE TABLE "DVB_LOG"."DVBUILDER_CREATION_LOG"(
		"LOG_ENTRY_ID" DECIMAL(18,0) IDENTITY NOT NULL,
		"LOG_TIMESTAMP" TIMESTAMP DEFAULT SYSTIMESTAMP,
		"FUNCTION_CALL" VARCHAR(2000000) UTF8 NOT NULL,
		"FUNCTION_NAME" VARCHAR(4000) UTF8,
		"OBJECT_ID" VARCHAR(4000) UTF8,
		"STAGING_TABLE_ID" VARCHAR(4000) UTF8,
		"LOGIN_USERNAME" VARCHAR(4000) UTF8,
		"PG_USERNAME" VARCHAR(4000) UTF8 DEFAULT CURRENT_USER );

CREATE TABLE "DVB_LOG"."DVBUILDER_LOG"(
		"LOG_ENTRY_ID" DECIMAL(18,0) IDENTITY NOT NULL,
		"LOG_TIMESTAMP" TIMESTAMP NOT NULL,
		"LOG_CURRENT_TIMESTAMP" TIMESTAMP DEFAULT SYSTIMESTAMP,
		"LOGIN_USERNAME" VARCHAR(4000) UTF8,
		"PG_USERNAME" VARCHAR(4000) UTF8 DEFAULT CURRENT_USER,
		"FUNCTION_NAME" VARCHAR(4000) UTF8 NOT NULL,
		"ACTION" VARCHAR(4000) UTF8 NOT NULL,
		"ACTION_STATUS" VARCHAR(4000) UTF8 NOT NULL,
		"ATTRIBUTE_LIST" VARCHAR(2000000) UTF8,
		"ERROR_MESSAGE" VARCHAR(2000000) UTF8,
		"QUERY" VARCHAR(2000000) UTF8,
		"EXPLAIN" VARCHAR(2000000) UTF8,
		"EXPLAIN_ANALYZE" VARCHAR(2000000) UTF8 );

CREATE TABLE "DVB_LOG"."JOB_LOAD_LOG"(
		"LOAD_ENTRY_ID" DECIMAL(18,0) IDENTITY NOT NULL,
		"LOAD_ENTRY_TIME" TIMESTAMP DEFAULT SYSTIMESTAMP,
		"JOB_ID" VARCHAR(256) UTF8 NOT NULL,
		"LOAD_START_TIME" TIMESTAMP,
		"LOAD_END_TIME" TIMESTAMP,
		"LOAD_STATE" VARCHAR(4000) UTF8 DEFAULT 'Waiting',
		"LOAD_RESULT" VARCHAR(2000000) UTF8,
		"LOGIN_USERNAME" VARCHAR(4000) UTF8,
		"PG_USERNAME" VARCHAR(4000) UTF8 DEFAULT CURRENT_USER,
		"PID" DECIMAL(18,0),
		"WHERE_CLAUSE_PARAMETERS" VARCHAR(4000) UTF8,
		"IS_DELTA_LOAD" BOOLEAN DEFAULT FALSE );

CREATE TABLE "DVB_LOG"."LOGIN_LOG"(
		"LOG_ENTRY_ID" DECIMAL(18,0) IDENTITY NOT NULL,
		"LOG_TIMESTAMP" TIMESTAMP DEFAULT SYSTIMESTAMP,
		"LOGIN_USERNAME" VARCHAR(4000) UTF8,
		"PG_USERNAME" VARCHAR(4000) UTF8 DEFAULT CURRENT_USER,
		"LOGIN_STATUS" VARCHAR(4000) UTF8 NOT NULL );

CREATE TABLE "DVB_LOG"."STAGING_LOAD_LOG"(
		"LOAD_ENTRY_ID" DECIMAL(18,0) IDENTITY NOT NULL,
		"LOAD_ENTRY_TIME" TIMESTAMP DEFAULT SYSTIMESTAMP,
		"STAGING_TABLE_ID" VARCHAR(4000) UTF8 NOT NULL,
		"SOURCE_TABLE_ID" VARCHAR(4000) UTF8,
		"SYSTEM_ID" VARCHAR(256) UTF8 NOT NULL,
		"LOAD_START_TIME" TIMESTAMP,
		"LOAD_END_TIME" TIMESTAMP,
		"LOAD_STATE" VARCHAR(4000) UTF8 DEFAULT 'Waiting',
		"LOAD_RESULT" VARCHAR(2000000) UTF8,
		"LOAD_PROGRESS" DECIMAL(18,0),
		"LOAD_TOTAL_ROWS" DECIMAL(36,0),
		"LOGIN_USERNAME" VARCHAR(4000) UTF8,
		"FROM_SYSTEM_LOAD" BOOLEAN DEFAULT FALSE,
		"PG_USERNAME" VARCHAR(4000) UTF8 DEFAULT CURRENT_USER,
		"PID" DECIMAL(18,0),
		"JOB_ID" VARCHAR(256) UTF8 );


--SCHEMA: ACCESS_ERRORMART -------------------------------------------------------------------------------------------

CREATE SCHEMA "ACCESS_ERRORMART";


--SCHEMA: ACCESSLAYER -------------------------------------------------------------------------------------------

CREATE SCHEMA "ACCESSLAYER";


--SCHEMA: BUSINESS_RULES -------------------------------------------------------------------------------------------

CREATE SCHEMA "BUSINESS_RULES";


--SCHEMA: BUSINESSOBJECTS -------------------------------------------------------------------------------------------

CREATE SCHEMA "BUSINESSOBJECTS";


--SCHEMA: DATAVAULT -------------------------------------------------------------------------------------------

CREATE SCHEMA "DATAVAULT";

CREATE TABLE "DATAVAULT"."_DVB_RUNTIME_LOAD_DATA"(
		"OBJECT_ID" VARCHAR(256) UTF8 NOT NULL,
		"MODIFIED_TIME" TIMESTAMP DEFAULT SYSDATE,
		"LAST_FULL_LOAD_TIME" TIMESTAMP );


--SCHEMA: DATAVAULT_STAGING -------------------------------------------------------------------------------------------

CREATE SCHEMA "DATAVAULT_STAGING";


--SCHEMA: STAGING -------------------------------------------------------------------------------------------

CREATE SCHEMA "STAGING";

CREATE TABLE "STAGING"."_DVB_RUNTIME_TABLE_STATUS"(
		"STAGING_TABLE_ID" VARCHAR(256) UTF8 NOT NULL,
		"MODIFIED_TIME" TIMESTAMP DEFAULT SYSDATE,
		"IS_UP_TO_DATE" BOOLEAN DEFAULT FALSE,
		"IS_DELTA_LOAD" BOOLEAN DEFAULT FALSE,
		"DATA_EXTRACT_START_TIME" TIMESTAMP WITH LOCAL TIME ZONE,
		"APPLIED_WHERE_CLAUSE_GENERAL_PART" VARCHAR(2000000) UTF8,
		"APPLIED_WHERE_CLAUSE_DELTA_PART" VARCHAR(2000000) UTF8,
		"APPLIED_WHERE_CLAUSE_DELTA_PART_TEMPLATE" VARCHAR(2000000) UTF8 );


--SCHEMA: EXA_TOOLBOX -------------------------------------------------------------------------------------------

CREATE SCHEMA "EXA_TOOLBOX";

CREATE TABLE "EXA_TOOLBOX"."JSON_TABLE"(
		"JSON_COLUMN" VARCHAR(2000000) UTF8 );

CREATE TABLE "EXA_TOOLBOX"."MOCK_TABLE"(
		"JSON" VARCHAR(2000000) UTF8 );


-- BEGIN OF SCRIPT: EXA_TOOLBOX.CREATE_DDL ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE LUA SCRIPT "CREATE_DDL" (add_user_structure,add_rights,store_in_table) RETURNS TABLE AS
/* 

PARAMETERS: 
	- add_user_structure: boolean	
	  If true then DDL for adding roles and users is added (at the top, before everything else).
	- add_rights: boolean
	  If true then DDL for user & role privileges is added (at the bottom, after everything else).	
	- store_in_table: boolean
	  If true, the entire output is stored in the table "DB_HISTORY"."DATABASE_DDL" before the output is diplayed.

ISSUE [PRJ-1156]:

Lua script - generates DDL for all objects in a database:
  	- all schemas
  	- all tables, constraints, distribution keys.
  	- all views (paying respect to dependencies)
  	- all scripts
  	- all functions
  	- all connections
	- all users, roles, rights
	- all virtual schemas

PREREQUISITES:
        - user executing the script needs "SELECT ANY DICTIONARY" privilege

LIMITATIONS:
        - views and functions which are created in a renamed schema will cause an error on DDL execution
	- GRANTOR of all privileges will be the user that runs the SQL code returned by the script
	- passwords of all users will be 'Start123', except for connections where passwords will be left empty
        - functions with dependencies will not be created in the appropriate order
        - UDF scripts with delimited identifiers (in- or output) will cause an error on DDL execution
	- UDF scripts using languages other than the defaults will fail if bucketfs is not set up beforehand
        - Virtual Schemas will not be created if the required drivers are not installed beforehand 

TODO:
        - omit privs for invalid views?

CHANGE LOG:

2018-06-15
	- Script now creates DDL for users who are authenticated using LDAP (using force). 
	- Added OPEN SCHEMA commands before Script DDL 
	- Allowed option to write the data into a table (only one-line supported). To change the table location, please change lines 670 and 673

2018-08-30
        - return in row is simply not possible, the output is longer than 2.000.000
        - the same applies to writing in a single table column
        - return is splitted in parts the same way the table is written
        - ddl.sql file remains same (export with group_concat)
        - fixed creation errors with added 'or replace' to get a newer version installed

2018-12-28
	- Enabled versioning for 6.1 (still compatible for version 6)
	- Fixed Kerberos authentication (no lines need to be uncommented)
	- check that calling user has "SELECT ANY DICTIONARY" privilege
	- 6.1 FEATURE: Added support for Custom Priority groups
	- 6.1 FEATURE: Added support for impersonation
	- 6.1 FEATURE: Added support for partition keys
	- 6.1 FEATURE: Added support for schema quotas
	- 6.1 FEATURE: Added support for password policies on system-wide or user-based
	- Adds ALTER SYSTEM/SESSION commands to set the parameters as they were on the old system
	- Virtual schemas are created
	- Script execution now works in DBVisualizer
	- Removed return_in_one_row parameter
	- Removed nulls from the output
	- Invalid views WILL be created

2019-01-30
        - Added new LUA script BACKUP_SCRIPTS."RESTORE_SYS"
        - Replace LUA script BACKUP_SCRIPTS."BACKUP_SYS" 
        - Format. Removed blank lines. Adjust Tab and spaces
        
2019-03-22
        - Added handling of DDL that was over 2 million characters
*/

-- sqlstring concatination
function check_version()
	version_suc, version = pquery([[SELECT SUBSTR(PARAM_VALUE, 0, 3) VERSION_NUMBER, PARAM_VALUE version_full FROM EXA_METADATA WHERE PARAM_NAME = 'databaseProductVersion']])

	if not (version_suc) then
		error('error determining version')
	else
		version_short = version[1][1]
		version_full = version[1][2]
	end
end

function sqlstr_add(str)
	sqlstr = sqlstr..str
end

-- set an empty sqlstring
function sqlstr_flush()
	sqlstr = ''
end

-- set an empty ddl
function ddl_flush()
	ddl = ''
end
-- adds sqlstring to dll or adds sqlstring to summary table
function sqlstr_commit()
	ddllength=string.len(ddl)+string.len(sqlstr)
	  -- Check if the length of the total string is greater than 2,000,000, insert into the table first to avoid string being too long
	if ddllength > 2000000 then
		write_table('SPLIT', ddl)
		ddl_flush()
	end
	ddl = ddl..sqlstr
	sqlstr_flush()
end

-- add linefeed to sqlstring
function sqlstr_lf()
		sqlstr_add('\n')
end

function ddl_endings()
	sqlstr_flush()
	sqlstr_lf()
	sqlstr_add('COMMIT;')
	sqlstr_commit();
end

function add_all_connections() 			-- ADD ALL CONNECTIONS -------------------------------------------------------------------------------------

	ac1_success,ac1_res = pquery([[select * from EXA_DBA_CONNECTIONS]])
	if not ac1_success then
		error('Error at ac1')
	end
	sqlstr_add('-- CONNECTIONS --------------------------------------------------------------------\n')
	sqlstr_lf() 
	if (#ac1_res) == 0 then
		sqlstr_add('\t--no connections specified\n')
	end
	for i=1,(#ac1_res) do
		sqlstr_add('\tCREATE CONNECTION '..ac1_res[i].CONNECTION_NAME..' \n\t\tTO \''..ac1_res[i].CONNECTION_STRING..'\'')
		if (ac1_res[i].USER_NAME ~= NULL) then
			sqlstr_add('\n\t\tUSER \''..ac1_res[i].USER_NAME..'\' \n\t\t IDENTIFIED BY \'\';\n\n')
		else
			sqlstr_add(';\n\n')
		end
		sqlstr_commit()
	end
	sqlstr_lf()
	sqlstr_commit()
end


function add_all_roles()					-- ADD ALL ROLES -----------------------------------------------------------------------------------------
	ar1_success, ar1_res = pquery([[SELECT * FROM EXA_DBA_ROLES]])
	if not ar1_success then
		error('Error at ar1')
	end
	if (#ar1_res) > 2 then -- if more than system roles 'public' and 'dba'
--		sqlstr_flush()
		sqlstr_add('-- ROLES --------------------------------------------------------------------\n')
		sqlstr_commit()
		sqlstr_lf() 
		for i=1, (#ar1_res) do
			if (ar1_res[i].ROLE_NAME~='PUBLIC' and ar1_res[i].ROLE_NAME~='DBA') then
				sqlstr_add('\tCREATE ROLE "'..ar1_res[i].ROLE_NAME..'";\n')
				if ar1_res[i].ROLE_COMMENT ~= null then	
					sqlstr_commit()
					sqlstr_add('\t\tCOMMENT ON ROLE "'..ar1_res[i].ROLE_NAME..'" IS \''..ar1_res[i].ROLE_COMMENT..'\';\n')
				end
			end
			sqlstr_commit()
		end
		sqlstr_add('\n')
	else 
			sqlstr_add('-- ROLES --------------------------------------------------------------------\n')
			sqlstr_lf()
			sqlstr_add('\t-- only system roles defined.\n')
			sqlstr_lf()
			sqlstr_commit()
	end
end

function add_all_users()					-- ADD ALL USERS -----------------------------------------------------------------------------------------

	aau1_success, aau1_res = pquery([[SELECT * FROM EXA_DBA_USERS]])
	if not aau1_success then
		error('Error at aau1')
	end
--	sqlstr_flush()
	sqlstr_add('-- USERS --------------------------------------------------------------------\n')
	sqlstr_commit()
	sqlstr_lf()
	if (#aau1_res) > 1 then -- if more than only user 'sys'
		for i=1,(#aau1_res) do
			if aau1_res[i].USER_NAME ~= 'SYS' then
				sqlstr_add('\tCREATE USER '..aau1_res[i].USER_NAME..' ')
				if aau1_res[i].DISTINGUISHED_NAME~=null then  -- if LDAP info given, create username with ldap, otherwise use password
					ldap_string = (string.gsub(aau1_res[i].DISTINGUISHED_NAME, "'", "''"))
					sqlstr_add(' identified at ldap as \''..ldap_string..'\' force;\n')
				elseif (aau1_res[i].KERBEROS_PRINCIPAL) then  -- if Kerberos info given, include Kerberos information
					if (aau1_res[i].KERBEROS_PRINCIPAL)~=null then
						sqlstr_add(' IDENTIFIED BY KERBEROS PRINCIPAL \''..aau1_res[i].KERBEROS_PRINCIPAL..'\';\n')
					else
						sqlstr_add(' identified by "start123";\n')
					end
		                else
		                       sqlstr_add(' identified by "start123";\n') 

				end
				if aau1_res[i].USER_COMMENT ~= NULL then
					sqlstr_commit()
					sqlstr_add('\t\tCOMMENT ON USER '..aau1_res[i].USER_NAME..''.." IS '"..aau1_res[i].USER_COMMENT.."';\n")
				end
				if aau1_res[i].USER_PRIORITY~=null then
					sqlstr_commit()
					if (version_short ~= ('6.0')) and (version_short ~= ('5.0')) then
						sqlstr_add('\t\tGRANT PRIORITY GROUP '..aau1_res[i].USER_PRIORITY..' TO '..aau1_res[i].USER_NAME..';\n')
					else
						sqlstr_add('\t\tGRANT PRIORITY '..aau1_res[i].USER_PRIORITY..' TO '..aau1_res[i].USER_NAME..';\n')
					end
				end
				
				if (version_short ~= ('6.0')) and (version_short ~= ('5.0'))  then
					if aau1_res[i].PASSWORD_EXPIRY_POLICY ~= null then

						sqlstr_commit()
						sqlstr_add('\tALTER USER "'..aau1_res[i].USER_NAME..'" SET PASSWORD_EXPIRY_POLICY=\''.. aau1_res[i].PASSWORD_EXPIRY_POLICY..'\' ;\n')
					end
				end
			end
			sqlstr_commit()
		end	
	sqlstr_add('\n')
	else 
		sqlstr_add('\t-- only system users defined.\n')
		sqlstr_lf()
		sqlstr_commit()
		
	end

end

function add_all_rights()					-- ADD ALL RIGHTS -----------------------------------------------------------------------------------------

	-- role privileges

	art1_success, art1_res = pquery([[SELECT * FROM EXA_DBA_ROLE_PRIVS WHERE NOT (GRANTEE='SYS' AND GRANTED_ROLE='DBA')]])
	if not art1_success then
		error('Error in art1')
	end
	sqlstr_flush()
	sqlstr_add('-- RIGHTS --------------------------------------------------------------------\n')
	sqlstr_lf()
  sqlstr_commit()
	sqlstr_add('\t--Please note that the grantor & owner of all grants will be the user who runs the script!\n')
	sqlstr_lf()
    sqlstr_commit()
	if (#art1_res) >0 then
		for i=1,(#art1_res) do
			sqlstr_add('\tGRANT "'..art1_res[i].GRANTED_ROLE..'" TO '..art1_res[i].GRANTEE..'')
			if art1_res[i].ADMIN_OPTION then
				sqlstr_add(' WITH ADMIN OPTION')
			end
			sqlstr_add(';\n')	
			sqlstr_commit()
		end
	else
		sqlstr_add('\t-- No user is granted any role except for standard.\n')
		sqlstr_lf()
		sqlstr_commit()
	end

	-- system privileges

	art12_success, art12_res = pquery([[SELECT * FROM EXA_DBA_SYS_PRIVS WHERE NOT GRANTEE in ('SYS', 'DBA')]])
	if not art12_success then
		error('Error in art12')
	elseif (#art12_res)>0 then
		sqlstr_flush()
		for i=1,(#art12_res)	do
			sqlstr_add('\tGRANT '..art12_res[i].PRIVILEGE..' TO '..art12_res[i].GRANTEE..';\n')
			sqlstr_add('\n')
			sqlstr_commit()
		end
	elseif (#art12_res)==0 then
		sqlstr_flush()
		sqlstr_add('\t-- No system privileges granted to users other than SYS or DBA. \n')
		sqlstr_lf()
		sqlstr_commit()
	end

	-- object privileges
	art2_success, art2_res = pquery([[SELECT 'GRANT '||PRIVILEGE||' ON "'||case when OBJECT_SCHEMA is not null then OBJECT_SCHEMA||'"."'||OBJECT_NAME||'"' else OBJECT_NAME||'"' end ||
                                        ' TO '||GRANTEE||' ' grant_text 
                                      FROM (select * from EXA_DBA_OBJ_PRIVS where object_type = 'VIEW') op
                                      join (select distinct COLUMN_SCHEMA, COLUMN_TABLE from exa_dba_columns where status is null) cols
                                         on cols.COLUMN_TABLE = op.OBJECT_NAME and cols.COLUMN_SCHEMA = op.OBJECT_SCHEMA
                                      union all 
                                      SELECT 'GRANT '||PRIVILEGE||' ON "'||case when OBJECT_SCHEMA is not null then OBJECT_SCHEMA||'"."'||OBJECT_NAME||'"' else OBJECT_NAME||'"' end ||
                                        ' TO '||GRANTEE||' ' grant_text 
                                      FROM EXA_DBA_OBJ_PRIVS where object_type <> 'VIEW']])
	
	if not art2_success then
		error('Error in art2 '..art2_res.statement_text)
	elseif (#art2_res)>0 then
		sqlstr_flush()
		for i=1,(#art2_res)	do
            sqlstr_add('\t'..art2_res[i].GRANT_TEXT..';\n')
            sqlstr_add('\n')
			sqlstr_commit()
		end
	elseif (#art2_res)==0 then
		sqlstr_flush()
		sqlstr_add('\t-- No object privileges granted to users other than SYS or DBA. \n')
		sqlstr_lf()
		sqlstr_commit()
	end

	-- connection privileges

	art3_success,art3_res = pquery([[select 'GRANT CONNECTION ' || granted_connection ||' to ' || group_concat('"' || grantee || '"' order by grantee) || case ADMIN_OPTION when 'TRUE' then ' WITH ADMIN OPTION;' else ';' end as expr from exa_dba_connection_privs group by granted_connection, admin_option]])
	if not art3_success then
		error('Error in art3.')
	elseif (#art3_res) == 0 then
		sqlstr_flush()
		sqlstr_add('\t-- No connection privileges found. \n')
		sqlstr_lf()
		sqlstr_commit()
	else
	sqlstr_flush()
	for i=1, (#art3_res) do
		sqlstr_add('\t'..art3_res[i].EXPR..'\n')
		sqlstr_lf()
		sqlstr_commit()
	end

	end

	-- impersonation privileges (version >= 6.1)
	if (version_short ~= ('6.0')) and (version_short ~= ('5.0')) then

		art4_success, art4_res = pquery([[SELECT 'GRANT IMPERSONATION ON '|| IMPERSONATION_ON || ' TO ' || GRANTEE || ';' EXPR FROM EXA_DBA_IMPERSONATION_PRIVS]])

		if not art4_success then 
			error('Error in art4: Creating impersonation privileges')
		elseif (#art3_res) == 0 then
			sqlstr_flush()
			sqlstr_add('\t-- No impersonation privileges found. \n')
		else
			sqlstr_flush()
			for i=1, (#art4_res) do 
				sqlstr_add('\t'..art4_res[i].EXPR..'\n')
			end
		
		sqlstr_lf()
		sqlstr_commit()
		end
	end
end

function change_schema_owners()
		co1_success, co1_res = pquery([[SELECT * from EXA_SCHEMAS]])

	if not co1_success then
		error('Error in co1')
	elseif (#co1_res)==0 then
		sqlstr_flush()
		sqlstr_lf()
		sqlstr_add('-- CHANGE SCHEMA OWNERS -----------------------------------------------------------------\n')
		sqlstr_add('\t -- All schemas owned by current user')
		sqlstr_commit()
		sqlstr_lf()
	elseif (#co1_res)>0 then
		sqlstr_flush()
		sqlstr_lf()
		sqlstr_add('-- CHANGE SCHEMA OWNERS -----------------------------------------------------------------\n')
		sqlstr_commit()
		sqlstr_lf()
		for i=1, (#co1_res) do
			sqlstr_add('\tALTER SCHEMA "'..co1_res[i].SCHEMA_NAME..'" CHANGE OWNER "'..co1_res[i].SCHEMA_OWNER..'";\n')
			sqlstr_commit()
		end
		sqlstr_add('\n')
--		sqlstr_commit()
	end
end

function add_all_views_to_DDL()  				--ADD ALL VIEWS--------------------------------------------------------------------------------------------
	
		av1_success, av1_res=pquery([[
WITH
	all_views AS(
		with
			view_dep AS(
				SELECT
					*
				FROM
					EXA_DBA_DEPENDENCIES_RECURSIVE
				WHERE
					REFERENCE_TYPE = 'VIEW'
			)
		SELECT
			view_schema,
			scope_schema,
			view_name,
			'CREATE VIEW "' || REPLACE(VIEW_SCHEMA,'"','""') || '"."' || REPLACE(VIEW_NAME,'"','""') || '"' || "$VIEW_MIGRATION_TEXT"(VIEW_TEXT) VIEW_TEXT
		FROM
			(
					view_dep AS re
				RIGHT OUTER JOIN
					EXA_DBA_VIEWS AS av                
				ON
					re.OBJECT_ID = av.VIEW_OBJECT_ID
                INNER JOIN 
                    (SELECT distinct COLUMN_TABLE, COLUMN_SCHEMA from exa_dba_columns where column_object_type = 'VIEW' and status is null) cols
                ON cols.COLUMN_TABLE = av.VIEW_NAME and cols.COLUMN_SCHEMA = av.VIEW_SCHEMA
			)
	       UNION ALL       
	       SELECT
			view_schema,
			scope_schema,
			view_name,
			'CREATE FORCE VIEW "' || REPLACE(VIEW_SCHEMA,'"','""') || '"."' || REPLACE(VIEW_NAME,'"','""') || '"' || "$VIEW_MIGRATION_TEXT"(VIEW_TEXT) VIEW_TEXT
		FROM
			(
					view_dep AS re
				RIGHT OUTER JOIN
					EXA_DBA_VIEWS AS av                
				ON
					re.OBJECT_ID = av.VIEW_OBJECT_ID
                INNER JOIN 
                    (SELECT distinct COLUMN_TABLE, COLUMN_SCHEMA from exa_dba_columns where column_object_type = 'VIEW' and status is not null) cols
                ON cols.COLUMN_TABLE = av.VIEW_NAME and cols.COLUMN_SCHEMA = av.VIEW_SCHEMA
			)
	)
SELECT
	view_schema,
	scope_schema,
	view_name,
	view_text || case
		when
			substr(
				rtrim(
					rtrim(
						REGEXP_REPLACE(view_text, '[' || CHR(9) || CHR(10) || CHR(13) || ']'),
						' '
					),
					' '
				),
				length(
					rtrim(
						REGEXP_REPLACE(
							view_text,
							'[' || CHR(9) || CHR(10) || CHR(13) || ']'
						),
						' '
					)
				),
				1
			) <> ';'
		then
			CHR(13) || ';'
		else
			''
	end as view_text,
	count(view_name) as count
FROM
	all_views
GROUP BY
	view_schema,
	scope_schema,
	view_name,
	view_text
ORDER BY
	count,
	view_schema,
	view_name;
]])	
		if not av1_success then
			error('Error at av1')  
		elseif (#av1_res) == 0 then
			sqlstr_flush()
			sqlstr_add('-- ALL VIEWS ---------------------------------------------------------------------------------\n')
			sqlstr_add('\t -- No views in the database')			
			sqlstr_commit()
			sqlstr_lf()
		elseif #av1_res > 0 then
			sqlstr_flush()
			sqlstr_add('-- ALL VIEWS ---------------------------------------------------------------------------------\n')
			sqlstr_commit()
			sqlstr_lf()
			if av1_res[1].SCOPE_SCHEMA==NULL then
				sqlstr_add('CLOSE SCHEMA;\n')-- close schema
			else
				 sqlstr_add('\nOPEN SCHEMA "'..av1_res[1].SCOPE_SCHEMA..'";\n')
			end				
			sqlstr_add('\t'..av1_res[1].VIEW_TEXT..'\n\n')
			sqlstr_commit()
			for j=2, (#av1_res) do

				if (av1_res[j].SCOPE_SCHEMA~=av1_res[j-1].SCOPE_SCHEMA)then
						if av1_res[j].SCOPE_SCHEMA==NULL then
							sqlstr_add('CLOSE SCHEMA;\n')-- close schema
						else
							 sqlstr_add('\nOPEN SCHEMA "'..av1_res[j].SCOPE_SCHEMA..'";\n')
						end		
				end
			    sqlstr_add('\t'..av1_res[j].VIEW_TEXT..'\n\n')
			    sqlstr_commit()
		     end	-- for
--		sqlstr_add('\n')
--		sqlstr_lf()
--		sqlstr_commit()
	  end -- else
end

function add_table_to_DDL(schema_name, tbl_name, tbl_comment)	--ADD TABLE-------------------------------------------------------------------------------------------

	sqlstr_flush()
	at1_success, at1_res = pquery([[SELECT * FROM EXA_DBA_COLUMNS WHERE COLUMN_SCHEMA=:s AND COLUMN_TABLE=:t ORDER BY COLUMN_ORDINAL_POSITION]], {s=schema_name, t=tbl_name})
	if not at1_success then  
		error('Error at at1 -- probably table not found')
	else
		sqlstr_add([[CREATE TABLE "]]..at1_res[1].COLUMN_SCHEMA..[["."]]..at1_res[1].COLUMN_TABLE..[["(]]) 							-- CREATE schema_name.table_name (
		distr={}
		part={}

		for i=1, (#at1_res) do
			if i>1 then sqlstr_add(',')
			end
			sqlstr_add('\n\t\t"'..at1_res[i].COLUMN_NAME..'" '..at1_res[i].COLUMN_TYPE)  	-- (beginn of column definition) column_name, column_datatype
			if at1_res[i].COLUMN_DEFAULT~=null then
				sqlstr_add(' DEFAULT '..at1_res[i].COLUMN_DEFAULT)						-- default
			end
			if at1_res[i].COLUMN_IDENTITY~=null then
				sqlstr_add(' IDENTITY')														-- identity
			end
			if not at1_res[i].COLUMN_IS_NULLABLE then									-- not null
				sqlstr_add(' NOT NULL')	
			end	
			if at1_res[i].COLUMN_COMMENT~=null then
				sqlstr_add(' COMMENT IS \''..string.gsub(at1_res[i].COLUMN_COMMENT, "'", "''")..'\'')					-- column comment
			end
			if at1_res[i].COLUMN_IS_DISTRIBUTION_KEY == true then
				table.insert(distr, {at1_res[i].COLUMN_NAME})
			end
		end --for
		if #distr >= 1  then	
			sqlstr_add(',\n\t\tDISTRIBUTE BY "'..distr[1][1]..'"')
		end
		if #distr > 1 then													--	distribute by
			for k=2,(#distr) do
				sqlstr_add(', "'..distr[k][1]..'" ')
			end				
		end

		if (version_short ~= ('6.0')) and (version_short ~= ('5.0')) then	                               --partition by
			at2_success, at2_res = pquery([[SELECT * FROM EXA_DBA_COLUMNS WHERE COLUMN_SCHEMA=:s AND COLUMN_TABLE=:t AND COLUMN_PARTITION_KEY_ORDINAL_POSITION IS NOT NULL ORDER BY COLUMN_PARTITION_KEY_ORDINAL_POSITION]], {s=schema_name, t=tbl_name})
			if not at2_success then  
				error('Error at at2 -- probably table not found')
			elseif #at2_res == 0 then

			else
				for p=1,#at2_res do
					table.insert(part, at2_res[p].COLUMN_NAME)
				end
			
			end
			
			if #part >= 1 then
				sqlstr_add(', \n\t\tPARTITION BY "'..part[1]..'"')
			end
			if #part > 1 then
				for x=2, (#part) do
					sqlstr_add(', "'..part[x]..'"')
				end
			end
		end
		sqlstr_add(' )')							
		if tbl_comment ~= null then														-- table comment
			sqlstr_add('\n\tCOMMENT IS \''..tbl_comment..'\'')
		end
		sqlstr_add(';\n')
		sqlstr_lf()
		sqlstr_commit()
	end
end

function add_schemas_constraint_to_DDL(schema_name)	--ADD THE SCHEMA'S CONSTRAINTS--------------------------------------------------------------------------------------------
	sqlstr_flush()
--	ac1_success, ac1_res = pquery([[SELECT * FROM EXA_DBA_CONSTRAINT_COLUMNS WHERE CONSTRAINT_SCHEMA=:s AND (CONSTRAINT_TYPE='PRIMARY KEY' OR CONSTRAINT_TYPE='FOREIGN KEY') ORDER BY CONSTRAINT_TYPE desc, COLUMN_NAME]], {s=schema_name})
	ac1_success, ac1_res = pquery([[with sel1 as (
	select COL.constraint_schema, COL.constraint_table, COL.constraint_type, COL.constraint_name, COL.column_name, AC.constraint_enabled, COL.REFERENCED_SCHEMA, COL.REFERENCED_TABLE, COL.REFERENCED_COLUMN 
	from EXA_DBA_constraints AC 
	join EXA_DBA_constraint_columns COL
	on AC.constraint_name=COL.constraint_name and AC.CONSTRAINT_SCHEMA = COL.CONSTRAINT_SCHEMA and AC.CONSTRAINT_TABLE = COL.CONSTRAINT_TABLE) ) 
select constraint_schema, constraint_table, constraint_type, constraint_name, constraint_enabled, REFERENCED_TABLE, group_concat(column_name separator '","') column_names, group_concat(REFERENCED_COLUMN separator '","') REFERENCED_COLUMNS
from sel1  where constraint_schema=:s AND (CONSTRAINT_TYPE='PRIMARY KEY' OR CONSTRAINT_TYPE='FOREIGN KEY')
group by  constraint_schema, constraint_table, constraint_type, constraint_name, constraint_enabled, REFERENCED_TABLE, REFERENCED_SCHEMA
order by constraint_type desc, constraint_table]], {s=schema_name})
	if not ac1_success then 
		error('Error in ac1'..aac1_res.statement_text)
	else
		for i=1,(#ac1_res) do 
			if ac1_res[i].CONSTRAINT_TYPE=='PRIMARY KEY' then
				sqlstr_add('\tALTER TABLE "'..ac1_res[i].CONSTRAINT_SCHEMA..'"."'..ac1_res[i].CONSTRAINT_TABLE..'"\n\t\tADD CONSTRAINT "'..ac1_res[i].CONSTRAINT_NAME..'"\n\t\t '..ac1_res[i].CONSTRAINT_TYPE..' ("'..ac1_res[i].COLUMN_NAMES..'");\n')
				sqlstr_lf()
			elseif ac1_res[i].CONSTRAINT_TYPE=='FOREIGN KEY' then
				sqlstr_add('\tALTER TABLE "'..ac1_res[i].CONSTRAINT_SCHEMA..'"."'..ac1_res[i].CONSTRAINT_TABLE..'"\n\t\tADD CONSTRAINT "'..ac1_res[i].CONSTRAINT_NAME..'"\n\t\t '..ac1_res[i].CONSTRAINT_TYPE..' ("'..ac1_res[i].COLUMN_NAMES..'")\n\t\t\tREFERENCES "'..ac1_res[i].REFERENCED_TABLE..'"("'..ac1_res[i].REFERENCED_COLUMNS..'");\n')
				sqlstr_lf()
			end
		end -- for
		sqlstr_commit()
	end -- else

end -- function

function add_all_constraints_to_DDL()	--ADD ALL CONSTRAINTS--------------------------------------------------------------------------------------------
	sqlstr_flush()
--	aac1_success, aac1_res = pquery([[SELECT * FROM EXA_DBA_CONSTRAINT_COLUMNS WHERE (CONSTRAINT_TYPE='PRIMARY KEY' OR CONSTRAINT_TYPE='FOREIGN KEY') ORDER BY CONSTRAINT_TYPE desc, CONSTRAINT_SCHEMA, COLUMN_NAME]])
	aac1_success, aac1_res = pquery([[with sel1 as (
	select COL.constraint_schema, COL.constraint_table, COL.constraint_type, COL.constraint_name, COL.column_name, AC.constraint_enabled, COL.REFERENCED_SCHEMA,  COL.REFERENCED_TABLE, COL.REFERENCED_COLUMN 
	from EXA_DBA_constraints AC 
	join EXA_DBA_constraint_columns COL
	on AC.constraint_name=COL.constraint_name and AC.CONSTRAINT_SCHEMA = COL.CONSTRAINT_SCHEMA and AC.CONSTRAINT_TABLE = COL.CONSTRAINT_TABLE) 
select constraint_schema, constraint_table, constraint_type, constraint_name, constraint_enabled, REFERENCED_TABLE, REFERENCED_SCHEMA, group_concat(column_name separator '","') column_names, group_concat(REFERENCED_COLUMN separator '","') REFERENCED_COLUMNS
from sel1  where (CONSTRAINT_TYPE='PRIMARY KEY' OR CONSTRAINT_TYPE='FOREIGN KEY')
group by  constraint_schema, constraint_table, constraint_type, constraint_name, constraint_enabled, REFERENCED_TABLE, REFERENCED_SCHEMA
order by constraint_type desc,constraint_schema, constraint_table]])

	if not aac1_success then 
		error('Error in aac1'..aac1_res.statement_text)
	else
				sqlstr_add('-- ALL CONSTRAINTS ---------------------------------------------------------------------------------\n')
				sqlstr_lf()
                sqlstr_commit()
		for i=1,(#aac1_res) do 
			if aac1_res[i].CONSTRAINT_TYPE=='PRIMARY KEY' then
				sqlstr_add('\tALTER TABLE "'..aac1_res[i].CONSTRAINT_SCHEMA..'"."'..aac1_res[i].CONSTRAINT_TABLE..'"\n\t\tADD CONSTRAINT "'..aac1_res[i].CONSTRAINT_NAME..'"\n\t\t '..aac1_res[i].CONSTRAINT_TYPE..' ("'..aac1_res[i].COLUMN_NAMES..'");\n')
				sqlstr_lf()
                sqlstr_commit()
			elseif aac1_res[i].CONSTRAINT_TYPE=='FOREIGN KEY' then
				sqlstr_add('\tALTER TABLE "'..aac1_res[i].CONSTRAINT_SCHEMA..'"."'..aac1_res[i].CONSTRAINT_TABLE..'"\n\t\tADD CONSTRAINT "'..aac1_res[i].CONSTRAINT_NAME..'"\n\t\t '..aac1_res[i].CONSTRAINT_TYPE..' ("'..aac1_res[i].COLUMN_NAMES..'")\n\t\t\tREFERENCES "'..aac1_res[i].REFERENCED_SCHEMA..'"."'..aac1_res[i].REFERENCED_TABLE..'"("'..aac1_res[i].REFERENCED_COLUMNS..'");\n')
				sqlstr_lf()
                sqlstr_commit()
			end
		end -- for
		sqlstr_commit()
	end -- else
end -- function

function add_function_to_DDL(function_text) 				--ADD FUNCTION-------------------------------------------------------------------------------------------
	sqlstr_flush()
	sqlstr_add('--/ \n'..function_text..'\n')
	sqlstr_lf()
	sqlstr_commit()
end

function add_script_to_DDL(schema_name, script_name) 				--ADD SCRIPT-------------------------------------------------------------------------------------------
	sqlstr_flush()
	as1_success, as1_res = pquery([[SELECT SCRIPT_SCHEMA, SCRIPT_TEXT FROM EXA_DBA_SCRIPTS WHERE SCRIPT_NAME=:s]], {s=script_name})
		if not as1_success then
			error('Error at as1')
		end
	sqlstr_lf()
	sqlstr_add('-- BEGIN OF SCRIPT: '..schema_name..'.'..script_name..' ======================================================================================================\n')
	sqlstr_commit()
	sqlstr_add('\nOPEN SCHEMA \"'..schema_name..'\";')    --Open schema to create the script
	sqlstr_commit()
	sqlstr_add('\n--/\n'..as1_res[1][2]..'\n\/')
	sqlstr_commit()
	sqlstr_add('\nCLOSE SCHEMA;')
	sqlstr_commit()
	sqlstr_add('\n-- END OF SCRIPT: '..schema_name..'.'..script_name..' ======================================================================================================\n')
	sqlstr_lf()
	sqlstr_commit()
end

function add_schema_to_DDL(schemaname, schema_comment) 		--ADD SCHEMA-------------------------------------------------------------------------------------------
	sqlstr_flush()
	sqlstr_add('--SCHEMA: '..schemaname..' -------------------------------------------------------------------------------------------\n')
	sqlstr_lf()
	sqlstr_commit()
	sqlstr_add([[CREATE SCHEMA "]]..schemaname..'\";\n')
	if schema_comment ~= null then
		sqlstr_add('COMMENT ON SCHEMA \"'..schemaname..'\" IS \''..schema_comment..'\';\n')
	end

	if (version_short ~= ('6.0')) and (version_short ~= ('5.0')) then              -- Add schema size limit
		ads1_suc, ads1_res = pquery([[SELECT * FROM EXA_DBA_OBJECT_SIZES WHERE OBJECT_TYPE = 'SCHEMA' AND OBJECT_NAME = :s]],{s=schemaname})

		if not (ads1_suc) then
			error('Error checking schema size limit')
		else

			if ads1_res[1].RAW_OBJECT_SIZE_LIMIT ~= null then
				sqlstr_add('\n\tALTER SCHEMA "'..ads1_res[1].OBJECT_NAME..'" SET RAW_SIZE_LIMIT='..ads1_res[1].RAW_OBJECT_SIZE_LIMIT..';\n')			
			end
		end
	end
	 --if
	sqlstr_lf()
	sqlstr_commit()
end

function write_table(p_type_in, p_txt_in)
	summary[#summary+1] = {p_txt_in}

	if store_in_table == true then
    	idx = idx + 1
    	suc, res = pquery([[INSERT INTO DB_HISTORY.DATABASE_DDL VALUES (:ct, :rn, :type, :txt)]]
                      ,{ct = t[1].CURRENT_TIMESTAMP, rn = idx, type = p_type_in, txt=p_txt_in})
		if (suc) then
		else
			output(string.len(p_txt_in))
			output(string.sub(p_txt_in, 1, 150000))
			errtext = "Type is :"..type(summary[1]).."Error in script!!: "..res.error_message
			error(errtext)
		end 
      
  	end
	ddl_flush()
end

function add_all_priority_groups()                              -- ADD PRIORITY GROUPS (AFTER VERSION 6.1)
	aapg1_suc, aapg1_res = pquery([[select * from exa_priority_groups where PRIORITY_GROUP_NAME NOT IN ('HIGH', 'MEDIUM', 'LOW')]])

	if not (aapg1_suc) then
		error('ERROR CREATING PRIORITY GROUPS')
	end

	sqlstr_add('-- PRIORITY GROUPS --------------------------------------------------------------------\n')
	sqlstr_lf() 
	if (#aapg1_res) == 0 then
		sqlstr_add('\t--no Priority Groups\n')
	end
	for i=1,(#aapg1_res) do
		sqlstr_add('\tCREATE PRIORITY GROUP \"'..aapg1_res[i].PRIORITY_GROUP_NAME..'\" WITH WEIGHT = '..aapg1_res[i].PRIORITY_GROUP_WEIGHT..';\n\t\t')
		if (aapg1_res[i].PRIORITY_GROUP_COMMENT ~= NULL) then
			
			sqlstr_add('\n\t\tCOMMENT ON PRIORITY GROUP "'..aapg1_res[i].PRIORITY_GROUP_NAME..'" IS \''..aapg1_res[i].PRIORITY_GROUP_COMMENT..'\'; \n\t\t ')
		else
			sqlstr_add('\n\n')
		end
		sqlstr_commit()
	end
end

function add_system_parameters()                                --ADD SYSTEM PARAMETERS
	asp1_suc, asp1_res = pquery([[SELECT * FROM EXA_PARAMETERS WHERE SYSTEM_VALUE IS NOT NULL AND PARAMETER_NAME != 'NICE']])

	if not (asp1_suc) then
		error('Error retrieving system parameters')
	else
		sqlstr_add('--SYSTEM PARAMETERS --------------------------------------------------------------------\n')
		for i=1, #asp1_res do
			if asp1_res[i].PARAMETER_NAME == ('NLS_FIRST_DAY_OF_WEEK' or 'QUERY_TIMEOUT') then
				sqlstr_add('ALTER SYSTEM SET '..asp1_res[i].PARAMETER_NAME..' = '..asp1_res[i].SYSTEM_VALUE..';\n')
			elseif asp1_res[i].PARAMETER_NAME == 'DEFAULT_PRIORITY_GROUP' then
				sqlstr_add('ALTER SYSTEM SET '..asp1_res[i].PARAMETER_NAME..' = "'..asp1_res[i].SYSTEM_VALUE..'";\n')
			else
				sqlstr_add('ALTER SYSTEM SET '..asp1_res[i].PARAMETER_NAME..' = \''..asp1_res[i].SYSTEM_VALUE..'\';\n')
			end
		end
	end

	asp2_suc, asp2_res = pquery([[SELECT * FROM EXA_PARAMETERS WHERE SESSION_VALUE IS NOT NULL AND PARAMETER_NAME NOT IN ('QUERY_TIMEOUT', 'DEFAULT_PRIORITY_GROUP','PASSWORD_EXPIRY_POLICY', 'PASSWORD_SECURITY_POLICY')]])
	
	if not (asp2_suc) then
		error('Error retrieving session parameters')
	else
		sqlstr_add('--SESSION PARAMETERS --------------------------------------------------------------------\n')
		for i=1, #asp2_res do
			if asp2_res[i].PARAMETER_NAME == ('NLS_FIRST_DAY_OF_WEEK') then
				sqlstr_add('ALTER SESSION SET '..asp2_res[i].PARAMETER_NAME..' = '..asp2_res[i].SESSION_VALUE..';\n')
			elseif asp2_res[i].PARAMETER_NAME == 'DEFAULT_PRIORITY_GROUP' then
				sqlstr_add('ALTER SESSION SET '..asp2_res[i].PARAMETER_NAME..' = "'..asp2_res[i].SESSION_VALUE..'";\n')
			else
				sqlstr_add('ALTER SESSION SET '..asp2_res[i].PARAMETER_NAME..' = \''..asp2_res[i].SESSION_VALUE..'\';\n')
			end
		end
	end
	sqlstr_commit()
end

function add_all_virtual_schemas()		-- ADD ALL VIRTUAL SCHEMAS -----------------------------------------------------------------------------------------
	avs1_success, avs1_res = pquery([[select
'CREATE VIRTUAL SCHEMA ' || s.SCHEMA_NAME || ' USING ' || ADAPTER_SCRIPT || '
WITH
' || GROUP_CONCAT(PROPERTY_NAME || ' = ''' || PROPERTY_VALUE || '''' ORDER BY PROPERTY_NAME SEPARATOR '
') || ';
' AS 'TEXT'
from
EXA_VIRTUAL_SCHEMAS s
join
EXA_ALL_VIRTUAL_SCHEMA_PROPERTIES p using (schema_object_id)
group by s.schema_name, adapter_script;]])
	output(#avs1_res)
	if not avs1_success then
		error('Error Creating virtual Schemas')
	end
	if (#avs1_res) >= 1 then -- if more than system roles 'public' and 'dba'
--		sqlstr_flush()
		sqlstr_add('-- VIRTUAL SCHEMAS --------------------------------------------------------------------\n')
		sqlstr_commit()
		sqlstr_lf() 
		for i=1, #avs1_res do
			sqlstr_add('\t'..avs1_res[i].TEXT..'\n\n')
		end
		sqlstr_commit()
		sqlstr_lf()
	else 
			sqlstr_add('-- VIRTUAL SCHEMAS --------------------------------------------------------------------\n')
			sqlstr_lf()
			sqlstr_add('\t-- no virtual schemas defined.\n')
			sqlstr_lf()
			sqlstr_commit()
	end
end

-- MAIN --------------------------------------------------------------------------------------------------------------------------------------------
-- Check if the user has SELECT ANY DICTIONARY privilege:
	privsuc, privcheck = pquery([[SELECT * FROM EXA_DBA_USERS LIMIT 1]])

	if not (privsuc) then
		error('The User does not have SELECT ANY DICTIONARY privileges')
	end

check_version()
-- Prepare Output Table if requested
if store_in_table == true then

	if version_short ~= '5.0' then

		cschemsucc,cschemres = pquery([[CREATE SCHEMA IF NOT EXISTS "DB_HISTORY";]])
		if (cschemsucc) then

			ctabsuc, ctabres = pquery ([[CREATE TABLE IF NOT EXISTS "DB_HISTORY"."DATABASE_DDL" (BACKUP_TIME TIMESTAMP, rn decimal(5), type varchar(20), DDL varchar(2000000));]])
			if (ctabsuc) then
      			query ([[COMMIT]])
    		else 
				error('error in creating DDL Table')
			end
		else
			error('error in create DDL schema')
		end
	else
		checkschemsucc,checkschemres = pquery([[SELECT SCHEMA_NAME FROM EXA_SCHEMAS WHERE SCHEMA_NAME = 'DB_HISTORY']])
		
		if not (checkschemsucc) then
			error('Error checking for DB_HISTORY schema')
		else
			if (#checkschemres) > 0 then
				cschemsucc,cschemres= pquery([[OPEN SCHEMA "DB_HISTORY"]])
			else
				cschemsucc,cschemres = pquery([[CREATE SCHEMA "DB_HISTORY";]])
			end
		end

		if (cschemsucc) then
			ctabchecksuc, ctabcheckres = pquery([[SELECT TABLE_NAME FROM EXA_DBA_TABLES WHERE TABLE_SCHEMA='DB_HISTORY' AND TABLE_NAME='DATABASE_DDL';]])

			if not (ctabchecksuc) then
				error('Error checking for Database_ddl table')
			else
				if (#ctabcheckres) == 0 then
					ctabsuc, ctabres = pquery ([[CREATE TABLE "DB_HISTORY"."DATABASE_DDL" (BACKUP_TIME TIMESTAMP, rn decimal(5), type varchar(20), DDL varchar(2000000));]])
	
					if (ctabsuc) then
      					query([[COMMIT]])
    				else 
						error('error in creating DDL Table')
					end
				
				end
			end	
			
		else
			error('error in create DDL schema')
		end
	end
end

t=query([[SELECT CURRENT_USER,CURRENT_TIMESTAMP]])

constraints_separately = true
return_in_one_row = true

ddl = ''
summary = {{'START'}}
sqlstr =[[]]
sqlstr_add('\n--DDL created by user '..t[1].CURRENT_USER..' at '..t[1].CURRENT_TIMESTAMP..'\n\n')
sqlstr_commit()
sqlstr_flush()

--Check Versioning and insert into string
check_version()

sqlstr_add([[--Database Version: ]]..version_full..'\n')
if version_short == '5.0' then
	sqlstr_add([[--WARNING: Version 5 is not supported]].. '\n')
end

-- ENABLE PROFILING

sqlstr_add([[ALTER SESSION SET PROFILE='ON';]]..'\n')
sqlstr_add([[SET DEFINE OFF;]]..'\n')
sqlstr_commit()
idx = 0
write_table('HEADER',ddl)

add_system_parameters()
write_table('SYSTEM PARAMETERS', ddl)
										-- roles, users
if add_user_structure then	
	if (version_short ~= ('6.0')) and (version_short ~= ('5.0')) then
		add_all_priority_groups()
 		 write_table ('PRIORTY GROUPS', ddl)
	end
	add_all_roles()
  write_table('ROLES',ddl)
	add_all_users()
  write_table('USERS',ddl)
end

										-- schemas
if version_short == '5.0' then
	m1_success, m1_res = pquery([[select OBJECT_NAME, OBJECT_COMMENT from EXA_DBA_OBJECTS WHERE OBJECT_TYPE = 'SCHEMA' ORDER BY 'OBJECT_NAME']])
else

	m1_success, m1_res = pquery([[select OBJECT_NAME, OBJECT_COMMENT from EXA_DBA_OBJECTS WHERE OBJECT_TYPE = 'SCHEMA' AND OBJECT_IS_VIRTUAL IS FALSE ORDER BY 'OBJECT_NAME']])
end
if not m1_success then
	error('Error at m1')
else
	for i=1,(#m1_res) do -- iterate through all schemas
		add_schema_to_DDL(m1_res[i].OBJECT_NAME, m1_res[i].OBJECT_COMMENT)
		
		m2_success, m2_res = pquery([[select table_schema,table_name,table_comment from EXA_DBA_TABLES WHERE TABLE_SCHEMA=:s ORDER BY TABLE_NAME]], {s = m1_res[i].OBJECT_NAME})
		if not m2_success then
			error('Error at m2')
		else
			for j=1,(#m2_res) do -- iterate through all tables of the current schema
				add_table_to_DDL(m2_res[j].TABLE_SCHEMA,m2_res[j].TABLE_NAME, m2_res[j].TABLE_COMMENT)
			end	
			if not constraints_separately then -- outline constraints within schema block
						add_schemas_constraint_to_DDL(m1_res[i].OBJECT_NAME)
			end -- if
		end	-- else (tables)
									-- add all functions to the schema
		m21_success, m21_res=pquery([[SELECT
	FUNCTION_NAME,
	FUNCTION_TEXT || case
		when
			substr(
				rtrim(
					REGEXP_REPLACE(
						function_text,
						'[' || CHR(10) || CHR(13) || ']',
						' '
					),
					' '
				),
				length(
					rtrim(
						REGEXP_REPLACE(
							function_text,
							'[' || CHR(10) || CHR(13) || ']',
							' '
						),
						' '
					)
				),
				1
			) <> '/'
		then
			'
/'
		else
			''
	end function_text
FROM
	EXA_DBA_FUNCTIONS WHERE FUNCTION_SCHEMA=:s]],{s = m1_res[i].OBJECT_NAME})
		if not m21_success then
			error('Error at m21')
		else
			for j=1,(#m21_res) do
				add_function_to_DDL(m21_res[j].FUNCTION_TEXT)
			end -- for
		end --else
								-- get all script names of the current schema
		m4_success, m4_res=pquery([[SELECT SCRIPT_SCHEMA,SCRIPT_NAME FROM EXA_DBA_SCRIPTS WHERE SCRIPT_SCHEMA=:s]],{s = m1_res[i].OBJECT_NAME}) 
		if not m4_success then
			error('Error at m3')
		end -- if
		for j=1,(#m4_res) do -- add scripts of the schema
			add_script_to_DDL(m4_res[j].SCRIPT_SCHEMA,m4_res[j].SCRIPT_NAME)
		end -- for (scripts)		
 
    write_table('SCHEMA', ddl)
	end --for (schemas)

    -- add all views
    add_all_views_to_DDL()
    write_table('VIEWS',ddl)

    --add all virtual schemas
	if version_short ~= '5.0' then
		add_all_virtual_schemas()
		write_table('VIRTUAL SCHEMAS', ddl)
	end

	if constraints_separately==true then
   	-- add all constraints
		add_all_constraints_to_DDL()
    	write_table('CONSTRAINTS',ddl)
	end

	-- add all connections
	add_all_connections()	
	write_table('CONNECTIONS',ddl)

	if add_user_structure then	
		change_schema_owners()
   	write_table('SCHEMA OWNERS',ddl)
	end

	if add_rights then
		add_all_rights()
   	write_table('RIGHTS',ddl)
	end

	ddl_endings()
	write_table('FOOTER',ddl)
  
end -- else

-- ##### Return results
summary[#summary+1] = {'STOP'}

-- Remove nulls from the summary table
summary_new={}
for i=1, #summary do
	if (string.match(summary[i][1], '%a')) then
		summary_new[#summary_new+1] = summary[i][1]
	else
	
	end
end

summary={{}}
for i=1, #summary_new do
	summary[#summary+1] = {summary_new[i]}	
end
table.remove(summary,1)
return summary, "DDL varchar(2000000)"


/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.CREATE_DDL ======================================================================================================


-- BEGIN OF SCRIPT: EXA_TOOLBOX.BACKUP_SYS ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE LUA SCRIPT "BACKUP_SYS" (file_location) RETURNS TABLE AS
summary={}

local suc1, res1 = pquery([[select schema_name, object_name from exa_syscat
                                                           where instr(object_name,'EXA_USER_') = 0
                                                             and instr(object_name,'EXA_ALL_') = 0
                                                             and instr(object_name,'AUDIT') = 0
                        ; ]])

if suc1 then
	for i=1, #res1 do
		summary[#summary+1] = {[[export ]]..res1[i][1]..[[.]]..res1[i][2]..[[ into local csv file ']]..file_location..[[]]..res1[i][2]..[[.csv' truncate;]]}
	end	
else
	local error_msg = "ERR: ["..res1.error_code.."] "..res1.error_message
	exit(query([[SELECT :error as ERROR FROM DUAL;]], {error=error_msg}))
end 

return summary, "DDL varchar(2000000)"


/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.BACKUP_SYS ======================================================================================================


-- BEGIN OF SCRIPT: EXA_TOOLBOX.RESTORE_SYS ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE LUA SCRIPT "RESTORE_SYS" () RETURNS TABLE AS
summary={}

summary[#summary+1] = {[[ALTER SESSION SET PROFILE='on';]]}
summary[#summary+1] = {[[CREATE SCHEMA IF NOT EXISTS SYS_OLD;]]}

local suc1, res1 = pquery([[select schema_name, object_name from exa_syscat
                                                           where instr(object_name,'EXA_USER_') = 0
                                                             and instr(object_name,'EXA_ALL_') = 0
                                                             and instr(object_name,'AUDIT') = 0
                        ; ]])

if suc1 then
	for i=1, #res1 do
		summary[#summary+1] = {[[create or replace table SYS_OLD.]]..res1[i][2]..[[ like ]]..res1[i][1]..[[.]]..res1[i][2]..[[;]]}
		summary[#summary+1] = {[[import into SYS_OLD.]]..res1[i][2]..[[ from local csv file ']]..'&'..[[1/]]..res1[i][2]..[[.csv';]]}
	end	
else
	local error_msg = "ERR: ["..res1.error_code.."] "..res1.error_message
	exit(query([[SELECT :error as ERROR FROM DUAL;]], {error=error_msg}))
end 

return summary, "DDL varchar(2000000)"


/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.RESTORE_SYS ======================================================================================================


-- BEGIN OF SCRIPT: EXA_TOOLBOX.JSON_FLATTEN ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE PYTHON SCALAR SCRIPT "JSON_FLATTEN" () RETURNS DOUBLE AS
from collections import defaultdict

'''
This function is used to convert python datatypes to exasol types
It is used to create the columns used in the "create table" and "insert into" statements  
'''
def convertType(columnType):
        exaType = 'varchar(2000000)'
        if columnType is int:
                exaType = 'decimal(18,0)'
        elif columnType is float:
                exaType = 'double precision'
        elif columnType is bool:
                exaType = 'bool'
        return exaType


'''
This function is used to convert all of the json fields to strings inside python
'''
def convertToString(obj):
    if isinstance(obj, bool):
        return unicode(str(obj).lower(), "utf-8")
    if isinstance(obj, int) or isinstance(obj, float) or isinstance(obj, long):
        return unicode(str(obj), "utf-8")
    if isinstance(obj, (list, tuple)):
        return [convertToString(item) for item in obj]
    if isinstance(obj, dict):
        return {convertToString(key):convertToString(value) for key, value in obj.items()}
    return obj

'''
This recursive function is used to completely flatten the json/dict object passed as a parameter (full depth)
The flatten_array parameter is used to specify if the lists/arrays found inside the json object should be flatenned too
This function returns a python dictonnary containing the fields/columns of the json object flattened as keys and their corresponding values
'''
def flatten_json_rec(my_json, flatten_array=True):
        out = {}
    
        def flatten(x, name=''):

                if type(x) is dict:
                        for a in x:
                                flatten(x[a], name + a + '_')
                elif type(x) is list and flatten_array:
                        i = 0
                        for a in x:
                                flatten(a, name + str(i) + '_')
                                i += 1
                else:
                        out[name[:-1]] = x

        flatten(my_json)
        return out
        
'''
This function takes a key and a value from a parent dictionnary as parameter
It returns a dict flatten once if the value passed as a parameter is also a dict
It returns a dict flatten once if the value passed as a parameter is a list and if the flatten_array boolean is true
It returns the pair as a dict given as a parameter if the value is nor a dict nor a list
'''
def flatten_dict(key, value, flatten_array=False):
        res = {}
        if type(value) is dict:
                for subkey in value:
                        new_key = key + "_" + subkey
                        new_value = value[subkey]
                        res[new_key] = new_value
        elif type(value) is list and flatten_array:
                for index, element in enumerate(value):
                        new_key = key + "_" + str(index)
                        new_value = element
                        res[new_key] = new_value
        else:
                res[key] = value
        return res
        
'''
This function will take a json field as a parameter and flatten it for one level of nested dictionnaries if it is a dict
It calls the function flatten_dict on each of the values of the dict given as a parameter and appends the result to a result dict
It returns a dict with the same field as the input dict but flattened once
'''
def flatten_dict_once(my_dict, flatten_array=False):
        res = {}
        if type(my_dict) is dict:
                for key in my_dict:
                        res_tmp = flatten_dict(key, my_dict[key], flatten_array)
                        res.update(res_tmp)
                return res
        else:
                return my_dict
        
'''
This function is the function called on the initial json object
It takes as parameter the json object, the depth and the boolean to specify if we want arrays/lists to be flattened
This function will act two different ways depending on the type of the json object
If the json object is of type dict, this function will flatten it to the depth specified and return a dict (flattened json) where each key (column name) only has one value 
(in this case, the table that will be created using the output of this function will have one row per json file)
If the json object is of type list, this function expect the json to contains subdicts of the same format : it will thus flatten each subdict to the depth specified and return a dict where each key (column name) has a list as value with each subvalues (column)
(in this case, the table that will be created using the output of this function will have multiple row per json file)
This function returns a tuple containing the resulting flattened dict and the type of the input json
'''
def flatten_json(my_json, depth=-1, flatten_array=False):
        '''
        #by uncommenting the following lines, all of the values/fields from the json file will be converted to string
        #this allows the user to import data from multiple json files even if the same columns/keys found within the different files do not have the same datatypes
        my_json=convertToString(my_json)
        '''
        if type(my_json) is dict:
                if depth == -1:
                        return (flatten_json_rec(my_json, flatten_array), "dict")
                elif depth > 0:
                        res = my_json
                        for i in range(1, depth):
                                res = flatten_dict_once(res, flatten_array)
                        return (res, "dict")
                else:
                        return (my_json, "dict")
                        
	#case of a json files that contains multiple dict with the same fieds
	elif type(my_json) is list:
		listDict = []
		for value in my_json:
			tmpDict, _ = flatten_json(value, depth, flatten_array)
			listDict.append(tmpDict)
		res = defaultdict(list)
		for d in listDict: 
			for key, value in d.iteritems():
   				res[key].append(value)
   		return (res, "list")
	else:
		print('input not of type "dict or list"')
                        


/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.JSON_FLATTEN ======================================================================================================


-- BEGIN OF SCRIPT: EXA_TOOLBOX.JSON_FLATTEN_GET_COLUMNS ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE PYTHON SCALAR SCRIPT "JSON_FLATTEN_GET_COLUMNS" ("INPUT" VARCHAR(2000000) UTF8, "flatten_array" BOOLEAN, "flatten_depth" DECIMAL(18,0)) EMITS ("COLUMNNAME" VARCHAR(10000) UTF8, "COLUMNTYPE" VARCHAR(10000) UTF8) AS
import json
FLATTENING = exa.import_script("EXA_TOOLBOX.JSON_FLATTEN")

def run(ctx):
        my_data = json.loads(ctx.INPUT)
        flat, jsonType = FLATTENING.flatten_json(my_data, ctx.flatten_depth, ctx.flatten_array)
        
        if(jsonType=="dict"):                 
                for key in sorted(flat.iterkeys()):
                        columnName = str(key)
                        columnType = FLATTENING.convertType(type(flat[key]))
                        ctx.emit(columnName, columnType)
        elif(jsonType=="list"):
                for key in sorted(flat.iterkeys()):
                        columnName = str(key)
                        columnType = FLATTENING.convertType(type(flat[key][0]))
                        ctx.emit(columnName, columnType)

/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.JSON_FLATTEN_GET_COLUMNS ======================================================================================================


-- BEGIN OF SCRIPT: EXA_TOOLBOX.GET_DATA ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE PYTHON SCALAR SCRIPT "GET_DATA" ("INPUT" VARCHAR(2000000) UTF8, "flatten_array" BOOLEAN, "flatten_depth" DECIMAL(18,0), "columns" VARCHAR(2000000) UTF8) EMITS (...) AS
import json
from collections import OrderedDict
FLATTENING = exa.import_script("EXA_TOOLBOX.JSON_FLATTEN")

def run(ctx):
        my_data = json.loads(ctx.INPUT)
        flat, jsonType = FLATTENING.flatten_json(my_data, ctx.flatten_depth, ctx.flatten_array)
        
        cols = OrderedDict()
        colsStr = ctx.columns.upper()
                        
        if(jsonType=="dict"):
                currentRow = []
                for col in colsStr.split(','):
                        cols[col]=None
                for key in sorted(flat.iterkeys()):
                        if type(flat[key]) is list or type(flat[key]) is dict:
                                str1 = json.dumps(flat[key])
                                cols[key.upper()] = str1
                        else:
                                cols[key.upper()] = flat[key]

                currentRow = cols.values()
                ctx.emit(*currentRow)
                
        elif(jsonType=="list"):
                nbRows = len(flat.values()[0])
                for index in range(0, nbRows):
                        currentRow = []
                        for col in colsStr.split(','):
                                cols[col]=None
                        for key in sorted(flat.iterkeys()):
                                tmpList = flat[key]
                                element = tmpList[index]
                                if type(element) is list or type(element) is dict:
                                        str1 = json.dumps(element)
                                        cols[key.upper()] = str1
                                else:
                                        cols[key.upper()] = element
                        currentRow = cols.values()
                        ctx.emit(*currentRow)


/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.GET_DATA ======================================================================================================


-- BEGIN OF SCRIPT: EXA_TOOLBOX.FLAT_JSON_TABLE ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE LUA SCRIPT "FLAT_JSON_TABLE" (json_table_schema,json_table_name,json_column,result_table_schema,result_table_name,flatten_array,flatten_depth) RETURNS TABLE AS
--get the columns from each json value
suc, cols = pquery([[
                    select distinct COLUMNNAME, COLUMNTYPE from (
                    select EXA_TOOLBOX.JSON_FLATTEN_GET_COLUMNS (]]..json_column..[[, :fl, :fd)
                    from ]]..json_table_schema..[[.]]..json_table_name..[[
                    )
                    order by COLUMNNAME;
                    ]], {fl = flatten_array, fd = flatten_depth})
--check if result table already exists
suc, checkExist = pquery([[describe ]]..result_table_schema..[[.]] .. result_table_name .. [[;]], {})

if suc then -- table already exists
        for j=1, #cols do
                --add column if it doesn't exist
                suc, addCol = pquery([[alter table ]]..result_table_schema..[[.]] .. result_table_name .. [[ add column if not exists (]]..cols[j][1]..[[ ]]..cols[j][2]..[[);]], {})
        end
else --table does not exists, we create it
        local query = "create table " .. result_table_schema .. "." .. result_table_name .. "("
        for j=1, #cols-1 do
                query = query ..'"'.. tostring(cols[j][1]) .. '" ' .. tostring(cols[j][2]) .. ', '
        end
        query = query ..'"'.. tostring(cols[#cols][1]) .. '" ' .. tostring(cols[#cols][2]) .. ');'
        -- execute the 'create table' statement
        
        suc, createTable = pquery([[]]..query..[[]],{})
end

-- get all the column names from the created/altered table
suc, colNames = pquery([[
                        select group_concat(COLUMN_NAME order by COLUMN_ORDINAL_POSITION) from SYS.EXA_ALL_COLUMNS
                        where COLUMN_TABLE = :table
                        and COLUMN_SCHEMA = :schema;
                        ]],{table = result_table_name, schema = result_table_schema})
                        
-- insert the data into the result table
suc, ins = pquery([[
                  insert into ]]..result_table_schema..[[.]]..result_table_name..[[ 
                  select GET_DATA(]]..json_column..[[, :fl, :fd, :cols)
                  from ]]..json_table_schema..[[.]]..json_table_name..[[;
                  ]],{fl = flatten_array, fd = flatten_depth, cols=colNames[1][1]}) 

if not suc then
        error('"'..ins.error_message..'" Caught while inserting the data using the script GET_DATA: "'..ins.statement_text..'"')
end 

suc, res = pquery([[select * from ]]..result_table_schema..[[.]]..result_table_name..[[ limit 100;]],{})

return(res)


/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.FLAT_JSON_TABLE ======================================================================================================


-- BEGIN OF SCRIPT: EXA_TOOLBOX.ISJSON ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE PYTHON SCALAR SCRIPT "ISJSON" ("json" VARCHAR(2000000) UTF8) RETURNS BOOLEAN AS
import json

def run(ctx):
    if ctx[0] == None:
        return None
    try:
        j = json.loads(ctx[0])
    except:
        return False
    return True

/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.ISJSON ======================================================================================================


-- BEGIN OF SCRIPT: EXA_TOOLBOX.JSON_TABLE ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE PYTHON SCALAR SCRIPT "JSON_TABLE" (...) EMITS (...) AS
import json

def run(ctx):
	try:
		obj = json.loads(ctx[0])
	except:
		raise Exception('Invalid JSON: '+ctx[0])

	if exa.meta.input_column_count != exa.meta.output_column_count+1:
		raise Exception('The UDF must be called with a JSON as first input parameter and one more input paramater for every output parameter')

	## find out the levels used in path expressions
	levels = {}
	for p in range(1, exa.meta.input_column_count):
		path = ctx[p]
		starpos = path.rfind('[*]')
		if starpos >= 0:										# $.attr[*].val or $.attr[*]
			if starpos != path.find('[*]'):						# two [*] found?
				raise Exception('Feature not supported: nested arrays')
			level = path[:starpos]								# $.attr
			if level not in levels: levels[level] = []
			levels[level].append(p)
		else:													# $.val
			if "$" not in levels: levels["$"] = []				# $
			levels["$"].append(p)


	## for each level evaluate path expression and generate parts
	## of the output table. The result table is the cross product of its parts.
	tbl = None
	for level, path_refs in levels.iteritems():
		tbl_part = []
		if level == "$": 
			if type(obj) is list:
				current = obj
			else:
				current = [ obj ]
		else:
			attr = level[2:]
			current = visit_path(obj, attr)

		for element in current:							# foreach child of $.attr
			row = {}
			for p in path_refs:
				path = ctx[p]
				if path.startswith(level+'[*]'):
					path = path[len(level)+4:]		# $.attr[*].subattr => subattr
				else:
					path = path[len(level)+1:]		# $.subattr => subattr
				val = visit_path(element, path)
				if val == None:
					val = None
				elif type(val) is list or type(val) is dict: 
					val = json.dumps(val)
				elif exa.meta.output_columns[p-1].type is decimal.Decimal:
					val = decimal.Decimal(val)
				elif exa.meta.output_columns[p-1].type is unicode and type(val) is not unicode:
					val = str(val)
				elif exa.meta.output_columns[p-1].type is datetime.date and type(val) is not datetime.date:
					val = datetime.datetime.strptime(val, '%Y-%m-%d').date()
				elif exa.meta.output_columns[p-1].type is datetime.datetime and type(val) is not datetime.datetime:
					val = datetime.datetime.strptime(val, '%Y-%m-%dT%H:%M:%S.%fZ')
				elif exa.meta.output_columns[p-1].type is float and type(val) is not float:
					val = float(val)
				elif exa.meta.output_columns[p-1].type is bool and type(val) is not bool:
					val = bool(val)
				elif exa.meta.output_columns[p-1].type is int and type(val) is not int:
					val = int(val)
				row[p] = val
			tbl_part.append(row)						

		tbl = cross_product(tbl, tbl_part)

	for row in tbl:
		rowarr = []
		for k,v in row.iteritems():
			rowarr.insert(k,v)
		ctx.emit(*rowarr)

	##for k, v in response.iteritems():
	##	ctx.emit(str(k), str(v))

def cross_product(a, b):
	if a == None: return b
	if b == None: return a
	res = []
	for aa in a:
		for bb in b:
			row = {}
			row.update(aa)
			row.update(bb)
			res.append(row)
	return res

# visit_path traverses a nested dictionary
# input: element["something"]["like"]["this"] = 5, 
#        path = "something.like.this"
# output: 5
def visit_path(element, path):
	val = element
	while path != '':
		dotpos = path.find('.')
		if dotpos < 0:		# no dot
			attr = path
			path = ''
		else:
			attr = path[:dotpos]
			path = path[dotpos+1:]
		if type(val) is not dict or attr not in val:
			return None
		val = val[attr]
	return val

/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.JSON_TABLE ======================================================================================================


-- BEGIN OF SCRIPT: EXA_TOOLBOX.JSON_VALUE ======================================================================================================

OPEN SCHEMA "EXA_TOOLBOX";
--/
CREATE PYTHON3 SCALAR SCRIPT "JSON_VALUE" ("json" VARCHAR(2000000) UTF8, "json_path" VARCHAR(2000000) UTF8) RETURNS VARCHAR(2000000) UTF8 AS
#   Based on jsonpath by Philip Budne
#
#   http://www.ultimate.com/phil/python/#jsonpath
#
#	Copyright (c) 2007 Stefan Goessner (goessner.net)
#   Copyright (c) 2008 Kate Rhodes (masukomi.org)
#   Copyright (c) 2008-2018 Philip Budne (ultimate.com)
#	Licensed under the MIT licence:
#
#	Permission is hereby granted, free of charge, to any person
#	obtaining a copy of this software and associated documentation
#	files (the "Software"), to deal in the Software without
#	restriction, including without limitation the rights to use,
#	copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the
#	Software is furnished to do so, subject to the following
#	conditions:
#
#	The above copyright notice and this permission notice shall be
#	included in all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#	OTHER DEALINGS IN THE SOFTWARE.

import json
import re
import sys


def normalize(x):
    """normalize the path expression; outside jsonpath to allow testing"""
    subx = []

    # replace index/filter expressions with placeholders
    # Python anonymous functions (lambdas) are cryptic, hard to debug
    def f1(m):
        n = len(subx)
        g1 = m.group(1)
        subx.append(g1)
        ret = "[#%d]" % n
        return ret

    x = re.sub(r"[\['](\??\(.*?\))[\]']", f1, x)
    x = re.sub(r"'?(?<!@)\.'?|\['?", ";", x)
    x = re.sub(r";;;|;;", ";..;", x)
    x = re.sub(r";$|'?\]|'$", "", x)

    def f2(m):
        g1 = m.group(1)
        return subx[int(g1)]

    x = re.sub(r"#([0-9]+)", f2, x)

    return x


def jsonpath(obj, expr, result_type='VALUE', use_eval=True):
    def s(x, y):
        return str(x) + ';' + str(y)

    def isint(x):
        return x.isdigit()

    def as_path(path):
        p = '$'
        for piece in path.split(';')[1:]:
            if isint(piece):
                p += "[%s]" % piece
            else:
                p += "['%s']" % piece
        return p

    def store(path, object):
        if result_type == 'VALUE':
            result.append(object)
        elif result_type == 'IPATH':
            result.append(path.split(';')[1:])
        else:  # PATH
            result.append(as_path(path))
        return path

    def trace(expr, obj, path):
        if expr:
            x = expr.split(';')
            loc = x[0]
            x = ';'.join(x[1:])
            if loc == "*":
                def f03(key, loc, expr, obj, path):
                    trace(s(key, expr), obj, path)

                walk(loc, x, obj, path, f03)
            elif loc == "..":
                trace(x, obj, path)

                def f04(key, loc, expr, obj, path):
                    if isinstance(obj, dict):
                        if key in obj:
                            trace(s('..', expr), obj[key], s(path, key))
                    else:
                        if key < len(obj):
                            trace(s('..', expr), obj[key], s(path, key))

                walk(loc, x, obj, path, f04)
            elif loc == "!":
                def f06(key, loc, expr, obj, path):
                    if isinstance(obj, dict):
                        trace(expr, key, path)

                walk(loc, x, obj, path, f06)
            elif isinstance(obj, dict) and loc in obj:
                trace(x, obj[loc], s(path, loc))
            elif isinstance(obj, list) and isint(loc):
                iloc = int(loc)
                if len(obj) > iloc:
                    trace(x, obj[iloc], s(path, loc))
            else:
                if loc.startswith("(") and loc.endswith(")"):
                    e = evalx(loc, obj)
                    trace(s(e, x), obj, path)
                    return

                if loc.startswith("?(") and loc.endswith(")"):
                    def f05(key, loc, expr, obj, path):
                        if isinstance(obj, dict):
                            eval_result = evalx(loc, obj[key])
                        else:
                            eval_result = evalx(loc, obj[int(key)])
                        if eval_result:
                            trace(s(key, expr), obj, path)

                    loc = loc[2:-1]
                    walk(loc, x, obj, path, f05)
                    return

                m = re.match(r'(-?[0-9]*):(-?[0-9]*):?(-?[0-9]*)$', loc)
                if m:
                    if isinstance(obj, (dict, list)):
                        def max(x, y):
                            if x > y:
                                return x
                            return y

                        def min(x, y):
                            if x < y:
                                return x
                            return y

                        objlen = len(obj)
                        s0 = m.group(1)
                        s1 = m.group(2)
                        s2 = m.group(3)

                        start = int(s0) if s0 else 0
                        end = int(s1) if s1 else objlen
                        step = int(s2) if s2 else 1

                        if start < 0:
                            start = max(0, start + objlen)
                        else:
                            start = min(objlen, start)
                        if end < 0:
                            end = max(0, end + objlen)
                        else:
                            end = min(objlen, end)

                        for i in range(start, end, step):
                            trace(s(i, x), obj, path)
                    return

                if loc.find(",") >= 0:
                    for piece in re.split(r"'?,'?", loc):
                        trace(s(piece, x), obj, path)
        else:
            store(path, obj)

    def walk(loc, expr, obj, path, funct):
        if isinstance(obj, list):
            for i in range(0, len(obj)):
                funct(i, loc, expr, obj, path)
        elif isinstance(obj, dict):
            for key in obj:
                funct(key, loc, expr, obj, path)

    def evalx(loc, obj):
        loc = loc.replace("@.length", "len(__obj)")

        loc = loc.replace("&&", " and ").replace("||", " or ")

        def notvar(m):
            return "'%s' not in __obj" % m.group(1)

        loc = re.sub("!@\.([a-zA-Z@_]+)", notvar, loc)

        def varmatch(m):
            def brackets(elts):
                ret = "__obj"
                for e in elts:
                    if isint(e):
                        ret += "[%s]" % e
                    else:
                        ret += "['%s']" % e
                return ret

            g1 = m.group(1)
            elts = g1.split('.')
            if elts[-1] == "length":
                return "len(%s)" % brackets(elts[1:-1])
            return brackets(elts[1:])

        loc = re.sub(r'(?<!\\)(@\.[a-zA-Z@_.]+)', varmatch, loc)

        loc = re.sub(r'(?<!\\)@', "__obj", loc).replace(r'\@', '@')
        if not use_eval:
            raise Exception("eval disabled")
        try:
            v = eval(loc, caller_globals, {'__obj': obj})
        except Exception as e:
            return False

        return v

    # Body of jsonpath()
    caller_globals = sys._getframe(1).f_globals
    result = []
    if expr and obj:
        cleaned_expr = normalize(expr)
        if cleaned_expr.startswith("$;"):
            cleaned_expr = cleaned_expr[2:]

        trace(cleaned_expr, obj, '$')

        if len(result) > 0:
            return result

    return False


def run(ctx):
    try:
        j = json.loads(ctx[0])
    except:
        raise Exception('Invalid JSON: ' + ctx[0])
    p = ctx[1]

    value = jsonpath(j, p)

    if not value:
        return (None)

    if len(value) == 1:
        val = value[0]
        
        if not val:
                return (None)
        
        if type(val) is list or type(val) is dict:
            val = json.dumps(val, ensure_ascii=False)
        else:
            val = str(val)
        return (val)

    return (json.dumps(value))

/
CLOSE SCHEMA;
-- END OF SCRIPT: EXA_TOOLBOX.JSON_VALUE ======================================================================================================


--SCHEMA: DB_HISTORY -------------------------------------------------------------------------------------------

CREATE SCHEMA "DB_HISTORY";

CREATE TABLE "DB_HISTORY"."DATABASE_DDL"(
		"BACKUP_TIME" TIMESTAMP,
		"RN" DECIMAL(5,0),
		"TYPE" VARCHAR(20) UTF8,
		"DDL" VARCHAR(2000000) UTF8 );


-- ALL VIEWS ---------------------------------------------------------------------------------

CLOSE SCHEMA;
	CREATE VIEW "DVB_CORE"."VIEW_RELATIONS" AS SELECT
    CONCAT(REFERENCED_OBJECT_SCHEMA, '.', dep.REFERENCED_OBJECT_NAME) AS table_id,
    dep.REFERENCED_OBJECT_SCHEMA AS table_schema_id,
    dep.REFERENCED_OBJECT_NAME AS table_nq_id,
    CASE
        WHEN dep.REFERENCED_OBJECT_TYPE = 'TABLE' THEN CAST('r' AS CHAR(1))
        WHEN dep.REFERENCED_OBJECT_TYPE = 'VIEW' THEN CAST('v' AS CHAR(1))
    END AS table_type_id,
    CONCAT(dep.OBJECT_SCHEMA, '.', dep.OBJECT_NAME) AS dependent_view_id,
    dep.OBJECT_SCHEMA AS dependent_view_schema_id,
    dep.OBJECT_NAME AS dependent_view_nq_id,
    CAST(LEFT(LOWER(dep.OBJECT_TYPE),
    1) AS CHAR(1)) AS dependent_view_type_id
FROM
    SYS.EXA_DBA_DEPENDENCIES_RECURSIVE dep
WHERE
    dep.REFERENCED_OBJECT_TYPE IN ('TABLE',
    'VIEW')
    AND dep.REFERENCED_OBJECT_SCHEMA IN ('STAGING',
    'DATAVAULT_STAGING',
    'DATAVAULT',
    'BUSINESSOBJECTS',
    'BUSINESS_RULES',
    'ACCESSLAYER',
    'ACCESS_ERRORMART')
    AND dep.OBJECT_TYPE = 'VIEW'
    AND dep.DEPENDENCY_LEVEL = 1;


	CREATE VIEW "DVB_CORE"."LATEST_DATAVAULT_LOAD_INFO" AS 
  SELECT
  dlog.load_entry_time,
  dlog.object_id,
  dlog.staging_table_id,
  dlog.load_start_time,
  dlog.load_end_time,
  CASE
    WHEN LOWER(dlog.load_state) = 'succeeded' OR
      LOWER(dlog.load_state) = 'failed' THEN dvb_core.f_get_time_interval_string(dlog.load_start_time, dlog.load_end_time)
    WHEN LOWER(dlog.load_state) = 'loading' THEN dvb_core.f_get_time_interval_string(dlog.load_start_time, LOCALTIMESTAMP)
    ELSE '0s'
  END AS load_duration,
  dlog.load_state,
  dlog.load_result,
  CASE
    WHEN dlog.load_progress >= 0 THEN dlog.load_progress
    ELSE NULL
  END AS load_progress,
  CASE
    WHEN dlog.load_total_rows >= 0 THEN dlog.load_total_rows
    ELSE NULL
  END AS load_total_rows,
  dlog.login_username,
  dlog.pg_username,
  dlog.job_id,
  dlog.pid
FROM  (SELECT
  dll.load_entry_id,
  dll.load_entry_time,
  dll.object_id,
  dll.staging_table_id,
  dll.load_start_time,
  dll.load_end_time,
  dll.load_state,
  dll.load_result,
  dll.load_progress,
  dll.load_total_rows,
  dll.login_username,
  dll.pg_username,
  dll.pid,
  dll.job_id,
  row_number() OVER(PARTITION BY dll.object_id, dll.staging_table_id ORDER BY dll.load_entry_id DESC) AS load_log_rank
FROM dvb_log.datavault_load_log dll
WHERE dll.load_state IS NOT NULL
) dlog
  WHERE load_log_rank = 1
;


	CREATE VIEW "DVB_CORE"."LATEST_JOB_LOAD_INFO" AS 
SELECT
  jlog.load_entry_time,
  jlog.job_id,
  jlog.load_start_time AS latest_load_start_time,
  jlog.load_end_time AS latest_load_end_time,
  jsuc.load_start_time AS succeeded_load_start_time,
  jsuc.load_end_time AS succeeded_load_end_time,
  jfail.load_start_time AS failed_load_start_time,
  dvb_core.f_get_time_interval_string(jsuc.load_start_time, jsuc.load_end_time) AS succeeded_load_duration,
  CASE
    WHEN LOWER(jlog.load_state) = 'loading' THEN dvb_core.f_get_time_interval_string(jlog.load_start_time, LOCALTIMESTAMP ) 
    ELSE '0s'
  END AS current_loading_duration,
  jlog.load_state,
  jlog.load_result,
  ((COALESCE(jlog.login_username || ' ', '') || '(') || jlog.pg_username) || ')' AS
  username,
  jlog.where_clause_parameters,
  jlog.is_delta_load,
  jlog.pid
FROM (
  SELECT
  jll.load_entry_id,
  jll.load_entry_time,
  jll.job_id,
  jll.load_start_time,
  jll.load_end_time,
  jll.load_state,
  jll.load_result,
  jll.login_username,
  jll.pg_username,
  jll.pid,
  jll.where_clause_parameters,
  jll.is_delta_load,
  ROW_NUMBER() OVER (PARTITION BY jll.job_id ORDER BY jll.load_entry_id DESC) AS load_log_rank
FROM dvb_log.job_load_log jll
WHERE jll.load_state IS NOT NULL

) jlog
LEFT JOIN (
  SELECT
  jll2.job_id,
  jll2.load_start_time,
  jll2.load_end_time,
  ROW_NUMBER() OVER (PARTITION BY jll2.job_id ORDER BY jll2.load_entry_id DESC) AS load_log_rank
FROM dvb_log.job_load_log jll2
WHERE LOWER(jll2.load_state) = 'succeeded') jsuc
  ON jsuc.job_id = jlog.job_id
  AND jsuc.load_log_rank = 1
LEFT JOIN (SELECT
  jll3.job_id,
  jll3.load_start_time,
  jll3.load_end_time,
  ROW_NUMBER() OVER (PARTITION BY jll3.job_id ORDER BY jll3.load_entry_id DESC) AS load_log_rank
FROM dvb_log.job_load_log jll3
WHERE LOWER(jll3.load_state) = 'failed') jfail
  ON jfail.job_id = jlog.job_id
  AND jfail.load_log_rank = 1
WHERE jlog.load_log_rank = 1
;


	CREATE VIEW "DVB_CORE"."LATEST_STAGING_LOAD_INFO" AS 
  SELECT
  slog.load_entry_time,
  slog.staging_table_id,
  slog.source_table_id,
  slog.load_start_time AS latest_load_start_time,
  slog.load_end_time AS latest_load_end_time,
  ssuc.load_start_time AS succeeded_load_start_time,
  ssuc.load_end_time AS succeeded_load_end_time,
  sfail.load_start_time AS failed_load_start_time,
  dvb_core.f_get_time_interval_string(ssuc.LOAD_START_TIME, ssuc.LOAD_END_TIME) AS succeeded_load_duration,
  CASE
    WHEN (LOWER(slog.load_state) = 'loading') THEN dvb_core.f_get_time_interval_string(slog.load_start_time, LOCALTIMESTAMP)
  ELSE NULL
  END AS current_loading_duration,
  slog.load_state,
  slog.load_result,
  slog.load_progress,
  slog.load_total_rows,
  CAST(ROUND(
    CASE 
      WHEN (slog.load_progress_percent_unlimited  < 0 OR slog.load_progress_percent_unlimited > 100) THEN NULL
      ELSE slog.load_progress_percent_unlimited
    END, 0) AS DECIMAL(5,2)) AS load_progress_percent,
  COALESCE(slog.login_username || ' ', '') || '(' || slog.pg_username || ')' AS username,
  slog.from_system_load,
  slog.job_id,
  slog.pid
FROM (
  SELECT sll.load_entry_id,
    sll.load_entry_time,
    sll.staging_table_id,
    sll.source_table_id,
    sll.load_start_time,
    sll.load_end_time,
    sll.load_state,
    sll.load_result,
    sll.load_progress,
    sll.load_total_rows,
    ((100 * sll.load_progress) / ((sll.load_total_rows) + 0.000000001)) AS load_progress_percent_unlimited,
    sll.login_username,
    sll.pg_username,
    sll.from_system_load,
    sll.job_id,
    sll.pid,
    row_number() OVER(PARTITION BY sll.staging_table_id ORDER BY sll.load_entry_id DESC) AS load_log_rank
  FROM dvb_log.staging_load_log sll
  WHERE sll.load_state IS NOT NULL
  ) slog
  LEFT JOIN
    (SELECT sll2.staging_table_id,
      sll2.load_start_time,
      sll2.load_end_time,
      row_number() OVER(PARTITION BY sll2.staging_table_id ORDER BY sll2.load_entry_id DESC) AS load_log_rank
    FROM dvb_log.staging_load_log sll2
    WHERE lower(sll2.load_state) = 'succeeded') ssuc
    ON ssuc.staging_table_id = slog.staging_table_id AND ssuc.load_log_rank = 1
  LEFT JOIN
    (SELECT sll3.staging_table_id,
      sll3.load_start_time,
      sll3.load_end_time,
      row_number() OVER(PARTITION BY sll3.staging_table_id ORDER BY sll3.load_entry_id DESC) AS load_log_rank
    FROM dvb_log.staging_load_log sll3
    WHERE lower(sll3.load_state) = 'failed') sfail
    ON sfail.staging_table_id = slog.staging_table_id AND sfail.load_log_rank = 1
  WHERE slog.load_log_rank = 1;


	CREATE VIEW "DVB_CORE"."LOAD_LOG_DATAVAULT" AS
  SELECT llp.load_entry_id,
    llp.load_entry_time,
    llp.object_id,
    llp.staging_table_id,
    llp.load_start_time,
    llp.load_end_time,
    dvb_core.f_get_time_interval_string(llp.load_start_time, llp.load_end_time) AS duration,
    llp.load_state,
    llp.load_result,
    llp.load_total_rows,
    llp.login_username,
    llp.load_progress,
    llp.pg_username
  FROM ( SELECT lls.load_entry_id,
            lls.load_entry_time,
            lls.object_id,
            lls.staging_table_id,
            lls.load_start_time,
            lls.load_end_time,
            lls.load_state,
            lls.load_result,
            lls.login_username,
            lls.pg_username,
            lls.load_progress,
            lls.load_total_rows,
            row_number() OVER (PARTITION BY lls.object_id, lls.staging_table_id, lls.load_entry_time ORDER BY lls.load_entry_id DESC) AS entry_order
           FROM ( SELECT ll.load_entry_id,
                    ll.load_entry_time,
                    ll.object_id,
                    ll.staging_table_id,
                    ll.load_start_time,
                    ll.load_end_time,
                    ll.load_state,
                    ll.load_result,
                    ll.login_username,
                    ll.pg_username,
                    ll.load_progress,
                    ll.load_total_rows
                   FROM dvb_log.datavault_load_log ll
                  WHERE (ll.load_state IS NOT NULL)
                 ) lls) llp
  WHERE (llp.entry_order = 1);


	CREATE VIEW "DVB_CORE"."LOAD_LOG_JOB" AS
  SELECT llp.load_entry_id,
    llp.load_entry_time,
    llp.job_id,
    llp.load_start_time,
    llp.load_end_time,
    dvb_core.f_get_time_interval_string(llp.load_start_time, llp.load_end_time) AS duration,
    llp.load_state,
    llp.load_result,
    llp.login_username,
    llp.pg_username,
    llp.pid,
    llp.where_clause_parameters,
    llp.is_delta_load
  FROM ( SELECT lls.load_entry_id,
            lls.load_entry_time,
            lls.job_id,
            lls.load_start_time,
            lls.load_end_time,
            lls.load_state,
            lls.load_result,
            lls.login_username,
            lls.pg_username,
            lls.pid,
            lls.where_clause_parameters,
            lls.is_delta_load,
            row_number() OVER (PARTITION BY lls.job_id, lls.load_entry_time ORDER BY lls.load_entry_id DESC) AS entry_order
           FROM ( SELECT ll.load_entry_id,
                    ll.load_entry_time,
                    ll.job_id,
                    ll.load_start_time,
                    ll.load_end_time,
                    ll.load_state,
                    ll.load_result,
                    ll.login_username,
                    ll.pg_username,
                    ll.pid,
                    ll.where_clause_parameters,
                    ll.is_delta_load
                   FROM dvb_log.job_load_log ll
                  WHERE (ll.load_state IS NOT NULL)
                 ) lls) llp
  WHERE (llp.entry_order = 1);


	CREATE VIEW "DVB_CORE"."LOAD_LOG_STAGING" AS
  SELECT llp.load_entry_id,
    llp.load_entry_time,
    llp.source_table_id,
    llp.staging_table_id,
    llp.load_start_time,
    llp.load_end_time,
    dvb_core.f_get_time_interval_string(llp.load_start_time, llp.load_end_time) AS duration,
    llp.load_progress,
    llp.load_total_rows,
    llp.load_state,
    llp.load_result,
    llp.login_username,
    llp.pg_username
  FROM ( SELECT lls.load_entry_id,
            lls.load_entry_time,
            lls.source_table_id,
            lls.staging_table_id,
            lls.load_start_time,
            lls.load_end_time,
            lls.load_progress,
            lls.load_total_rows,
            lls.load_state,
            lls.load_result,
            lls.login_username,
            lls.pg_username,
            row_number() OVER (PARTITION BY lls.staging_table_id, lls.load_entry_time ORDER BY lls.load_entry_id DESC) AS entry_order
           FROM ( SELECT ll.load_entry_id,
                    ll.load_entry_time,
                    ll.source_table_id,
                    ll.staging_table_id,
                    ll.load_start_time,
                    ll.load_end_time,
                    ll.load_progress,
                    ll.load_total_rows,
                    ll.load_state,
                    ll.load_result,
                    ll.login_username,
                    ll.pg_username
                   FROM dvb_log.staging_load_log ll
                  WHERE (ll.load_state IS NOT NULL)
                 ) lls) llp
  WHERE (llp.entry_order = 1);


	CREATE VIEW "DVB_CORE"."SUBJECT_AREAS" AS
SELECT  DISTINCT subject_area_name
FROM (SELECT
 dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'subject_area') AS subject_area_name
from SYS.EXA_ALL_OBJECTS ao
where OBJECT_COMMENT like '{"%subject_area"%'
and ROOT_NAME = 'DATAVAULT'
) t
WHERE subject_area_name IS NOT NULL
;


	CREATE VIEW "DVB_CORE"."SYSTEM_CONNECTIONS" AS 
  SELECT sd.system_id,
    sd.system_name,
    sc.system_color,
    sd.system_comment,
    sd.source_type_id,
    sd.source_type_url,
    sd.source_type_parameters
   FROM dvb_config.system_data sd
     LEFT JOIN dvb_config.system_colors sc ON (sd.system_id = sc.system_id);


	CREATE VIEW "DVB_CORE"."TABLES_SIMPLE" AS SELECT
    ao.ROOT_NAME || '.' || ao.OBJECT_NAME AS TABLE_ID,
    ao.ROOT_NAME AS SCHEMA_ID,
    ao.OBJECT_NAME AS TABLE_NQ_ID,
    CASE
        ao.OBJECT_TYPE
        WHEN 'TABLE' THEN 'r'
        WHEN 'VIEW' THEN 'v'
        ELSE NULL
    END AS TYPE_ID,
    CASE
        ao.OBJECT_TYPE
        WHEN 'TABLE' THEN 'Base Table'
        WHEN 'VIEW' THEN 'View'
        ELSE NULL
    END AS TYPE_NAME,
    CASE 
    	WHEN ao.OBJECT_NAME LIKE '%\_P' THEN 'DVB_PROTOTYPE'
    	WHEN ao.OBJECT_NAME LIKE 'T\_%' THEN NULL
    	ELSE
    COALESCE(dvb_core.f_string_between(ao.OBJECT_NAME,
    '_S_',
    '_R_'),
    dvb_core.f_string_between(ao.OBJECT_NAME,
    '_S_',
    '_C_'),
    dvb_core.f_string_between(ao.OBJECT_NAME,
    '_S_',
    ''),
    dvb_core.f_string_between(ao.OBJECT_NAME,
    '',
    '_R_')) END AS SYSTEM_ID,
    OBJECT_COMMENT AS TABLE_COMMENT
FROM
    SYS.EXA_ALL_OBJECTS ao
WHERE
    ao.ROOT_NAME IN ('STAGING',
    'DATAVAULT_STAGING',
    'DATAVAULT',
    'BUSINESSOBJECTS',
    'BUSINESS_RULES',
    'ACCESSLAYER',
    'ACCESS_ERRORMART')
    AND ao.OBJECT_TYPE IN ('TABLE',
    'VIEW',
    'MATERIALIZED VIEW')
    AND ao.OBJECT_NAME NOT LIKE '\_DVB\_%' ESCAPE '\';



OPEN SCHEMA "STAGING";
	CREATE VIEW "DVB_LOG"."DDL_LOG_COMBINED" AS 
SELECT
    ROW_NUMBER() OVER (ORDER BY LOG_TIMESTAMP) AS LOG_ENTRY_ID,
    LOG_TIMESTAMP,
    "SOURCE",
    TYPE,
    OBJECT_ID,
    LOGIN_USERNAME,
    PG_USERNAME
FROM
  (
    SELECT 
        LOG_TIMESTAMP,
        "SOURCE",
        TYPE,
        OBJECT_ID,
        LOGIN_USERNAME,
        PG_USERNAME
    FROM
        DVB_LOG.DDL_LOG
    UNION ALL
    SELECT
        LOG_TIMESTAMP,
        'event_trigger' AS "SOURCE",
        FUNCTION_NAME AS TYPE,
        COALESCE(OBJECT_ID, STAGING_TABLE_ID) AS OBJECT_ID,
        LOGIN_USERNAME,
        PG_USERNAME
    FROM DVB_LOG.DVBUILDER_CREATION_LOG
  )
;


CLOSE SCHEMA;
	CREATE VIEW "DVB_CORE"."COLUMNS" AS SELECT
    col.schema_id,
    col.table_nq_id,
    col.column_nq_id,
    col.column_id,
    col.column_name,
    col.column_comment,
    col.column_conversion_type,
    col.data_type,
    col.data_type_id,
    col.character_maximum_length,
    col.numeric_precision,
    col.numeric_scale,
    col.datetime_precision,
    col.ordinal_position,
    col.complete_data_type,
    col.description
FROM
    (
        SELECT DISTINCT
        --filter duplicates from materialized views and tables
 atc.COLUMN_SCHEMA AS schema_id,
        atc.COLUMN_TABLE AS table_nq_id,
        atc.COLUMN_NAME AS column_nq_id,
        atc.COLUMN_SCHEMA || '.' || atc.COLUMN_TABLE || '.' || atc.COLUMN_NAME AS column_id,
        dvb_core.f_get_value_from_json(atc.COLUMN_COMMENT,
        'name') AS column_name,
        dvb_core.f_get_value_from_json(atc.COLUMN_COMMENT,
        'comment') AS column_comment,
        dvb_core.f_get_value_from_json(atc.COLUMN_COMMENT,
        'conversion_type') AS column_conversion_type,
        CASE
            WHEN atc.COLUMN_TYPE = 'DOUBLE' THEN 'DOUBLE PRECISION'
            ELSE REGEXP_REPLACE(atc.COLUMN_TYPE, '\(\d+\)|\(\d+,\d+\)', '')
        END AS data_type,
        COLUMN_TYPE_ID AS data_type_id,
        atc.COLUMN_MAXSIZE AS character_maximum_length,
        atc.COLUMN_NUM_PREC AS numeric_precision,
        atc.COLUMN_NUM_SCALE AS numeric_scale,
        CASE
            WHEN atc.COLUMN_TYPE LIKE '%TIMESTAMP%' THEN atc.COLUMN_NUM_SCALE
            ELSE NULL
        END AS datetime_precision,
        atc.COLUMN_ORDINAL_POSITION AS ordinal_position,
        CASE
            WHEN atc.COLUMN_TYPE = 'DOUBLE' THEN 'DOUBLE PRECISION'
            ELSE atc.COLUMN_TYPE
        END ||
        CASE
            WHEN atc.COLUMN_TYPE = 'NUMBER'
            AND atc.COLUMN_NUM_PREC IS NOT NULL THEN '(' || atc.COLUMN_NUM_PREC || ',' || atc.COLUMN_NUM_SCALE || ')'
            ELSE NULL
        END AS complete_data_type,
        atc.COLUMN_COMMENT AS DESCRIPTION
    FROM
        SYS.EXA_ALL_COLUMNS atc
    JOIN SYS.EXA_ALL_OBJECTS ao ON
        (ao.ROOT_NAME = atc.COLUMN_SCHEMA
        AND ao.OBJECT_NAME = atc.COLUMN_TABLE)
    WHERE
        atc.COLUMN_SCHEMA IN ('STAGING',
        'DATAVAULT_STAGING',
        'DATAVAULT',
        'BUSINESSOBJECTS',
        'BUSINESS_RULES',
        'ACCESSLAYER',
        'ACCESS_ERRORMART')
        AND ao.OBJECT_TYPE IN ('TABLE',
        'VIEW' /*,'MATERIALIZED VIEW' --no such thing in exasol*/
        ) ) col;


	CREATE VIEW "DVB_CORE"."SYSTEMS" AS 
  SELECT sd.system_id,
         sd.system_name,
         sd.system_comment,
         sc.system_color
  FROM dvb_config.system_data sd
       LEFT JOIN dvb_config.system_colors sc ON sd.system_id = sc.system_id
  WHERE lower(sd.system_id) NOT LIKE '\_dvb\_%' ESCAPE '\'
  UNION ALL
  SELECT
    'DVB_HUB' AS system_id,
    'Hub' AS system_name,
    'Dummy System for Business Objects on Hubs' AS system_comment,
	'#ffa500' AS system_color
  UNION ALL
  SELECT 'DVB_PROTOTYPE' AS system_id,
	'Prototype' AS system_name,
	'Dummy System for Business Objects on Prototypes' AS system_comment,
	'#cccccc' AS system_color;


	CREATE VIEW "DVB_CORE"."VIEWS" AS 
WITH view_sub_sub_query AS (
SELECT
    VIEW_SCHEMA,
    VIEW_NAME,
    VIEW_COMMENT,
    VIEW_TEXT,
    REGEXP_REPLACE(VIEW_TEXT, '(*CRLF)COMMENT IS.*(?![^\(]*\))|;') AS VIEW_CODE_WO_COMMENT_IS
    -- remove view comment part

    FROM SYS.EXA_ALL_VIEWS av
WHERE
    av.VIEW_SCHEMA IN ('STAGING',
    'DATAVAULT_STAGING',
    'DATAVAULT',
    'BUSINESSOBJECTS',
    'BUSINESS_RULES',
    'ACCESSLAYER',
    'ACCESS_ERRORMART')),
view_sub_query AS (
SELECT
    VIEW_SCHEMA,
    VIEW_NAME,
    VIEW_COMMENT,
    VIEW_TEXT,
    RTRIM( REGEXP_REPLACE(VIEW_CODE_WO_COMMENT_IS, '(?x)(?s)(?U)\R/\*[\{\[].*[\}\]]\*/\s*$', ''), '; ' || CHR(9) || CHR(10) || CHR(13)) AS VIEW_CODE_PART,
    NULLIF( REGEXP_REPLACE(VIEW_CODE_WO_COMMENT_IS, '(?x)(?s)(?U)^.*\R/\*\s*([\{\[].*[\}\]])\s*\*/\s*$', '\1'),
    VIEW_CODE_WO_COMMENT_IS ) AS VIEW_INLINE_JSON
FROM
    view_sub_sub_query )
SELECT
    CONCAT(v.VIEW_SCHEMA, '.', v.VIEW_NAME) AS view_id,
    v.VIEW_NAME AS view_nq_id,
    v.VIEW_SCHEMA AS schema_id,
    dvb_core.f_get_schema_name(v.VIEW_SCHEMA) AS schema_name,
    FALSE AS view_is_materialized,
    --no materizlized views in exasol
    LTRIM(REGEXP_REPLACE(v.VIEW_CODE_PART, '(*CRLF)(?s).*?' || v.VIEW_NAME || '.*?(?<!\()AS(?!\))', '', 1, 1), ' ' || CHR(9) || CHR(10) || CHR(13)) AS view_code,
    -- takes out only the select code of the view definition by removing the create statement
 dvb_core.f_get_value_from_json(v.VIEW_COMMENT,
    'name') AS metadata_name,
    dvb_core.f_get_value_from_json(v.VIEW_COMMENT,
    'comment') AS metadata_comment,
    CASE WHEN (v.VIEW_SCHEMA != 'DVB_CORE') THEN VIEW_INLINE_JSON
    ELSE NULL
END AS metadata_businessobject_structure,
dvb_core.f_get_value_from_json(v.VIEW_COMMENT,
'quick_inserts') AS metadata_quick_inserts,
LTRIM(v.view_code_part, ' ' || CHR(9) || CHR(10) || CHR(13)) AS metadata_code,
CAST(dvb_core.f_get_value_from_json(v.VIEW_COMMENT,
'is_error_ruleset') AS BOOLEAN) AS metadata_is_error_ruleset,
CAST(dvb_core.f_get_value_from_json(v.VIEW_COMMENT,
'include_in_accesslayer') AS BOOLEAN) AS metadata_include_in_accesslayer,
CAST(dvb_core.f_get_value_from_json(v.VIEW_COMMENT,
'accesslayer_priorization') AS NUMBER) AS metadata_accesslayer_priorization
FROM
view_sub_query AS v;


	CREATE VIEW "DVB_CORE"."Y_BLOCKING_PROCS" AS SELECT
    b.CONFLICT_SESSION_ID AS blocking_pid,
    b.CONFLICT_TYPE AS blocking_reason,
    ss.USER_NAME AS blocking_user,
    ss.SQL_TEXT AS blocking_query,
    b.STOP_TIME - b.START_TIME AS blocking_duration,
    b.SESSION_ID AS blocked_pid,
    sb.USER_NAME AS blocked_user,
    sb.SQL_TEXT AS blocked_query
FROM
    EXA_DBA_TRANSACTION_CONFLICTS b
JOIN SYS.EXA_DBA_SESSIONS ss ON
    b.CONFLICT_SESSION_ID = ss.SESSION_ID
JOIN SYS.EXA_DBA_SESSIONS sb ON
    b.SESSION_ID = sb.SESSION_ID
    -- ******************************* exasol_dev_dummy_objects.sql
UNION ALL SELECT
    w.session_id AS blocking_pid,
    CASE
        WHEN w.session_id IS NOT NULL THEN 'Waiting'
        ELSE NULL
    END AS blocking_reason,
    w.USER_NAME AS blocking_user,
    w.SQL_TEXT AS blocking_query,
    NUMTODSINTERVAL(SUM(r.duration), 'SECOND') AS blocking_duration,
    r.SESSION_ID AS blocked_pid,
    s.USER_NAME AS blocked_user,
    s.SQL_TEXT AS blocked_query
FROM
    EXA_dba_profile_RUNNING r
LEFT JOIN EXA_DBA_SESSIONS s ON
    r.session_id = s.session_id
LEFT JOIN EXA_DBA_SESSIONS w ON
    'Waiting for session ' || w.session_id = s.activity
GROUP BY
    w.session_id,
    w.USER_NAME,
    w.SQL_TEXT,
    r.SESSION_ID,
    s.USER_NAME,
    s.SQL_TEXT ;


	CREATE VIEW "DVB_CORE"."HUBS" AS 
  SELECT DISTINCT 
    o.OBJECT_NAME AS hub_id,
    COALESCE(convert(varchar(2000),dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'name')), '') AS hub_name,
    dvb_core.f_string_between(o.OBJECT_NAME, 'H_', '') AS boid,
    vr.table_nq_id AS hub_id_of_alias_parent,
    COALESCE(convert(varchar(2000),dvb_core.f_get_value_from_json(ovr.OBJECT_COMMENT,'name')), '') AS hub_name_of_alias_parent,
    COALESCE(convert(varchar(2000),dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'subject_area')), '') AS hub_subject_area_name,
    COALESCE(convert(varchar(2000),dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'comment')), '') AS hub_comment,
    CASE WHEN v.VIEW_NAME IS NULL THEN CAST(1 as BOOLEAN) ELSE CAST(0 as BOOLEAN) END AS hub_is_prototype
  FROM SYS.EXA_ALL_OBJECTS o
    LEFT JOIN dvb_core.view_relations vr ON vr.dependent_view_nq_id =  o.OBJECT_NAME
    LEFT JOIN SYS.EXA_ALL_OBJECTS ovr ON vr.TABLE_ID = (ovr.ROOT_NAME || '.' || ovr.OBJECT_NAME)
    LEFT JOIN sys.EXA_ALL_VIEWS v ON dvb_core.f_string_between(v.VIEW_NAME, '', '_S_') = o.OBJECT_NAME
  WHERE o.ROOT_NAME = 'DATAVAULT' AND o.OBJECT_NAME LIKE 'H\_%' ESCAPE '\' ;


	CREATE VIEW "DVB_CORE"."X_HUBS_DISTINCT" AS
  SELECT DISTINCT hubs.hub_id, 
	hubs.boid,
	hubs.hub_name,
	hubs.hub_name_of_alias_parent,
	hubs.hub_subject_area_name AS subject_area,  
	hubs.hub_comment AS "COMMENT" 
  FROM dvb_core.hubs;


	CREATE VIEW "DVB_CORE"."X_LATEST_LOAD_INFO"(
    entry_time,
    source_id,
    target_id,
    start_time,
    end_time,
    duration,
    "STATE",
    "RESULT",
    progress,
    total_rows,
    username,
    job_id,
    pid)
AS
  SELECT combined.entry_time,
         combined.source_id,
         combined.target_id,
         combined.start_time,
         combined.end_time,
         combined.duration,
         combined."STATE",
         combined."RESULT",
         combined.progress,
         combined.total_rows,
         combined.username,
         combined.job_id,
         combined.pid
  FROM (
         SELECT lsli.load_entry_time AS entry_time,
                dvb_core.f_string_between(lsli.staging_table_id, '.', '_R_') AS source_id,
                lsli.staging_table_id AS target_id,
                lsli.latest_load_start_time AS start_time,
                lsli.latest_load_end_time AS end_time,
                COALESCE(lsli.current_loading_duration, lsli.succeeded_load_duration) AS duration,
                lsli.load_state AS "STATE",
                lsli.load_result AS "RESULT",
                lsli.load_progress AS progress,
                lsli.load_total_rows AS total_rows,
                lsli.username,
                lsli.job_id,
                lsli.pid
         FROM dvb_core.latest_staging_load_info lsli
         UNION ALL
         SELECT ldli.load_entry_time AS entry_time,
                ldli.staging_table_id AS source_id,
                'DATAVAULT.' || ldli.object_id AS target_id,
                ldli.load_start_time AS start_time,
                ldli.load_end_time AS end_time,
                ldli.load_duration AS duration,
                ldli.load_state AS "STATE",
                ldli.load_result AS "RESULT",
                ldli.load_progress AS progress,
                ldli.load_total_rows AS total_rows,
                ldli.login_username AS username,
                ldli.job_id,
                ldli.pid
         FROM dvb_core.latest_datavault_load_info ldli
       ) combined
  ORDER BY combined.entry_time;


	CREATE VIEW "DVB_CORE"."TRACKING_SATELLITES" AS
SELECT
    td.table_nq_id,
    td.tracking_satellite_id,
    td.tracking_satellite_name,
    td.tracked_object_id,
    dvb_core.f_get_value_from_json(so.OBJECT_COMMENT,
    'name') AS tracked_object_name,
    td.is_tracking_a_link,
    td.is_tracking_a_satellite,
    td.is_delta_load_satellite,
    td.is_full_load_satellite,
    rtl.last_full_load_time,
    td.system_id,
    s.system_name,
    s.system_color,
    s.system_comment,
    td.staging_table_id,
    td.tracking_satellite_subject_area_name,
    td.tracking_satellite_comment
FROM
    (
    SELECT
        o.OBJECT_NAME AS table_nq_id,
        LEFT(o.OBJECT_NAME,
        LEN(o.OBJECT_NAME)- 2) AS tracking_satellite_id,
        dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,
        'name') AS tracking_satellite_name,
        CASE WHEN LEFT(o.OBJECT_NAME,
        2) = 'S_' THEN 'H_' || dvb_core.f_string_between(o.OBJECT_NAME,
        'S_',
        '_S_')
        -- !
        ELSE 'L_' || dvb_core.f_string_between(o.OBJECT_NAME,
        'LS_',
        '_S_')
        -- !
END AS tracked_object_id,
    o.OBJECT_NAME LIKE 'LS\_%' ESCAPE '\' is_tracking_a_link,
    o.OBJECT_NAME LIKE 'S\_%' ESCAPE '\' AS is_tracking_a_satellite,
    o.OBJECT_NAME LIKE '%\_W\_TRKD\_H' ESCAPE '\' AS is_delta_load_satellite,
    o.OBJECT_NAME LIKE '%\_W\_TRKF\_H' ESCAPE '\' AS is_full_load_satellite,
    NULLIF( dvb_core.f_string_between(o.OBJECT_NAME,
    '_S_',
    '_R_'),
    '' ) AS system_id,
    'STAGING.' || dvb_core.f_string_between(o.OBJECT_NAME,
    '_S_',
    '_W_') AS staging_table_id,
    dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,
    'subject_area') AS tracking_satellite_subject_area_name,
    dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,
    'comment') AS tracking_satellite_comment
FROM
    SYS.EXA_ALL_OBJECTS o
WHERE
    o.ROOT_NAME = 'DATAVAULT'
    AND( o.OBJECT_NAME LIKE 'S\_%\_W\_TRKF\_H' ESCAPE '\'
    OR o.OBJECT_NAME LIKE 'S\_%\_W\_TRKD\_H' ESCAPE '\'
    OR o.OBJECT_NAME LIKE 'LS\_%\_W\_TRKF\_H' ESCAPE '\'
    OR o.OBJECT_NAME LIKE 'LS\_%\_W\_TRKD\_H' ESCAPE '\' )
) td
LEFT JOIN dvb_core.systems s ON
    (s.system_id = td.system_id)
LEFT JOIN SYS.EXA_ALL_OBJECTS so ON
    (so.OBJECT_NAME = td.tracked_object_id)
    --LEFT JOIN sys.schemas sn ON (so.schema_id = sn.schema_id)
LEFT JOIN DATAVAULT."_DVB_RUNTIME_LOAD_DATA" rtl ON
    (rtl.object_id = 'DATAVAULT.' || td.tracking_satellite_id);


	CREATE VIEW "DVB_CORE"."BUSINESSOBJECTS" AS
WITH
	view_sub_sub_query AS
(
	SELECT
		VIEW_SCHEMA,
		VIEW_NAME,
		VIEW_COMMENT,
		VIEW_TEXT,
		COALESCE(dvb_core.f_string_between_ci(VIEW_TEXT, '', 'COMMENT IS '''), VIEW_TEXT) AS VIEW_CODE_WO_COMMENT_IS
	FROM SYS.EXA_ALL_VIEWS
	WHERE VIEW_SCHEMA = 'BUSINESSOBJECTS'
),
view_sub_query AS 
(
	SELECT
		VIEW_SCHEMA,
		VIEW_NAME,
		VIEW_COMMENT,
		VIEW_TEXT,
		RTRIM(
			REGEXP_REPLACE(VIEW_CODE_WO_COMMENT_IS, '(?x)(?s)(?U)\R/\*[\{\[].*[\}\]]\*/\s*$', ''),
			'; ' || CHR(9) || CHR(10) || CHR(13)) || '
;' AS VIEW_CODE_PART,
    NULLIF(
      REGEXP_REPLACE(VIEW_CODE_WO_COMMENT_IS, '(?x)(?s)(?U)^.*\R/\*\s*([\{\[].*[\}\]])\s*\*/\s*$', '\1'), 
      VIEW_CODE_WO_COMMENT_IS
    ) AS VIEW_INLINE_JSON
	FROM view_sub_sub_query
)
SELECT
  b.businessobject_view_id,
  b.functional_suffix_id,
  b.functional_suffix_name,
  b.system_id,
  b.system_name,
  b.system_color,
  b.system_comment,
  b.businessobject_comment,
  b.start_hub_id,
  b.start_hub_name,
  b.start_hub_name || ' > ' || b.system_name || ' > ' || COALESCE(
    NULLIF(b.functional_suffix_name, ''),
    'Default'
  ) AS businessobject_name,
  b.businessobject_structure
FROM (
	SELECT bo.businessobject_view_id,
		bo.functional_suffix_id,
		bo.functional_suffix_name,
		COALESCE(s.system_id, bo.system_id) AS system_id,
		s.system_name,
		s.system_color,
		s.system_comment,
		bo.businessobject_comment,
		bo.start_hub_id,
		dvb_core.f_get_value_from_json(ext.OBJECT_COMMENT,'name')  AS start_hub_name,
		bo.businessobject_structure
	FROM
		(SELECT v.view_name,
			v.view_schema || '.' || v.view_name AS businessobject_view_id,
			COALESCE(dvb_core.f_string_between(v.view_name, '_C_', ''),
		    '') AS functional_suffix_id,
			dvb_core.f_get_value_from_json(v.VIEW_COMMENT,'name') AS functional_suffix_name,
			COALESCE(dvb_core.f_string_between(v.view_name, '_S_', '_C_'),
				dvb_core.f_string_between(v.view_name, '_S_', ''))	AS system_id,
			dvb_core.f_get_value_from_json(v.VIEW_COMMENT,'comment') AS businessobject_comment,
		  'H_' || dvb_core.f_string_between(v.view_name, '', '_S_') AS start_hub_id,
			VIEW_INLINE_JSON AS businessobject_structure
		FROM view_sub_query v) bo
	LEFT JOIN dvb_core.systems s
		ON (s.system_id = bo.system_id)
	LEFT JOIN SYS.EXA_ALL_OBJECTS ext 
		ON (ext.ROOT_NAME || '.'  || ext.OBJECT_NAME) = ('DATAVAULT.H_' || dvb_core.f_string_between(bo.view_name, '', '_S_'))  
) b;


	CREATE VIEW "DVB_CORE"."STAGING_TABLES" AS 
SELECT
	st.staging_table_id,
  st.staging_table_name,
  st.staging_table_display_string,
  st.staging_table_comment,
  st.staging_table_type_name,
  st.staging_table_type_id,
  st.schema_id,
  st.schema_name,
  st.system_id,
  s.system_name,
  s.system_color,
  s.system_comment,
  st.source_table_id,
  st.source_name,
  st.source_table_type_id,
  st.source_object_id,
  st.source_schema_id,
  st.batch_size,
  st.where_clause_general_part,
  st.where_clause_delta_part_template,
  st.is_delta_load,
  st.is_up_to_date,
  st.applied_where_clause_general_part,
  st.applied_where_clause_delta_part,
  st.applied_where_clause_delta_part_template,
  st.data_extract_start_time
FROM (
	SELECT
	    concat(ao.ROOT_NAME ,'.' , ao.OBJECT_NAME) AS staging_table_id,
	    dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'name') AS staging_table_name,
	    CASE
	      WHEN dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'name') IS NOT NULL THEN
	        dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'name')
	      ELSE
	        upper(replace (dvb_core.f_string_between(ao.OBJECT_NAME, '_R_', ''), '_', ' '))
	    END || COALESCE(NULLIF(' (' || dvb_core.f_string_between(ao.OBJECT_NAME, '_U_', '') || ')', ' ()'), '') 
	    	|| ' [' || ao.OBJECT_NAME || ']' AS staging_table_display_string,
	    dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'comment') AS staging_table_comment,
	    CASE ao.OBJECT_TYPE
	      WHEN 'TABLE' THEN 'Table'
	      WHEN 'VIEW' THEN 'View'
	      ELSE NULL
	    END AS staging_table_type_name,
	    CASE ao.OBJECT_TYPE
	      WHEN 'TABLE' THEN 'r'
	      WHEN 'VIEW' THEN 'v'
	      ELSE NULL
	    END AS staging_table_type_id,
	    ao.ROOT_NAME AS schema_id,
	    dvb_core.f_get_schema_name(ao.ROOT_NAME) AS schema_name,
	    dvb_core.f_string_between(ao.OBJECT_NAME, '', '_R_') AS system_id,
	    dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'source_table_id') AS source_table_id,
	    dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'name') AS source_name,
	    dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'source_table_type') AS source_table_type_id,
	    COALESCE(dvb_core.f_string_between(ao.OBJECT_NAME, '_R_', '_U_'), dvb_core.f_string_between(ao.OBJECT_NAME, '_R_', ''), '') AS source_object_id,
	    COALESCE(dvb_core.f_string_between(ao.OBJECT_NAME, '_U_', ''), '') AS source_schema_id,
	    COALESCE(TO_NUMBER(dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'batch_size')),-1) AS batch_size,
	    dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'where_clause_general_part') AS where_clause_general_part,
      dvb_core.f_get_value_from_json(ao.OBJECT_COMMENT,'where_clause_delta_part_template') AS where_clause_delta_part_template,
	    COALESCE(rts.is_delta_load, FALSE) AS is_delta_load,
	    COALESCE(rts.is_up_to_date, FALSE) AS is_up_to_date,
		rts.applied_where_clause_general_part,
		rts.applied_where_clause_delta_part,
		rts.applied_where_clause_delta_part_template,
		rts.data_extract_start_time
	  FROM SYS.EXA_ALL_OBJECTS ao
	  LEFT JOIN staging."_DVB_RUNTIME_TABLE_STATUS" rts ON rts.STAGING_TABLE_ID = (CONCAT( ao.ROOT_NAME , '.' ,ao.OBJECT_NAME))
	  WHERE ao.ROOT_NAME = 'STAGING' 
	    AND (ao.OBJECT_TYPE IN ('TABLE', 'VIEW' /*,'MATERIALIZED VIEW' --no such thing in exasol*/)) 
	    AND  ao.OBJECT_NAME NOT LIKE '\_DVB\_%' ESCAPE '\' 
	    AND  ao.OBJECT_NAME NOT LIKE 'T\_%' ESCAPE '\'
  ) st
  LEFT JOIN dvb_core.systems s ON s.SYSTEM_ID = st.system_id
	WHERE st.system_id IS NOT NULL;


	CREATE VIEW "DVB_CORE"."TRANSACTION_LINKS" AS 
    SELECT
        td.table_nq_id,
        td.transaction_link_id,
        td.boid,
        td.system_id,
        s.system_name,
        s.system_color,
        s.system_comment,
        td.functional_suffix_id,
        MAX( td.functional_suffix_name ) AS functional_suffix_name,
        MAX( td.transaction_link_subject_area_name ) AS transaction_link_subject_area_name,
        MAX( td.transaction_link_comment ) AS transaction_link_comment,
        'transaction_link' AS transaction_link_type,
        vr.table_id AS staging_table_id,
        COALESCE(dvb_core.f_string_between(td.transaction_link_id, '_R_', '_F_'), dvb_core.f_string_between(td.transaction_link_id, '_R_', '')) AS staging_resource_id,
        'H_' || td.boid AS parent_hub_id,
        dvb_core.f_get_value_from_json(so.OBJECT_COMMENT,'name') AS parent_hub_name,
        dvb_core.f_get_value_from_json(so.OBJECT_COMMENT,'name') || COALESCE(' > ' || NULLIF(s.system_name, ''), '') || ' > ' || COALESCE(NULLIF(MAX(td.functional_suffix_name), ''), 'Default') AS transaction_link_name,
        td.datavault_category_id
    FROM
        (
            SELECT
                o.OBJECT_NAME AS table_nq_id,
                LEFT(
                    o.OBJECT_NAME,
                    LEN(o.OBJECT_NAME)- 2
                ) AS transaction_link_id,
                dvb_core.f_string_between(
                    o.OBJECT_NAME,
                    'LT_',
                    '_S_'
                ) AS boid,
                NULLIF(
                    dvb_core.f_string_between(
                        o.OBJECT_NAME,
                        '_S_',
                        '_R_'
                    ),
                    ''
                ) AS system_id,
                COALESCE(
                    dvb_core.f_string_between(
                        LEFT(
                            o.OBJECT_NAME,
                            LEN(o.OBJECT_NAME)- 2
                        ),
                        '_F_',
                        ''
                    ),
                    ''
                ) AS functional_suffix_id,
                COALESCE(dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'datavault_category'), 'raw_vault') AS datavault_category_id,
                dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'name') AS functional_suffix_name,
                dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'subject_area')  AS transaction_link_subject_area_name,
                dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'comment') AS transaction_link_comment

            FROM
                SYS.EXA_ALL_OBJECTS o
                
            WHERE
                o.ROOT_NAME = 'DATAVAULT'
                AND(
                    o.OBJECT_NAME LIKE 'LT\_%H' ESCAPE '\'
                    OR o.OBJECT_NAME LIKE 'LT\_%O' ESCAPE '\'
                    OR o.OBJECT_NAME LIKE 'LT\_%C' ESCAPE '\'
                )
                OR o.OBJECT_NAME LIKE 'LT\_%\_P' ESCAPE '\'
        ) td
    LEFT JOIN dvb_core.systems s ON
        s.system_id = td.system_id
    LEFT JOIN dvb_core.view_relations vr ON
        td.transaction_link_id = vr.dependent_view_nq_id
        AND vr.dependent_view_schema_id = 'DATAVAULT_STAGING'
    LEFT JOIN SYS.EXA_ALL_OBJECTS so ON
        so.OBJECT_NAME = 'H_' || td.boid --LEFT JOIN sys.schemas sn
 --  ON so.schema_id = sn.schema_id
 --LEFT JOIN ep
 --  ON so.object_id = ep.major_id
    WHERE
        td.table_nq_id LIKE 'LT\_%\_H' ESCAPE '\'
    GROUP BY
        td.table_nq_id,
        td.transaction_link_id,
        td.boid,
        td.system_id,
        s.system_name,
        s.system_color,
        s.system_comment,
        td.functional_suffix_id,
        vr.table_id, 
		dvb_core.f_get_value_from_json(so.OBJECT_COMMENT,'name'),
 		td.datavault_category_id
;


	CREATE VIEW "DVB_CORE"."JOBS" as 
SELECT
  jd.job_id,
  dvb_core.f_string_between(jd.job_id, '', '_J_') AS system_id,
  s.system_name,
  s.system_color,
  s.system_comment,
  jd.job_name,
  dvb_core.f_string_between(jd.job_id, '_J_', '') AS job_suffix_id,
  jd.job_type,
  jd.parallel_loads,
  COALESCE(jd.job_comment, '') AS job_comment,
  jd.job_enabled,
  MIN(js.schedule_next_run) AS next_run,
  COALESCE(jli.latest_load_start_time, MAX(js.schedule_last_run)) AS last_run,
  COALESCE(jli.succeeded_load_duration, jli.current_loading_duration/*, jlog.jlgduration*/) AS last_run_duration
FROM dvb_config.job_data jd 
LEFT JOIN dvb_config.job_schedules js
  ON ((jd.job_id = js.job_id))
/*LEFT JOIN ( SELECT jl.jlgduration,
       jl.jlgjobid,
       jl.jobname,
       row_number() OVER (PARTITION BY jl.jobname ORDER BY jl.jlgid DESC) AS rownnr
      FROM ( SELECT l.jlgid,
               l.jlgjobid,
               l.jlgduration,
               j_1.jobname
              FROM pgagent.pga_joblog l
                JOIN pgagent.pga_job j_1 ON l.jlgjobid = j_1.jobid) jl) jlog
                ON j.jobname = jlog.jobname */
LEFT JOIN dvb_core.systems s 
  ON dvb_core.f_string_between(jd.job_id, '', '_J_') = s.system_id
LEFT JOIN dvb_core.latest_job_load_info jli
  ON jd.job_id = jli.job_id
/*  WHERE jlog.rownnr = 1 OR jlog.rownnr IS NULL */
WHERE (jd.job_id NOT LIKE '\_DVB\_%' ESCAPE '\')
GROUP BY jd.job_id,
         jd.job_name,
         jd.job_type,
         jd.parallel_loads,
         jd.job_enabled,
         jd.job_comment,
         /* jlog.jlgduration,*/
         jli.latest_load_start_time,
         jli.succeeded_load_duration,
         jli.current_loading_duration,
         s.system_id,
         s.system_name,
         s.system_color,
         s.system_comment
;


	CREATE VIEW "DVB_CORE"."SATELLITES" AS 
SELECT 
  td.table_nq_id,
  td.satellite_id,
  td.boid,
  td.system_id,
  s.system_name,
  s.system_color,
  s.system_comment,
  td.functional_suffix_id,
  MAX(td.functional_suffix_name) AS functional_suffix_name,
  MAX(td.satellite_subject_area_name) AS satellite_subject_area_name,
  MAX(td.satellite_comment) AS satellite_comment,
  vr.table_id AS staging_table_id,
  COALESCE(dvb_core.f_string_between(td.satellite_id, '_R_', '_F_'), dvb_core.f_string_between(td.satellite_id, '_R_', '')) AS staging_resource_id,
  'H_' || td.boid AS parent_hub_id,
  td.parent_hub_name AS parent_hub_name,
  td.parent_hub_name || COALESCE(NULLIF(' > ' || s.system_name, ' > '), '') || ' > ' || COALESCE(NULLIF(MAX(td.functional_suffix_name), ''), 'Default') AS satellite_name,
  COALESCE(dvb_core.f_get_value_from_json(sv.VIEW_COMMENT,'datavault_category'), 'raw_vault') AS datavault_category_id,
  td.satellite_is_prototype
FROM (
  SELECT DISTINCT
    LEFT(o.OBJECT_NAME, LENGTH(o.OBJECT_NAME) -2) AS table_nq_id,
    LEFT(o.OBJECT_NAME, LENGTH(o.OBJECT_NAME) -2) AS satellite_id,
    dvb_core.f_string_between(SUBSTRING(o.OBJECT_NAME, 3, 214748364), '', '_S_')  AS boid,
    COALESCE(NULLIF(dvb_core.f_string_between(o.OBJECT_NAME, '_S_', '_R_'), ''), 'DVB_PROTOTYPE') AS system_id,
    COALESCE(dvb_core.f_string_between(LEFT(o.OBJECT_NAME, LEN(o.OBJECT_NAME) - 2), '_F_', ''), '') AS functional_suffix_id,
    COALESCE(dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'name'), '') AS functional_suffix_name,
    COALESCE(dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'subject_area'), '') AS satellite_subject_area_name,
    COALESCE(dvb_core.f_get_value_from_json(o.OBJECT_COMMENT,'comment'), '') AS satellite_comment,
    COALESCE(dvb_core.f_get_value_from_json(po.OBJECT_COMMENT,'name'), '') AS parent_hub_name,
	CASE WHEN o.OBJECT_NAME LIKE '%\_P' ESCAPE '\' THEN TRUE ELSE FALSE END AS satellite_is_prototype
  FROM SYS.EXA_ALL_OBJECTS o
    LEFT JOIN SYS.EXA_ALL_OBJECTS po ON (po.OBJECT_NAME = 'H_' || dvb_core.f_string_between(SUBSTRING(o.OBJECT_NAME, 3, 214748364), '', '_S_') AND po.ROOT_NAME = 'DATAVAULT')
  WHERE o.ROOT_NAME = 'DATAVAULT'
    AND o.OBJECT_NAME NOT LIKE 'S\_%\_W\_TRK_%' ESCAPE '\'
    AND (o.OBJECT_NAME LIKE 'S\_%\H' ESCAPE '\' OR o.OBJECT_NAME LIKE 'S\_%\O' ESCAPE '\' OR o.OBJECT_NAME LIKE 'S\_%\C' ESCAPE '\' ) 
    OR o.OBJECT_NAME LIKE 'S\_%\_P' ESCAPE '\'      
      ) td
  LEFT JOIN dvb_core.systems s ON s.system_id = td.system_id
  LEFT JOIN dvb_core.view_relations vr ON td.table_nq_id = vr.dependent_view_nq_id
  LEFT JOIN SYS.EXA_ALL_VIEWS sv ON (sv.VIEW_SCHEMA = 'DATAVAULT_STAGING' AND sv.VIEW_NAME = 'H_' || td.boid || '_S_' || vr.table_nq_id)
  --LEFT JOIN sys.schemas sn ON so.schema_id = sn.schema_id
GROUP BY 
  td.table_nq_id,
  td.satellite_id,
  td.boid,
  td.system_id,
  s.system_name,
  s.system_color,
  s.system_comment,
  td.functional_suffix_id,
  vr.table_id,
  sv.VIEW_COMMENT,
  td.parent_hub_name,
  td.satellite_is_prototype;


	CREATE VIEW "DVB_CORE"."X_BUSINESSOBJECTS_DISTINCT" AS
  SELECT DISTINCT bl.start_hub_id,
    bl.start_hub_name,
    bl.functional_suffix_id,
    bl.functional_suffix_name
  FROM dvb_core.businessobjects bl
;


	CREATE VIEW "DVB_CORE"."X_BUSINESSOBJECTS_SYSTEM" AS 
  SELECT bl.start_hub_id,
    bl.functional_suffix_id,
    bl.system_id,
    bl.system_name,
    bl.system_color,
    bl.system_comment
  FROM dvb_core.businessobjects bl
;


	CREATE VIEW "DVB_CORE"."BUSINESS_RULES" AS SELECT
        a.business_ruleset_view_id,
        a.functional_suffix_id,
        a.functional_suffix_name,
        a.business_ruleset_suffix_id,
        a.business_ruleset_suffix_name,
        a.system_id,
        a.system_name,
        a.system_color,
        a.system_comment,
        a.start_hub_id,
        a.start_hub_name,
        a.related_businessobject_view_id,
        a.business_rules_comment,
        a.start_hub_name || ' > ' || a.system_name || ' > ' || COALESCE(NULLIF(a.functional_suffix_name, ''), 'Default') || ' > ' || COALESCE(NULLIF(a.business_ruleset_suffix_name, ''), 'Default') AS business_ruleset_name,
        a.business_rules_view_code,
        a.is_error_ruleset,
        a.include_in_accesslayer,
        a.accesslayer_priorization,
        a.quick_inserts
    FROM
        (
            SELECT
                iv.view_id AS business_ruleset_view_id,
                COALESCE(dvb_core.f_string_between(iv.view_nq_id, '_C_', '_B_'), dvb_core.f_string_between(iv.view_nq_id, '_C_', ''), '') AS functional_suffix_id,
                dvb_core.f_get_value_from_json(ext2.OBJECT_COMMENT,'name') AS functional_suffix_name,
                COALESCE(
                    dvb_core.f_string_between(iv.view_nq_id, '_B_', ''),
                    ''
                ) AS business_ruleset_suffix_id,
                iv.metadata_name AS business_ruleset_suffix_name,
                s.system_id,
                s.system_name,
                s.system_color,
                s.system_comment,
                'H_' || dvb_core.f_string_between(iv.view_nq_id, '', '_S_') AS start_hub_id,
                 dvb_core.f_get_value_from_json(ext.OBJECT_COMMENT,'name') AS start_hub_name,
                'BUSINESSOBJECTS.' || COALESCE(
                    dvb_core.f_string_between(iv.view_nq_id, '', '_B_'),
                    iv.view_nq_id
                ) AS related_businessobject_view_id,
                iv.metadata_comment AS business_rules_comment,
                iv.metadata_code AS business_rules_view_code,
                iv.metadata_is_error_ruleset AS is_error_ruleset,
                iv.metadata_include_in_accesslayer AS include_in_accesslayer,
                iv.metadata_accesslayer_priorization AS accesslayer_priorization,
                iv.metadata_quick_inserts AS quick_inserts
            FROM dvb_core.views iv
              LEFT JOIN SYS.EXA_ALL_OBJECTS ext ON (ext.ROOT_NAME || '.'  || ext.OBJECT_NAME) = ('DATAVAULT.H_' || dvb_core.f_string_between(iv.view_nq_id, '', '_S_'))
              LEFT JOIN SYS.EXA_ALL_OBJECTS ext2 ON (ext2.ROOT_NAME || '.'  || ext2.OBJECT_NAME) = ('BUSINESSOBJECTS.' || COALESCE(dvb_core.f_string_between(iv.view_nq_id, '', '_B_'), iv.view_nq_id))
              LEFT JOIN dvb_core.systems s ON
                s.system_id = COALESCE(
                    dvb_core.f_string_between(iv.view_nq_id, '_S_', '_C_'),
                    dvb_core.f_string_between(iv.view_nq_id, '_S_', '_B_'),
                    dvb_core.f_string_between(iv.view_nq_id, '_S_', '')
                )
            WHERE
                iv.schema_id = 'BUSINESS_RULES'
        ) a
    WHERE
        a.system_id IS NOT NULL;


	CREATE VIEW "DVB_CORE"."HUB_LOADS" AS SELECT
    hl.hub_load_id,
    hl.hub_id,
    hl.technical_business_key,
    hl.short_business_key,
    CONCAT( COALESCE(s.system_name, dvb_core.f_initcap(REPLACE(hl.system_id, '_', ' '))), ': ', UPPER(REPLACE(dvb_core.f_string_between(dvb_core.f_string_between(hl.staging_table_id, '.', ''), '_R_', ''), '_', ' ')), ' (' , hl.short_business_key, ')' ) AS hub_load_list_entry,
    hl.system_id,
    COALESCE( s.system_name,
    dvb_core.f_initcap( REPLACE( hl.system_id,
    '_',
    ' ' ) ) ) AS system_name,
    s.system_color,
    s.system_comment,
    hl.staging_table_id,
    dvb_core.s_generate_hash_crc32_int(hl.hub_load_id) AS staging_view_id_hash,
    keys_are_unique,
    CAST( 0 AS BOOLEAN ) AS keys_are_prehashed,
    COALESCE( CONVERT( NVARCHAR(40),
    hl.datavault_category ),
    'raw_vault' ) AS datavault_category_id
FROM
    ( (
    SELECT
        v.VIEW_NAME AS hub_load_id,
        dvb_core.f_string_between( v.VIEW_NAME,
        '',
        '_S_' ) AS hub_id,
        --regexp_replace(
 REPLACE(REPLACE(REPLACE(REPLACE(dvb_core.f_string_between(bks.VIEW_TEXT,
        '/*bk_start*/',
        '/*bk_end*/'),
        '/*prefix_start*/',
        ''),
        '/*prefix_end*/',
        ''),
        CHAR(13) ,
        ''),
        CHAR(10),
        '')
        -- '/*.*/', '')
 AS technical_business_key,
        dvb_core.f_string_between(v.VIEW_NAME,
        '_S_',
        '_R_') AS system_id,
        CONCAT( 'STAGING.', dvb_core.f_string_between(v.VIEW_NAME, '_S_', '') ) AS staging_table_id,
        dvb_core.f_get_value_from_json(v.VIEW_COMMENT,
        'datavault_category') AS datavault_category,
        replace(NULLIF(dvb_core.f_string_between(bks.VIEW_TEXT,
        '/*prefix_start*/',
        '/*prefix_end*/') || ', ',
        ', '), '''', '"') || dvb_core.f_get_bk_fields(dvb_core.f_string_between(bks.VIEW_TEXT,
        '/*bk_start*/',
        '/*bk_end*/')) AS short_business_key,
        dvb_core.f_get_keys_are_unique(V.VIEW_TEXT) AS keys_are_unique
    FROM
        SYS.EXA_ALL_VIEWS v
    LEFT JOIN SYS.EXA_ALL_VIEWS bks ON
        (bks.VIEW_SCHEMA || '.' || bks.VIEW_NAME) = ( 'STAGING.T_' || dvb_core.f_string_between(v.VIEW_NAME,
        '_S_',
        '') || '_O_' || dvb_core.f_string_between(v.VIEW_NAME,
        'H_',
        '_S_') || '_TABLE')
    WHERE
        v.VIEW_SCHEMA = 'DATAVAULT_STAGING'
        AND v.VIEW_NAME LIKE 'H\_%' ESCAPE '\' ) hl
LEFT JOIN dvb_core.systems s ON
    hl.system_id = s.system_id );


	CREATE VIEW "DVB_CORE"."X_JOBS_SYSTEM" AS 
  SELECT DISTINCT jb.system_id,
    jb.system_name,
    jb.system_color,
    jb.system_comment
  FROM dvb_core.jobs jb
;


	CREATE VIEW "DVB_CORE"."X_SATELLITES_SYSTEM" AS 
  SELECT sat.satellite_id,
    sat.boid,
    sat.system_id,
    sat.system_name,
    sat.system_color,
    sat.system_comment,
    sat.functional_suffix_id,
    sat.functional_suffix_name,
    sat.parent_hub_id,
    sat.parent_hub_name
  FROM dvb_core.satellites sat
  WHERE NULLIF(sat.SYSTEM_ID,'') IS NOT NULL 
  ;


	CREATE VIEW "DVB_CORE"."X_BUSINESS_RULES_DISTINCT" AS
  SELECT DISTINCT br.start_hub_id,
    br.start_hub_name,
    br.functional_suffix_id,
    br.functional_suffix_name
  FROM dvb_core.business_rules br   
;


	CREATE VIEW "DVB_CORE"."X_BUSINESS_RULES_SYSTEM" AS
  SELECT DISTINCT br.start_hub_id,
    br.start_hub_name,
    br.functional_suffix_id,
    br.functional_suffix_name,
    br.system_id,
    br.system_name,
    br.system_color,
    br.system_comment,
    br.related_businessobject_view_id
  FROM dvb_core.business_rules br
   ;


	CREATE VIEW "DVB_CORE"."X_HUBS_SYSTEM" AS
  SELECT DISTINCT h.hub_id,
    h.system_id,
    h.system_name,
    h.system_color,
    h.system_comment
  FROM dvb_core.hub_loads h
  WHERE h.system_id IS NOT NULL
  ;


	CREATE VIEW "DVB_CORE"."LINKS" AS 
SELECT
  td.table_nq_id,
  td.link_id,
  td.boid,
  td.hub_a_boid,
  'H_' || td.hub_a_boid AS hub_a_id,
  td.hub_a_name,
  td.hub_b_boid,
  'H_' || td.hub_b_boid AS hub_b_id,
  td.hub_b_name,
  td.link_suffix_id,
  td.link_suffix_name,
  td.link_type,
  td.link_subject_area_name,
  td.link_comment,
  td.hub_a_name || ' to ' || td.hub_b_name || ' > ' || COALESCE(NULLIF(td.link_suffix_name, ''), 'Default') AS link_name,
  td.link_is_prototype
FROM (
SELECT
  tdi.table_nq_id,
  tdi.link_id,
  tdi.boid,
  tdi.hub_a_boid,
  dvb_core.f_get_value_from_json(a_name.OBJECT_COMMENT,'name') AS hub_a_name,
  tdi.hub_b_boid,
  dvb_core.f_get_value_from_json(b_name.OBJECT_COMMENT,'name') AS hub_b_name,
  tdi.link_suffix_id,
  tdi.link_type,
  tdi.link_suffix_name,
  tdi.subject_area AS link_subject_area_name,
  tdi.comment AS link_comment,
  tdi.table_type,
  tdi.link_is_prototype
FROM (
  SELECT DISTINCT
    t.table_name AS table_nq_id,
    t.table_name AS link_id,
    SUBSTRING(t.table_name, 3, 214748364) AS boid,
    dvb_core.f_string_between(t.table_name, 'L_', '_T_') AS hub_a_boid,
    COALESCE(dvb_core.f_string_between(t.table_name, '_T_', '_L_'), dvb_core.f_string_between(t.table_name, '_T_', '')) AS hub_b_boid,
    COALESCE(dvb_core.f_string_between(t.table_name, '_L_', ''), '') AS link_suffix_id,
    COALESCE(dvb_core.f_get_value_from_json(t.TABLE_COMMENT,'link_type'), '') AS link_type,
    COALESCE(dvb_core.f_get_value_from_json(t.TABLE_COMMENT,'name'), '') AS link_suffix_name,
    COALESCE(dvb_core.f_get_value_from_json(t.TABLE_COMMENT,'subject_area'), '') AS subject_area,
    COALESCE(dvb_core.f_get_value_from_json(t.TABLE_COMMENT,'comment'), '') AS comment,
    'TABLE'  AS table_type,
    vr.dependent_view_nq_id IS NULL AS link_is_prototype
  FROM SYS.EXA_ALL_TABLES t
    LEFT JOIN dvb_core.view_relations vr
      ON t.table_name = dvb_core.f_string_between(vr.dependent_view_nq_id, '', '_S_')
        AND vr.table_schema_id = 'STAGING'
  WHERE t.table_schema = 'DATAVAULT'
    AND t.table_name LIKE 'L\_%' ESCAPE '\'
  ) tdi 
  LEFT JOIN SYS.EXA_ALL_OBJECTS AS a_name ON (a_name.ROOT_NAME ||'.'|| a_name.OBJECT_NAME) = concat('DATAVAULT.H_' , tdi.hub_a_boid)
  LEFT JOIN SYS.EXA_ALL_OBJECTS AS b_name ON (b_name.ROOT_NAME ||'.'|| b_name.OBJECT_NAME) = concat('DATAVAULT.H_' , tdi.hub_b_boid)   

) td

UNION ALL

SELECT
  cast(NULL AS varchar(255)) AS table_nq_id,
  'L_' || SUBSTRING(dvh.hub_id_of_alias_parent, 3, 214748364) || '_T_' || dvh.boid || '_L_alias_default' AS link_id,
  SUBSTRING(dvh.hub_id_of_alias_parent, 3, 214748364) || '_T_' || dvh.boid || '_L_alias_default' AS boid,
  SUBSTRING(dvh.hub_id_of_alias_parent, 3, 214748364) AS hub_a_boid,
  dvh.hub_id_of_alias_parent AS hub_a_id,
  dvh.hub_name_of_alias_parent AS hub_a_name,
  dvh.boid AS hub_b_boid,
  dvh.hub_id AS hub_b_id,
  dvh.hub_name AS hub_b_name,
  'alias_default' AS link_suffix_id,
  cast(NULL AS varchar(255)) AS link_suffix_name,
  'alias_of' AS link_type,
  cast(NULL AS varchar(255)) AS link_subject_area_name,
  cast(NULL AS varchar(255)) AS link_comment,
  cast(NULL AS varchar(255)) AS link_name,
  CAST(0 AS BOOLEAN) AS link_is_prototype
FROM dvb_core.hubs dvh
WHERE ((dvh.hub_id_of_alias_parent NOT LIKE 'STAGING.%')
  AND (dvh.hub_id_of_alias_parent IS NOT NULL))
;


	CREATE VIEW "DVB_CORE"."LINK_LOADS" AS SELECT
    DISTINCT td.link_load_id,
    td.link_id,
    td.system_id,
    s.system_name,
    s.system_color,
    s.system_comment,
    td.staging_table_id,
    td.staging_view_id_hash
FROM
    ((
        SELECT vr.dependent_view_nq_id AS link_load_id,
        COALESCE(v.view_nq_id,
        t.table_name) AS table_nq_id,
        t.table_name AS link_id,
        dvb_core.f_string_between(vr.dependent_view_nq_id,
        '_S_',
        '_R_') AS system_id,
        vr.table_id AS staging_table_id,
        dvb_core.s_generate_hash_crc32_int(vr.dependent_view_nq_id) AS staging_view_id_hash
    FROM
        SYS.EXA_ALL_TABLES t
    LEFT JOIN dvb_core.views v ON
        v.view_nq_id LIKE t.table_name || '%'
        AND v.view_nq_id NOT LIKE t.table_name || '%\_L\_%' ESCAPE '\'
        AND v.view_nq_id NOT LIKE t.table_name || '%\_F\_DRV%' ESCAPE '\'
    LEFT JOIN dvb_core.view_relations vr ON
        t.table_name = dvb_core.f_string_between(vr.dependent_view_nq_id,
        '',
        '_S_')
        AND vr.table_schema_id = 'STAGING'
    WHERE
        t.table_schema = 'DATAVAULT'
        AND t.table_name LIKE 'L\_%' ESCAPE '\'
        --AND t.table_type = 'BASE TABLE'
        AND vr.dependent_view_id IS NOT NULL /*AND (v.view_nq_id IS NULL
    OR v.view_nq_id NOT LIKE '%\_s\_%' ESCAPE '\')*/
        ) td
LEFT JOIN dvb_core.systems s ON
    s.system_id = td.system_id );


	CREATE VIEW "DVB_CORE"."X_LINKS_DISTINCT" AS 
  SELECT links.link_id,
    links.boid,
    links.hub_a_boid,
    links.hub_a_name,
    links.hub_b_boid,
    links.hub_b_name,
    links.link_suffix_id,
    links.link_type,
    links.link_suffix_name,
    links.link_subject_area_name AS subject_area,
    links.link_comment AS comment,
    links.link_name,
    links.link_is_prototype
  FROM dvb_core.links
;


	CREATE VIEW "DVB_CORE"."X_LINKS_SYSTEM" AS
  SELECT l.link_id,
    l.system_id,
    l.system_name,
    l.system_color,
    l.system_comment
  FROM dvb_core.link_loads l
;


	CREATE VIEW "DVB_CORE"."ACCESSLAYERS" AS SELECT
        a.accesslayer_id,
        dvb_core.f_get_value_from_json(ext.OBJECT_COMMENT,'name') || CASE WHEN a.functional_suffix_name IS NULL THEN '' ELSE  ' > ' || a.functional_suffix_name END   AS accesslayer_name,
        a.functional_suffix_id,
        bl.functional_suffix_name,
        (
            'H_' || a.boid
        ) AS parent_hub_id,
        dvb_core.f_get_value_from_json(ext.OBJECT_COMMENT,'name') AS parent_hub_name,
        a.accesslayer_comment
    FROM
        (
            (
                SELECT
                    iv.table_schema || '.' || iv.table_name AS accesslayer_id,
                    COALESCE(
                        dvb_core.f_string_between(
                            (iv.table_name),
                            '',
                            '_C_'
                        ),
                        (iv.table_name)
                    ) AS boid,
                    COALESCE(
                        dvb_core.f_string_between(
                            (iv.table_name),
                            '_C_',
                            ''
                        ),
                        ''
                    ) AS functional_suffix_id,
                    UPPER( dvb_core.f_string_between(( iv.table_name ), '_C_', '' )) AS functional_suffix_name,
                    dvb_core.f_get_value_from_json(iv.table_comment,'comment') AS accesslayer_comment 
                FROM
                    (
                        SELECT
                            v.VIEW_NAME AS table_name,
                            v.VIEW_SCHEMA AS table_schema,
                            v.VIEW_COMMENT AS table_comment
                        FROM
                            SYS.EXA_ALL_VIEWS AS v
                        WHERE
                            VIEW_SCHEMA = 'ACCESSLAYER'
                    ) iv
                   
            ) a
        LEFT JOIN SYS.EXA_ALL_OBJECTS ext ON (ext.ROOT_NAME || '.'  || ext.OBJECT_NAME) = ('DATAVAULT.H_' || a.boid)    
        LEFT JOIN dvb_core.x_businessobjects_distinct bl ON
            (
                (
                    (
                        a.functional_suffix_id = bl.functional_suffix_id
                    )
                    AND(
                        (
                            'H_' || a.boid
                        )= bl.start_hub_id
                    )
                )
            )
        );


	CREATE VIEW "DVB_CORE"."LINKSATELLITES"
AS

SELECT
  td.table_nq_id,
  td.linksatellite_id,
  td.system_id,
  s.system_name,
  s.system_color,
  s.system_comment,
  td.functional_suffix_id,
  td.functional_suffix_name,
  td.linksatellite_subject_area_name,
  td.linksatellite_comment,
  td.parent_link_id,
  td.parent_link_name,
  td.parent_link_name || ' > ' || COALESCE(NULLIF(td.functional_suffix_name, ''), 'Default')  AS linksatellite_name
FROM ((

SELECT
  (t.table_name) AS table_nq_id,
  LEFT(t.table_name, LEN(t.table_name) - 2) AS linksatellite_id,
  NULLIF(COALESCE(dvb_core.f_string_between((t.table_name), '_S_', '_F_'), dvb_core.f_string_between(LEFT(t.table_name, LEN(t.table_name) - 2), '_S_', '')), '') AS system_id,
  COALESCE(dvb_core.f_string_between(LEFT(t.table_name, LEN(t.table_name) - 2), '_F_', ''), '') AS functional_suffix_id,
  NULLIF(COALESCE(dvb_core.f_get_value_from_json(com_h.OBJECT_COMMENT,'name'),dvb_core.f_get_value_from_json(com_c.OBJECT_COMMENT,'name'),dvb_core.f_get_value_from_json(com_o.OBJECT_COMMENT,'name'),dvb_core.f_get_value_from_json(com_p.OBJECT_COMMENT,'name')),'') AS functional_suffix_name,
  NULLIF(COALESCE(dvb_core.f_get_value_from_json(com_h.OBJECT_COMMENT,'subject_area'),dvb_core.f_get_value_from_json(com_c.OBJECT_COMMENT,'subject_area'),dvb_core.f_get_value_from_json(com_o.OBJECT_COMMENT,'subject_area'),dvb_core.f_get_value_from_json(com_p.OBJECT_COMMENT,'subject_area')),'') AS linksatellite_subject_area_name,
  NULLIF(COALESCE(dvb_core.f_get_value_from_json(com_h.OBJECT_COMMENT,'comment'),dvb_core.f_get_value_from_json(com_c.OBJECT_COMMENT,'comment'),dvb_core.f_get_value_from_json(com_o.OBJECT_COMMENT,'comment'),dvb_core.f_get_value_from_json(com_p.OBJECT_COMMENT,'comment')),'') AS linksatellite_comment,
  l.link_id AS parent_link_id,
  l.link_name AS parent_link_name
FROM (
  SYS.EXA_ALL_TABLES t
    LEFT JOIN (
      SELECT
        links.link_id,
        links.link_name
      FROM dvb_core.links
      ) l
      ON ((l.link_id = ('L_' || dvb_core.f_string_between((t.table_name), 'LS_', '_S_')))))
    LEFT JOIN SYS.EXA_ALL_OBJECTS AS com_h ON (com_h.ROOT_NAME ||'.'|| com_h.OBJECT_NAME) = t.table_schema || '.' || LEFT(t.table_name, LEN(t.table_name) - 2) ||  '_H'  
    LEFT JOIN SYS.EXA_ALL_OBJECTS AS com_c ON (com_c.ROOT_NAME ||'.'|| com_c.OBJECT_NAME) = t.table_schema || '.' || LEFT(t.table_name, LEN(t.table_name) - 2) ||  '_C'    
    LEFT JOIN SYS.EXA_ALL_OBJECTS AS com_o ON (com_o.ROOT_NAME ||'.'|| com_o.OBJECT_NAME) = t.table_schema || '.' || LEFT(t.table_name, LEN(t.table_name) - 2) ||  '_O'    
    LEFT JOIN SYS.EXA_ALL_OBJECTS AS com_p ON (com_p.ROOT_NAME ||'.'|| com_p.OBJECT_NAME) = t.table_schema || '.' || LEFT(t.table_name, LEN(t.table_name) - 2) ||  '_P'     
    
WHERE t.table_schema = 'DATAVAULT'
  AND t.table_name LIKE 'LS\_%' ESCAPE '\'
  AND t.table_name NOT LIKE 'LS\_%\_W\_TRK_\_H' ESCAPE '\'
  AND t.table_name NOT LIKE 'LS\_%\_W\_TRK_\_C' ESCAPE '\'
) td
  LEFT JOIN dvb_core.systems s
    ON ((s.system_id = td.system_id)))
;


	CREATE VIEW "DVB_CORE"."TRANSACTION_LINK_RELATIONS" AS 
SELECT
  'LTR_' || dvb_core.f_string_between(tl.transaction_link_id, 'LT_', '') || '_T_' || h.boid AS transaction_link_relation_id,
  tl.transaction_link_id,
  tl.functional_suffix_name AS transaction_link_name,
  h.hub_id AS linked_hub_id,
  h.hub_name AS linked_hub_name,
  CASE
    WHEN tl.parent_hub_id = h.hub_id THEN 'transaction_link'
    ELSE 'many_to_one'
  END AS link_type
FROM dvb_core.transaction_links tl
INNER JOIN dvb_core.columns c
  ON (c.table_nq_id = tl.table_nq_id
  AND c.schema_id = 'DATAVAULT')
INNER JOIN dvb_core.hubs h
  ON (h.boid || '_H' = c.column_nq_id)
;


	CREATE VIEW "DVB_CORE"."ACCESS_ERRORMART" AS SELECT
        a.access_errormart_id,
        dvb_core.f_get_value_from_json(ext.OBJECT_COMMENT,'name') || 
        COALESCE(' > ' || NULLIF(a.system_name, ''), '') || 
        COALESCE(' > ' || NULLIF(bl.functional_suffix_name, ''), '') || 
        COALESCE(' > ' || NULLIF(a.business_ruleset_suffix_name, ''), '') AS access_errormart_name,
        a.functional_suffix_id,
        bl.functional_suffix_name,
        a.business_ruleset_suffix_id,
        a.business_ruleset_suffix_name,
        'H_' || a.boid AS parent_hub_id,
        dvb_core.f_get_value_from_json(ext.OBJECT_COMMENT,'name') AS parent_hub_name,
        a.access_errormart_comment
    FROM
        (
            (
                SELECT
                    iv.view_schema || '.' || iv.view_name AS access_errormart_id,
                    dvb_core.f_string_between(
                        COALESCE(
                            dvb_core.f_string_between(
                                iv.view_name,
                                '',
                                '_C_'
                            ),
                            iv.view_name
                        ),
                        '',
                        '_S_'
                    ) AS boid,
                    COALESCE(
                        dvb_core.f_string_between(
                            iv.view_name,
                            '_C_',
                            '_B_'
                        ),
                        dvb_core.f_string_between(
                            iv.view_name,
                            '_C_',
                            ''
                        ),
                        ''
                    ) AS functional_suffix_id,
                    COALESCE(
                        UPPER( dvb_core.f_string_between( iv.view_name, '_C_', '_B_' )),
                        UPPER( dvb_core.f_string_between( iv.view_name, '_C_', '' )),
                        ''
                    ) AS functional_suffix_name,
                    COALESCE(
                        br.business_ruleset_suffix_id,
                        ''
                    ) AS business_ruleset_suffix_id,
                    COALESCE(
                        br.business_ruleset_suffix_name,
                        ''
                    ) AS business_ruleset_suffix_name,
                    dvb_core.f_get_value_from_json(iv.VIEW_COMMENT,'comment') AS access_errormart_comment,

                    COALESCE(
                        s.system_name,
                        ''
                    ) AS system_name
                FROM
                    SYS.EXA_ALL_VIEWS iv
                   
                LEFT JOIN dvb_core.systems s ON
                    s.system_id = COALESCE(
                        dvb_core.f_string_between(
                            iv.VIEW_NAME,
                            '_S_',
                            '_C_'
                        ),
                        dvb_core.f_string_between(
                            iv.VIEW_NAME,
                            '_S_',
                            ''
                        )
                    )
                LEFT JOIN dvb_core.business_rules br ON
                    br.business_ruleset_view_id = 'BUSINESS_RULES.' || iv.VIEW_NAME
                WHERE
                    iv.VIEW_schema = 'ACCESS_ERRORMART'
            ) a
        LEFT JOIN SYS.EXA_ALL_OBJECTS ext ON (ext.ROOT_NAME || '.'  || ext.OBJECT_NAME) = ('DATAVAULT.H_' || a.boid)     
        LEFT JOIN dvb_core.x_businessobjects_distinct bl ON
            a.functional_suffix_id = bl.functional_suffix_id
            AND 'H_' || a.boid = bl.start_hub_id
        );


	CREATE VIEW "DVB_CORE"."TABLES" AS SELECT
    sub.table_id,
    sub.table_nq_id,
    sub.schema_id,
    sub.schema_name,
    sub.table_name,
    sub.table_comment,
    sub.type_id,
    sub.type_name,
    sub.system_id,
    s.system_name,
    s.system_color,
    s.system_comment
FROM
    (
    SELECT
        DISTINCT c.ROOT_NAME || '.' || c.OBJECT_NAME AS table_id,
        c.OBJECT_NAME AS table_nq_id,
        c.ROOT_NAME AS schema_id,
        dvb_core.f_get_schema_name(c.ROOT_NAME) AS schema_name,
        COALESCE( CAST(a.accesslayer_name AS VARCHAR(1000)),
        CAST(ae.access_errormart_name AS VARCHAR(1000)),
        CAST(br.business_ruleset_name AS VARCHAR(1000)),
        CAST(bl.businessobject_name AS VARCHAR(1000)),
        CAST(h.hub_name AS VARCHAR(1000)),
        CAST(s_1.satellite_name AS VARCHAR(1000)),
        CAST(ls.linksatellite_name AS VARCHAR(1000)),
        CAST(l.link_name AS VARCHAR(1000)),
        CAST(ts.tracking_satellite_name AS VARCHAR(1000)),
        CAST(tl.transaction_link_name AS VARCHAR(1000)),
        CAST(st.staging_table_name AS VARCHAR(1000)),
        'N/A' ) AS table_name,
        dvb_core.f_get_value_from_json(c.OBJECT_COMMENT,
        'comment') AS table_comment,
        CASE
            WHEN c.OBJECT_TYPE = 'TABLE' THEN CAST('r' AS CHAR(1))
            WHEN c.OBJECT_TYPE = 'VIEW' THEN CAST('v' AS CHAR(1))
            ELSE CAST(NULL AS CHAR(1))
        END AS type_id,
        CASE
            WHEN c.OBJECT_TYPE = 'TABLE' THEN 'Base Table'
            WHEN c.OBJECT_TYPE = 'VIEW' THEN 'View'
            --WHEN 'm' THEN 'Materialized View'
            ELSE CAST(NULL AS VARCHAR(1))
        END AS type_name,
        CASE WHEN S_1.SATELLITE_IS_PROTOTYPE THEN 'DVB_PROTOTYPE' ELSE
        COALESCE( dvb_core.f_string_between(c.OBJECT_NAME,
        '_S_',
        '_R_'),
        dvb_core.f_string_between(c.OBJECT_NAME,
        '_S_',
        '_C_'),
        dvb_core.f_string_between(c.OBJECT_NAME,
        '_S_',
        ''),
        dvb_core.f_string_between('^' || c.OBJECT_NAME,
        '^T_',
        '_R_'),
        dvb_core.f_string_between(c.OBJECT_NAME,
        '',
        '_R_')
        -- in case of a staging table
) END AS system_id
    FROM
        SYS.EXA_ALL_OBJECTS c
        --select * from SYS.EXA_ALL_OBJECTS
    LEFT JOIN dvb_core.accesslayers a ON
        a.accesslayer_id = c.ROOT_NAME || '.' || c.OBJECT_NAME
    LEFT JOIN dvb_core.access_errormart ae ON
        ae.access_errormart_id = c.ROOT_NAME || '.' || c.OBJECT_NAME
    LEFT JOIN dvb_core.business_rules br ON
        br.business_ruleset_view_id = c.ROOT_NAME || '.' || c.OBJECT_NAME
    LEFT JOIN dvb_core.businessobjects bl ON
        bl.businessobject_view_id = c.ROOT_NAME || '.' || c.OBJECT_NAME
    LEFT JOIN dvb_core.hubs h ON
        c.ROOT_NAME = 'DATAVAULT'
        AND h.hub_id = c.OBJECT_NAME
    LEFT JOIN dvb_core.links l ON
        c.ROOT_NAME = 'DATAVAULT'
        AND l.link_id = c.OBJECT_NAME
    LEFT JOIN dvb_core.satellites s_1 ON
        c.ROOT_NAME = 'DATAVAULT'
        AND s_1.satellite_id = LEFT(c.OBJECT_NAME,
        LEN(c.OBJECT_NAME)- 2)
    LEFT JOIN dvb_core.linksatellites ls ON
        c.ROOT_NAME = 'DATAVAULT'
        AND ls.linksatellite_id = LEFT(c.OBJECT_NAME,
        LEN(c.OBJECT_NAME)- 2)
    LEFT JOIN dvb_core.tracking_satellites ts ON
        c.ROOT_NAME = 'DATAVAULT'
        AND ts.tracking_satellite_id = LEFT(c.OBJECT_NAME,
        LEN(c.OBJECT_NAME)- 2)
    LEFT JOIN dvb_core.transaction_links tl ON
        c.ROOT_NAME = 'DATAVAULT'
        AND tl.transaction_link_id = LEFT(c.OBJECT_NAME,
        LEN(c.OBJECT_NAME)- 2)
    LEFT JOIN dvb_core.staging_tables st ON
        st.staging_table_id = c.ROOT_NAME || '.' || c.OBJECT_NAME
    WHERE
        c.ROOT_NAME IN( 'STAGING',
        'DATAVAULT_STAGING',
        'DATAVAULT',
        'BUSINESSOBJECTS',
        'BUSINESS_RULES',
        'ACCESSLAYER',
        'ACCESS_ERRORMART' )
        --AND c.OBJECT_TYPE NOT IN ('U', 'V')
        AND c.OBJECT_NAME NOT LIKE '\_DVB\_%' ESCAPE '\' ) sub
LEFT JOIN dvb_core.systems s ON
    s.system_id = sub.system_id
    --WHERE sub.type_id IS NOT NULL
;



-- VIRTUAL SCHEMAS --------------------------------------------------------------------

	-- no virtual schemas defined.


-- ALL CONSTRAINTS ---------------------------------------------------------------------------------

	ALTER TABLE "DATAVAULT"."_DVB_RUNTIME_LOAD_DATA"
		ADD CONSTRAINT "PK_DVB_METADATA"
		 PRIMARY KEY ("OBJECT_ID");

	ALTER TABLE "DVB_CONFIG"."API_HOOK_TEMPLATES"
		ADD CONSTRAINT "PK_API_HOOK_TEMPLATES"
		 PRIMARY KEY ("DVB_API_ID","HOOK_POINT_ID");

	ALTER TABLE "DVB_CONFIG"."AUTH_USERS"
		ADD CONSTRAINT "PK_AUTH_USERS"
		 PRIMARY KEY ("USER_ID");

	ALTER TABLE "DVB_CONFIG"."CONFIG"
		ADD CONSTRAINT "PK_CONFIG"
		 PRIMARY KEY ("CONFIG_KEY");

	ALTER TABLE "DVB_CONFIG"."JOB_DATA"
		ADD CONSTRAINT "PK_JOB_DATA"
		 PRIMARY KEY ("JOB_ID");

	ALTER TABLE "DVB_CONFIG"."JOB_LOADS"
		ADD CONSTRAINT "PK_JOB_LOADS"
		 PRIMARY KEY ("JOB_ID","SOURCE_ID","TARGET_ID");

	ALTER TABLE "DVB_CONFIG"."JOB_SCHEDULES"
		ADD CONSTRAINT "PK_JOB_SCHEDULES"
		 PRIMARY KEY ("JOB_ID","SCHEDULE_ID");

	ALTER TABLE "DVB_CONFIG"."JOB_SQL_QUERIES"
		ADD CONSTRAINT "PK_JOB_SQL_QUERIES"
		 PRIMARY KEY ("JOB_ID","JOB_SQL_QUERY_ID");

	ALTER TABLE "DVB_CONFIG"."JOB_TRIGGERS"
		ADD CONSTRAINT "PK_JOB_TRIGGERS"
		 PRIMARY KEY ("TRIGGERED_BY_JOB_ID","TRIGGERED_JOB_ID");

	ALTER TABLE "DVB_CONFIG"."SYSTEM_COLORS"
		ADD CONSTRAINT "PK_SYSTEM_COLORS"
		 PRIMARY KEY ("SYSTEM_COLOR");

	ALTER TABLE "DVB_CONFIG"."SYSTEM_DATA"
		ADD CONSTRAINT "PK_SYSTEM_DATA"
		 PRIMARY KEY ("SYSTEM_ID");

	ALTER TABLE "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK"
		ADD CONSTRAINT "PK_DVB_RUNTIME_BOOKMARK"
		 PRIMARY KEY ("BOOKMARK_NAME","BOOKMARK_TYPE","OWNER_USERNAME");

	ALTER TABLE "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION"
		ADD CONSTRAINT "PK_DVB_RUNTIME_DOCUMENTATION"
		 PRIMARY KEY ("DOCUMENTATION_NR");

	ALTER TABLE "DVB_LOG"."DATAVAULT_LOAD_LOG"
		ADD CONSTRAINT "PK_DATAVAULT_LOAD_LOG"
		 PRIMARY KEY ("LOAD_ENTRY_ID");

	ALTER TABLE "DVB_LOG"."DDL_LOG"
		ADD CONSTRAINT "PK_DDL_LOG"
		 PRIMARY KEY ("LOG_ENTRY_ID");

	ALTER TABLE "DVB_LOG"."DVBUILDER_CREATION_LOG"
		ADD CONSTRAINT "PK_DVBUILDER_CREATION_LOG"
		 PRIMARY KEY ("LOG_ENTRY_ID");

	ALTER TABLE "DVB_LOG"."DVBUILDER_LOG"
		ADD CONSTRAINT "PK_DVBUILDER_LOG"
		 PRIMARY KEY ("LOG_ENTRY_ID");

	ALTER TABLE "DVB_LOG"."JOB_LOAD_LOG"
		ADD CONSTRAINT "PK_JOB_LOAD_LOG"
		 PRIMARY KEY ("LOAD_ENTRY_ID");

	ALTER TABLE "DVB_LOG"."LOGIN_LOG"
		ADD CONSTRAINT "PK_LOGIN_LOG"
		 PRIMARY KEY ("LOG_ENTRY_ID");

	ALTER TABLE "DVB_LOG"."STAGING_LOAD_LOG"
		ADD CONSTRAINT "PK_STAGING_LOAD_LOG"
		 PRIMARY KEY ("LOAD_ENTRY_ID");

	ALTER TABLE "STAGING"."_DVB_RUNTIME_TABLE_STATUS"
		ADD CONSTRAINT "PK_DVB_METADATA"
		 PRIMARY KEY ("STAGING_TABLE_ID");

	ALTER TABLE "DVB_CONFIG"."JOB_LOADS"
		ADD CONSTRAINT "FK_JOB_LOADS_JOB_ID"
		 FOREIGN KEY ("JOB_ID")
			REFERENCES "DVB_CONFIG"."JOB_DATA"("JOB_ID");

	ALTER TABLE "DVB_CONFIG"."JOB_SQL_QUERIES"
		ADD CONSTRAINT "FK_JOB_SQL_QUERIES_JOB_ID"
		 FOREIGN KEY ("JOB_ID")
			REFERENCES "DVB_CONFIG"."JOB_DATA"("JOB_ID");

	ALTER TABLE "DVB_CONFIG"."JOB_TRIGGERS"
		ADD CONSTRAINT "FK_JOB_TRIGGERS_TRIGGERED_JOB_ID"
		 FOREIGN KEY ("TRIGGERED_JOB_ID")
			REFERENCES "DVB_CONFIG"."JOB_DATA"("JOB_ID");

	ALTER TABLE "DVB_CONFIG"."JOB_TRIGGERS"
		ADD CONSTRAINT "FK_JOB_TRIGGERS_TRIGGERED_BY_JOB_ID"
		 FOREIGN KEY ("TRIGGERED_BY_JOB_ID")
			REFERENCES "DVB_CONFIG"."JOB_DATA"("JOB_ID");

	ALTER TABLE "DVB_CONFIG"."SYSTEM_COLORS"
		ADD CONSTRAINT "FK_SYSTEM_COLORS_SYSTEM_ID"
		 FOREIGN KEY ("SYSTEM_ID")
			REFERENCES "DVB_CONFIG"."SYSTEM_DATA"("SYSTEM_ID");


-- CONNECTIONS --------------------------------------------------------------------

	--no connections specified



-- CHANGE SCHEMA OWNERS -----------------------------------------------------------------

	ALTER SCHEMA "DVB_CORE" CHANGE OWNER "SYS";
	ALTER SCHEMA "DVB_CONFIG" CHANGE OWNER "SYS";
	ALTER SCHEMA "DVB_LOG" CHANGE OWNER "SYS";
	ALTER SCHEMA "ACCESS_ERRORMART" CHANGE OWNER "SYS";
	ALTER SCHEMA "ACCESSLAYER" CHANGE OWNER "SYS";
	ALTER SCHEMA "BUSINESS_RULES" CHANGE OWNER "SYS";
	ALTER SCHEMA "BUSINESSOBJECTS" CHANGE OWNER "SYS";
	ALTER SCHEMA "DATAVAULT" CHANGE OWNER "SYS";
	ALTER SCHEMA "DATAVAULT_STAGING" CHANGE OWNER "SYS";
	ALTER SCHEMA "STAGING" CHANGE OWNER "SYS";
	ALTER SCHEMA "EXA_TOOLBOX" CHANGE OWNER "SYS";
	ALTER SCHEMA "DB_HISTORY" CHANGE OWNER "SYS";

-- RIGHTS --------------------------------------------------------------------

	--Please note that the grantor & owner of all grants will be the user who runs the script!

	-- No user is granted any role except for standard.

	GRANT CREATE SESSION TO AUTHENTICATOR;

	GRANT EXECUTE ANY FUNCTION TO DVB_USER;

	GRANT CREATE ANY TABLE TO DVB_USER;

	GRANT ALTER ANY TABLE TO DVB_USER;

	GRANT DROP ANY TABLE TO DVB_USER;

	GRANT CREATE ANY VIEW TO DVB_USER;

	GRANT DROP ANY VIEW TO DVB_USER;

	GRANT SELECT ANY DICTIONARY TO DVB_USER;

	GRANT EXECUTE ANY SCRIPT TO DVB_USER;

	GRANT EXECUTE ANY FUNCTION TO DVB_USER_READONLY;

	GRANT SELECT ANY DICTIONARY TO DVB_USER_READONLY;

	GRANT EXECUTE ANY SCRIPT TO DVB_USER_READONLY;

	GRANT EXECUTE ANY FUNCTION TO DVB_ADMIN;

	GRANT CREATE ANY TABLE TO DVB_ADMIN;

	GRANT ALTER ANY TABLE TO DVB_ADMIN;

	GRANT DROP ANY TABLE TO DVB_ADMIN;

	GRANT CREATE ANY VIEW TO DVB_ADMIN;

	GRANT DROP ANY VIEW TO DVB_ADMIN;

	GRANT SELECT ANY DICTIONARY TO DVB_ADMIN;

	GRANT EXECUTE ANY SCRIPT TO DVB_ADMIN;

	GRANT EXECUTE ANY FUNCTION TO DVB_OPERATIONS;

	GRANT CREATE ANY TABLE TO DVB_OPERATIONS;

	GRANT ALTER ANY TABLE TO DVB_OPERATIONS;

	GRANT DROP ANY TABLE TO DVB_OPERATIONS;

	GRANT CREATE ANY VIEW TO DVB_OPERATIONS;

	GRANT DROP ANY VIEW TO DVB_OPERATIONS;

	GRANT SELECT ANY DICTIONARY TO DVB_OPERATIONS;

	GRANT EXECUTE ANY SCRIPT TO DVB_OPERATIONS;

	GRANT EXECUTE ANY FUNCTION TO DBADMIN;

	GRANT CREATE ANY TABLE TO DBADMIN;

	GRANT ALTER ANY TABLE TO DBADMIN;

	GRANT DROP ANY TABLE TO DBADMIN;

	GRANT CREATE ANY VIEW TO DBADMIN;

	GRANT DROP ANY VIEW TO DBADMIN;

	GRANT SELECT ANY DICTIONARY TO DBADMIN;

	GRANT EXECUTE ANY SCRIPT TO DBADMIN;

	GRANT EXECUTE ANY FUNCTION TO PGAGENT;

	GRANT CREATE ANY TABLE TO PGAGENT;

	GRANT ALTER ANY TABLE TO PGAGENT;

	GRANT DROP ANY TABLE TO PGAGENT;

	GRANT CREATE ANY VIEW TO PGAGENT;

	GRANT DROP ANY VIEW TO PGAGENT;

	GRANT SELECT ANY DICTIONARY TO PGAGENT;

	GRANT EXECUTE ANY SCRIPT TO PGAGENT;

	GRANT ALTER ON "DVB_CORE" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CORE" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CORE" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CORE" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CORE" TO DVB_ADMIN ;

	GRANT EXECUTE ON "DVB_CORE" TO DVB_ADMIN ;

	GRANT REFERENCES ON "DVB_CORE" TO DVB_ADMIN ;

	GRANT ALTER ON "DVB_CORE" TO DBADMIN ;

	GRANT SELECT ON "DVB_CORE" TO DBADMIN ;

	GRANT DELETE ON "DVB_CORE" TO DBADMIN ;

	GRANT INSERT ON "DVB_CORE" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CORE" TO DBADMIN ;

	GRANT EXECUTE ON "DVB_CORE" TO DBADMIN ;

	GRANT REFERENCES ON "DVB_CORE" TO DBADMIN ;

	GRANT SELECT ON "DVB_CORE" TO DVB_USER ;

	GRANT DELETE ON "DVB_CORE" TO DVB_USER ;

	GRANT INSERT ON "DVB_CORE" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CORE" TO DVB_USER ;

	GRANT SELECT ON "DVB_CORE" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CORE" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CORE" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CORE" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CORE" TO PGAGENT ;

	GRANT DELETE ON "DVB_CORE" TO PGAGENT ;

	GRANT INSERT ON "DVB_CORE" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CORE" TO PGAGENT ;

	GRANT SELECT ON "DVB_CORE" TO DVB_USER_READONLY ;

	GRANT ALTER ON "DVB_CONFIG" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG" TO DVB_ADMIN ;

	GRANT EXECUTE ON "DVB_CONFIG" TO DVB_ADMIN ;

	GRANT REFERENCES ON "DVB_CONFIG" TO DVB_ADMIN ;

	GRANT ALTER ON "DVB_CONFIG" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG" TO DBADMIN ;

	GRANT EXECUTE ON "DVB_CONFIG" TO DBADMIN ;

	GRANT REFERENCES ON "DVB_CONFIG" TO DBADMIN ;

	GRANT ALTER ON "DVB_LOG" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_LOG" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_LOG" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_LOG" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_LOG" TO DVB_ADMIN ;

	GRANT EXECUTE ON "DVB_LOG" TO DVB_ADMIN ;

	GRANT REFERENCES ON "DVB_LOG" TO DVB_ADMIN ;

	GRANT ALTER ON "DVB_LOG" TO DBADMIN ;

	GRANT SELECT ON "DVB_LOG" TO DBADMIN ;

	GRANT DELETE ON "DVB_LOG" TO DBADMIN ;

	GRANT INSERT ON "DVB_LOG" TO DBADMIN ;

	GRANT UPDATE ON "DVB_LOG" TO DBADMIN ;

	GRANT EXECUTE ON "DVB_LOG" TO DBADMIN ;

	GRANT REFERENCES ON "DVB_LOG" TO DBADMIN ;

	GRANT SELECT ON "DVB_LOG" TO DVB_USER ;

	GRANT INSERT ON "DVB_LOG" TO DVB_USER ;

	GRANT UPDATE ON "DVB_LOG" TO DVB_USER ;

	GRANT SELECT ON "DVB_LOG" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_LOG" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_LOG" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_LOG" TO PGAGENT ;

	GRANT INSERT ON "DVB_LOG" TO PGAGENT ;

	GRANT UPDATE ON "DVB_LOG" TO PGAGENT ;

	GRANT SELECT ON "DVB_LOG" TO DVB_USER_READONLY ;

	GRANT INSERT ON "DVB_LOG" TO DVB_USER_READONLY ;

	GRANT ALTER ON "ACCESS_ERRORMART" TO DVB_USER ;

	GRANT SELECT ON "ACCESS_ERRORMART" TO DVB_USER ;

	GRANT DELETE ON "ACCESS_ERRORMART" TO DVB_USER ;

	GRANT INSERT ON "ACCESS_ERRORMART" TO DVB_USER ;

	GRANT UPDATE ON "ACCESS_ERRORMART" TO DVB_USER ;

	GRANT EXECUTE ON "ACCESS_ERRORMART" TO DVB_USER ;

	GRANT REFERENCES ON "ACCESS_ERRORMART" TO DVB_USER ;

	GRANT ALTER ON "ACCESS_ERRORMART" TO DVB_OPERATIONS ;

	GRANT SELECT ON "ACCESS_ERRORMART" TO DVB_OPERATIONS ;

	GRANT DELETE ON "ACCESS_ERRORMART" TO DVB_OPERATIONS ;

	GRANT INSERT ON "ACCESS_ERRORMART" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "ACCESS_ERRORMART" TO DVB_OPERATIONS ;

	GRANT EXECUTE ON "ACCESS_ERRORMART" TO DVB_OPERATIONS ;

	GRANT REFERENCES ON "ACCESS_ERRORMART" TO DVB_OPERATIONS ;

	GRANT ALTER ON "ACCESS_ERRORMART" TO DVB_ADMIN ;

	GRANT SELECT ON "ACCESS_ERRORMART" TO DVB_ADMIN ;

	GRANT DELETE ON "ACCESS_ERRORMART" TO DVB_ADMIN ;

	GRANT INSERT ON "ACCESS_ERRORMART" TO DVB_ADMIN ;

	GRANT UPDATE ON "ACCESS_ERRORMART" TO DVB_ADMIN ;

	GRANT EXECUTE ON "ACCESS_ERRORMART" TO DVB_ADMIN ;

	GRANT REFERENCES ON "ACCESS_ERRORMART" TO DVB_ADMIN ;

	GRANT ALTER ON "ACCESS_ERRORMART" TO DBADMIN ;

	GRANT SELECT ON "ACCESS_ERRORMART" TO DBADMIN ;

	GRANT DELETE ON "ACCESS_ERRORMART" TO DBADMIN ;

	GRANT INSERT ON "ACCESS_ERRORMART" TO DBADMIN ;

	GRANT UPDATE ON "ACCESS_ERRORMART" TO DBADMIN ;

	GRANT EXECUTE ON "ACCESS_ERRORMART" TO DBADMIN ;

	GRANT REFERENCES ON "ACCESS_ERRORMART" TO DBADMIN ;

	GRANT ALTER ON "ACCESS_ERRORMART" TO PGAGENT ;

	GRANT SELECT ON "ACCESS_ERRORMART" TO PGAGENT ;

	GRANT DELETE ON "ACCESS_ERRORMART" TO PGAGENT ;

	GRANT INSERT ON "ACCESS_ERRORMART" TO PGAGENT ;

	GRANT UPDATE ON "ACCESS_ERRORMART" TO PGAGENT ;

	GRANT EXECUTE ON "ACCESS_ERRORMART" TO PGAGENT ;

	GRANT REFERENCES ON "ACCESS_ERRORMART" TO PGAGENT ;

	GRANT SELECT ON "ACCESS_ERRORMART" TO DVB_USER_READONLY ;

	GRANT ALTER ON "ACCESSLAYER" TO DVB_USER ;

	GRANT SELECT ON "ACCESSLAYER" TO DVB_USER ;

	GRANT DELETE ON "ACCESSLAYER" TO DVB_USER ;

	GRANT INSERT ON "ACCESSLAYER" TO DVB_USER ;

	GRANT UPDATE ON "ACCESSLAYER" TO DVB_USER ;

	GRANT EXECUTE ON "ACCESSLAYER" TO DVB_USER ;

	GRANT REFERENCES ON "ACCESSLAYER" TO DVB_USER ;

	GRANT ALTER ON "ACCESSLAYER" TO DVB_OPERATIONS ;

	GRANT SELECT ON "ACCESSLAYER" TO DVB_OPERATIONS ;

	GRANT DELETE ON "ACCESSLAYER" TO DVB_OPERATIONS ;

	GRANT INSERT ON "ACCESSLAYER" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "ACCESSLAYER" TO DVB_OPERATIONS ;

	GRANT EXECUTE ON "ACCESSLAYER" TO DVB_OPERATIONS ;

	GRANT REFERENCES ON "ACCESSLAYER" TO DVB_OPERATIONS ;

	GRANT ALTER ON "ACCESSLAYER" TO DVB_ADMIN ;

	GRANT SELECT ON "ACCESSLAYER" TO DVB_ADMIN ;

	GRANT DELETE ON "ACCESSLAYER" TO DVB_ADMIN ;

	GRANT INSERT ON "ACCESSLAYER" TO DVB_ADMIN ;

	GRANT UPDATE ON "ACCESSLAYER" TO DVB_ADMIN ;

	GRANT EXECUTE ON "ACCESSLAYER" TO DVB_ADMIN ;

	GRANT REFERENCES ON "ACCESSLAYER" TO DVB_ADMIN ;

	GRANT ALTER ON "ACCESSLAYER" TO DBADMIN ;

	GRANT SELECT ON "ACCESSLAYER" TO DBADMIN ;

	GRANT DELETE ON "ACCESSLAYER" TO DBADMIN ;

	GRANT INSERT ON "ACCESSLAYER" TO DBADMIN ;

	GRANT UPDATE ON "ACCESSLAYER" TO DBADMIN ;

	GRANT EXECUTE ON "ACCESSLAYER" TO DBADMIN ;

	GRANT REFERENCES ON "ACCESSLAYER" TO DBADMIN ;

	GRANT ALTER ON "ACCESSLAYER" TO PGAGENT ;

	GRANT SELECT ON "ACCESSLAYER" TO PGAGENT ;

	GRANT DELETE ON "ACCESSLAYER" TO PGAGENT ;

	GRANT INSERT ON "ACCESSLAYER" TO PGAGENT ;

	GRANT UPDATE ON "ACCESSLAYER" TO PGAGENT ;

	GRANT EXECUTE ON "ACCESSLAYER" TO PGAGENT ;

	GRANT REFERENCES ON "ACCESSLAYER" TO PGAGENT ;

	GRANT SELECT ON "ACCESSLAYER" TO DVB_USER_READONLY ;

	GRANT ALTER ON "BUSINESS_RULES" TO DVB_USER ;

	GRANT SELECT ON "BUSINESS_RULES" TO DVB_USER ;

	GRANT DELETE ON "BUSINESS_RULES" TO DVB_USER ;

	GRANT INSERT ON "BUSINESS_RULES" TO DVB_USER ;

	GRANT UPDATE ON "BUSINESS_RULES" TO DVB_USER ;

	GRANT EXECUTE ON "BUSINESS_RULES" TO DVB_USER ;

	GRANT REFERENCES ON "BUSINESS_RULES" TO DVB_USER ;

	GRANT ALTER ON "BUSINESS_RULES" TO DVB_OPERATIONS ;

	GRANT SELECT ON "BUSINESS_RULES" TO DVB_OPERATIONS ;

	GRANT DELETE ON "BUSINESS_RULES" TO DVB_OPERATIONS ;

	GRANT INSERT ON "BUSINESS_RULES" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "BUSINESS_RULES" TO DVB_OPERATIONS ;

	GRANT EXECUTE ON "BUSINESS_RULES" TO DVB_OPERATIONS ;

	GRANT REFERENCES ON "BUSINESS_RULES" TO DVB_OPERATIONS ;

	GRANT ALTER ON "BUSINESS_RULES" TO DVB_ADMIN ;

	GRANT SELECT ON "BUSINESS_RULES" TO DVB_ADMIN ;

	GRANT DELETE ON "BUSINESS_RULES" TO DVB_ADMIN ;

	GRANT INSERT ON "BUSINESS_RULES" TO DVB_ADMIN ;

	GRANT UPDATE ON "BUSINESS_RULES" TO DVB_ADMIN ;

	GRANT EXECUTE ON "BUSINESS_RULES" TO DVB_ADMIN ;

	GRANT REFERENCES ON "BUSINESS_RULES" TO DVB_ADMIN ;

	GRANT ALTER ON "BUSINESS_RULES" TO DBADMIN ;

	GRANT SELECT ON "BUSINESS_RULES" TO DBADMIN ;

	GRANT DELETE ON "BUSINESS_RULES" TO DBADMIN ;

	GRANT INSERT ON "BUSINESS_RULES" TO DBADMIN ;

	GRANT UPDATE ON "BUSINESS_RULES" TO DBADMIN ;

	GRANT EXECUTE ON "BUSINESS_RULES" TO DBADMIN ;

	GRANT REFERENCES ON "BUSINESS_RULES" TO DBADMIN ;

	GRANT ALTER ON "BUSINESS_RULES" TO PGAGENT ;

	GRANT SELECT ON "BUSINESS_RULES" TO PGAGENT ;

	GRANT DELETE ON "BUSINESS_RULES" TO PGAGENT ;

	GRANT INSERT ON "BUSINESS_RULES" TO PGAGENT ;

	GRANT UPDATE ON "BUSINESS_RULES" TO PGAGENT ;

	GRANT EXECUTE ON "BUSINESS_RULES" TO PGAGENT ;

	GRANT REFERENCES ON "BUSINESS_RULES" TO PGAGENT ;

	GRANT SELECT ON "BUSINESS_RULES" TO DVB_USER_READONLY ;

	GRANT ALTER ON "BUSINESSOBJECTS" TO DVB_USER ;

	GRANT SELECT ON "BUSINESSOBJECTS" TO DVB_USER ;

	GRANT DELETE ON "BUSINESSOBJECTS" TO DVB_USER ;

	GRANT INSERT ON "BUSINESSOBJECTS" TO DVB_USER ;

	GRANT UPDATE ON "BUSINESSOBJECTS" TO DVB_USER ;

	GRANT EXECUTE ON "BUSINESSOBJECTS" TO DVB_USER ;

	GRANT REFERENCES ON "BUSINESSOBJECTS" TO DVB_USER ;

	GRANT ALTER ON "BUSINESSOBJECTS" TO DVB_OPERATIONS ;

	GRANT SELECT ON "BUSINESSOBJECTS" TO DVB_OPERATIONS ;

	GRANT DELETE ON "BUSINESSOBJECTS" TO DVB_OPERATIONS ;

	GRANT INSERT ON "BUSINESSOBJECTS" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "BUSINESSOBJECTS" TO DVB_OPERATIONS ;

	GRANT EXECUTE ON "BUSINESSOBJECTS" TO DVB_OPERATIONS ;

	GRANT REFERENCES ON "BUSINESSOBJECTS" TO DVB_OPERATIONS ;

	GRANT ALTER ON "BUSINESSOBJECTS" TO DVB_ADMIN ;

	GRANT SELECT ON "BUSINESSOBJECTS" TO DVB_ADMIN ;

	GRANT DELETE ON "BUSINESSOBJECTS" TO DVB_ADMIN ;

	GRANT INSERT ON "BUSINESSOBJECTS" TO DVB_ADMIN ;

	GRANT UPDATE ON "BUSINESSOBJECTS" TO DVB_ADMIN ;

	GRANT EXECUTE ON "BUSINESSOBJECTS" TO DVB_ADMIN ;

	GRANT REFERENCES ON "BUSINESSOBJECTS" TO DVB_ADMIN ;

	GRANT ALTER ON "BUSINESSOBJECTS" TO DBADMIN ;

	GRANT SELECT ON "BUSINESSOBJECTS" TO DBADMIN ;

	GRANT DELETE ON "BUSINESSOBJECTS" TO DBADMIN ;

	GRANT INSERT ON "BUSINESSOBJECTS" TO DBADMIN ;

	GRANT UPDATE ON "BUSINESSOBJECTS" TO DBADMIN ;

	GRANT EXECUTE ON "BUSINESSOBJECTS" TO DBADMIN ;

	GRANT REFERENCES ON "BUSINESSOBJECTS" TO DBADMIN ;

	GRANT ALTER ON "BUSINESSOBJECTS" TO PGAGENT ;

	GRANT SELECT ON "BUSINESSOBJECTS" TO PGAGENT ;

	GRANT DELETE ON "BUSINESSOBJECTS" TO PGAGENT ;

	GRANT INSERT ON "BUSINESSOBJECTS" TO PGAGENT ;

	GRANT UPDATE ON "BUSINESSOBJECTS" TO PGAGENT ;

	GRANT EXECUTE ON "BUSINESSOBJECTS" TO PGAGENT ;

	GRANT REFERENCES ON "BUSINESSOBJECTS" TO PGAGENT ;

	GRANT SELECT ON "BUSINESSOBJECTS" TO DVB_USER_READONLY ;

	GRANT ALTER ON "DATAVAULT" TO DVB_USER ;

	GRANT SELECT ON "DATAVAULT" TO DVB_USER ;

	GRANT DELETE ON "DATAVAULT" TO DVB_USER ;

	GRANT INSERT ON "DATAVAULT" TO DVB_USER ;

	GRANT UPDATE ON "DATAVAULT" TO DVB_USER ;

	GRANT EXECUTE ON "DATAVAULT" TO DVB_USER ;

	GRANT REFERENCES ON "DATAVAULT" TO DVB_USER ;

	GRANT ALTER ON "DATAVAULT" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DATAVAULT" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DATAVAULT" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DATAVAULT" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DATAVAULT" TO DVB_OPERATIONS ;

	GRANT EXECUTE ON "DATAVAULT" TO DVB_OPERATIONS ;

	GRANT REFERENCES ON "DATAVAULT" TO DVB_OPERATIONS ;

	GRANT ALTER ON "DATAVAULT" TO DVB_ADMIN ;

	GRANT SELECT ON "DATAVAULT" TO DVB_ADMIN ;

	GRANT DELETE ON "DATAVAULT" TO DVB_ADMIN ;

	GRANT INSERT ON "DATAVAULT" TO DVB_ADMIN ;

	GRANT UPDATE ON "DATAVAULT" TO DVB_ADMIN ;

	GRANT EXECUTE ON "DATAVAULT" TO DVB_ADMIN ;

	GRANT REFERENCES ON "DATAVAULT" TO DVB_ADMIN ;

	GRANT ALTER ON "DATAVAULT" TO DBADMIN ;

	GRANT SELECT ON "DATAVAULT" TO DBADMIN ;

	GRANT DELETE ON "DATAVAULT" TO DBADMIN ;

	GRANT INSERT ON "DATAVAULT" TO DBADMIN ;

	GRANT UPDATE ON "DATAVAULT" TO DBADMIN ;

	GRANT EXECUTE ON "DATAVAULT" TO DBADMIN ;

	GRANT REFERENCES ON "DATAVAULT" TO DBADMIN ;

	GRANT ALTER ON "DATAVAULT" TO PGAGENT ;

	GRANT SELECT ON "DATAVAULT" TO PGAGENT ;

	GRANT DELETE ON "DATAVAULT" TO PGAGENT ;

	GRANT INSERT ON "DATAVAULT" TO PGAGENT ;

	GRANT UPDATE ON "DATAVAULT" TO PGAGENT ;

	GRANT EXECUTE ON "DATAVAULT" TO PGAGENT ;

	GRANT REFERENCES ON "DATAVAULT" TO PGAGENT ;

	GRANT SELECT ON "DATAVAULT" TO DVB_USER_READONLY ;

	GRANT ALTER ON "DATAVAULT_STAGING" TO DVB_USER ;

	GRANT SELECT ON "DATAVAULT_STAGING" TO DVB_USER ;

	GRANT DELETE ON "DATAVAULT_STAGING" TO DVB_USER ;

	GRANT INSERT ON "DATAVAULT_STAGING" TO DVB_USER ;

	GRANT UPDATE ON "DATAVAULT_STAGING" TO DVB_USER ;

	GRANT EXECUTE ON "DATAVAULT_STAGING" TO DVB_USER ;

	GRANT REFERENCES ON "DATAVAULT_STAGING" TO DVB_USER ;

	GRANT ALTER ON "DATAVAULT_STAGING" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DATAVAULT_STAGING" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DATAVAULT_STAGING" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DATAVAULT_STAGING" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DATAVAULT_STAGING" TO DVB_OPERATIONS ;

	GRANT EXECUTE ON "DATAVAULT_STAGING" TO DVB_OPERATIONS ;

	GRANT REFERENCES ON "DATAVAULT_STAGING" TO DVB_OPERATIONS ;

	GRANT ALTER ON "DATAVAULT_STAGING" TO DVB_ADMIN ;

	GRANT SELECT ON "DATAVAULT_STAGING" TO DVB_ADMIN ;

	GRANT DELETE ON "DATAVAULT_STAGING" TO DVB_ADMIN ;

	GRANT INSERT ON "DATAVAULT_STAGING" TO DVB_ADMIN ;

	GRANT UPDATE ON "DATAVAULT_STAGING" TO DVB_ADMIN ;

	GRANT EXECUTE ON "DATAVAULT_STAGING" TO DVB_ADMIN ;

	GRANT REFERENCES ON "DATAVAULT_STAGING" TO DVB_ADMIN ;

	GRANT ALTER ON "DATAVAULT_STAGING" TO DBADMIN ;

	GRANT SELECT ON "DATAVAULT_STAGING" TO DBADMIN ;

	GRANT DELETE ON "DATAVAULT_STAGING" TO DBADMIN ;

	GRANT INSERT ON "DATAVAULT_STAGING" TO DBADMIN ;

	GRANT UPDATE ON "DATAVAULT_STAGING" TO DBADMIN ;

	GRANT EXECUTE ON "DATAVAULT_STAGING" TO DBADMIN ;

	GRANT REFERENCES ON "DATAVAULT_STAGING" TO DBADMIN ;

	GRANT ALTER ON "DATAVAULT_STAGING" TO PGAGENT ;

	GRANT SELECT ON "DATAVAULT_STAGING" TO PGAGENT ;

	GRANT DELETE ON "DATAVAULT_STAGING" TO PGAGENT ;

	GRANT INSERT ON "DATAVAULT_STAGING" TO PGAGENT ;

	GRANT UPDATE ON "DATAVAULT_STAGING" TO PGAGENT ;

	GRANT EXECUTE ON "DATAVAULT_STAGING" TO PGAGENT ;

	GRANT REFERENCES ON "DATAVAULT_STAGING" TO PGAGENT ;

	GRANT SELECT ON "DATAVAULT_STAGING" TO DVB_USER_READONLY ;

	GRANT ALTER ON "STAGING" TO DVB_USER ;

	GRANT SELECT ON "STAGING" TO DVB_USER ;

	GRANT DELETE ON "STAGING" TO DVB_USER ;

	GRANT INSERT ON "STAGING" TO DVB_USER ;

	GRANT UPDATE ON "STAGING" TO DVB_USER ;

	GRANT EXECUTE ON "STAGING" TO DVB_USER ;

	GRANT REFERENCES ON "STAGING" TO DVB_USER ;

	GRANT ALTER ON "STAGING" TO DVB_ADMIN ;

	GRANT SELECT ON "STAGING" TO DVB_ADMIN ;

	GRANT DELETE ON "STAGING" TO DVB_ADMIN ;

	GRANT INSERT ON "STAGING" TO DVB_ADMIN ;

	GRANT UPDATE ON "STAGING" TO DVB_ADMIN ;

	GRANT EXECUTE ON "STAGING" TO DVB_ADMIN ;

	GRANT REFERENCES ON "STAGING" TO DVB_ADMIN ;

	GRANT ALTER ON "STAGING" TO DVB_OPERATIONS ;

	GRANT SELECT ON "STAGING" TO DVB_OPERATIONS ;

	GRANT DELETE ON "STAGING" TO DVB_OPERATIONS ;

	GRANT INSERT ON "STAGING" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "STAGING" TO DVB_OPERATIONS ;

	GRANT EXECUTE ON "STAGING" TO DVB_OPERATIONS ;

	GRANT REFERENCES ON "STAGING" TO DVB_OPERATIONS ;

	GRANT ALTER ON "STAGING" TO DBADMIN ;

	GRANT SELECT ON "STAGING" TO DBADMIN ;

	GRANT DELETE ON "STAGING" TO DBADMIN ;

	GRANT INSERT ON "STAGING" TO DBADMIN ;

	GRANT UPDATE ON "STAGING" TO DBADMIN ;

	GRANT EXECUTE ON "STAGING" TO DBADMIN ;

	GRANT REFERENCES ON "STAGING" TO DBADMIN ;

	GRANT ALTER ON "STAGING" TO PGAGENT ;

	GRANT SELECT ON "STAGING" TO PGAGENT ;

	GRANT DELETE ON "STAGING" TO PGAGENT ;

	GRANT INSERT ON "STAGING" TO PGAGENT ;

	GRANT UPDATE ON "STAGING" TO PGAGENT ;

	GRANT EXECUTE ON "STAGING" TO PGAGENT ;

	GRANT REFERENCES ON "STAGING" TO PGAGENT ;

	GRANT SELECT ON "STAGING" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."CONFIG" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."CONFIG" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."CONFIG" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."CONFIG" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."CONFIG" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."CONFIG" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_USER ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_USER ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_DATA" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_DATA" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_DATA" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_DATA" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_DATA" TO PGAGENT ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_DATA" TO PGAGENT ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_DATA" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_DATA" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_DATA" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_USER ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_USER ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_COLORS" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_COLORS" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_COLORS" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_COLORS" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_COLORS" TO PGAGENT ;

	GRANT DELETE ON "DVB_CONFIG"."SYSTEM_COLORS" TO PGAGENT ;

	GRANT INSERT ON "DVB_CONFIG"."SYSTEM_COLORS" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CONFIG"."SYSTEM_COLORS" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."SYSTEM_COLORS" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."AUTH_USERS" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."AUTH_USERS" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."AUTH_USERS" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."AUTH_USERS" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."AUTH_USERS" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."AUTH_USERS" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_DATA" TO DVB_USER ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_DATA" TO DVB_USER ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_DATA" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_DATA" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_DATA" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_DATA" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_DATA" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_DATA" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_DATA" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_DATA" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_DATA" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_DATA" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_DATA" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_DATA" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_DATA" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_DATA" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_DATA" TO PGAGENT ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_DATA" TO PGAGENT ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_DATA" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_DATA" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_DATA" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_LOADS" TO DVB_USER ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_LOADS" TO DVB_USER ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_LOADS" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_LOADS" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_LOADS" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_LOADS" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_LOADS" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_LOADS" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_LOADS" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_LOADS" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_LOADS" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_LOADS" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_LOADS" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_LOADS" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_LOADS" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_LOADS" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_LOADS" TO PGAGENT ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_LOADS" TO PGAGENT ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_LOADS" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_LOADS" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_LOADS" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_USER ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_USER ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SCHEDULES" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SCHEDULES" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SCHEDULES" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SCHEDULES" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SCHEDULES" TO PGAGENT ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SCHEDULES" TO PGAGENT ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SCHEDULES" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SCHEDULES" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SCHEDULES" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_USER ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_USER ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO PGAGENT ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO PGAGENT ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_SQL_QUERIES" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_USER ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_USER ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_TRIGGERS" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_TRIGGERS" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_TRIGGERS" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_TRIGGERS" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_TRIGGERS" TO PGAGENT ;

	GRANT DELETE ON "DVB_CONFIG"."JOB_TRIGGERS" TO PGAGENT ;

	GRANT INSERT ON "DVB_CONFIG"."JOB_TRIGGERS" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CONFIG"."JOB_TRIGGERS" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."JOB_TRIGGERS" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_USER ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_USER ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO PGAGENT ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO PGAGENT ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_USER_READONLY ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_USER_READONLY ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_USER_READONLY ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_DOCUMENTATION" TO DVB_USER_READONLY ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_USER ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_USER ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_USER ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_USER ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_OPERATIONS ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_OPERATIONS ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_OPERATIONS ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_OPERATIONS ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_ADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_ADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_ADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_ADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DBADMIN ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DBADMIN ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DBADMIN ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DBADMIN ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO PGAGENT ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO PGAGENT ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO PGAGENT ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO PGAGENT ;

	GRANT SELECT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_USER_READONLY ;

	GRANT DELETE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_USER_READONLY ;

	GRANT INSERT ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_USER_READONLY ;

	GRANT UPDATE ON "DVB_CONFIG"."_DVB_RUNTIME_BOOKMARK" TO DVB_USER_READONLY ;

	-- No connection privileges found. 



COMMIT;

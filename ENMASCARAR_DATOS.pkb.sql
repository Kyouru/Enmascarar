

CREATE OR REPLACE PACKAGE BODY SISGODBA.PKG_ENMASCARAR_DATOS IS

PROCEDURE P_ENMASCARAR_DATOS (ENMASCARARTABLAS          IN      BOOLEAN,
                              LIMPIARTABLAS             IN      BOOLEAN,
                              EJECUTARQUERY             IN      BOOLEAN) IS
    CURSOR c_whitetabla IS
    SELECT DISTINCT atc.owner, atc.table_name
    FROM (SELECT owner, table_name FROM SISGODBA.ENMASCARARMANTTABLAS WHERE activo = 'Y') emt
    RIGHT JOIN ALL_TAB_COLS atc
    ON emt.owner = atc.owner AND emt.table_name = atc.table_name
    WHERE emt.table_name IS NULL AND (atc.owner = 'SISGODBA' --OR atc.owner = 'AGVIRTUAL'
        )
        AND (atc.table_name != 'ENMASCARARLOG' AND atc.owner != 'SISGODBA')
        AND (atc.table_name != 'ENMASCARARMANTTABLAS' AND atc.owner != 'SISGODBA')
        AND (atc.table_name != 'ENMASCARARDATOS' AND atc.owner != 'SISGODBA')
    ORDER BY atc.owner, atc.table_name;

    v_owner                     SISGODBA.ENMASCARARMANTTABLAS.owner%TYPE;
    v_table_name                SISGODBA.ENMASCARARMANTTABLAS.table_name%TYPE;

    CURSOR c_maskcol IS
    SELECT ed.owner, ed.table_name, ed.column_name, ed.tipo, ed.activo
    FROM SISGODBA.ENMASCARARDATOS ed
    WHERE activo = 'Y' ORDER BY ed.prioridad, ed.owner, ed.table_name;

    v2_owner                    SISGODBA.ENMASCARARDATOS.owner%TYPE;
    v2_table_name               SISGODBA.ENMASCARARDATOS.table_name%TYPE;
    v2_column_name              SISGODBA.ENMASCARARDATOS.column_name%TYPE;
    v2_tipo                     SISGODBA.ENMASCARARDATOS.tipo%TYPE;
    v2_activo                   SISGODBA.ENMASCARARDATOS.activo%TYPE;

    nomBD               VARCHAR2(100);
    strSQL              VARCHAR2(30000);
    anterior            VARCHAR2(200);
    anteriordate        DATE;
    resultado           BOOLEAN := FALSE;

    --O_NOMBRE            VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
    --N_NOMBRE            VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';
--
--    --O_TEXTO            VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
--    --N_TEXTO            VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';
--    --
--    --O_APELLIDO          VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
--    --N_APELLIDO          VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';
--
--    --O_DIRECCION         VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
--    --N_DIRECCION         VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';
--    --
--    --O_CORREO            VARCHAR2 (40) := 'aeiouAEIOUSsNnCcPp';
    --N_CORREO            VARCHAR2 (40) := 'xxxxxxxxxxxxxxxxxx';

    --O_NUMERO VARCHAR2 (40) := '0123456789';
    --N_NUMERO VARCHAR2 (40) := '7030517942';
    
BEGIN
    SELECT GLOBAL_NAME INTO nomBD FROM GLOBAL_NAME;
    IF nomBD = 'DESA' THEN
        --PADRONFECHA
        BEGIN
            EXECUTE IMMEDIATE ('ALTER TRIGGER SISGODBA.CRE06085 DISABLE');
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        --PERSONANATURAL
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER SISGODBA.GEN01200 DISABLE';
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        --DIRECCION
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER SISGODBA.GEN01220 DISABLE';
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        --PERSONANUMEROTELEFONO
        BEGIN
            EXECUTE IMMEDIATE 'DROP INDEX XPKPERSONANUMEROTELEFONO';
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        COMMIT;

        --strSQL := '';

        IF ENMASCARARTABLAS THEN
            OPEN c_maskcol;
            LOOP
                FETCH c_maskcol INTO v2_owner, v2_table_name, v2_column_name, v2_tipo, v2_activo;
                EXIT WHEN c_maskcol%NOTFOUND;
                IF (anterior != v2_table_name) OR anterior IS NULL THEN
                    IF strSQL IS NOT NULL THEN
                        DBMS_OUTPUT.PUT_LINE(strSQL);
                        BEGIN
                            IF EJECUTARQUERY THEN
                                EXECUTE IMMEDIATE strSQL;
                                COMMIT;
                            END IF;
                            resultado := TRUE;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                                resultado := FALSE;
                        END;
                        IF resultado OR SQLCODE = 0 THEN
                            EXECUTE IMMEDIATE 'INSERT INTO SISGODBA.ENMASCARARLOG VALUES (''CORRECTO'', ''ENMASCARAR'', '''|| v2_owner ||''', '''|| anterior ||''', NULL, NULL, ''' || REPLACE(TRIM(LPAD(strSQL, 2900)),'''','''''') ||''', '''|| TO_CHAR(anteriordate, 'YYYY-MM-DD HH24:MI:SS') || ''', '''|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ''')';
                            resultado := FALSE;
                        ELSE
                            EXECUTE IMMEDIATE 'INSERT INTO SISGODBA.ENMASCARARLOG VALUES (''ERRADO'', ''ENMASCARAR'', '''|| v2_owner ||''', '''|| anterior ||''', '''|| SQLCODE ||''', '''|| SQLERRM ||''', ''' || REPLACE(TRIM(LPAD(strSQL, 2900)),'''','''''') ||''', ''' || TO_CHAR(anteriordate, 'YYYY-MM-DD HH24:MI:SS') || ''', '''|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ''')';
                        END IF;
                        COMMIT;
                    END IF;
                    CASE
                        WHEN v2_tipo = 'NOMBRE' THEN
                            --strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_NOMBRE || ''', ''' || N_NOMBRE || ''')';
                            strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || '= ''XXXXX''';
                        WHEN v2_tipo = 'APELLIDO' THEN
                            --strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_APELLIDO || ''', ''' || N_APELLIDO || ''')';
                            strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || '= ''XXXXX''';
                        WHEN v2_tipo = 'DIRECCION' THEN
                            --strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_DIRECCION || ''', ''' || N_DIRECCION || ''')';
                            strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || '= ''XXXXX''';
                        WHEN v2_tipo = 'CORREO' THEN
                            --strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_CORREO || ''', ''' || N_CORREO || ''')';
                            strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || '= ''XXXXX''';
                        WHEN v2_tipo = 'NUMERO' THEN
                            --strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_NUMERO || ''', ''' || N_NUMERO || ''')';
                            strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = SUBSTR(' || v2_column_name || ',3,1)||SUBSTR(' || v2_column_name || ',6,1)||SUBSTR(' || v2_column_name || ',2,1)||SUBSTR(' || v2_column_name || ',1,1)||SUBSTR(' || v2_column_name || ',5,1)||SUBSTR(' || v2_column_name || ',8,1)||SUBSTR(' || v2_column_name || ',7,1)||SUBSTR(' || v2_column_name || ',4,1)||SUBSTR(' || v2_column_name || ',9,3)';
                    END CASE;
                ELSE
                    CASE v2_tipo
                        WHEN 'NOMBRE' THEN
                            strSQL := strSQL || ', ' || v2_column_name || ' = ''XXXXX''';
                        WHEN 'APELLIDO' THEN
                            strSQL := strSQL || ', ' || v2_column_name || ' = ''XXXXX''';
                        WHEN 'DIRECCION' THEN
                            strSQL := strSQL || ', ' || v2_column_name || ' = ''XXXXX''';
                        WHEN 'CORREO' THEN
                            strSQL := strSQL || ', ' || v2_column_name || ' = ''XXXXX''';
                        WHEN 'NUMERO' THEN
                            --strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_NUMERO || ''', ''' || N_NUMERO || ''')';
                            strSQL := strSQL || ', ' || v2_column_name || ' = SUBSTR(' || v2_column_name || ',3,1)||SUBSTR(' || v2_column_name || ',6,1)||SUBSTR(' || v2_column_name || ',2,1)||SUBSTR(' || v2_column_name || ',1,1)||SUBSTR(' || v2_column_name || ',5,1)||SUBSTR(' || v2_column_name || ',8,1)||SUBSTR(' || v2_column_name || ',7,1)||SUBSTR(' || v2_column_name || ',4,1)||SUBSTR(' || v2_column_name || ',9,3)';
                    END CASE;
                END IF;
                anterior := v2_table_name;
                anteriordate := SYSDATE;
            END LOOP;

            IF strSQL IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE(strSQL);
                BEGIN
                    IF EJECUTARQUERY THEN
                        EXECUTE IMMEDIATE strSQL;
                        COMMIT;
                    END IF;
                    COMMIT;
                    resultado := TRUE;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        resultado := FALSE;
                END;
                IF resultado OR SQLCODE = 0 THEN
                    EXECUTE IMMEDIATE 'INSERT INTO SISGODBA.ENMASCARARLOG VALUES (''CORRECTO'', ''ENMASCARAR'', '''|| v2_owner ||''', '''|| anterior ||''', NULL, NULL, ''' || REPLACE(TRIM(LPAD(strSQL, 2900)),'''','''''') ||''', ''' || TO_CHAR(anteriordate, 'YYYY-MM-DD HH24:MI:SS') || ''', '''|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ''')';
                    resultado := FALSE;
                ELSE
                    EXECUTE IMMEDIATE 'INSERT INTO SISGODBA.ENMASCARARLOG VALUES (''ERRADO'', ''ENMASCARAR'', '''|| v2_owner ||''', '''|| anterior ||''', '''|| SQLCODE ||''', '''|| SQLERRM ||''', ''' || REPLACE(TRIM(LPAD(strSQL, 2900)),'''','''''') ||''', ''' || TO_CHAR(anteriordate, 'YYYY-MM-DD HH24:MI:SS') || ''', '''|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ''')';
                END IF;
            END IF;
            COMMIT;
        END IF;

        IF LIMPIARTABLAS THEN
            OPEN c_whitetabla;
            LOOP
                FETCH c_whitetabla INTO v_owner, v_table_name;
                EXIT WHEN c_whitetabla%NOTFOUND;
                strSQL := 'TRUNCATE TABLE ' || v_owner || '.' || v_table_name;
                DBMS_OUTPUT.PUT_LINE(strSQL);
                BEGIN
                    anteriordate := SYSDATE;
                    IF EJECUTARQUERY THEN
                        EXECUTE IMMEDIATE strSQL;
                        COMMIT;
                    END IF;
                    resultado := TRUE;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        resultado := FALSE;
                END;
                IF resultado OR SQLCODE = 0 THEN
                    EXECUTE IMMEDIATE 'INSERT INTO SISGODBA.ENMASCARARLOG VALUES (''CORRECTO'', ''LIMPIAR'', '''|| v_owner ||''', '''|| v_table_name ||''', NULL, NULL, ''DELETE ' || v_owner || '.' || v_table_name ||''', ''' || TO_CHAR(anteriordate, 'YYYY-MM-DD HH24:MI:SS') || ''', '''|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ''')';
                    resultado := FALSE;
                ELSE
                    EXECUTE IMMEDIATE 'INSERT INTO SISGODBA.ENMASCARARLOG VALUES (''ERRADO'', ''LIMPIAR'', '''|| v_owner ||''', '''|| v_table_name ||''', '''|| SQLCODE ||''', '''|| SQLERRM ||''', ''DELETE ' || v_owner || '.' || v_table_name ||''', ''' || TO_CHAR(anteriordate, 'YYYY-MM-DD HH24:MI:SS') || ''', '''|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ''')';
                END IF;
                COMMIT;
            END LOOP;
        END IF;

        --PADRONFECHA
        BEGIN
            EXECUTE IMMEDIATE ('ALTER TRIGGER SISGODBA.CRE06085 ENABLE');
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;
        
        --PERSONANATURAL
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER SISGODBA.GEN01200 ENABLE';
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        --DIRECCION
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TRIGGER SISGODBA.GEN01220 ENABLE';
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        ----PERSONANUMEROTELEFONO
        --BEGIN
        --    EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX SISGODBA.XPKPERSONANUMEROTELEFONO ON SISGODBA.PERSONANUMEROTELEFONO (CODIGOPERSONA, NUMEROTELEFONO)    NOLOGGING    TABLESPACE SISGO_INDICES    PCTFREE    10    INITRANS   2    MAXTRANS   255    STORAGE    (                INITIAL          896K                NEXT             1M                MAXSIZE          UNLIMITED                MINEXTENTS       1                MAXEXTENTS       UNLIMITED                PCTINCREASE      0                BUFFER_POOL      DEFAULT               )';
        --EXCEPTION
        --    WHEN OTHERS
        --    THEN
        --        NULL;
        --END;

        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No es GLOBAL_NAME=DESA');
    END IF;
END;
END PKG_ENMASCARAR_DATOS;
/

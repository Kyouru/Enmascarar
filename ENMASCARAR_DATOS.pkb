CREATE OR REPLACE PACKAGE BODY SISGODBA.PKG_ENMASCARAR_DATOS IS

PROCEDURE P_ENMASCARAR_DATOS (NOMBREBDENMASCARAR    IN      VARCHAR2,   --DESA
                              LIMPIARTABLAS         IN      BOOLEAN)
    CURSOR c_whitetabla IS
    SELECT  owner, table_name, activo
    FROM SISGODBA.MANTENER_TABLAS lt
    INNER JOIN ALL_TAB_COLS atc
    ON lt.owner = atc.owner AND lt.table_name = atc.table_name
    WHERE lt.table_name IS NULL AND activo = 'Y';

    v_owner                 SISGODBA.MANTENER_TABLAS.owner%TYPE;
    v_table_name                SISGODBA.MANTENER_TABLAS.table_name%TYPE;
    v_activo                   SISGODBA.MANTENER_TABLAS.activo%TYPE;

    CURSOR c_maskcol IS
    SELECT owner, table_name, column_name, tipo, activo
    FROM SISGODBA.ENMASCARAR_DATOS lt
    WHERE activo = 'Y' ORDER BY owner, table_name;

    v2_owner                 SISGODBA.ENMASCARAR_DATOS.owner%TYPE;
    v2_table_name                SISGODBA.ENMASCARAR_DATOS.table_name%TYPE;
    v2_column_name                   SISGODBA.ENMASCARAR_DATOS.column_name%TYPE;
    v2_tipo                   SISGODBA.ENMASCARAR_DATOS.tipo%TYPE;
    v2_activo                   SISGODBA.ENMASCARAR_DATOS.activo%TYPE;

    nomBD          VARCHAR2(100);
    strSQL          VARCHAR2(5000);
    anterior          VARCHAR2(200);

    O_NOMBRE VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
    N_NOMBRE VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';
    
    O_APELLIDO VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
    N_APELLIDO VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';

    O_DIRECCION VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
    N_DIRECCION VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';
    
    O_CORREO VARCHAR2 (40) := 'aeiouAEIOUSsNnCcPp';
    N_CORREO VARCHAR2 (40) := 'xxxxxxxxxxxxxxxxxx';

    --O_NUMERO VARCHAR2 (40) := '0123456789';
    --N_NUMERO VARCHAR2 (40) := '7030517942';
    
BEGIN
    SELECT GLOBAL_NAME INTO nomBD FROM GLOBAL_NAME;
    IF nomBD = NOMBREBDENMASCARAR THEN
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

        --PERSONANUMEROTELEFONO
        BEGIN
            EXECUTE IMMEDIATE 'DROP INDEX XPKPERSONANUMEROTELEFONO';
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        COMMIT;

        IF LIMPIARTABLAS THEN
            OPEN c_whitetabla;
            LOOP
                FETCH v_owner, v_table_name, v_activo
                EXIT WHEN c_whitetabla%NOTFOUND;
                EXECUTE IMMEDIATE 'DELETE ' || v_table_name;
                DBMS_OUTPUT.PUT_LINE('DELETE ' || v_table_name);
            END LOOP;
        END IF;

        strSQL := '';
        OPEN c_maskcol;
        LOOP
            FETCH c_maskcol INTO v2_owner, v2_table_name, v2_column_name, v2_tipo, v2_activo;
            EXIT WHEN c_maskcol%NOTFOUND;
            IF (anterior != v2_table_name) OR anterior IS NULL THEN
                IF strSQL IS NOT NULL THEN
                    DBMS_OUTPUT.PUT_LINE(strSQL);
                    EXECUTE IMMEDIATE strSQL;
                    --COMMIT;
                END IF;
                CASE
                    WHEN v2_tipo = 'NOMBRE' THEN
                        strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_NOMBRE || ''', ''' || N_NOMBRE || ''')';
                    WHEN v2_tipo = 'APELLIDO' THEN
                        strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_APELLIDO || ''', ''' || N_APELLIDO || ''')';
                    WHEN v2_tipo = 'DIRECCION' THEN
                        strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_DIRECCION || ''', ''' || N_DIRECCION || ''')';
                    WHEN v2_tipo = 'CORREO' THEN
                        strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_CORREO || ''', ''' || N_CORREO || ''')';
                    WHEN v2_tipo = 'NUMERO' THEN
                        strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = SUBSTR(' || v2_column_name || ',3,1)||SUBSTR(' || v2_column_name || ',6,1)||SUBSTR(' || v2_column_name || ',2,1)||SUBSTR(' || v2_column_name || ',1,1)||SUBSTR(' || v2_column_name || ',5,1)||SUBSTR(' || v2_column_name || ',8,1)||SUBSTR(' || v2_column_name || ',7,1)||SUBSTR(' || v2_column_name || ',4,1)||SUBSTR(' || v2_column_name || ',9,3)';
                END CASE;
            ELSE
                CASE v2_tipo
                    WHEN 'NOMBRE' THEN
                        strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_NOMBRE || ''', ''' || N_NOMBRE || ''')';
                    WHEN 'APELLIDO' THEN
                        strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_APELLIDO || ''', ''' || N_APELLIDO || ''')';
                    WHEN 'DIRECCION' THEN
                        strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_DIRECCION || ''', ''' || N_DIRECCION || ''')';
                    WHEN 'CORREO' THEN
                        strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', ''' || O_CORREO || ''', ''' || N_CORREO || ''')';
                    WHEN 'NUMERO' THEN
                        strSQL := strSQL || ', ' || v2_column_name || ' = SUBSTR(' || v2_column_name || ',3,1)||SUBSTR(' || v2_column_name || ',6,1)||SUBSTR(' || v2_column_name || ',2,1)||SUBSTR(' || v2_column_name || ',1,1)||SUBSTR(' || v2_column_name || ',5,1)||SUBSTR(' || v2_column_name || ',8,1)||SUBSTR(' || v2_column_name || ',7,1)||SUBSTR(' || v2_column_name || ',4,1)||SUBSTR(' || v2_column_name || ',9,3)';
                END CASE;
            END IF;
            anterior := v2_table_name;
        END LOOP;

        IF strSQL != '' THEN
            DBMS_OUTPUT.PUT_LINE(strSQL);
            EXECUTE IMMEDIATE strSQL;
        END IF;

        COMMIT;
        
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
        COMMIT;

        --PERSONANUMEROTELEFONO
        BEGIN
            EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX SISGODBA.XPKPERSONANUMEROTELEFONO ON SISGODBA.PERSONANUMEROTELEFONO (CODIGOPERSONA, NUMEROTELEFONO)    NOLOGGING    TABLESPACE SISGO_INDICES    PCTFREE    10    INITRANS   2    MAXTRANS   255    STORAGE    (                INITIAL          896K                NEXT             1M                MAXSIZE          UNLIMITED                MINEXTENTS       1                MAXEXTENTS       UNLIMITED                PCTINCREASE      0                BUFFER_POOL      DEFAULT               )';
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No es GLOBAL_NAME=' || NOMBREBDENMASCARAR);
    END IF;
END;

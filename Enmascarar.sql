DECLARE
    CURSOR c_whitetabla IS
    SELECT  owner, table_name, activo
    FROM SISGODBA.MANTENER_TABLAS lt
    INNER JOIN ALL_TAB_COLS atc
    ON lt.owner = atc.owner AND lt.table_name = atc.table_name
    WHERE lt.table_name IS NULL AND activo = 1;

    v_owner                 SISGODBA.MANTENER_TABLAS.owner%TYPE;
    v_table_name                SISGODBA.MANTENER_TABLAS.table_name%TYPE;
    v_activo                   SISGODBA.MANTENER_TABLAS.activo%TYPE;

    CURSOR c_maskcol IS
    SELECT owner, table_name, column_name, tipo, activo
    FROM SISGODBA.ENMASCARAR_DATOS lt
    WHERE activo = 1;

    v2_owner                 SISGODBA.ENMASCARAR_DATOS.owner%TYPE;
    v2_table_name                SISGODBA.ENMASCARAR_DATOS.table_name%TYPE;
    v2_column_name                   SISGODBA.ENMASCARAR_DATOS.column_name%TYPE;
    v2_tipo                   SISGODBA.ENMASCARAR_DATOS.tipo%TYPE;
    v2_activo                   SISGODBA.ENMASCARAR_DATOS.activo%TYPE;

    strSQL          VARCHAR2(5000);
    anterior          VARCHAR2(200);

    O_NOMBRE VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
    N_NOMBRE VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';
    
    O_APELLIDO VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
    N_APELLIDO VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';

    O_DIRECCION VARCHAR2 (40) := 'AEIOUNKSTPMDLGCYHRaeiounkstpmdlgcyhr';
    N_DIRECCION VARCHAR2 (40) := 'XXXXXXXXXXXXXXXXXXxxxxxxxxxxxxxxxxxx';
    
    O_EMAIL VARCHAR2 (40) := 'aeiouAEIOUSsNnCcPp';
    N_EMAIL VARCHAR2 (40) := 'xxxxxxxxxxxxxxxxxx';

    O_NUMERO VARCHAR2 (40) := '0123456789';
    N_NUMERO VARCHAR2 (40) := '7030517942';
    
BEGIN
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

    OPEN c_whitetabla;
    LOOP
        FETCH v_owner, v_table_name, v_activo
        EXIT WHEN c_whitetabla%NOTFOUND;
        --EXECUTE IMMEDIATE 'DELETE ' || v_table_name;
        DBMS_OUTPUT.PUT_LINE('DELETE ' || v_table_name);
    END LOOP;

    strSQL := '';
    OPEN c_maskcol;
    LOOP
        FETCH v2_owner, v2_table_name, v2_column_name, v2_activo
        EXIT WHEN c_maskcol%NOTFOUND;
        IF anterior <> v2_table_name THEN
            --EXECUTE IMMEDIATE strSQL
            DBMS_OUTPUT.PUT_LINE(strSQL);
            CASE tipo
                WHEN 'NOMBRE' THEN
                    strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_NOMBRE, N_NOMBRE)';
                WHEN 'APELLIDO' THEN
                    strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_APELLIDO, N_APELLIDO)';
                WHEN 'DIRECCION' THEN
                    strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_DIRECCION, N_DIRECCION)';
                WHEN 'EMAIL' THEN
                    strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_EMAIL, N_EMAIL)';
                WHEN 'NUMERO' THEN
                    strSQL := 'UPDATE ' || v2_owner || '.' || v2_table_name || ' SET ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_NUMERO, N_NUMERO)';
            END CASE;
        ELSE
            CASE tipo
                WHEN 'NOMBRE' THEN
                    strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_NOMBRE, N_NOMBRE)';
                WHEN 'APELLIDO' THEN
                    strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_APELLIDO, N_APELLIDO)';
                WHEN 'DIRECCION' THEN
                    strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_DIRECCION, N_DIRECCION)';
                WHEN 'EMAIL' THEN
                    strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_EMAIL, N_EMAIL)';
                WHEN 'NUMERO' THEN
                    strSQL := strSQL || ', ' || v2_column_name || ' = TRANSLATE(' || v2_column_name || ', O_NUMERO, N_NUMERO)';
            END CASE;
        END IF;
        anterior := v2_table_name;
    END LOOP;

    IF strSQL <> '' THEN
        --EXECUTE IMMEDIATE strSQL
        DBMS_OUTPUT.PUT_LINE(strSQL);
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

END;
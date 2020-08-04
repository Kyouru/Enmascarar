CREATE OR REPLACE PACKAGE SYS.PKG_ENMASCARAR_DATOS IS
    PROCEDURE P_ENMASCARAR_DATOS (	ENMASCARARTABLAS		IN      BOOLEAN,	--Enmascara los datos
                              		LIMPIARTABLAS			IN      BOOLEAN,	--Borra los datos de las tablas que no se encuentren en la lista
                              		EJECUTARQUERY			IN      BOOLEAN);	--Para evitar que se ejecute los query y solo muestre por dbms = pruebas
END PKG_ENMASCARAR_DATOS;
/
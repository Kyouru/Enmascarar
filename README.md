--README


BEGIN
	--Se ejecuta si GLOBAL_NAME = 'DESA'
	
	SYS.PKG_ENMASCARAR_DATOS.P_ENMASCARAR_DATOS(TRUE,		--Enmascara los datos de las tablas y columnas que se encuentren en la tabla ENMASCARARDATOS
												TRUE,		--Borra los datos de las tablas que no se encuentren en la tabla ENMASCARARMANTTABLAS
												TRUE		--Para evitar que se ejecute los query y solo muestre por dbms
												);
END;

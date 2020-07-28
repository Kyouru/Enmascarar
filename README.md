--README
-

BEGIN
	--Se ejecuta si GLOBAL_NAME = 'DESA'
	
	PKG_ENMASCARAR_DATOS.P_ENMASCARAR_DATOS(TRUE,		--Borra los datos de las tablas que no se encuentren en la tabla MANTENER_TABLAS
											TRUE		--Enmascara los datos de las tablas y columnas que se encuentren en la tabla ENMASCARAR_DATOS
											);
END;

# Definicion de objetos  
  
#### ENMASCARAR_DATOS.pks.sql 	= PACKAGE  
#### ENMASCARAR_DATOS.pkb.sql 	= PACKAGE BODY  
  
#### Crear Tablas.sql 			= Crear Tablas  
- SISGODBA.ENMASCARARDATOS  
 En esta tabla se definen las columnas que se van a enmascarar, especificando tipo de enmascaramiento y prioridad (orden)  
- SISGODBA.ENMASCARARMANTTABLAS  
 En esta tabla se definen las tablas que se van a mantener, todas las tablas del schema SISGODBA que no se encuentren definidas se eliminaran los datos  
- SISGODBA.ENMASCARARLOG  
 Tabla en la que se lleva un log de los query ejecutados por el package, ya sea la ejecucion correcta o errada  
  
#### ENMASCARARDATOS.xlsx		= Datos de la Tabla SISGODBA.ENMASCARARDATOS  
#### ENMASCARARMANTTABLAS.xlsx 	= Datos de la Tabla SISGODBA.ENMASCARARMANTTABLAS  
  
### Para Llamar al package:  
  
    BEGIN  
    	SISGODBA.PKG_ENMASCARAR_DATOS.P_ENMASCARAR_DATOS(
	    	    	TRUE, --Enmascara los datos de las columnas que se encuentren en la tabla ENMASCARARDATOS
    	    	TRUE, --Borra los datos de las tablas que NO se encuentren en la tabla ENMASCARARMANTTABLAS. Solo Schema SISGODBA
    	    	TRUE  --Para ejecute los query.
    	    	);  
    END;  
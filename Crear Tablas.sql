CREATE TABLE ENMASCARAR_DATOS (
	OWNER               VARCHAR2(20)                NOT NULL,
	TABLE_NAME    		VARCHAR2(100)             	NOT NULL,
	COLUMN_NAME         VARCHAR2(100)              	NOT NULL,
	TIPO      			VARCHAR2(40)                NOT NULL,
	ACTIVO              CHAR(1)                     NOT NULL,
	OBSERVACION   		VARCHAR2(200) 				NOT NULL
	);


CREATE TABLE MANTENER_TABLAS(
	OWNER               VARCHAR2(20)                NOT NULL,
	TABLE_NAME    		VARCHAR2(100)              	NOT NULL,
	ACTIVO              CHAR(1)                     NOT NULL
	);

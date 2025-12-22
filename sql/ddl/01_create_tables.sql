--creaciones de tablas

CREATE TABLE Organizacion
 (
	ID_Organizacion INT PRIMARY KEY ,
	nombre VARCHAR (50) ,
	objetivo VARCHAR (100)
);


CREATE TABLE Gobierno
(
 ID_Gobierno INT PRIMARY KEY ,
 pais VARCHAR (50)
 );


 CREATE TABLE ODS 
 (
	ID_ODS INT PRIMARY KEY 
 );


 CREATE TABLE Incubadora
 (
 	ID_Incubadora INT PRIMARY KEY ,
 	nombre VARCHAR (50)
 );


 CREATE TABLE StartUp
 (
	ID_StartUp INT PRIMARY KEY ,
	ID_Incubadora INT ,
	nombre VARCHAR (50) ,
	sector VARCHAR (50) ,
	FOREIGN KEY ( ID_Incubadora ) REFERENCES Incubadora ( ID_Incubadora )
);


CREATE TABLE Persona
(
	DNI INT PRIMARY KEY ,
    edad INT ,
    profesion VARCHAR (50) ,
    nombre_completo VARCHAR (100)
);


CREATE TABLE Fundador
 (
   DNI INT PRIMARY KEY ,
   rol VARCHAR (50) ,
   FOREIGN KEY (DNI ) REFERENCES Persona (DNI)
  );
  

CREATE TABLE Participante
 (
 	DNI INT PRIMARY KEY ,
	funcion VARCHAR (50) ,
	FOREIGN KEY (DNI) REFERENCES Persona (DNI)
);  


CREATE TABLE Inversionista
 (
	DNI INT PRIMARY KEY,
	capital INT,
	FOREIGN KEY (DNI) REFERENCES Persona (DNI)
);


CREATE TABLE Pre_Seed
  (
  	ID_Pre_Seed INT PRIMARY KEY ,
  	ID_StartUp INT ,
	MVP VARCHAR (500) ,
	FOREIGN KEY (ID_StartUp) REFERENCES StartUp (ID_StartUp)
	);
	

CREATE TABLE Seed
	(
		ID_Seed INT PRIMARY KEY ,
		ID_Pre_Seed INT ,
		ID_StartUp INT ,
		viabilidad VARCHAR (50) ,
		FOREIGN KEY ( ID_Pre_Seed ) REFERENCES Pre_Seed ( ID_Pre_Seed ),
		FOREIGN KEY ( ID_StartUp ) REFERENCES StartUp ( ID_StartUp )
	);


CREATE TABLE Early_Stage
(
	ID_Early_Stage INT PRIMARY KEY ,
	ID_Seed INT ,
 	FOREIGN KEY (ID_Seed) REFERENCES Seed (ID_Seed)
);


CREATE TABLE Growth_Stage
	(
	ID_Growth_Stage INT PRIMARY KEY ,
	flujo_de_caja DECIMAL ,
	ID_Early_Stage INT ,
	FOREIGN KEY ( ID_Early_Stage ) REFERENCES Early_Stage ( ID_Early_Stage )
 	);


CREATE TABLE Expansion_Stage
 (
 	ID_Expansion_Stage INT PRIMARY KEY ,
	ID_Growth_Stage INT ,
	FOREIGN KEY ( ID_Growth_Stage ) REFERENCES Growth_Stage ( ID_Growth_Stage )
 );	
 

CREATE TABLE Exit
 (
	ID_Exit INT PRIMARY KEY ,
 	ID_Expansion_Stage INT ,
	FOREIGN KEY ( ID_Expansion_Stage ) REFERENCES Expansion_Stage (
	ID_Expansion_Stage )
 );
 

 CREATE TABLE ContratoGobierno_Early
 (
 	ID_Gobierno INT ,
 	ID_Early_Stage INT ,
 	fecha DATE ,
 	monto DECIMAL ,
	PRIMARY KEY ( ID_Gobierno , ID_Early_Stage ),
 	FOREIGN KEY ( ID_Gobierno ) REFERENCES Gobierno ( ID_Gobierno ),
 	FOREIGN KEY ( ID_Early_Stage ) REFERENCES Early_Stage ( ID_Early_Stage )
 );
 

CREATE TABLE ContratoGobierno_Growth
(
	ID_Gobierno INT ,
	ID_Growth_Stage INT ,
	fecha DATE ,
	monto DECIMAL ,
	PRIMARY KEY ( ID_Gobierno , ID_Growth_Stage ),
 	FOREIGN KEY ( ID_Gobierno ) REFERENCES Gobierno ( ID_Gobierno ),
	FOREIGN KEY ( ID_Growth_Stage ) REFERENCES Growth_Stage ( ID_Growth_Stage )
 	);

	
CREATE TABLE ContratoGobierno_Expansion
	(
		ID_Gobierno INT ,
		ID_Expansion_Stage INT ,
		fecha DATE ,
 		monto DECIMAL ,
		PRIMARY KEY ( ID_Gobierno , ID_Expansion_Stage ),
		FOREIGN KEY ( ID_Gobierno ) REFERENCES Gobierno ( ID_Gobierno ),
 		FOREIGN KEY ( ID_Expansion_Stage ) REFERENCES Expansion_Stage (
		ID_Expansion_Stage )
		);	

CREATE TABLE ContratoOrganizacion_Early
(
	ID_Organizacion INT ,
	ID_Early_Stage INT ,
	fecha DATE ,
	monto DECIMAL ,
	PRIMARY KEY ( ID_Organizacion , ID_Early_Stage ),
	FOREIGN KEY ( ID_Organizacion ) REFERENCES Organizacion ( ID_Organizacion ),
	FOREIGN KEY ( ID_Early_Stage ) REFERENCES Early_Stage ( ID_Early_Stage )
	);

CREATE TABLE ContratoOrganizacion_Growth
(
 	ID_Organizacion INT ,
	ID_Growth_Stage INT ,
 	fecha DATE ,
	monto DECIMAL ,
	PRIMARY KEY ( ID_Organizacion , ID_Growth_Stage ),
	FOREIGN KEY ( ID_Organizacion ) REFERENCES Organizacion ( ID_Organizacion ),
	FOREIGN KEY ( ID_Growth_Stage ) REFERENCES Growth_Stage ( ID_Growth_Stage )
 );

CREATE TABLE ContratoOrganizacion_Expansion
 (
	ID_Organizacion INT ,
	ID_Expansion_Stage INT ,
	fecha DATE ,
	monto DECIMAL ,
	PRIMARY KEY ( ID_Organizacion , ID_Expansion_Stage ),
	FOREIGN KEY ( ID_Organizacion ) REFERENCES Organizacion ( ID_Organizacion ),
	FOREIGN KEY ( ID_Expansion_Stage ) REFERENCES Expansion_Stage (
	ID_Expansion_Stage )
 );

 CREATE TABLE ContratoInversionista_Early
(
	DNI INT ,
	ID_Early_Stage INT ,
	fecha DATE ,
	monto DECIMAL ,
	PRIMARY KEY (DNI , ID_Early_Stage ),
	FOREIGN KEY (DNI ) REFERENCES Persona (DNI ),
 	FOREIGN KEY ( ID_Early_Stage ) REFERENCES Early_Stage ( ID_Early_Stage )
 );


 CREATE TABLE ContratoInversionista_Growth
 (
	DNI INT ,
	ID_Growth_Stage INT ,
	fecha DATE ,
	monto DECIMAL ,
	PRIMARY KEY (DNI , ID_Growth_Stage ),
	FOREIGN KEY (DNI ) REFERENCES Persona (DNI ),
	FOREIGN KEY ( ID_Growth_Stage ) REFERENCES Growth_Stage ( ID_Growth_Stage )
 );
 

 CREATE TABLE ContratoInversionista_Expansion
(
 	DNI INT ,
	ID_Expansion_Stage INT ,
	fecha DATE ,
	monto DECIMAL ,
	PRIMARY KEY (DNI , ID_Expansion_Stage ),
	FOREIGN KEY (DNI ) REFERENCES Persona (DNI ),
	FOREIGN KEY ( ID_Expansion_Stage ) REFERENCES Expansion_Stage (
	ID_Expansion_Stage )
 );


CREATE TABLE Impacta
(
	ID_StartUp INT ,
	ID_ODS INT ,
	PRIMARY KEY ( ID_StartUp , ID_ODS ),
	FOREIGN KEY ( ID_StartUp ) REFERENCES StartUp ( ID_StartUp ),
	FOREIGN KEY ( ID_ODS ) REFERENCES ODS ( ID_ODS )
 );


CREATE TABLE Fundo
(
	ID_StartUp INT ,
	DNI INT ,
	fecha DATE ,
	PRIMARY KEY ( ID_StartUp , DNI ),
	FOREIGN KEY ( ID_StartUp ) REFERENCES StartUp ( ID_StartUp ),
	FOREIGN KEY (DNI ) REFERENCES Persona (DNI )
 );


 CREATE TABLE Participa
 (
	ID_StartUp INT ,
	DNI INT ,
	fecha_union DATE ,
 	PRIMARY KEY ( ID_StartUp , DNI ),
	FOREIGN KEY ( ID_StartUp ) REFERENCES StartUp ( ID_StartUp ),
 	FOREIGN KEY (DNI ) REFERENCES Persona (DNI )
 );

CREATE DATABASE SPORTSLINK

GO
USE SPORTSLINK;
GO

CREATE TABLE Utilizador (
  ID                INT,
  Nome              VARCHAR(256),
  Email             VARCHAR(512),
  Num_Tele          INT,
  [Password]          VARCHAR(512),
  Nacionalidade     VARCHAR(128),

  PRIMARY KEY ID
);

CREATE TABLE Jogador (
  ID_Utilizador     INT,
  Idade             INT,
  Descricao         VARCHAR(MAX),

  PRIMARY KEY ID_Utilizador,
  FOREIGN KEY ID_Utilizador REFERENCES Utilizador(ID)
);

CREATE TABLE Desporto (
  ID_Desporto INT PRIMARY KEY,
  Nome VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE Desporto_Jogador (
  ID_Jogador INT,
  ID_Desporto INT,

  PRIMARY KEY (ID_Jogador, ID_Desporto),
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID_Jogador),
  FOREIGN KEY (ID_Desporto) REFERENCES Desporto(ID_Desporto)
);

CREATE TABLE Arrendador (
  ID_Arrendador     INT,
  IBAN              INT,
  No_Campos         INT,
  Descricao         VARCHAR(MAX),

  PRIMARY KEY ID_Arrendador,
  FOREIGN KEY ID_Arrendador REFERENCES Utilizador(ID)

);

CREATE TABLE Mapa (
  ID            INT,
  Ultimo_update TIMESTAMP,

  PRIMARY KEY ID
);

CREATE TABLE ModExib_Mapa (
  ID_Mapa           INT,
  Modo_exib         VARCHAR(50)

  PRIMARY KEY (ID_Mapa, Modo_exib),
  FOREIGN KEY ID_Mapa REFERENCES Mapa(ID)
);

CREATE TABLE Ponto (
  ID            INT,
  ID_Mapa       INT,
  Latitude      DECIMAL(9,6),
  Longitude     DECIMAL(9,6),

  PRIMARY KEY (ID, ID_Mapa),
  FOREIGN KEY ID_Mapa REFERENCES Mapa(ID)
);

CREATE TABLE Campo (
  ID            INT,
  ID_Ponto      INT,
  Nome          VARCHAR(256),
  Comprimento   DECIMAL(10,2),
  Largura       DECIMAL(10,2),
  ocupado       BIT,
  Descricao     VARCHAR(MAX)

  PRIMARY KEY ID
  FOREIGN KEY ID_Ponto REFERENCES Ponto(ID)
);

CREATE TABLE Campo_Priv (
  ID_Campo            INT,
  ID_Arrendador       INT,

  PRIMARY KEY ID_Campo,
  FOREIGN KEY ID_Campo REFERENCES Campo(ID),
  FOREIGN KEY ID_Arrendador REFERENCES Arrendador(ID_Arrendador)

);

CREATE TABLE Campo_Pub (
  ID_Campo              INT,
  Entidade_publica_resp VARCHAR(256),

  PRIMARY KEY ID_Campo,
  FOREIGN KEY ID_Campo REFERENCES Campo(ID)
);
















CREATE TABLE Jogador_Amizade (
  ID_J1 INT,
  ID_J2 INT,
  PRIMARY KEY (ID_J1, ID_J2),
  FOREIGN KEY (ID_J1) REFERENCES Jogador(ID),
  FOREIGN KEY (ID_J2) REFERENCES Jogador(ID),
  CHECK (ID_J1 < ID_J2)  -- Garante que não há duplicações invertidas
);
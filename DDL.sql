CREATE DATABASE SPORTSLINK;
GO

USE SPORTSLINK;
GO

CREATE TABLE Utilizador (
  ID                INT PRIMARY KEY,
  Nome              VARCHAR(256),
  Email             VARCHAR(512),
  Num_Tele          VARCHAR(64),
  [Password]        VARCHAR(512),
  Nacionalidade     VARCHAR(128)
);


CREATE TABLE Jogador (
  ID                INT PRIMARY KEY,
  Idade             INT,
  Descricao         VARCHAR(2500),

  FOREIGN KEY (ID) REFERENCES Utilizador(ID) ON DELETE CASCADE
);


CREATE TABLE Arrendador (
  ID_Arrendador     INT PRIMARY KEY,
  IBAN              VARCHAR(34) UNIQUE,
  No_Campos         INT,
  Descricao         VARCHAR(2500),

  FOREIGN KEY (ID_Arrendador) REFERENCES Utilizador(ID) ON DELETE CASCADE
);


CREATE TABLE Mapa (
  ID            INT PRIMARY KEY,
  Ultimo_update TIMESTAMP
);


CREATE TABLE ModExib_Mapa (
  ID_Mapa           INT,
  Modo_exib         VARCHAR(50),

  PRIMARY KEY (ID_Mapa, Modo_exib),
  FOREIGN KEY (ID_Mapa) REFERENCES Mapa(ID) ON DELETE CASCADE
);


CREATE TABLE Ponto (
  ID            INT,
  ID_Mapa       INT,
  Latitude      DECIMAL(9,6),
  Longitude     DECIMAL(9,6),

  PRIMARY KEY (ID, ID_Mapa),
  FOREIGN KEY (ID_Mapa) REFERENCES Mapa(ID) ON DELETE CASCADE
);


CREATE TABLE Campo (
  ID            INT PRIMARY KEY,
  ID_Ponto      INT,
  ID_Mapa       INT,
  Nome          VARCHAR(256),
  Comprimento   DECIMAL(10,2),
  Largura       DECIMAL(10,2),
  ocupado       BIT,
  Descricao     VARCHAR(2500),

  FOREIGN KEY (ID_Ponto, ID_Mapa) REFERENCES Ponto(ID, ID_Mapa) ON DELETE CASCADE
);


CREATE TABLE Campo_Priv (
  ID_Campo            INT PRIMARY KEY,
  ID_Arrendador       INT,

  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Arrendador) REFERENCES Arrendador(ID_Arrendador) ON DELETE CASCADE
);


CREATE TABLE Campo_Pub (
  ID_Campo              INT PRIMARY KEY,
  Entidade_publica_resp VARCHAR(256),

  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE
);

CREATE TABLE Imagem (
  [URL]              VARCHAR(512) PRIMARY KEY
);


CREATE TABLE IMG_Campo (
  ID_Campo           INT,
  [URL]              VARCHAR(512),

  PRIMARY KEY (ID_Campo, [URL]),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE,
  FOREIGN KEY ([URL]) REFERENCES Imagem([URL]) ON DELETE CASCADE
);


CREATE TABLE IMG_Perfil (
  ID_Utilizador         INT,
  [URL]              VARCHAR(512),

  PRIMARY KEY (ID_Utilizador, [URL]),
  FOREIGN KEY (ID_Utilizador) REFERENCES Utilizador(ID) ON DELETE CASCADE,
  FOREIGN KEY ([URL]) REFERENCES Imagem([URL]) ON DELETE CASCADE
);


CREATE TABLE Partida (
  ID                 INT,
  ID_Campo           INT,
  no_jogadores       INT,
  Data_Hora          DATETIME,
  Duracao            INT,
  Resultado          VARCHAR(50),
  /*[Status]           VARCHAR(50) CHECK ([Status] IN ('Agendada', 'A decorrer', 'Cancelada', 'Concluída')),*/

  PRIMARY KEY (ID),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE SET NULL
);


CREATE TABLE Jogador_joga (
  ID_Partida         INT,
  ID_Jogador         INT,

  PRIMARY KEY (ID_Partida, ID_Jogador),
  FOREIGN KEY (ID_Partida) REFERENCES Partida(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID) ON DELETE CASCADE
);


CREATE TABLE Reserva (
  ID                 INT PRIMARY KEY,
  ID_Campo           INT,
  ID_Jogador         INT,
  Data_Hora          DATETIME NOT NULL,
  Descricao          VARCHAR(2500),

  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID) ON DELETE CASCADE
);


CREATE TABLE Rating (
  ID_Avaliador      INT PRIMARY KEY,
  Data_Hora         DATETIME,
  Comentario        VARCHAR(2500),
  Avaliacao         INT,

  FOREIGN KEY (ID_Avaliador) REFERENCES Jogador(ID) ON DELETE CASCADE
);


CREATE TABLE Rating_Campo (
  ID_Avaliador       INT,
  ID_Campo           INT,

  PRIMARY KEY (ID_Campo, ID_Avaliador),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Avaliador) REFERENCES Rating(ID_Avaliador) ON DELETE CASCADE
);


CREATE TABLE Rating_Jogador (
  ID_Jogador         INT,
  ID_Avaliador       INT,

  PRIMARY KEY (ID_Jogador, ID_Avaliador),
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Avaliador) REFERENCES Rating(ID_Avaliador) ON DELETE NO ACTION
);


CREATE TABLE Dias_semana (
  ID               INT PRIMARY KEY CHECK (ID BETWEEN 1 AND 7),
  Nome             VARCHAR(50) UNIQUE NOT NULL CHECK (Nome IN ('Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado')),
  ativo            BIT
);


CREATE TABLE Disponibilidade (
  ID_Campo           INT,
  ID_dia             INT CHECK (ID_dia BETWEEN 1 AND 7),
  preco              DECIMAL(10,2),
  Hora_Inicio        TIME,
  Hora_Fim           TIME,

  CHECK (Hora_Inicio < Hora_Fim),
  PRIMARY KEY (ID_Campo, ID_dia, Hora_Inicio),
  FOREIGN KEY (ID_Campo) REFERENCES Campo_Priv(ID_Campo) ON DELETE CASCADE,
  FOREIGN KEY (ID_dia) REFERENCES Dias_semana(ID) ON DELETE CASCADE
);


CREATE TABLE Chat_Live (
  ID_Partida         INT PRIMARY KEY,
  Titulo             VARCHAR(256),
  
  FOREIGN KEY (ID_Partida) REFERENCES Partida(ID) ON DELETE CASCADE
);


CREATE TABLE Desporto (
  ID          INT PRIMARY KEY,
  Nome        VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE Desporto_Jogador (
  ID_Jogador INT,
  ID_Desporto INT,

  PRIMARY KEY (ID_Jogador, ID_Desporto),
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Desporto) REFERENCES Desporto(ID) ON DELETE CASCADE
);


CREATE TABLE Desporto_Campo (
  ID_Desporto        INT,
  ID_Campo           INT,

  PRIMARY KEY (ID_Desporto, ID_Campo),
  FOREIGN KEY (ID_Desporto) REFERENCES Desporto(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE
);


CREATE TABLE Jogador_Amizade (
  ID_J1 INT,
  ID_J2 INT,

  CHECK (ID_J1 < ID_J2),
  PRIMARY KEY (ID_J1, ID_J2),
  FOREIGN KEY (ID_J1) REFERENCES Jogador(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_J2) REFERENCES Jogador(ID) ON DELETE NO ACTION
);


CREATE TABLE Met_Paga_Arrendador (
  ID_Arrendador       INT,
  Met_pagamento       VARCHAR(50) CHECK (Met_pagamento IN ('MBWay', 'Transferência Bancária', 'ACobrança', 'PayPal')),

  PRIMARY KEY (ID_Arrendador, Met_pagamento),
  FOREIGN KEY (ID_Arrendador) REFERENCES Arrendador(ID_Arrendador) ON DELETE CASCADE
);


/* IDEIAS */

/* CREATE TABLE Met_Paga_Jogador (
  ID_Jogador          INT,
  Met_pagamento       VARCHAR(50) CHECK (Met_pagamento IN ('MBWay', 'Transferência Bancária', 'ACobrança', 'PayPal')),

  PRIMARY KEY (ID_Jogador, Met_pagamento),
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID) ON DELETE CASCADE
); */

/* CREATE TABLE Registo_Pagamento (
  ID_Pagamento        INT PRIMARY KEY,
  ID_Jogador          INT,
  ID_Arrendador       INT,
  Data_Hora           DATETIME,
  Valor               DECIMAL(10,2),
  Met_pagamento       VARCHAR(50) CHECK (Met_pagamento IN ('MBWay', 'Transferência Bancária', 'ACobrança', 'PayPal')),

  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Arrendador, Met_pagameno) REFERENCES Arrendador(ID_Arrendador) ON DELETE CASCADE
); */

CREATE DATABASE SPORTSLINK

GO
USE SPORTSLINK;
GO

CREATE TABLE Utilizador (
  ID                INT,
  Nome              VARCHAR(256),
  Email             VARCHAR(512),
  Num_Tele          VARCHAR(64),
  [Password]        VARCHAR(512),
  Nacionalidade     VARCHAR(128),

  PRIMARY KEY (ID)
);


CREATE TABLE Jogador (
  ID                INT,
  Idade             INT,
  Descricao         VARCHAR(2500),

  PRIMARY KEY (ID),
  FOREIGN KEY (ID) REFERENCES Utilizador(ID)
);


CREATE TABLE Arrendador (
  ID_Arrendador     INT,
  IBAN              INT,
  No_Campos         INT,
  Descricao         VARCHAR(2500),

  PRIMARY KEY (ID_Arrendador),
  FOREIGN KEY (ID_Arrendador) REFERENCES Utilizador(ID)

);


CREATE TABLE Mapa (
  ID            INT,
  Ultimo_update TIMESTAMP,

  PRIMARY KEY (ID)
);


CREATE TABLE ModExib_Mapa (
  ID_Mapa           INT,
  Modo_exib         VARCHAR(50),
  PRIMARY KEY (ID_Mapa, Modo_exib),
  FOREIGN KEY (ID_Mapa) REFERENCES Mapa(ID)
);


CREATE TABLE Ponto (
  ID            INT,
  ID_Mapa       INT,
  Latitude      DECIMAL(9,6),
  Longitude     DECIMAL(9,6),

  PRIMARY KEY (ID, ID_Mapa),
  FOREIGN KEY (ID_Mapa) REFERENCES Mapa(ID)
);


CREATE TABLE Campo (
  ID            INT,
  ID_Ponto      INT,
  ID_Mapa		    INT,
  Nome          VARCHAR(256),
  Comprimento   DECIMAL(10,2),
  Largura       DECIMAL(10,2),
  ocupado       BIT,
  Descricao     VARCHAR(2500),

  PRIMARY KEY (ID),
  FOREIGN KEY (ID_Ponto, ID_Mapa) REFERENCES Ponto(ID, ID_Mapa)
);


CREATE TABLE Campo_Priv (
  ID_Campo            INT,
  ID_Arrendador       INT,

  PRIMARY KEY (ID_Campo),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID),
  FOREIGN KEY (ID_Arrendador) REFERENCES Arrendador(ID_Arrendador)

);


CREATE TABLE Campo_Pub (
  ID_Campo              INT,
  Entidade_publica_resp VARCHAR(256),

  PRIMARY KEY (ID_Campo),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID)
);


CREATE TABLE Imagem (
  [URL]              VARCHAR(512),

  PRIMARY KEY ([URL])
);


CREATE TABLE IMG_Campo (
  ID_Campo           INT,
  [URL]              VARCHAR(512),

  PRIMARY KEY (ID_Campo, [URL]),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID),
  FOREIGN KEY ([URL]) REFERENCES Imagem([URL])
);


CREATE TABLE IMG_Perfil (
  ID_Utilizador         INT,
  [URL]              VARCHAR(512),

  PRIMARY KEY (ID_Utilizador, [URL]),
  FOREIGN KEY (ID_Utilizador) REFERENCES Utilizador(ID),
  FOREIGN KEY ([URL]) REFERENCES Imagem([URL])
);


CREATE TABLE Partida (
  ID                 INT,
  ID_Campo           INT,
  no_jogadores       INT,
  Data_Hora          DATETIME,
  Duracao            INT,
  Resultado          VARCHAR(50),

  PRIMARY KEY (ID),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID)
);


CREATE TABLE Jogador_joga (
  ID_Partida         INT,
  ID_Jogador         INT,

  PRIMARY KEY (ID_Partida, ID_Jogador),
  FOREIGN KEY (ID_Partida) REFERENCES Partida(ID),
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID)
);


CREATE TABLE Reserva (
  ID                 INT,
  ID_Campo           INT,
  ID_Jogador         INT,
  Data_Hora          DATETIME NOT NULL,
  Descricao          VARCHAR(2500),

  PRIMARY KEY (ID),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID),
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID)
);


CREATE TABLE Rating (
  ID_Avaliador      INT,
  Data_Hora         DATETIME,
  Comentario        VARCHAR(2500),
  Avaliacao         INT,

  PRIMARY KEY (ID_Avaliador),
  FOREIGN KEY (ID_Avaliador) REFERENCES Jogador(ID)
);


CREATE TABLE Rating_Campo (
  ID_Avaliador       INT,
  ID_Campo           INT,

  PRIMARY KEY (ID_Campo, ID_Avaliador),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID),
  FOREIGN KEY (ID_Avaliador) REFERENCES Rating(ID_Avaliador)
);


CREATE TABLE Rating_Jogador (
  ID_Jogador         INT,
  ID_Avaliador       INT,

  PRIMARY KEY (ID_Jogador, ID_Avaliador),
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID),
  FOREIGN KEY (ID_Avaliador) REFERENCES Rating(ID_Avaliador)
);

CREATE TABLE Dias_semana (
  ID               INT CHECK (ID BETWEEN 1 AND 7), -- 1 = Domingo, 2 = Segunda, ..., 7 = Sábado
  Nome             VARCHAR(50) UNIQUE NOT NULL CHECK (Nome IN ('Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado')),
  ativo            BIT,
  PRIMARY KEY (ID)
);

CREATE TABLE Disponibilidade (
  ID_Campo           INT,
  ID_dia             INT CHECK (id_dia BETWEEN 1 AND 7), -- 1 = Domingo, 2 = Segunda, ..., 7 = Sábado
  preco              DECIMAL(10,2),
  Hora_Inicio        TIME,
  Hora_Fim           TIME,

  PRIMARY KEY (ID_Campo),
  FOREIGN KEY (ID_Campo) REFERENCES Campo_Priv(ID_Campo),
  FOREIGN KEY (ID_dia) REFERENCES Dias_semana(ID)
);


CREATE TABLE Chat_Live (
  ID_Partida         INT,
  Titulo             VARCHAR(256),

  PRIMARY KEY (ID_Partida),
  FOREIGN KEY (ID_Partida) REFERENCES Partida(ID)
);


CREATE TABLE Desporto (
  ID          INT,
  Nome        VARCHAR(50) UNIQUE NOT NULL,

  PRIMARY KEY (ID)
);


CREATE TABLE Desporto_Jogador (
  ID_Jogador INT,
  ID_Desporto INT,

  PRIMARY KEY (ID_Jogador, ID_Desporto),
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID),
  FOREIGN KEY (ID_Desporto) REFERENCES Desporto(ID)
);


CREATE TABLE Desporto_Campo (
  ID_Desporto        INT,
  ID_Campo           INT,

  PRIMARY KEY (ID_Desporto, ID_Campo),
  FOREIGN KEY (ID_Desporto) REFERENCES Desporto(ID),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID)
);


CREATE TABLE Jogador_Amizade (
  ID_J1 INT,
  ID_J2 INT,
  PRIMARY KEY (ID_J1, ID_J2),
  FOREIGN KEY (ID_J1) REFERENCES Jogador(ID),
  FOREIGN KEY (ID_J2) REFERENCES Jogador(ID),
  CHECK (ID_J1 < ID_J2)  -- Garante que não há duplicações invertidas
);


CREATE TABLE Met_Paga_Arrendador (
  ID_Arrendador       INT,
  Met_pagamento       VARCHAR(50) CHECK (Met_pagamento IN ('MBWay', 'Transferência Bancária', 'ACobrança', 'PayPal')),

  PRIMARY KEY (ID_Arrendador, Met_pagamento),
  FOREIGN KEY (ID_Arrendador) REFERENCES Arrendador(ID_Arrendador)
);
CREATE DATABASE SPORTSLINK;
GO

USE SPORTSLINK;
GO

CREATE TABLE Utilizador (
  ID                INT IDENTITY(1,1),
  Nome              VARCHAR(256) NOT NULL,
  Email             VARCHAR(512) UNIQUE,
  Num_Tele          VARCHAR(64)  UNIQUE,
  [Password]        VARCHAR(512) NOT NULL,
  Nacionalidade     VARCHAR(128),

  PRIMARY KEY (ID)
);

CREATE TABLE Jogador (
  ID INT PRIMARY KEY,
  Data_Nascimento DATE NOT NULL,
  Idade INT, 
  Descricao VARCHAR(2500),
  Peso DECIMAL(5,2),
  Altura DECIMAL(5,2),

  FOREIGN KEY (ID) REFERENCES Utilizador(ID) ON DELETE CASCADE
);

CREATE TABLE Arrendador (
  ID_Arrendador     INT,
  IBAN              VARCHAR(34) UNIQUE,
  No_Campos         INT,

  PRIMARY KEY (ID_Arrendador),
  FOREIGN KEY (ID_Arrendador) REFERENCES Utilizador(ID) ON DELETE CASCADE
);

CREATE TABLE Mapa (
  ID            INT IDENTITY(1,1),
  Ultimo_update TIMESTAMP

  PRIMARY KEY (ID)
);

/* CREATE TABLE ModExib_Mapa (
  ID_Mapa           INT,
  Modo_exib         VARCHAR(50),

  PRIMARY KEY (ID_Mapa, Modo_exib),
  FOREIGN KEY (ID_Mapa) REFERENCES Mapa(ID) ON DELETE CASCADE
); */ -- Comentado porque achámos desnecessário

CREATE TABLE Ponto (
  ID            INT IDENTITY(1,1),
  ID_Mapa       INT,
  Latitude      DECIMAL(9,6),
  Longitude     DECIMAL(9,6),

  PRIMARY KEY (ID, ID_Mapa),
  FOREIGN KEY (ID_Mapa) REFERENCES Mapa(ID) ON DELETE CASCADE
);

CREATE TABLE Campo (
  ID            INT IDENTITY(1,1),
  ID_Ponto      INT,
  ID_Mapa       INT,
  Nome          VARCHAR(256),
  Endereco      VARCHAR(512),
  Comprimento   DECIMAL(10,2),
  Largura       DECIMAL(10,2),
  ocupado       BIT,
  Descricao     VARCHAR(2500),

   PRIMARY KEY (ID),
  FOREIGN KEY (ID_Ponto, ID_Mapa) REFERENCES Ponto(ID, ID_Mapa) ON DELETE CASCADE
);

CREATE TABLE Campo_Priv (
  ID_Campo            INT,
  ID_Arrendador       INT,

  PRIMARY KEY (ID_Campo),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Arrendador) REFERENCES Arrendador(ID_Arrendador) ON DELETE CASCADE
);

CREATE TABLE Campo_Pub (
  ID_Campo              INT,
  Entidade_publica_resp VARCHAR(256),

  PRIMARY KEY (ID_Campo),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE
);

CREATE TABLE Imagem (
  ID                 INT IDENTITY(1,1) PRIMARY KEY,
  [URL]              VARCHAR(512) NOT NULL,
);

CREATE TABLE IMG_Campo (
  ID_Campo          INT,
  ID_img            INT,

  PRIMARY KEY (ID_Campo, ID_img),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_img) REFERENCES Imagem(ID) ON DELETE CASCADE
);

CREATE TABLE IMG_Perfil (
  ID_Utilizador       INT,
  ID_img              INT,

  PRIMARY KEY (ID_Utilizador, ID_img),
  FOREIGN KEY (ID_Utilizador) REFERENCES Utilizador(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_img) REFERENCES Imagem(ID) ON DELETE CASCADE
);

CREATE TABLE Partida (
  ID                 INT IDENTITY(1,1),
  ID_Campo           INT,
  no_jogadores       INT,
  Data_Hora          DATETIME NOT NULL,
  Duracao            INT,
  Resultado          VARCHAR(50),
  Estado             VARCHAR(50) CHECK (Estado IN ('Aguardando', 'Em Andamento', 'Finalizada')),

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
  ID                 INT IDENTITY(1,1),
  ID_Campo           INT,
  ID_Jogador         INT,
  [Data]             DATE NOT NULL,
  Hora_Inicio        TIME NOT NULL,
  Hora_Fim           TIME NOT NULL,
  Total_Pagamento    DECIMAL(10,2),
  Estado             VARCHAR(50) CHECK (Estado IN ('Pendente', 'Confirmada', 'Cancelada')),
  Descricao          VARCHAR(2500),

  PRIMARY KEY (ID),
  CHECK (Hora_Inicio < Hora_Fim),
  CHECK ([Data] >= GETDATE()),
  FOREIGN KEY (ID_Campo) REFERENCES Campo(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_Jogador) REFERENCES Jogador(ID) ON DELETE CASCADE
);

CREATE TABLE Rating (
  ID_Avaliador      INT,
  Data_Hora         DATETIME,
  Comentario        VARCHAR(2500),
  Avaliacao         INT CHECK (Avaliacao BETWEEN 1 AND 5) NOT NULL,

  PRIMARY KEY (ID_Avaliador),
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
  ID               INT,
  Nome             VARCHAR(50) UNIQUE NOT NULL CHECK (Nome IN ('Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado')),

  CHECK (ID BETWEEN 1 AND 7),
  PRIMARY KEY (ID)
);

CREATE TABLE Disponibilidade (
  ID_Campo           INT,
  ID_dia             INT CHECK (ID_dia BETWEEN 1 AND 7),
  Preco              DECIMAL(10,2) NOT NULL,
  Hora_abertura      TIME NOT NULL,
  Hora_fecho         TIME NOT NULL,

  PRIMARY KEY (ID_Campo, ID_dia, Hora_abertura),
  CHECK (Hora_abertura < Hora_fecho),
  CHECK (Preco > 0),
  FOREIGN KEY (ID_Campo) REFERENCES Campo_Priv(ID_Campo) ON DELETE CASCADE,
  FOREIGN KEY (ID_dia) REFERENCES Dias_semana(ID) ON DELETE CASCADE
);

CREATE TABLE Chat_Live (
  ID_Partida         INT,
  Titulo             VARCHAR(256) NOT NULL,
  
  PRIMARY KEY (ID_Partida),
  FOREIGN KEY (ID_Partida) REFERENCES Partida(ID) ON DELETE CASCADE
);

CREATE TABLE Desporto (
  ID          INT IDENTITY(1,1),
  Nome        VARCHAR(50) UNIQUE NOT NULL,

  PRIMARY KEY (ID)
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

  CHECK (ID_J1 <> ID_J2),
  PRIMARY KEY (ID_J1, ID_J2),
  FOREIGN KEY (ID_J1) REFERENCES Jogador(ID) ON DELETE CASCADE,
  FOREIGN KEY (ID_J2) REFERENCES Jogador(ID) ON DELETE NO ACTION
);

CREATE TABLE Met_Paga_Arrendador (
  ID_Arrendador      INT,
  Met_pagamento      VARCHAR(50) CHECK (Met_pagamento IN ('MBWay', 'PayPal', 'CC', 'Transferência Bancária')),
  Detalhes           NVARCHAR(4000),

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

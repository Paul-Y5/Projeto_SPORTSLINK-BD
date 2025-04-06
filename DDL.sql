CREATE DATABASE SPORTSLINK

GO
USE SPORTSLINK;
GO

CREATE TABLE Utilizador (
    [ID]    
    []
)
















CREATE TABLE Jogador_Amizade (
  ID_J1 INT,
  ID_J2 INT,
  PRIMARY KEY (ID_J1, ID_J2),
  FOREIGN KEY (ID_J1) REFERENCES Jogador(ID),
  FOREIGN KEY (ID_J2) REFERENCES Jogador(ID),
  CHECK (ID_J1 < ID_J2)  -- Garante que não há duplicações invertidas
);
-- Índices para a tabela Utilizador
CREATE INDEX idx_utilizador_email ON Utilizador(Email);
CREATE INDEX idx_utilizador_nome ON Utilizador(Nome);

-- Índices para a tabela Jogador
CREATE INDEX idx_jogador_idade ON Jogador(Idade);
CREATE INDEX idx_jogador_descricao ON Jogador(Descricao);

-- Índices para a tabela Arrendador
CREATE INDEX idx_arrendador_iban ON Arrendador(IBAN);
CREATE INDEX idx_arrendador_no_campos ON Arrendador(No_Campos);

-- Índices para a tabela Mapa
CREATE INDEX idx_mapa_ultimo_update ON Mapa(Ultimo_update);

-- Índices para a tabela Ponto
CREATE INDEX idx_ponto_id_mapa ON Ponto(ID_Mapa);

-- Índices para a tabela Campo
CREATE INDEX idx_campo_id_ponto ON Campo(ID_Ponto);
CREATE INDEX idx_campo_id_mapa ON Campo(ID_Mapa);
CREATE INDEX idx_campo_nome ON Campo(Nome);

-- Índices para a tabela Partida
CREATE INDEX idx_partida_id_campo ON Partida(ID_Campo);
CREATE INDEX idx_partida_data_hora ON Partida(Data_Hora);

-- Índices para a tabela Reserva
CREATE INDEX idx_reserva_id_campo ON Reserva(ID_Campo);
CREATE INDEX idx_reserva_id_jogador ON Reserva(ID_Jogador);
CREATE INDEX idx_reserva_data_hora ON Reserva(Data_Hora);

-- Índices para a tabela Rating
CREATE INDEX idx_rating_id_avaliador ON Rating(ID_Avaliador);
CREATE INDEX idx_rating_data_hora ON Rating(Data_Hora);

-- Índices para a tabela Rating_Campo
CREATE INDEX idx_rating_campo_id_campo ON Rating_Campo(ID_Campo);
CREATE INDEX idx_rating_campo_id_avaliador ON Rating_Campo(ID_Avaliador);

-- Índices para a tabela Rating_Jogador
CREATE INDEX idx_rating_jogador_id_jogador ON Rating_Jogador(ID_Jogador);
CREATE INDEX idx_rating_jogador_id_avaliador ON Rating_Jogador(ID_Avaliador);

-- Índices para a tabela Disponibilidade
CREATE INDEX idx_disponibilidade_id_campo ON Disponibilidade(ID_Campo);
CREATE INDEX idx_disponibilidade_id_dia ON Disponibilidade(ID_dia);
CREATE INDEX idx_disponibilidade_preco ON Disponibilidade(preco);

-- Índices para a tabela Desporto_Jogador
CREATE INDEX idx_desporto_jogador_id_jogador ON Desporto_Jogador(ID_Jogador);
CREATE INDEX idx_desporto_jogador_id_desporto ON Desporto_Jogador(ID_Desporto);

-- Índices para a tabela Desporto_Campo
CREATE INDEX idx_desporto_campo_id_campo ON Desporto_Campo(ID_Campo);
CREATE INDEX idx_desporto_campo_id_desporto ON Desporto_Campo(ID_Desporto);

-- Índices para a tabela Jogador_Amizade
CREATE INDEX idx_jogador_amizade_id_j1 ON Jogador_Amizade(ID_J1);
CREATE INDEX idx_jogador_amizade_id_j2 ON Jogador_Amizade(ID_J2);

-- Índices para a tabela Met_Paga_Arrendador
CREATE INDEX idx_met_paga_arrendador_met_pagamento ON Met_Paga_Arrendador(Met_pagamento);

-- Índices para a tabela Campo_Priv
CREATE INDEX idx_campo_priv_id_arrendador ON Campo_Priv(ID_Arrendador);

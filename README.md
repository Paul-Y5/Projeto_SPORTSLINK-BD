# Projeto_SPORTSLINK-BD
# 🏅 Aplicação de Agendamento de Partidas e Arrendamento de Campos Esportivos  

## 📌 Introdução  
Este projeto tem como objetivo desenvolver uma **base de dados** para suporte a uma aplicação de **agendamento de partidas desportivas** e **arrendamento de espaços** para a prática de diversos desportos.  

A aplicação procura **aproximar a comunidade** de pessoas que gostam de praticar desporto e incentivar mais pessoas a aderirem à prática desportiva, facilitando a organização de jogos e a reserva de espaços adequados.  

---
## Requisitos-Funcionais
O objetivo é conseguir que as seguintes funcionalidades sejam possiveis:

- Aceder a campos por localização, por desporto, por nome, entre outros filtros;
- Criar campos;
- O utilizador poder aceder à lista de amigos que disponibiliza a visualização do perfil dos mesmos;
- Utilizador pode visualizar o campo e os participantes de uma partida;
- Utilizador edita perfil;
- Pode realizar uma reserva, vendo os horários disponiveis e preços (campo privado);
- Pode iniciar uma partida, selecionando campo e características da partida e convidar amigos (disponibilizar publicamente também);
- Colocar o resultado no final da partida e avaliar jogadores;
- Poder visualizar e dar reviews a um campo; 
- Poder ver os campos disponibilizados para arrendamento (por parte do dono), para além disso pode ajustar a tabela de preços e horários e verificar as reservas efetuadas em cada campo;
- Ver partidas ao vivo ou agendadas em campos;
- etc.  

---
## 🏛️ Modelagem do Banco de Dados  

A base de dados é composta pelas seguintes **entidades**:  

### 👤 **Utilizador**  
Representa os usuários cadastrados na aplicação.  
- 📸 **Foto de Perfil**  
- 🆔 **ID** (Primary Key)  
- 🏷️ **Nome**  
- 📧 **Email**  
- 📞 **Número de Telefone**  
- 🔑 **Palavra-Passe**  
- 🌍 **Nacionalidade** 

#### 🎾 **Jogador** (Subtipo de Utilizador)   
- 🏅 **Desportos Favoritos**   
- 🎂 **Idade**  
- 📝 **Descrição**  

#### 🏢 **Empresa / Arrendador Particular** (Subtipo de Utilizador)   
- 📝 **Descrição**
- 💰 **IBAN** 
- 💰 **Métodos Pagamento**
- 📊 **Número de Campos**

---

### 🗺️ **Mapa**  
- 🆔 **ID** (Primary Key)     
- 🗺️ **Modo Exibição** (ex: vista de satélite, mapa simplificado)  
- ⏳ **Última Atualização** (Timestamp)   

---

### ⚽ **Campo**  
- 🆔 **ID do Campo** (Primary Key)  
- 🆔 **ID do Ponto** (Foreign Key)  
- 🏷️ **Nome do Campo**  
- 📏 **Dimensões**   
- ✅ **Estado de Ocupação** (Ocupado/Livre)  
- 🏅 **Tipo de Desporto Permitido**  
- 📝 **Descrição**  

#### 🏛️ **Campo Público**  
- 🏢 **Nome da Entidade Pública Responsável**  

#### 🏠 **Campo Privado**  
- 👤 **ID do Dono** (Foreign Key)   

---

### 📅 **Reserva**  
- 🆔 **ID da Reserva** (Primary Key)  
- 👥 **Jogadores da Reserva** (Foreign Key)  
- 🏟️ **ID do Campo Reservado** (Foreign Key)  
- 📅 **Data** 
- ⏰ **Hora** 
- 📝 **Descrição**  

---

### 🏆 **Partida**  
- 🆔 **ID da Partida** (Primary Key)  
- 🏟️ **ID do Campo** (Foreign Key)  
- 👥 **Número de Jogadores** 
- ⏳ **Duração da Partida**  
- 📊 **Resultado**  
- ⏰ **Hora**  
- 📅 **Data**  

---

### ⭐ **Rating (Avaliação)**  
- 👤 **ID do Utilizador (Avaliador)** (Foreign Key)  
- 🏟️ **ID do Avaliado** (Foreign Key)
- 📝 **Comentário**  
- ⭐ **Avaliação**
- 📅 **Data** 

---

### 💬 **ChatLive**  
- 🎮 **ID da Partida** (Foreign Key)  
- 👥 **IDs dos Participantes** (Foreign Key)  
- 🏷️ **Título**  

---

### 🖼️ **Imagem**  
- 🌐 **URL da Imagem** (Primary Key)  
- 🔗 **ID Associado** (Foreign Key)  

---

### 📆 **Preçário**  
- 🏟️ **ID do Campo** (Foreign Key)  
- 💰 **Preço**

---

### 📌 **Ponto**
- 🆔 **ID do Ponto** (Primary Key)  
- 📍 **Coordenadas (Latitude, Longitude)** 
- 🗺️ **ID_Mapa** (Foreign Key)

---
---

## 📌 Tabela de Relações e Cardinalidades

| **Entidade 1**       | **Relacionamento**  | **Entidade 2**       | **Cardinalidade** |
|----------------------|-------------------|----------------------|------------------|
| Utilizador          | is A               | Jogador             |                 |
| Utilizador          | is A               | Arrendador          |                 |
| Utilizador          | Possui               | Imagem          |         N:M             |
| Jogador            | Faz                | Reserva             |       1 : N            |
| Jogador            | Joga                | Partida             |      N : M            |
| Jogador            | Possui                | Rating             |         1 : N            |
| Jogador            | atribui                | Rating             |         1 : N            |
| Jogador           | Adiciona como amigo (Amizade) | Jogador             |         N : M            |
| Reserva            | Possui          | Campo Privado              |       N : 1            |
| Partida            | Utiliza          | Campo               |         N : 1            |
| Partida           | Possui                | Chat_Live           |         1 : 1            |
| Campo             | is A           | Campo Privado |                             |
| Campo             | is A           | Campo Público |                             |
| Campo             | Possui           | Imagem |               1:N                    |
| Campo             | Possui                | Rating              |         1 : N            |
| Campo              | Possui              | Ponto               |        1 : 1            |
| Arrendador         | Possui             | Campo Privado       |       1 : N            |
| Campo Privado             | Possui                | Preçário              |         1 : N            |
| Mapa              | exibe              | Ponto               |        1 : N            |
| Jogador             | Gosta de           | Desporto             |        N : M            |
| Campo               | disponibiliza      | Desporto             |         N : M            |
| Campo               | possui      |   Metdodo_pagamento          |         N : M            |
| Mapa                | Tem modo de exibição | Modo_Exib           |        N : M            |
| Imagem                |         possui       |   Formato           |        N : M            |


---
---
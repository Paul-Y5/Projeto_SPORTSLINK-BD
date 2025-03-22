# Projeto_SPORTSLINK-BD
# 🏅 Aplicação de Agendamento de Partidas e Arrendamento de Campos Esportivos  

## 📌 Introdução  
Este projeto tem como objetivo desenvolver uma **base de dados** para suporte a uma aplicação de **agendamento de partidas esportivas** e **arrendamento de espaços** para a prática de diversos desportos.  

A aplicação busca **aproximar a comunidade** de pessoas que gostam de praticar desporto e incentivar mais pessoas a aderirem à prática esportiva, facilitando a organização de jogos e a reserva de espaços adequados.  

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
- 🆔 **ID do Ponto** (Foreign Key)  

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
- 💰 **Preço de Aluguer**  

---

### 📅 **Reserva**  
- 🆔 **ID da Reserva** (Primary Key)  
- 👥 **Jogadores da Reserva** (Foreign Key)  
- 🏟️ **ID do Campo Reservado** (Foreign Key)  
- 📅 **Data da Reserva** (Foreign Key)  
- ⏰ **Hora da Reserva** (Foreign Key)  
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

---

### 💬 **ChatLive**  
- 🎮 **ID da Partida** (Foreign Key)  
- 👥 **IDs dos Participantes** (Foreign Key)  
- 🏷️ **Título**  

---

### 🖼️ **Imagem**  
- 🌐 **URL da Imagem** (Primary Key)  
- 📂 **Formato**  
- 🔗 **ID Associado** (Foreign Key)  

---

### 📆 **Agenda**  
- 🏟️ **ID do Campo** (Foreign Key)  
- 📅 **Data**  
- ⏰ **Hora** 

---

### 📌 **Ponto**
- 🆔 **ID do Ponto** (Primary Key)  
- 📍 **Coordenadas (Latitude, Longitude)** 

---
---

## 📌 Tabela de Relações e Cardinalidades

| **Entidade 1**       | **Relacionamento**  | **Entidade 2**       | **Cardinalidade** |
|----------------------|-------------------|----------------------|------------------|
| Utilizador          | is A               | Jogador             |                 |
| Utilizador          | is A               | Arrendador          |                 |
| Utilizador          | Possui               | Imagem          |         1:1             |
| Jogador            | Faz                | Reserva             |       1 : N            |
| Jogador            | Joga                | Partida             |      N : N            |
| Jogador            | Possui                | Rating             |         1 : N            |
| Jogador           | Participa  | Chat_Live           |        N : N            |
| Jogador           | Adiciona como amigo (Amizade) | Jogador             |         N : N            |
| Reserva            | Possui          | Campo Privado              |       N : 1            |
| Partida            | Utiliza          | Campo               |         N : 1            |
| Partida           | Possui                | Chat_Live           |         1 : 1            |
| Campo             | is A           | Campo Privado |                             |
| Campo             | is A           | Campo Público |                             |
| Campo             | Possui           | Imagem |               1:N                    |
| Campo             | Possui                | Rating              |         1 : N            |
| Campo              | Possui              | Ponto               |        1 : 1            |
| Arrendador         | Possui             | Campo Privado       |       1 : N            |
| Campo Privado             | Possui                | Agenda              |         1 : 1            |
| Mapa              | Possui              | Ponto               |        1 : N            |
| Mapa              | exibe              | Campo               |        1 : N            |

---
---
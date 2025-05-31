# Projeto_SPORTSLINK-BD

# Para executar a BD:

## Ordem de carregamento de ficheiros para a BD:
- DDL
- MDL
- Indices
- Triggers
- UDF
- Views
- Procedures
### Para executar: python app.py (dentro da pasta src)
### Ou correr na BD que se encotra no IETTA

---
# 🏅 Aplicação de Agendamento de Partidas e Arrendamento de Campos Esportivos  

## 📌 Introdução  
Este projeto tem como objetivo desenvolver uma **base de dados** para suporte a uma aplicação de **agendamento de partidas desportivas** e **arrendamento de espaços** para a prática de diversos desportos.  

A aplicação procura **aproximar a comunidade** de pessoas que gostam de praticar desporto e incentivar mais pessoas a aderirem à prática desportiva, facilitando a organização de jogos e a reserva de espaços adequados.  

---
## Requisitos-Funcionais
O objetivo é conseguir que as seguintes funcionalidades sejam possiveis:

🔹 **Gestão de Utilizadores**

- O sistema deve permitir o registo de utilizadores com dados como nome, email, telefone, nacionalidade e foto de perfil.
    
- O sistema deve permitir o utilizador editar o seu perfil.

- O sistema deve permitir classificar utilizadores após uma partida, com nota e comentário.

- O sistema deve suportar dois tipos principais de utilizadores: Jogadores e Arrendadores.

🔹 **Funcionalidades Sociais**
- O sistema deve permitir aos jogadores adicionarem outros jogadores como amigos.

- O sistema deve permitir visualizar o perfil e histórico dos amigos adicionados.

🔹 **Gestão de Campos**
- O sistema deve permitir criar e editar campos (públicos e privados).

- O sistema deve permitir associar campos a desportos específicos.

- O sistema deve permitir ver a disponibilidade de campos por localização, tipo de desporto ou nome.

- O sistema deve permitir associar imagens aos campos.

- O sistema deve permitir associar preços e horários aos campos privados.

- O sistema deve permitir avaliações e reviews dos campos.

🔹 **Agendamento de Reservas e Partidas**
- O sistema deve permitir ao jogador realizar reservas em campos privados.

- O sistema deve permitir visualizar horários disponíveis e preços antes da reserva.

- O sistema deve permitir criar partidas em campos públicos ou privados.

- O sistema deve permitir convidar amigos ou disponibilizar a partida publicamente.

- O sistema deve permitir visualizar partidas ao vivo ou agendadas.

- O sistema deve permitir registrar o resultado da partida ao final da mesma.

🔹 **Financeiro e Métodos de Pagamento**
- O sistema deve permitir que o arrendador configure métodos de pagamento e IBAN.

- O sistema deve permitir ao arrendador visualizar reservas realizadas nos seus campos.

🔹 **Outros Requisitos Funcionais**
- O sistema deve permitir anexar imagens a perfis de utilizadores, partidas ou campos.

- O sistema deve permitir a criação de chats ao vivo entre participantes de uma partida.

- O sistema deve apresentar a localização dos campos via mapa interativo.

---
## 🏛️ Modelagem da Base de Dados  

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
- **Status**  (não implementada)

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

### 📆 **Disponibilidadoe**  
- 🏟️ **ID do Campo** (Foreign Key)
- 💰 **Preço**
-  **Hora de Inicio** 
-  **Hora de Fim** 
-  **Dias da semana**

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
| Campo Privado             | Possui                | Disponibilidade              |         1 : N            |
| Mapa              | exibe              | Ponto               |        1 : N            |
| Jogador             | Gosta de           | Desporto             |        N : M            |
| Campo               | disponibiliza      | Desporto             |         N : M            |
| Campo               | possui      |   Metdodo_pagamento          |         N : M            |
| Mapa                | Tem modo de exibição | Modo_Exib           |        N : M            |
| Imagem                |         possui       |   Formato           |        N : M            |

---
---

Atualizações realizadas na BD de acordo com Normalização e alteração de alguma lógica. Definição de indices
# Desafio Técnico - Backend (Carrinho de compras)

Este projeto implementa uma API REST para gerenciamento de um carrinho de compras de e-commerce, desenvolvido com Ruby on Rails.

## Visão Geral

O objetivo deste desafio é criar uma API para gerenciar carrinhos de compras, incluindo funcionalidades para adicionar, listar, atualizar a quantidade e remover produtos, além de um sistema para gerenciar carrinhos abandonados. O foco está em código limpo, de fácil leitura e com boa cobertura de testes.

## Tecnologias Utilizadas

*   **Ruby**: 3.3.1
*   **Rails**: 7.1.3.2
*   **PostgreSQL**: 16 (Banco de dados principal)
*   **Redis**: 7.0.15 (Utilizado pelo Sidekiq para processamento de jobs em background)
*   **Sidekiq**: Processamento de jobs em background para gerenciamento de carrinhos abandonados.

## Como Executar o Projeto

Você pode executar o projeto de duas maneiras: diretamente (necessita das dependências instaladas na sua máquina) ou utilizando Docker Compose (ambiente conteinerizado).

### Executando sem Docker

Certifique-se de que Ruby (com `bundler`), PostgreSQL e Redis estejam instalados e configurados em sua máquina.

1.  **Instalar dependências Ruby:**
    ```bash
    bundle install
    ```

2.  **Configurar o banco de dados:**
    Crie o banco de dados e execute as migrações:
    ```bash
    rails db:create
    rails db:migrate
    ```

3.  **Executar o Sidekiq:**
    O Sidekiq é necessário para processar os jobs de carrinhos abandonados.
    ```bash
    bundle exec sidekiq
    ```
    Mantenha este processo rodando em um terminal separado.

4.  **Executar o servidor Rails:**
    ```bash
    bundle exec rails server
    ```
    O servidor estará disponível em `http://localhost:3000`.

### Executando com Docker Compose (Recomendado)

O projeto pode ser facilmente executado usando Docker Compose, que irá configurar o ambiente com a aplicação Rails, PostgreSQL e Redis.

1.  **Construir e iniciar os serviços:**
    ```bash
    docker-compose up --build
    ```
    Este comando irá construir as imagens Docker (se necessário), criar os contêineres e iniciá-los. Os serviços incluem:
    *   `web`: A aplicação Rails.
    *   `db`: O banco de dados PostgreSQL.
    *   `redis`: O servidor Redis para o Sidekiq.
    *   `sidekiq`: O worker Sidekiq para jobs em background.

2.  **Acessar a aplicação:**
    A aplicação Rails estará disponível em `http://localhost:3000`.
    O painel do Sidekiq estará disponível em `http://localhost:3000/sidekiq`.

3.  **Executar migrações no contêiner:**
    Após o primeiro `docker-compose up`, você precisará executar as migrações do banco de dados no contêiner da aplicação:
    ```bash
    docker-compose exec web rails db:create db:migrate
    ```

## Documentação da API

A API está versionada em `/api/v1`. Todos os endpoints retornam JSON.

### 1. Registrar um Produto no Carrinho / Adicionar Item

Adiciona um produto ao carrinho. Se o carrinho não existir na sessão, um novo será criado. Se o produto já estiver no carrinho, sua quantidade será atualizada.

*   **Endpoint:** `POST /api/v1/cart`
*   **Payload (JSON):**
    ```json
    {
      "product_id": 345,
      "quantity": 2
    }
    ```
*   **Response (JSON):**
    ```json
    {
      "id": 789,
      "products": [
        {
          "id": 645,
          "name": "Nome do produto",
          "quantity": 2,
          "unit_price": 1.99,
          "total_price": 3.98
        }
      ],
      "total_price": 3.98
    }
    ```

### 2. Listar Itens do Carrinho Atual

Recupera a lista de todos os produtos no carrinho atual.

*   **Endpoint:** `GET /api/v1/cart`
*   **Response (JSON):**
    ```json
    {
      "id": 789,
      "products": [
        {
          "id": 645,
          "name": "Nome do produto",
          "quantity": 2,
          "unit_price": 1.99,
          "total_price": 3.98
        },
        {
          "id": 646,
          "name": "Nome do produto 2",
          "quantity": 1,
          "unit_price": 2.50,
          "total_price": 2.50
        }
      ],
      "total_price": 6.48
    }
    ```

### 3. Alterar a Quantidade de Produtos no Carrinho

Altera a quantidade de um produto específico que já existe no carrinho.

*   **Endpoint:** `PUT /api/v1/cart/add_item`
*   **Payload (JSON):**
    ```json
    {
      "product_id": 1230,
      "quantity": 1
    }
    ```
*   **Response (JSON):**
    ```json
    {
      "id": 1,
      "products": [
        {
          "id": 1230,
          "name": "Nome do produto X",
          "quantity": 2,
          "unit_price": 7.00,
          "total_price": 14.00
        }
      ],
      "total_price": 14.00
    }
    ```

### 4. Remover um Produto do Carrinho

Remove um produto específico do carrinho.

*   **Endpoint:** `DELETE /api/v1/cart/:product_id`
    *   Exemplo: `DELETE /api/v1/cart/1230`
*   **Response (JSON):**
    ```json
    {
      "id": 1,
      "products": [
        {
          "id": 01020,
          "name": "Nome do produto Y",
          "quantity": 1,
          "unit_price": 9.90,
          "total_price": 9.90
        }
      ],
      "total_price": 9.90
    }
    ```
    Em caso de o produto não ser encontrado ou o carrinho estar vazio, uma mensagem de erro apropriada será retornada (ex: status 404 ou 422).

## Executando os Testes

Para executar a suíte de testes RSpec do projeto:

```bash
bundle exec rspec
```

Se estiver usando Docker Compose:

```bash
docker-compose exec web bundle exec rspec
```

## Jobs de Carrinhos Abandonados

Um job em background (`MarkCartAsAbandonedJob`) é responsável por gerenciar carrinhos abandonados:

*   **Marcação:** Um carrinho é marcado como abandonado se não houver interação (adição ou remoção de produtos) por mais de 3 horas.
*   **Remoção:** Carrinhos marcados como abandonados por mais de 7 dias são excluídos do sistema.

Este job é executado periodicamente pelo Sidekiq.
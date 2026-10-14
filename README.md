# One Piece Wiki

Aplicativo Flutter em português para consultar dados de **One Piece** diretamente pela **One Piece API**.

O projeto foi organizado para não depender de dados fictícios nas telas: listas, detalhes, pesquisas, relações e imagens são obtidos do JSON retornado pela API. Favoritos e perfil são dados locais do próprio aplicativo.

## 1. API utilizada

**One Piece API**

Base da API:

`https://api.api-onepiece.com/v2`

Documentação:

`https://documentation.api-onepiece.com/`

A documentação atual informa 16 categorias disponíveis e 87 endpoints documentados. A API é pública e não exige autenticação.

### Importante sobre as rotas

As rotas atuais da API usam o nome do recurso no **singular**. Por isso o aplicativo não usa mais rotas antigas como `/characters/en` ou `/fruits/en`.

Rotas principais usadas pelo aplicativo:

- `/saga`
- `/fruit`
- `/chapter`
- `/tome`
- `/episode`
- `/dial`
- `/film`
- `/sword`
- `/haki`
- `/luffy-gear`
- `/luffy-technique`
- `/crew`
- `/character`
- `/boat`
- `/arc`
- `/locate`

A documentação confirma, por exemplo, `/character` para personagens, `/fruit` para frutas, `/haki` para Hakis e `/locate` para locais.

## 2. O que foi corrigido

### Locais
- Corrigida a rota de `locations` para `locate`.
- A lista de locais passa a consultar a rota documentada da API.
- Detalhes e pesquisa usam a mesma fonte.

### Personagens
- Corrigida a rota de `characters` para `character`.
- A área vermelha de destaque na Home foi aumentada.
- O botão ficou maior, com título mais destacado e melhor área de toque.
- A lista de personagens continua usando os dados reais da API.

### Hakis
- Corrigida a rota de `hakis` para `haki`.
- A categoria geral de Hakis usa os dados retornados pela API.
- No detalhe de um personagem, a relação “Hakis do personagem” é exibida somente quando a API realmente retorna dados. Se a relação falhar ou vier vazia, o botão é ocultado apenas nessa página, sem quebrar o restante do aplicativo.

A documentação da API possui endpoints próprios para listar Hakis e para consultar Hakis relacionados a um personagem.

### Frutas do Demônio
- Corrigida a rota de `fruits` para `fruit`.
- As imagens são procuradas diretamente nos campos enviados pela API.
- O aplicativo reconhece URLs reais presentes em campos como `image`, `imageUrl`, `image_url`, `img`, `picture`, `poster`, `thumbnail`, `cover`, `filename`, `technicalFile` e `technical_file`.
- Nenhuma imagem fictícia é criada pelo aplicativo.
- Se a API não fornecer uma URL de imagem válida, aparece apenas o placeholder visual.

## 3. Funcionalidades

### Home
- Destaque de Personagens.
- Categorias da API.
- Quantidade de registros por categoria.
- Acesso rápido às listas.
- Informações sobre o aplicativo e a API.

### Listas
Cada categoria possui:
- carregamento direto da API;
- pesquisa;
- cards responsivos;
- imagem quando fornecida pela API;
- identificação por ID;
- acesso ao detalhe.

### Detalhes
A tela de detalhes apresenta:
- nome do registro;
- imagem quando disponível;
- todos os campos relevantes recebidos no JSON;
- botão de favorito;
- recursos relacionados quando disponíveis.

### Favoritos
- Salvamento local dos favoritos.
- Lista de favoritos.
- Imagem da API quando o registro possui imagem.
- Deslize para remover.
- Acesso novamente aos detalhes.

### Perfil
- Nome editável.
- Idade.
- Anime favorito.
- Personagem favorito.
- Foto escolhida pelo usuário.
- Dados armazenados localmente.

## 4. Categorias disponíveis

O aplicativo possui as seguintes categorias:

1. Sagas
2. Frutas do Demônio
3. Capítulos
4. Tomos
5. Episódios
6. Dials
7. Filmes
8. Sabres
9. Hakis
10. Gears de Luffy
11. Técnicas de Luffy
12. Tripulações
13. Personagens
14. Barcos
15. Arcos
16. Locais

A documentação oficial da API lista essas categorias e seus endpoints.

## 5. Estrutura do projeto

```text
lib/
├── main.dart
│
├── model/
│   ├── arc.dart
│   ├── boat.dart
│   ├── chapter.dart
│   ├── character.dart
│   ├── crew.dart
│   ├── dial.dart
│   ├── episode.dart
│   ├── fruit.dart
│   ├── haki.dart
│   ├── location.dart
│   ├── luffy_gear.dart
│   ├── luffy_technique.dart
│   ├── movie.dart
│   ├── saga.dart
│   ├── sword.dart
│   └── tome.dart
│
├── screens/
│   ├── favorites.dart
│   ├── home.dart
│   ├── profile.dart
│   ├── related_resource_list.dart
│   ├── resource_detail.dart
│   └── resource_list.dart
│
├── services/
│   ├── favorites_service.dart
│   └── onepiece_service.dart
│
├── theme/
│   └── app_theme.dart
│
└── widgets/
    ├── app_header.dart
    ├── bottom_nav.dart
    ├── count_badge.dart
    ├── offline_art.dart (somente placeholder visual; não contém dados da API)
    ├── resource_card.dart
    ├── search_box.dart
    └── state_view.dart
```

## 6. Dependências

Principais dependências do projeto:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.5.0
  shared_preferences: ^2.5.3
  image_picker: ^1.2.0
```

### `http`
Responsável pelas requisições HTTP para a One Piece API.

### `shared_preferences`
Usado para salvar informações locais, principalmente favoritos e dados do perfil.

### `image_picker`
Usado para permitir que o usuário escolha uma foto para o perfil.

## 7. Como executar

Dentro da pasta do projeto:

```bash
flutter pub get
flutter run
```

Para executar no Chrome:

```bash
flutter run -d chrome
```

Para Windows:

```bash
flutter run -d windows
```

É necessário estar conectado à internet para carregar os dados da API.

## 8. Imagens

O aplicativo não possui um banco local de imagens de personagens, frutas ou outros recursos.

A lógica de imagem procura uma URL válida dentro do JSON retornado pela API. Assim:

**API retorna imagem → aplicativo mostra a imagem**

**API não retorna imagem → aplicativo mostra o placeholder**

Isso evita inventar imagens ou dados que não estejam na fonte da API.

## 9. Dados locais x dados da API

### Dados vindos da API
- personagens;
- frutas;
- Hakis;
- locais;
- tripulações;
- barcos;
- sagas;
- arcos;
- episódios;
- capítulos;
- tomos;
- dials;
- filmes;
- sabres;
- gears;
- técnicas.

### Dados locais do aplicativo
- favoritos;
- informações do perfil;
- foto escolhida para o perfil;
- preferência de tema, quando configurada.

O projeto não contém um JSON offline de personagens, frutas, locais ou outros registros de One Piece. Os registros exibidos são obtidos da API em tempo de execução.

## 10. Tratamento de erros

Se a API não responder:
- a tela mostra o estado de erro;
- existe opção para tentar novamente;
- o aplicativo não substitui os dados por personagens, frutas ou outros registros inventados.

Se um relacionamento específico não estiver disponível:
- somente aquela relação é ocultada quando necessário;
- as demais informações da página continuam funcionando.

## 11. Arquivos principais para manutenção

### `lib/services/onepiece_service.dart`
É o principal arquivo de comunicação com a API.

Nele ficam:
- URL base;
- rotas;
- requisições HTTP;
- cache da sessão;
- conversão dos JSONs;
- pesquisa;
- relacionamentos;
- contagem;
- identificação de imagens.

### `lib/screens/home.dart`
Controla:
- Home;
- categorias;
- destaque de Personagens;
- abertura das listas;
- detalhes;
- relações entre recursos.

### `lib/screens/resource_list.dart`
Controla:
- listas;
- pesquisa;
- estados de carregamento;
- erros;
- cards responsivos.

### `lib/screens/resource_detail.dart`
Controla:
- detalhes;
- imagem;
- campos retornados pela API;
- favoritos;
- recursos relacionados.

### `lib/screens/favorites.dart`
Controla:
- favoritos salvos;
- remoção;
- imagem dos registros;
- abertura dos detalhes.

## 12. Tecnologias

- Flutter
- Dart
- Material 3
- HTTP/REST
- JSON
- SharedPreferences
- Image Picker
- One Piece API

## 13. Observação sobre a API

A One Piece API é uma API não oficial destinada a fins educacionais e de desenvolvimento. Os dados dependem da disponibilidade e do formato atualmente fornecido pelo serviço. citeturn1view0turn1view1

## 14. Projeto

**Nome:** One Piece Wiki

**Plataforma:** Flutter

**Objetivo:** criar uma wiki interativa de One Piece consumindo dados reais de uma API REST, com pesquisa, detalhes, relações, imagens disponíveis na API, favoritos e perfil.

**Fonte de dados:** One Piece API

**Autenticação:** não necessária.

**Banco de dados remoto:** não utilizado.

**Armazenamento local:** SharedPreferences para dados específicos do aplicativo.

# Морской бой / Sea Battle

Godot 4.4. Версия 0.1. Sprouee.

Расставь флот на поле 10×10 и стреляй по противнику. От классического морского боя игра отличается одним правилом: корабли можно отзеркалить через середину поля, но за это пропускаешь ход.

A Godot 4.4 battleship game, version 0.1, by Sprouee. Place a fleet on a 10×10 grid and shoot at your opponent. One rule is not in the classic game: you can mirror your ships across the board, and that costs your turn.

## По-русски

### Запуск

Нужен [Godot 4.4](https://godotengine.org/).

1. Склонируй репозиторий.
2. Открой `project.godot`.
3. Нажми F5.

В меню три пункта: **Играть**, **Правила**, **Настройки**. Между ними переключаются клавишами W / S или стрелками.

### Как начинается партия

1. Нажми **Играть**.
2. Введи никнейм. Свою персональную информацию лучше не писать.
3. Расставь корабли по сетке.
4. Если корабль не получается доставить до конца, нажми **Сбросить**.
5. Нажми Enter.
6. Создай игру как сервер или зайди по коду, который дал второй игрок.

Этот сценарий в клиенте ещё есть. Сервер, к которому он ходил, больше не работает, поэтому создать партию или подключиться по коду не получится.

### Флот

Столбцы А–К, строки 1–10.

| Корабль | Длина | Сколько |
| --- | --- | --- |
| Катер | 1 | 4 |
| Эсминец | 2 | 3 |
| Линкор | 3 | 2 |
| Крейсер | 4 | 1 |

### Чем отличается от обычного морского боя

- Игра не говорит, когда корабль противника убит. Видны только попадания и промахи.
- **Завертикалить** зеркалит твои корабли через вертикальную середину поля. Цифра строки не меняется, корабль перескакивает на противоположную сторону по буквам. Был у левого края — окажется у правого, и наоборот. За это пропускаешь ход.
- На клетке, по которой ты уже стрелял, может появиться корабль, если противник завертикалил флот прямо на неё.

### Настройки

Три музыкальных трека, зацикливание, громкость и полноэкранный режим.

## In English

### Run it

You need [Godot 4.4](https://godotengine.org/).

1. Clone the repository.
2. Open `project.godot`.
3. Press F5.

The menu has **Play**, **Rules**, and **Settings**. Move between them with W / S or the arrow keys.

### How a match starts

1. Press **Play**.
2. Enter a nickname. Do not use personal information.
3. Place your ships on the grid.
4. If a ship cannot be finished, press **Reset**.
5. Press Enter.
6. Host a game, or join with a code from the other player.

The client still has this flow. The server it used to call is no longer running, so hosting or joining a match will not connect.

### Fleet

Columns are А–К, rows are 1–10.

| Ship | Length | Count |
| --- | --- | --- |
| Cutter | 1 | 4 |
| Destroyer | 2 | 3 |
| Battleship | 3 | 2 |
| Cruiser | 4 | 1 |

### What is different from classic Battleship

- The game never tells you that a ship has been sunk. You only see hits and misses.
- **Mirror** (in the client: «завертикалить») reflects your ships across the vertical middle of the board. They stay on the same row and jump to the opposite side by column. A ship near the left edge lands near the right edge, and the other way around. This costs your turn.
- A ship can appear on a cell you already shot if the opponent mirrors their fleet onto it.

### Settings

Three music tracks, a loop toggle, volume, and fullscreen.

## Проект / Project

- Движок / engine: Godot 4.4
- Стартовая сцена / entry scene: `menu.tscn`
- Рендер / renderer: Mobile

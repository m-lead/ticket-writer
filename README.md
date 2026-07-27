# Ticket Writer

Ticket Writer помогает готовить Jira-ready описания задач для проекта: уточняет размытый scope, отделяет исследование от реализации, формулирует проверяемые AC и выдаёт markdown, который можно вставить в Jira. Поддерживаются две платформы:

- **Claude Code** — исходный plugin со всеми существующими slash-командами.
- **ChatGPT / GPT** — переносимый ChatGPT Skill, который использует то же ядро сценариев и правил.

## Возможности

| Сценарий | Jira-тип | Claude Code | ChatGPT |
|---|---|---|---|
| Feature | Epic / крупная Story | `/ticket-writer:feature` | `@ticket-writer feature: …` |
| Story | Story | `/ticket-writer:story` | `@ticket-writer story: …` |
| Task | Task | `/ticket-writer:task` | `@ticket-writer task: …` |
| Sub-task | Sub-task | `/ticket-writer:subtask` | `@ticket-writer subtask: …` |
| Bug report | Bug | `/ticket-writer:bug-report` | `@ticket-writer bug-report: …` |
| Research | Task + Research | `/ticket-writer:research` | `@ticket-writer research: …` |
| Spike | Task + Spike | `/ticket-writer:spike` | `@ticket-writer spike: …` |
| Risk | Risk (Agile Hive) | `/ticket-writer:risk` | `@ticket-writer risk: …` |
| Release | Release | `/ticket-writer:release` | `@ticket-writer release: …` |
| Release version | Jira Version / Fix Version | `/ticket-writer:release-version` | `@ticket-writer release-version: …` |
| Sprint goal | Sprint Goal | `/ticket-writer:sprint-goal` | `@ticket-writer sprint-goal: …` |
| Retro action | Retro Action Item | `/ticket-writer:retro-action` | `@ticket-writer retro-action: …` |

Для каждого типа поддержаны четыре режима: создать описание с нуля, проверить черновик (`проверь:`), сократить длинный текст (`сократи:`), превратить ADR/RFC/заметки во встрече в тикет. Для Feature также есть декомпозиция: `разбей на задачи:`.

## Установка в Claude Code

Репозиторий остаётся собственным Claude marketplace. В Claude Code выполните:

```text
/plugin marketplace add m-lead/ticket-writer
/plugin install ticket-writer@ticket-writer
```

Затем перезапустите Claude Code или выполните `/reload-plugins`. Проверка: начните `/ticket-writer:bug-report` — плагин должен запросить первую порцию данных о баге.

Для локальной разработки Claude plugin можно подключить без marketplace:

```bash
git clone https://github.com/m-lead/ticket-writer.git
claude --plugin-dir ./ticket-writer
```

## Установка в ChatGPT / GPT

Соберите артефакт и загрузите получившийся ZIP как Skill:

```bash
git clone https://github.com/m-lead/ticket-writer.git
cd ticket-writer
./scripts/build.sh
```

В ChatGPT откройте **Plugins → Skills → Create → Upload** и выберите `dist/ticket-writer-chatgpt-skill.zip`. Дождитесь проверки загружаемого skill и установите его. После установки можно явно вызвать skill через `@ticket-writer` или просто описать задачу — skill может сработать автоматически.

### Установка и распространение в workspace

1. Владелец репозитория собирает ZIP командой `./scripts/build.sh` и передаёт коллегам именно `dist/ticket-writer-chatgpt-skill.zip` (не папку `skills/` и не Claude ZIP).
2. Пользователь с правом загрузки открывает **Plugins → Skills → Create → Upload**, выбирает ZIP, проходит встроенную проверку и нажимает **Install**.
3. Чтобы сделать Skill доступным коллегам, владелец открывает **Plugins → Skills**, у Ticket Writer выбирает меню `•••` → **Share**, задаёт пользователей, группы либо весь workspace и отправляет ссылку.
4. Получатель открывает раздел **Shared with me** или **Shared by _<workspace>_**, у Ticket Writer выбирает `•••` → **Install**.
5. Проверка после установки: в новом чате написать `@ticket-writer bug-report: кнопка Deposit не открывает форму в prod`. Skill должен начать с вопросов о баге, а не с готового выдуманного описания.

Для Enterprise/Edu администратор до шагов выше включает в настройках ролей: **Enable skills**, **Enable skill uploading**, **Share skills**; для централизованной установки за других пользователей — **Enable skills installing**. При отсутствии пункта Upload или Share это ограничение роли/workspace, а не ошибка пакета.

Примеры:

```text
@ticket-writer bug-report: на Glory в prod у VIP-игроков с нулевым балансом кнопка Deposit не открывает форму; воспроизводится всегда

@ticket-writer task: проверь: <черновик технической задачи>

@ticket-writer feature: разбей на задачи: <описание фичи>

@ticket-writer release-version: Glory, BE, PI8 S5 R1, 22.07.2026, бонусная система и фикс конвертации валют
```

ChatGPT Skill не требует API-ключа, GPT Action, MCP-сервера или отдельного app: проект не обращается к Jira и не содержит внешних инструментов. Он готовит текст; создание тикета в Jira остаётся действием пользователя. Если в будущем появится интеграция с Jira или другим внешним сервисом, для ChatGPT потребуется отдельный MCP/app-адаптер.

Актуальная справка OpenAI описывает загрузку Skill через **Plugins → Skills → Create → Upload**, проверку перед активацией, явный вызов через `@`-упоминание, а также workspace sharing и роли: [Skills in ChatGPT](https://help.openai.com/en/articles/20001066).

## Использование

Claude сохраняет прежние команды и неймспейс. В ChatGPT вместо slash-команд используйте `@ticket-writer <тип>: <текст>`. Если тип очевиден, его можно не писать, например: `@ticket-writer оформи баг: …`.

В обоих вариантах Ticket Writer:

1. Задаёт вопросы порциями только по недостающим данным.
2. Прогоняет описание через нужные ролевые линзы (Delivery, Engineer, Analyst, QA).
3. Не придумывает бизнес-правила, API-контракты, сроки, оценки и приоритеты; вместо этого ставит `**TODO:**` или `**Assumption:**`.
4. Возвращает русскоязычный markdown с проверяемыми AC.

Полный пример bug-report приведён в [skills/bug-report/SKILL.md](skills/bug-report/SKILL.md). Общие правила находятся в [skills/shared/gtp-conventions.md](skills/shared/gtp-conventions.md).

## Сборка и проверка

```bash
# Собрать независимые ZIP-артефакты
./scripts/build.sh

# Проверить структуру ZIP, Claude-совместимость и все GPT-сценарии
./tests/verify-artifacts.sh
```

Сборка создаёт:

- `dist/ticket-writer-claude-plugin.zip` — Claude plugin с исходной `.claude-plugin/` и неизменёнными `skills/`.
- `dist/ticket-writer-chatgpt-skill.zip` — ChatGPT Skill с одним GPT-entrypoint, `agents/openai.yaml` и ссылочными материалами, сгенерированными из того же `skills/`.

Проверка контролирует наличие обоих пакетов, валидность ZIP, наличие всех 12 сценариев в GPT-артефакте и отсутствие Claude-only frontmatter и slash-команд в GPT-материалах. Финальная проверка поведения — установить ZIP в ChatGPT и выполнить любой основной сценарий, например bug-report из примера выше.

## Структура

```text
ticket-writer/
├── .claude-plugin/              # неизменяемый Claude Code manifest/marketplace
├── skills/                      # единое ядро правил и сценариев
├── openai/ticket-writer/
│   ├── SKILL.md                 # ChatGPT entrypoint
│   └── agents/openai.yaml       # OpenAI UI metadata
├── scripts/build.sh             # собирает Claude и ChatGPT ZIP
└── tests/verify-artifacts.sh    # контрактная проверка обеих версий
```

`skills/` — единственный источник основной логики. Claude Code читает его напрямую. При GPT-сборке сценарии копируются в `references/`, Claude-only YAML-поля и slash-команды адаптируются автоматически. Поэтому изменение шаблона или правила достаточно внести один раз.

## Различия и ограничения платформ

| Возможность | Claude Code | ChatGPT Skill |
|---|---|---|
| Вызов | Строгие slash-команды | `@ticket-writer` или автоматическое применение |
| Установка | Claude marketplace / `--plugin-dir` | Загрузка ZIP в Skills |
| Внешние действия | Нет в текущем проекте | Нет; MCP/app не требуется |
| Основная логика и шаблоны | `skills/` напрямую | Те же файлы в собранных references |

При изменениях запускайте `./tests/verify-artifacts.sh` перед pull request. Не редактируйте `dist/`: это воспроизводимый результат сборки.

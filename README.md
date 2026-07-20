# Ticket Writer

Плагин для [Claude Code](https://claude.com/claude-code), который помогает писать Jira-ready описания задач через слэш-команды. Задачи часто приходят на грумминг неподготовленными: размытый scope, нет AC, смешаны исследование и реализация, непонятно, к какому продукту относится. Ticket Writer задаёт уточняющие вопросы и выдаёт готовое markdown-описание, которое можно сразу вставить в Jira.

## Что умеет

Поддерживает основные типы задач Jira-проекта GTP:

| Команда | Тип в Jira | Кто пользуется |
|---|---|---|
| `/ticket-writer:feature` | Epic / крупная Story | PM, Delivery, Lead |
| `/ticket-writer:story` | Story | PM, Delivery, Lead, Dev |
| `/ticket-writer:task` | Task | Dev, Delivery, Lead |
| `/ticket-writer:subtask` | Sub-task | Dev, Delivery |
| `/ticket-writer:bug` | Bug | QA, Dev, PM |
| `/ticket-writer:research` | Task (метка Research) | Dev, Lead, Delivery |
| `/ticket-writer:spike` | Task (метка Spike) | Dev, Lead |
| `/ticket-writer:risk` | Risk (Agile Hive) | Delivery, Lead, PM |
| `/ticket-writer:release` | Release | Delivery, Lead, PM |
| `/ticket-writer:sprint-goal` | Sprint Goal | Delivery, PM, Lead |
| `/ticket-writer:retro-action` | Retro Action Item | Delivery, все участники ретро |

Каждая команда прогоняет задачу через несколько ролевых «линз» (Delivery, Engineer, Analyst, QA — в зависимости от типа) и задаёт уточняющие вопросы, прежде чем выдать финальное описание.

Помимо создания тикета с нуля, скилл поддерживает ещё четыре режима работы: проверка уже готового черновика, сокращение длинного текста, сжатие ADR/RFC/конспекта созвона в тикет и декомпозиция крупной фичи на задачи. Подробности по каждой команде и режиму — в `skills/<команда>/SKILL.md` и `skills/shared/gtp-conventions.md`.

## Как установить

Ticket Writer — плагин Claude Code (формат `.claude-plugin/`). Репозиторий сам себе marketplace, поэтому установка — две команды внутри Claude Code:

```
/plugin marketplace add m-lead/ticket-writer
/plugin install ticket-writer@ticket-writer
```

После установки перезапустить Claude Code (или выполнить `/reload-plugins`) и проверить: набрать `/ticket-writer:bug` — должен появиться flow (описание команды + подсказка ввести текст бага).

**Для разработки/локальной проверки плагина** — без marketplace:

```bash
git clone https://github.com/m-lead/ticket-writer.git
claude --plugin-dir ./ticket-writer
```

Команды при этом тоже живут под неймспейсом плагина: `/ticket-writer:bug`, `/ticket-writer:feature` и т.д. — так Claude Code разделяет команды разных плагинов.

## Как пользоваться

**Создать тикет с нуля:**
```
/ticket-writer:bug на Glory на проде у VIP-игроков с нулевым балансом кнопка Deposit не открывает форму, воспроизводится всегда
```
Скилл задаст уточняющие вопросы порциями (шаги воспроизведения, устройство, приоритет и т.д.) и выдаст готовое markdown-описание со всеми обязательными полями для этого типа задачи.

**Проверить готовый черновик:**
```
/ticket-writer:task проверь: <уже написанное описание задачи>
```
Скилл коротко скажет, что понятно, что размыто или избыточно, и выдаст исправленную версию в шаблоне команды.

**Сократить длинный текст:**
```
/ticket-writer:story сократи: <длинное описание>
```
Скилл уберёт теорию и лишний контекст, оставит только рабочие секции шаблона.

**Разбить фичу на задачи:**
```
/ticket-writer:feature разбей на задачи: <описание фичи>
```
Скилл отделит фичу от задач реализации и предложит список `/ticket-writer:task` / `/ticket-writer:subtask` с Goal и AC для каждой.

Полный пример вход → вопросы → ответ → выход для `/ticket-writer:bug` — в [skills/bug/SKILL.md](skills/bug/SKILL.md).

## Структура репозитория

```
ticket-writer/
├── README.md                          — этот файл
├── .claude-plugin/
│   ├── plugin.json                    — манифест плагина
│   └── marketplace.json               — каталог для /plugin marketplace add
└── skills/
    ├── shared/
    │   └── gtp-conventions.md         — общие правила: стиль, язык, AC, режимы работы, что не выдумывать
    ├── feature/SKILL.md               — /ticket-writer:feature — крупная фича или инициатива
    ├── story/SKILL.md                 — /ticket-writer:story — user story
    ├── task/SKILL.md                  — /ticket-writer:task — техническая или административная задача
    ├── subtask/SKILL.md               — /ticket-writer:subtask — атомарная под-задача
    ├── bug/SKILL.md                   — /ticket-writer:bug — баг-репорт
    ├── research/SKILL.md              — /ticket-writer:research — задача на исследование
    ├── spike/SKILL.md                 — /ticket-writer:spike — короткое timeboxed-исследование
    ├── risk/SKILL.md                  — /ticket-writer:risk — риск (Agile Hive)
    ├── release/SKILL.md               — /ticket-writer:release — релиз
    ├── sprint-goal/SKILL.md           — /ticket-writer:sprint-goal — цель спринта
    └── retro-action/SKILL.md          — /ticket-writer:retro-action — action item из ретро
```

## Как контрибьютить

Общие правила и конвенции — в `skills/shared/gtp-conventions.md`, флоу конкретных команд — в `skills/<команда>/SKILL.md`. Изменения оформляются через pull request; конвенции проекта GTP (типы задач, иерархия, окружения) менять только по согласованию, так как от них зависят все команды сразу.

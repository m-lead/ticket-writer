# Ticket Writer

Скилл для Claude Code, который помогает писать Jira-ready описания задач через слэш-команды. Задачи часто приходят на грумминг неподготовленными: размытый scope, нет AC, смешаны исследование и реализация, непонятно, к какому продукту относится. Ticket Writer задаёт уточняющие вопросы и выдаёт готовое markdown-описание, которое можно сразу вставить в Jira.

## Что умеет

Поддерживает основные типы задач Jira-проекта GTP:

| Команда | Тип в Jira | Кто пользуется |
|---|---|---|
| `/feature` | Epic / крупная Story | PM, Delivery, Lead |
| `/story` | Story | PM, Delivery, Lead, Dev |
| `/task` | Task | Dev, Delivery, Lead |
| `/subtask` | Sub-task | Dev, Delivery |
| `/bug` | Bug | QA, Dev, PM |
| `/research` | Task (метка Research) | Dev, Lead, Delivery |
| `/spike` | Task (метка Spike) | Dev, Lead |
| `/risk` | Risk (Agile Hive) | Delivery, Lead, PM |
| `/release` | Release | Delivery, Lead, PM |
| `/sprint-goal` | Sprint Goal | Delivery, PM, Lead |
| `/retro-action` | Retro Action Item | Delivery, все участники ретро |

Каждая команда прогоняет задачу через несколько ролевых «линз» (Delivery, Engineer, Analyst, QA — в зависимости от типа) и задаёт уточняющие вопросы, прежде чем выдать финальное описание.

Помимо создания тикета с нуля, скилл поддерживает ещё четыре режима работы: проверка уже готового черновика, сокращение длинного текста, сжатие ADR/RFC/конспекта созвона в тикет и декомпозиция крупной фичи на задачи. Подробности по каждой команде и режиму — в `.claude/skills/<команда>/SKILL.md` и `.claude/skills/shared/gtp-conventions.md`.

## Как установить

Скилл рассчитан на [Claude Code](https://claude.com/claude-code) и использует его формат `SKILL.md`. Другие AI-агенты сейчас не поддерживаются.

1. Склонировать репозиторий:
   ```bash
   git clone https://github.com/m-lead/ticket-writer.git
   ```
2. Скопировать `.claude/skills/` в свой проект (или в `~/.claude/skills/` для глобального доступа):
   ```bash
   cp -r ticket-writer/.claude/skills ~/.claude/skills
   ```
3. Перезапустить Claude Code.
4. Проверить: набрать `/bug` — должен появиться flow (описание команды + подсказка ввести текст бага). Если команда не появляется — проверить, что `.claude/skills/` лежит в `~/.claude/skills/` или `<проект>/.claude/skills/`, и что Claude Code перезапущен после копирования.

## Как пользоваться

**Создать тикет с нуля:**
```
/bug на Glory на проде у VIP-игроков с нулевым балансом кнопка Deposit не открывает форму, воспроизводится всегда
```
Скилл задаст уточняющие вопросы порциями (шаги воспроизведения, устройство, приоритет и т.д.) и выдаст готовое markdown-описание со всеми обязательными полями для этого типа задачи.

**Проверить готовый черновик:**
```
/task проверь: <уже написанное описание задачи>
```
Скилл коротко скажет, что понятно, что размыто или избыточно, и выдаст исправленную версию в шаблоне команды.

**Сократить длинный текст:**
```
/story сократи: <длинное описание>
```
Скилл уберёт теорию и лишний контекст, оставит только рабочие секции шаблона.

**Разбить фичу на задачи:**
```
/feature разбей на задачи: <описание фичи>
```
Скилл отделит фичу от задач реализации и предложит список `/task` / `/subtask` с Goal и AC для каждой.

Полный пример вход → вопросы → ответ → выход для `/bug` — в [.claude/skills/bug/SKILL.md](.claude/skills/bug/SKILL.md).

## Структура репозитория

```
ticket-writer/
├── README.md                          — этот файл
└── .claude/
    └── skills/
        ├── shared/
        │   └── gtp-conventions.md     — общие правила: стиль, язык, AC, режимы работы, что не выдумывать
        ├── feature/SKILL.md           — /feature — крупная фича или инициатива
        ├── story/SKILL.md             — /story — user story
        ├── task/SKILL.md              — /task — техническая или административная задача
        ├── subtask/SKILL.md           — /subtask — атомарная под-задача
        ├── bug/SKILL.md               — /bug — баг-репорт
        ├── research/SKILL.md          — /research — задача на исследование
        ├── spike/SKILL.md             — /spike — короткое timeboxed-исследование
        ├── risk/SKILL.md              — /risk — риск (Agile Hive)
        ├── release/SKILL.md           — /release — релиз
        ├── sprint-goal/SKILL.md       — /sprint-goal — цель спринта
        └── retro-action/SKILL.md      — /retro-action — action item из ретро
```

## Как контрибьютить

Общие правила и конвенции — в `.claude/skills/shared/gtp-conventions.md`, флоу конкретных команд — в `.claude/skills/<команда>/SKILL.md`. Изменения оформляются через pull request; конвенции проекта GTP (типы задач, иерархия, окружения) менять только по согласованию, так как от них зависят все команды сразу.

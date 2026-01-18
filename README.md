# Лабораторна робота 5: Нормалізація системи управління бібліотекою

## Огляд

Ця лабораторна робота присвячена нормалізації схеми БД системи управління бібліотекою. На основі аналізу оригінальної схеми було виявлено надлишковість даних та аномалії оновлення, які були усунені шляхом застосування принципів нормалізації до 3НФ.

---

## Проблеми в оригінальній схемі

### 1. Дублювання даних про осіб
**Проблема:** Атрибути як `FullName`, `Phone`, `Email`, `Address` дублювалися в таблицях **Staff** та **Author**, що призводило до:
- Надмірності даних
- Ризику аномалій оновлення (якщо особа є і персоналом, і автором)
- Порушення 3НФ (транзитивна залежність)

### 2. Неправильні зв'язки M:N
**Проблема:** У таблиці **Book** були присутні поля:
- `Author_ID FK` — один автор на книгу (не підтримувало M:N)
- `Genre_ID FK` — один жанр на книгу (не підтримувало M:N)

**Результат:** Неможливо було зберегти книги з кількома авторами або жанрами без дублювання рядків.

### 3. Порушення нормальних форм
- **1НФ:** Атомарність порушена внутрішніми зв'язками
- **2НФ:** Часткові залежності через складені ключі
- **3НФ:** Транзитивні залежності через дублювання даних про осіб

---

## Нормалізація схеми

### Крок 1: Виділення базової таблиці Person (1НФ → Розділення даних)

**Оригінальна проблема:**
```
Staff:
  Staff_ID PK
  FullName
  Phone
  Email
  Address
  Position
  Education

Author:
  Author_ID PK
  FirstName
  SecondName
  DateOfBirth
  DateOfDeath
```

**Рішення:** Створена базова таблиця **Person** з загальними атрибутами осіб:

```sql
-- НОВА ТАБЛИЦЯ
CREATE TABLE Person (
    Person_ID int PRIMARY KEY,
    FullName varchar NOT NULL,
    Phone varchar NOT NULL,
    Email varchar NOT NULL,
    Address varchar NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- ЗМІНЕНА ТАБЛИЦЯ
CREATE TABLE Staff (
    Staff_ID int PRIMARY KEY,
    Person_ID int FK NOT NULL REFERENCES Person(Person_ID),
    Position varchar NOT NULL,
    Education varchar NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- ЗМІНЕНА ТАБЛИЦЯ
CREATE TABLE Author (
    Author_ID int PRIMARY KEY,
    FirstName varchar NOT NULL,
    SecondName varchar NOT NULL,
    DateOfBirth date NOT NULL,
    DateOfDeath date,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);
```

**Результат:** Усунення дублювання даних про осіб, підтримка можливості того, що одна особа може мати різні ролі.

---

### Крок 2: Розділення зв'язків M:N (2НФ → Виділення складених зв'язків)

#### 2.1 Book → Author (M:N)

**Оригінальна проблема:**
```
Book:
  Book_ID PK
  Title
  Author_ID FK  ← Тільки один автор!
  AmountOfPages
  Cost
  Genre_ID FK
  ...
```

**Рішення:** Створена таблиця **BookAuthor** для підтримки M:N:

```sql
-- НОВА ТАБЛИЦЯ
CREATE TABLE BookAuthor (
    BookAuthor_int PRIMARY KEY,
    Book_ID int FK NOT NULL REFERENCES Book(Book_ID),
    Author_ID int FK NOT NULL REFERENCES Author(Author_ID),
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- ЗМІНЕНА ТАБЛИЦЯ Book
CREATE TABLE Book (
    Book_ID int PRIMARY KEY,
    Title varchar NOT NULL,
    AmountOfPages int NOT NULL,
    Cost float NOT NULL,
    PublisherYear int NOT NULL,
    CopiesAvailable int NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
    -- Author_ID видалено!
    -- Genre_ID переміщено в BookGenre
);
```

**Переваги:**
- Одна книга може мати кількох авторів
- Один автор може писати кілька книг
- Немає дублювання рядків книги

#### 2.2 Book → Genre (M:N)

**Оригінальна проблема:**
```
Book:
  Book_ID PK
  Genre_ID FK  ← Тільки один жанр!
```

**Рішення:** Створена таблиця **BookGenre** для підтримки M:N:

```sql
-- НОВА ТАБЛИЦЯ
CREATE TABLE BookGenre (
    BookGenre_int PRIMARY KEY,
    Book_ID int FK NOT NULL REFERENCES Book(Book_ID),
    Genre_ID int FK NOT NULL REFERENCES Genre(Genre_ID),
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);
```

**Переваги:**
- Одна книга може належати кількома жанрам
- Один жанр може мати кілька книг

---

### Крок 3: Оптимізація таблиці Member (3НФ)

**Оригінальна проблема:**
```
Member:
  Member_ID PK
  FullName
  Phone
  Email
  Address
  MembershipDate
  ...
```

**Рішення:** Інтеграція з Person (опціонально):

```sql
-- ЗМІНЕНА ТАБЛИЦЯ Member
CREATE TABLE Member (
    Member_ID int PRIMARY KEY,
    MembershipDate date NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL,
    Person_ID int FK NOT NULL REFERENCES Person(Person_ID)
);
```

**Результат:** Зменшення дублювання особистої інформації.

---

## Функціональні залежності (ФЗ)

### Таблиця Person
```
Person_ID → FullName
Person_ID → Phone
Person_ID → Email
Person_ID → Address
Person_ID → CreatedAt
Person_ID → UpdatedAt
```

### Таблиця Staff
```
Staff_ID → Position
Staff_ID → Education
Staff_ID → Person_ID (FK)
Staff_ID → {Person_ID} → {FullName, Phone, Email, Address}
```

### Таблиця Author
```
Author_ID → FirstName
Author_ID → SecondName
Author_ID → DateOfBirth
Author_ID → DateOfDeath
```

### Таблиця Book
```
Book_ID → Title
Book_ID → AmountOfPages
Book_ID → Cost
Book_ID → PublisherYear
Book_ID → CopiesAvailable
```

### Таблиця BookAuthor (складений ключ)
```
(Book_ID, Author_ID) → BookAuthor_int
```

### Таблиця BookGenre (складений ключ)
```
(Book_ID, Genre_ID) → BookGenre_int
```

---

## Перевірка нормальних форм

### 1НФ (Atomicity)
✅ **ВИТРИМАНО** — Всі атрибути атомарні, немає повторюваних груп

### 2НФ (No Partial Dependencies)
✅ **ВИТРИМАНО** — Жодний неключовий атрибут не залежить від частини складеного ключа:
- У таблицях з простим ключем: автоматично задовольнено
- У таблицях зі складеним ключем (BookAuthor, BookGenre): немає додаткових атрибутів, тільки ключові поля

### 3НФ (No Transitive Dependencies)
✅ **ВИТРИМАНО** — Усунено всі транзитивні залежності:
- ❌ Раніше: Member → Personal Data → Contact Info (транзитивна залежність)
- ✅ Тепер: Member → Person (1:1), Person має особисті дані
- ❌ Раніше: Book → Author → AuthorName (не прямо, але дублювалося)
- ✅ Тепер: Book →← BookAuthor →← Author (нормальний M:N через junction table)

---

## Порівняння: що оптимізовано

| Аспект | Оригінально | Нормалізовано |
|--------|-------------|---------------|
| **Дублювання даних про осіб** | Так (Staff, Author) | Ні (Person центр.) |
| **M:N Book→Author** | Не підтримано | Підтримано (BookAuthor) |
| **M:N Book→Genre** | Не підтримано | Підтримано (BookGenre) |
| **Транзитивні залежності** | Наявні | Усунені |
| **Часткові залежності** | Наявні | Усунені |
| **Кількість таблиць** | 9 | 12 |
| **Нормальна форма** | 2НФ | 3НФ |
| **Аномалії оновлення** | Можливі | Усунені |

---

## Переваги нормалізованої схеми

### 1. **Зменшення надлишковості**
- Одна особа зберігається один раз
- Немає копіювання FullName, Phone в кількох місцях
- Економія простору БД

### 2. **Усунення аномалій оновлення**
- Якщо змінити телефон персони, змінюється один раз у Person
- Раніше: потребувалось оновити в Staff, Author, Member одночасно
- Риск несогласованості даних мінімізований

### 3. **Гнучкість у зберіганні зв'язків**
- Книга може мати кількох авторів
- Книга може належати кільком жанрам
- Додавання нових авторів/жанрів не потребує дублювання книги

### 4. **Кращі запити**
- Запити стають передбачуваними
- JOIN-операції чіткі та оптимізовані
- Прості условияmultiple authors: `SELECT * FROM Book JOIN BookAuthor USING (Book_ID) WHERE Author_ID = ?`

### 5. **Цілісність даних**
- Зовнішні ключи забезпечують referential integrity
- Неможливо створити осиротілі записи
- Автоматична перевірка обмежень БД

---

## Структура нормалізованої схеми

```
Person (базова таблиця осіб)
├── Staff (arbeitter з Person_ID FK)
├── Author (автор)
└── Member (член бібліотеки з Person_ID FK)

Book (головна таблиця книг)
├── BookAuthor (M:N зв'язок з Author)
├── BookGenre (M:N зв'язок з Genre)
├── Loan (зв'язок з Member і Staff)
├── Publication (інформація про видавництво)
└── BookPublisher (M:N зв'язок Book з Publication)

Loan (позики книг)
├── Fine (штрафи за просрочку)
└── посилання на Member, Staff, Book

Допоміжні таблиці:
├── Genre (жанри)
├── Publication (видавництва)
└── BookPublisher (Book ↔ Publication)
```

---

## SQL-скрипти

### Створення нової схеми

```sql
-- 1. Таблиця Person (базова для всіх осіб)
CREATE TABLE Person (
    Person_ID int PRIMARY KEY,
    FullName varchar NOT NULL,
    Phone varchar NOT NULL,
    Email varchar NOT NULL,
    Address varchar NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 2. Таблиця Staff (спеціалізація Person)
CREATE TABLE Staff (
    Staff_ID int PRIMARY KEY,
    Person_ID int NOT NULL REFERENCES Person(Person_ID),
    Position varchar NOT NULL,
    Education varchar NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 3. Таблиця Author
CREATE TABLE Author (
    Author_ID int PRIMARY KEY,
    FirstName varchar NOT NULL,
    SecondName varchar NOT NULL,
    DateOfBirth date NOT NULL,
    DateOfDeath date,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 4. Таблиця Member
CREATE TABLE Member (
    Member_ID int PRIMARY KEY,
    MembershipDate date NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL,
    Person_ID int NOT NULL REFERENCES Person(Person_ID)
);

-- 5. Таблиця Genre
CREATE TABLE Genre (
    Genre_ID int PRIMARY KEY,
    Title varchar NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 6. Таблиця Publication
CREATE TABLE Publication (
    Publication_ID int PRIMARY KEY,
    Title varchar NOT NULL,
    DateOfEstablishment date NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 7. Таблиця Book (без Author_ID і Genre_ID!)
CREATE TABLE Book (
    Book_ID int PRIMARY KEY,
    Title varchar NOT NULL,
    AmountOfPages int NOT NULL,
    Cost float NOT NULL,
    PublisherYear int NOT NULL,
    CopiesAvailable int NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 8. Таблиця BookAuthor (M:N)
CREATE TABLE BookAuthor (
    BookAuthor_int PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID),
    Author_ID int NOT NULL REFERENCES Author(Author_ID),
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 9. Таблиця BookGenre (M:N)
CREATE TABLE BookGenre (
    BookGenre_int PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID),
    Genre_ID int NOT NULL REFERENCES Genre(Genre_ID),
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 10. Таблиця BookPublisher (M:N)
CREATE TABLE BookPublisher (
    BookPublisher_int PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID),
    Publisher_ID int NOT NULL REFERENCES Publication(Publication_ID),
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL,
    DayOfArrivalToLibrary date NOT NULL
);

-- 11. Таблиця Loan
CREATE TABLE Loan (
    Loan_ID int PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID),
    Member_ID int NOT NULL REFERENCES Member(Member_ID),
    Staff_ID int NOT NULL REFERENCES Staff(Staff_ID),
    LoanDate date NOT NULL,
    ReturnDate date NOT NULL,
    DueDate date NOT NULL
);

-- 12. Таблиця Fine
CREATE TABLE Fine (
    Fine_ID int PRIMARY KEY,
    Date date NOT NULL,
    Amount float NOT NULL,
    Member_ID int NOT NULL REFERENCES Member(Member_ID),
    Loan_ID int NOT NULL REFERENCES Loan(Loan_ID),
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);
```

---

## Висновок

Нормалізація схеми до 3НФ дозволила:
- ✅ Усунути надлишковість даних про осіб
- ✅ Забезпечити правильне зберігання M:N зв'язків (Book↔Author, Book↔Genre)
- ✅ Усунути транзитивні та часткові залежності
- ✅ Поліпшити цілісність та консистентність даних
- ✅ Гарантувати, що аномалії оновлення більше не виникатимуть
- ✅ Зробити схему масштабованою та易 maintainable
-- ==============================================================================
-- ЛАБОРАТОРНА РОБОТА 5: НОРМАЛІЗАЦІЯ СХЕМИ БД
-- Файл містить CREATE TABLE для нових таблиць та ALTER TABLE для змін
-- ==============================================================================

-- ==============================================================================
-- НОВІ ТАБЛИЦІ (CREATE TABLE)
-- ==============================================================================

-- 1. Нова базова таблиця Person (виділена з Staff, Author, Member)
CREATE TABLE Person (
    Person_ID int PRIMARY KEY,
    FullName varchar NOT NULL,
    Phone varchar NOT NULL,
    Email varchar NOT NULL,
    Address varchar NOT NULL,
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 2. Нова таблиця BookAuthor (M:N зв'язок для підтримки кількох авторів на одну книгу)
CREATE TABLE BookAuthor (
    BookAuthor_int PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID),
    Author_ID int NOT NULL REFERENCES Author(Author_ID),
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 3. Нова таблиця BookGenre (M:N зв'язок для підтримки кількох жанрів на одну книгу)
CREATE TABLE BookGenre (
    BookGenre_int PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID),
    Genre_ID int NOT NULL REFERENCES Genre(Genre_ID),
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL
);

-- 4. Нова таблиця BookPublisher (M:N зв'язок для підтримки кількох видавництв на одну книгу)
CREATE TABLE BookPublisher (
    BookPublisher_int PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID),
    Publisher_ID int NOT NULL REFERENCES Publication(Publication_ID),
    CreatedAt date NOT NULL,
    UpdatedAt date NOT NULL,
    DayOfArrivalToLibrary date NOT NULL
);

-- ==============================================================================
-- ЗМІНИ ІСНУЮЧИХ ТАБЛИЦЬ (ALTER TABLE)
-- ==============================================================================

-- 1. Змінити таблицю Staff: видалити повторювані атрибути, додати FK на Person
ALTER TABLE Staff
    DROP COLUMN IF EXISTS FullName CASCADE,
    DROP COLUMN IF EXISTS Phone CASCADE,
    DROP COLUMN IF EXISTS Email CASCADE,
    DROP COLUMN IF EXISTS Address CASCADE;

ALTER TABLE Staff
    ADD COLUMN Person_ID int NOT NULL REFERENCES Person(Person_ID);

-- 2. Змінити таблицю Author: залишити тільки специфічні поля автора
-- (FullName розділяється на FirstName та SecondName, що вже є в Author)
-- Автор може опціонально посилатися на Person (якщо це та сама людина)
-- Але в поточному дизайні Author має окремі FirstName, SecondName
-- Тому додаємо опціональний FK на Person
ALTER TABLE Author
    ADD COLUMN Person_ID int REFERENCES Person(Person_ID);

-- 3. Змінити таблицю Member: видалити повторювані атрибути, додати FK на Person
ALTER TABLE Member
    DROP COLUMN IF EXISTS FullName CASCADE,
    DROP COLUMN IF EXISTS Phone CASCADE,
    DROP COLUMN IF EXISTS Email CASCADE,
    DROP COLUMN IF EXISTS Address CASCADE;

ALTER TABLE Member
    ADD COLUMN Person_ID int NOT NULL REFERENCES Person(Person_ID);

-- 4. Змінити таблицю Book: видалити прямі FK на Author і Genre
-- (замість них будуть M:N таблиці BookAuthor та BookGenre)
ALTER TABLE Book
    DROP COLUMN IF EXISTS Author_ID CASCADE,
    DROP COLUMN IF EXISTS Genre_ID CASCADE;

-- 5. Змінити таблицю Staff: додати FK на Person (якщо ще не додано)
-- Це гарантує, що кожна людина у Staff збережена в Person
ALTER TABLE Staff
    ADD CONSTRAINT fk_staff_person 
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID);

-- 6. Змінити таблицю Member: додати FK на Person (якщо ще не додано)
ALTER TABLE Member
    ADD CONSTRAINT fk_member_person 
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID);
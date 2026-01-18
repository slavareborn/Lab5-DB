-- ==============================================================================
-- 1. СТВОРЕННЯ НОВИХ ТАБЛИЦЬ
-- ==============================================================================

-- Таблиця публікацій
CREATE TABLE IF NOT EXISTS Publication (
    Publication_ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    DateOfEstablishment DATE NOT NULL,
    CreatedAt DATE NOT NULL DEFAULT CURRENT_DATE,
    UpdatedAt DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Нова базова таблиця Person
CREATE TABLE IF NOT EXISTS Person (
    Person_ID SERIAL PRIMARY KEY,
    FullName varchar(255) NOT NULL,
    Phone varchar(50) NOT NULL,
    Email varchar(100) NOT NULL,
    Address varchar(255) NOT NULL,
    CreatedAt date NOT NULL DEFAULT CURRENT_DATE,
    UpdatedAt date NOT NULL DEFAULT CURRENT_DATE
);

-- Таблиця BookAuthor (M:N зв'язок)
CREATE TABLE IF NOT EXISTS BookAuthor (
    BookAuthor_ID SERIAL PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID) ON DELETE CASCADE,
    Author_ID int NOT NULL REFERENCES Author(Author_ID) ON DELETE CASCADE,
    CreatedAt date NOT NULL DEFAULT CURRENT_DATE,
    UpdatedAt date NOT NULL DEFAULT CURRENT_DATE
);

-- Таблиця BookGenre (M:N зв'язок)
CREATE TABLE IF NOT EXISTS BookGenre (
    BookGenre_ID SERIAL PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID) ON DELETE CASCADE,
    Genre_ID int NOT NULL REFERENCES Genre(Genre_ID) ON DELETE CASCADE,
    CreatedAt date NOT NULL DEFAULT CURRENT_DATE,
    UpdatedAt date NOT NULL DEFAULT CURRENT_DATE
);

-- Таблиця BookPublisher (M:N зв'язок)
CREATE TABLE IF NOT EXISTS BookPublisher (
    BookPublisher_ID SERIAL PRIMARY KEY,
    Book_ID int NOT NULL REFERENCES Book(Book_ID) ON DELETE CASCADE,
    Publisher_ID int NOT NULL REFERENCES Publication(Publication_ID) ON DELETE CASCADE,
    DayOfArrivalToLibrary date NOT NULL,
    CreatedAt date NOT NULL DEFAULT CURRENT_DATE,
    UpdatedAt date NOT NULL DEFAULT CURRENT_DATE
);

-- ==============================================================================
-- 2. МОДИФІКАЦІЯ ІСНУЮЧИХ ТАБЛИЦЬ
-- ==============================================================================

-- Зміна Staff: Видаляємо старі поля, додаємо зв'язок з Person
ALTER TABLE Staff
    DROP COLUMN IF EXISTS FullName CASCADE,
    DROP COLUMN IF EXISTS Phone CASCADE,
    DROP COLUMN IF EXISTS Email CASCADE,
    DROP COLUMN IF EXISTS Address CASCADE;

ALTER TABLE Staff
    ADD COLUMN IF NOT EXISTS Person_ID int NOT NULL REFERENCES Person(Person_ID);


-- Зміна Member: Видаляємо старі поля, додаємо зв'язок з Person
ALTER TABLE Member
    DROP COLUMN IF EXISTS FullName CASCADE,
    DROP COLUMN IF EXISTS Phone CASCADE,
    DROP COLUMN IF EXISTS Email CASCADE,
    DROP COLUMN IF EXISTS Address CASCADE;

ALTER TABLE Member
    ADD COLUMN IF NOT EXISTS Person_ID int NOT NULL REFERENCES Person(Person_ID);


-- Зміна Author: Додаємо опціональний зв'язок
ALTER TABLE Author
    ADD COLUMN IF NOT EXISTS Person_ID int REFERENCES Person(Person_ID);


-- Зміна Book: Видаляємо прямі зв'язки, бо тепер є проміжні таблиці
ALTER TABLE Book
    DROP COLUMN IF EXISTS Author_ID CASCADE,
    DROP COLUMN IF EXISTS Genre_ID CASCADE;
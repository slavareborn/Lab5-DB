-- =============================================
-- 1. Таблиця читачів (Member)
-- Зберігає інформацію про людей, які записані в бібліотеку
-- =============================================
CREATE TABLE Member (
    Member_ID SERIAL PRIMARY KEY, -- Унікальний ідентифікатор читача (автоінкремент)
    
    FullName VARCHAR(100) NOT NULL CHECK (LENGTH(FullName) > 1), -- ПІБ читача (не може бути пустим або з 1 літери)
    
    Phone VARCHAR(20) NOT NULL UNIQUE, -- Контактний номер телефону (має бути унікальним у системі)
    
    Email VARCHAR(100) NOT NULL UNIQUE CHECK (Email LIKE '%@%'), -- Email (унікальний + проста перевірка на наявність "собачки")
    
    Address VARCHAR(255) NOT NULL, -- Домашня адреса читача
    
    MembershipDate DATE NOT NULL DEFAULT CURRENT_DATE, -- Дата реєстрації (за замовчуванням - сьогодні)
    
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Технічне поле: коли запис створено
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Технічне поле: коли запис востаннє змінено
);

-- =============================================
-- 2. Таблиця персоналу (Staff)
-- Зберігає дані про працівників бібліотеки
-- =============================================
CREATE TABLE Staff (
    Staff_ID SERIAL PRIMARY KEY, -- Унікальний ID працівника
    
    FullName VARCHAR(100) NOT NULL CHECK (LENGTH(FullName) > 1), -- ПІБ працівника
    
    Address VARCHAR(255) NOT NULL, -- Адреса проживання
    
    Phone VARCHAR(20) NOT NULL UNIQUE, -- Телефон (унікальний для зв'язку)
    
    Position VARCHAR(50) NOT NULL CHECK (LENGTH(Position) > 0), -- Посада (наприклад: 'Бібліотекар', 'Охоронець')
    
    Education VARCHAR(255) NOT NULL, -- Інформація про освіту
    
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Дата створення запису
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Дата оновлення запису
);

-- =============================================
-- 3. Таблиця авторів (Author)
-- Довідник авторів книг
-- =============================================
CREATE TABLE Author (
    Author_ID SERIAL PRIMARY KEY, -- Унікальний ID автора
    
    FirstName VARCHAR(50) NOT NULL CHECK (LENGTH(FirstName) > 0), -- Ім'я автора
    
    SecondName VARCHAR(50) NOT NULL CHECK (LENGTH(SecondName) > 0), -- Прізвище автора
    
    DateOfBirth DATE NOT NULL, -- Дата народження
    
    DateOfDeath DATE, -- Дата смерті (може бути NULL, якщо автор живий)
    
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Перевірка: дата смерті (якщо є) не може бути раніше дати народження
    CONSTRAINT chk_author_dates CHECK (DateOfDeath IS NULL OR DateOfDeath >= DateOfBirth)
);

-- =============================================
-- 4. Таблиця жанрів (Genre)
-- Довідник літературних жанрів
-- =============================================
CREATE TABLE Genre (
    Genre_ID SERIAL PRIMARY KEY, -- Унікальний ID жанру
    
    Title VARCHAR(50) NOT NULL UNIQUE CHECK (LENGTH(Title) > 1), -- Назва жанру (унікальна, не пуста)
    
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 5. Таблиця книг (Book)
-- Основна таблиця з інформацією про книги у фонді
-- =============================================
CREATE TABLE Book (
    Book_ID SERIAL PRIMARY KEY, -- Унікальний ID книги
    
    Title VARCHAR(200) NOT NULL CHECK (LENGTH(Title) > 0), -- Назва книги
    
    Author_ID INT NOT NULL, -- Посилання на автора
    
    AmountOfPages INT NOT NULL CHECK (AmountOfPages > 0), -- Кількість сторінок (має бути більше 0)
    
    Cost DECIMAL(10, 2) NOT NULL CHECK (Cost >= 0), -- Вартість книги (для компенсації при втраті), не від'ємна
    
    PublisherYear INT NOT NULL CHECK (PublisherYear > 1000 AND PublisherYear <= 3000), -- Рік видання (реалістичний діапазон)
    
    Publication VARCHAR(100) NOT NULL, -- Назва видавництва
    
    CopiesAvailable INT NOT NULL DEFAULT 0 CHECK (CopiesAvailable >= 0), -- Кількість доступних примірників на полиці
    
    Genre_ID INT NOT NULL, -- Посилання на жанр
    
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Зовнішні ключі
    FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID) ON DELETE RESTRICT,
    FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID) ON DELETE SET NULL
);

-- =============================================
-- 6. Таблиця позик (Loan)
-- Реєструє факт видачі книги читачеві
-- =============================================
CREATE TABLE Loan (
    Loan_ID SERIAL PRIMARY KEY, -- Унікальний ID операції видачі
    
    Book_ID INT NOT NULL, -- Яку книгу взяли
    Member_ID INT NOT NULL, -- Хто взяв
    Staff_ID INT NOT NULL, -- Хто видав
    
    LoanDate DATE NOT NULL DEFAULT CURRENT_DATE, -- Дата видачі (сьогодні)
    
    DueDate DATE NOT NULL, -- Гранична дата повернення (планова)
    
    ReturnDate DATE, -- Фактична дата повернення (NULL, поки книга на руках)
    
    -- Зовнішні ключі
    FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID),
    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID),
    
    -- Перевірка 1: Дата повернення не може бути раніше дати видачі
    CONSTRAINT chk_loan_return CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate),
    
    -- Перевірка 2: Планова дата повернення (DueDate) має бути пізніше або дорівнювати даті видачі
    CONSTRAINT chk_loan_due CHECK (DueDate >= LoanDate)
);

-- =============================================
-- 7. Таблиця штрафів (Fine)
-- Фіксує штрафи за прострочення або пошкодження
-- =============================================
CREATE TABLE Fine (
    Fine_ID SERIAL PRIMARY KEY, -- Унікальний ID штрафу
    
    Date DATE NOT NULL DEFAULT CURRENT_DATE, -- Дата виписування штрафу
    
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0), -- Сума штрафу (має бути додатною)
    
    Member_ID INT NOT NULL, -- Кому виписано
    Loan_ID INT NOT NULL, -- За яку видачу (транзакцію)
    
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (Member_ID) REFERENCES Member(Member_ID),
    FOREIGN KEY (Loan_ID) REFERENCES Loan(Loan_ID)
);

INSERT INTO Genre (Title) VALUES 
('Фантастика'),
('Українська класика'),
('Наукова література'),
('Детектив'),
('Поезія');

INSERT INTO Author (FirstName, SecondName, DateOfBirth, DateOfDeath) VALUES 
('Тарас', 'Шевченко', '1814-03-09', '1861-03-10'),
('Джоан', 'Роулінг', '1965-07-31', NULL), -- Жива (NULL)
('Стівен', 'Кінг', '1947-09-21', NULL),
('Агата', 'Крісті', '1890-09-15', '1976-01-12'),
('Ліна', 'Костенко', '1930-03-19', NULL);

INSERT INTO Member (FullName, Phone, Email, Address, MembershipDate) VALUES 
('Іван Петренко', '+380501112233', 'ivan.petrenko@gmail.com', 'м. Київ, вул. Хрещатик, 1', '2023-01-15'),
('Марія Коваленко', '+380672223344', 'maria.k@ukr.net', 'м. Львів, пл. Ринок, 5', '2023-03-10'),
('Олексій Бондар', '+380633334455', 'alex.bond@gmail.com', 'м. Одеса, вул. Дерибасівська, 12', '2023-05-20'),
('Оксана Мельник', '+380994445566', 'oksana.m@yahoo.com', 'м. Харків, вул. Сумська, 45', '2023-08-01'),
('Андрій Сидоренко', '+380975556677', 'andriy.s@gmail.com', 'м. Київ, пр. Перемоги, 10', '2023-11-05');

INSERT INTO Staff (FullName, Address, Phone, Position, Education) VALUES 
('Олена Василівна', 'м. Київ, вул. Франка, 10', '+380441110000', 'Головний бібліотекар', 'Магістр культурології'),
('Дмитро Козак', 'м. Київ, вул. Борщагівська, 100', '+380442220000', 'Адміністратор', 'Бакалавр менеджменту'),
('Світлана Бойко', 'м. Ірпінь, вул. Університетська, 5', '+380443330000', 'Архіваріус', 'Спеціаліст архівної справи'),
('Ігор Ткач', 'м. Київ, вул. Садова, 2', '+380444440000', 'Охоронець', 'Середня спеціальна');

INSERT INTO Book (Title, Author_ID, AmountOfPages, Cost, PublisherYear, Publication, CopiesAvailable, Genre_ID) VALUES 
('Кобзар', 1, 700, 450.00, 2010, 'А-ба-ба-га-ла-ма-га', 5, 5), -- Шевченко, Поезія
('Гаррі Поттер і філософський камінь', 2, 350, 600.50, 2002, 'А-ба-ба-га-ла-ма-га', 10, 1), -- Роулінг, Фантастика
('Воно', 3, 1100, 800.00, 2015, 'КСД', 3, 1), -- Кінг, Фантастика (жах)
('Вбивство у Східному експресі', 4, 250, 300.00, 2018, 'КСД', 4, 4), -- Крісті, Детектив
('Маруся Чурай', 5, 180, 250.00, 2019, 'Либідь', 2, 2); -- Костенко, Укр. класика

INSERT INTO Loan (Book_ID, Member_ID, Staff_ID, LoanDate, DueDate, ReturnDate) VALUES 
(1, 1, 1, '2023-10-01', '2023-10-15', '2023-10-14'), -- Повернув вчасно
(2, 2, 1, '2023-11-01', '2023-11-15', NULL), -- Ще не повернув (на руках)
(3, 3, 2, '2023-09-01', '2023-09-15', '2023-09-20'), -- Повернув із запізненням (буде штраф)
(4, 4, 3, '2023-12-01', '2023-12-14', NULL), -- Ще не повернув
(5, 5, 1, '2023-10-10', '2023-10-24', '2023-10-24'); -- Повернув у день дедлайну

INSERT INTO Fine (Date, Amount, Member_ID, Loan_ID) VALUES 
('2023-09-20', 50.00, 3, 3), -- Штраф за запізнення (для Loan_ID = 3)
('2023-11-20', 150.00, 2, 2), -- Штраф за пошкодження книги (для Loan_ID = 2, хоча вона ще на руках)
('2023-10-05', 20.00, 1, 1), -- Дрібний штраф (наприклад, загубив закладку)
('2023-12-05', 500.00, 4, 4); -- Втрата книги (великий штраф)
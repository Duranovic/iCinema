CREATE DATABASE iCinema;
GO
USE iCinema;
GO

-- COUNTRIES
CREATE TABLE Countries
(
    Id   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) NOT NULL
);

-- CITIES
CREATE TABLE Cities
(
    Id        UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    CountryId UNIQUEIDENTIFIER NOT NULL,
    Name      NVARCHAR(100)    NOT NULL,
    CONSTRAINT FK_Cities_Countries FOREIGN KEY (CountryId) REFERENCES Countries (Id)
);

-- GENRES
CREATE TABLE Genres
(
    Id   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(50) NOT NULL
);

-- CINEMAS
CREATE TABLE Cinemas
(
    Id      UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    CityId  UNIQUEIDENTIFIER NOT NULL,
    Name    NVARCHAR(150)    NOT NULL,
    Address NVARCHAR(250),
    Email       nvarchar(max),
    PhoneNumber nvarchar(max),
    CONSTRAINT FK_Cinemas_Cities FOREIGN KEY (CityId) REFERENCES Cities (Id)
);

-- HALLS
CREATE TABLE Halls
(
    Id           UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    CinemaId     UNIQUEIDENTIFIER NOT NULL,
    Name         NVARCHAR(50)     NOT NULL,
    RowsCount    INT              NOT NULL,
    SeatsPerRow  INT              NOT NULL,
    HallType     NVARCHAR(50), -- e.g. VIP, 4DX
    ScreenSize   NVARCHAR(50),
    IsDolbyAtmos BIT                          DEFAULT 0,
    CONSTRAINT FK_Halls_Cinemas FOREIGN KEY (CinemaId) REFERENCES Cinemas (Id)
);

CREATE TABLE Actors
(
    Id       UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    FullName NVARCHAR(100) NOT NULL,
    Bio      NVARCHAR(MAX),
    PhotoUrl NVARCHAR(250)
);

CREATE TABLE Directors
(
    Id       UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    FullName NVARCHAR(100) NOT NULL,
    Bio      NVARCHAR(MAX),
    PhotoUrl NVARCHAR(250)
);

-- MOVIES
CREATE TABLE Movies
(
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    DirectorId  UNIQUEIDENTIFIER,
    Title       NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    DurationMin INT           NOT NULL,
    ReleaseDate DATE,
    PosterUrl   NVARCHAR(250),
    AgeRating   NVARCHAR(10), -- e.g. PG, R
    Language    NVARCHAR(50),
    TrailerUrl  NVARCHAR(250),
    CONSTRAINT FK_Movies_Director FOREIGN KEY (DirectorId) REFERENCES Directors (Id)
);

CREATE TABLE MovieActors
(
    MovieId  UNIQUEIDENTIFIER NOT NULL,
    ActorId  UNIQUEIDENTIFIER NOT NULL,
    RoleName NVARCHAR(100), -- e.g., "Main", "Supporting", or character name

    PRIMARY KEY (MovieId, ActorId),
    CONSTRAINT FK_MovieActors_Movie FOREIGN KEY (MovieId) REFERENCES Movies (Id),
    CONSTRAINT FK_MovieActors_Actor FOREIGN KEY (ActorId) REFERENCES Actors (Id)
);

CREATE TABLE MovieGenres
(
    MovieId   UNIQUEIDENTIFIER,
    GenreId   UNIQUEIDENTIFIER,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (MovieId, GenreId),
    CONSTRAINT FK_MovieGenres_Movie FOREIGN KEY (MovieId) REFERENCES Movies (Id),
    CONSTRAINT FK_MovieGenres_Genre FOREIGN KEY (GenreId) REFERENCES Genres (Id)
);

-- ROLES
CREATE TABLE Roles
(
    Id   UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(50) NOT NULL
);

-- USERS
CREATE TABLE Users
(
    Id             UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    RoleId         UNIQUEIDENTIFIER NOT NULL,
    Username       NVARCHAR(50)     NOT NULL,
    Email          NVARCHAR(100)    NOT NULL,
    PasswordHash   NVARCHAR(200)    NOT NULL,
    PhoneNumber    NVARCHAR(20),
    EmailConfirmed BIT              NOT NULL    DEFAULT 0,
    IsActive       BIT              NOT NULL    DEFAULT 1,
    CreatedAt      DATETIME         NOT NULL    DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles (Id)
);

-- PROJECTIONS
CREATE TABLE Projections
(
    Id             UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MovieId        UNIQUEIDENTIFIER NOT NULL,
    HallId         UNIQUEIDENTIFIER NOT NULL,
    StartTime      DATETIME         NOT NULL,
    Price          DECIMAL(8, 2)    NOT NULL,
    IsActive       BIT              NOT NULL    DEFAULT 1,
    ProjectionType NVARCHAR(20), -- e.g. 2D, 3D, IMAX
    IsSubtitled    BIT                          DEFAULT 0,
    CONSTRAINT FK_Projections_Movies FOREIGN KEY (MovieId) REFERENCES Movies (Id),
    CONSTRAINT FK_Projections_Halls FOREIGN KEY (HallId) REFERENCES Halls (Id)
);

-- RATINGS
CREATE TABLE Ratings
(
    Id          UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL,
    MovieId     UNIQUEIDENTIFIER NOT NULL,
    RatingValue TINYINT          NOT NULL CHECK (RatingValue BETWEEN 1 AND 10),
    Review      NVARCHAR(1000),
    RatedAt     DATETIME         NOT NULL    DEFAULT GETDATE(),
    CONSTRAINT FK_Ratings_Users FOREIGN KEY (UserId) REFERENCES Users (Id),
    CONSTRAINT FK_Ratings_Movies FOREIGN KEY (MovieId) REFERENCES Movies (Id),
    CONSTRAINT UQ_Ratings_User_Movie UNIQUE (UserId, MovieId)
);

-- RECOMMENDATIONS
CREATE TABLE Recommendations
(
    Id      UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId  UNIQUEIDENTIFIER NOT NULL,
    MovieId UNIQUEIDENTIFIER NOT NULL,
    Score   FLOAT            NOT NULL,
    CONSTRAINT FK_Recommendations_Users FOREIGN KEY (UserId) REFERENCES Users (Id),
    CONSTRAINT FK_Recommendations_Movies FOREIGN KEY (MovieId) REFERENCES Movies (Id)
);

-- RESERVATIONS
CREATE TABLE Reservations
(
    Id           UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId       UNIQUEIDENTIFIER NOT NULL,
    ProjectionId UNIQUEIDENTIFIER NOT NULL,
    ReservedAt   DATETIME         NOT NULL    DEFAULT GETDATE(),
    ExpiresAt    DATETIME,
    IsCanceled   BIT                          DEFAULT 0,
    CONSTRAINT FK_Reservations_Users FOREIGN KEY (UserId) REFERENCES Users (Id),
    CONSTRAINT FK_Reservations_Projections FOREIGN KEY (ProjectionId) REFERENCES Projections (Id)
);

-- SEATS
CREATE TABLE Seats
(
    Id         UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    HallId     UNIQUEIDENTIFIER NOT NULL,
    RowNumber  INT              NOT NULL,
    SeatNumber INT              NOT NULL,
    CONSTRAINT FK_Seats_Halls FOREIGN KEY (HallId) REFERENCES Halls (Id)
);

-- TICKETS
CREATE TABLE Tickets
(
    Id            UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ReservationId UNIQUEIDENTIFIER NOT NULL,
    SeatId        UNIQUEIDENTIFIER NOT NULL,
    QRCode        NVARCHAR(200),
    TicketStatus  NVARCHAR(20),
    TicketType    NVARCHAR(30), -- e.g. Regular, VIP, Student
    CONSTRAINT FK_Tickets_Reservations FOREIGN KEY (ReservationId) REFERENCES Reservations (Id),
    CONSTRAINT FK_Tickets_Seats FOREIGN KEY (SeatId) REFERENCES Seats (Id)
);

-- PROMO CODES
CREATE TABLE PromoCodes
(
    Id               UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Code             NVARCHAR(50)     NOT NULL,
    DiscountPercent  DECIMAL(5, 2),
    ValidFrom        DATETIME,
    ValidTo          DATETIME,
    MaxUses          INT,
    CurrentUses      INT                          DEFAULT 0,
    AppliesToMovieId UNIQUEIDENTIFIER NULL,
    CreatedBy        UNIQUEIDENTIFIER NULL,
    CONSTRAINT FK_PromoCodes_Movies FOREIGN KEY (AppliesToMovieId) REFERENCES Movies (Id),
    CONSTRAINT FK_PromoCodes_Admin FOREIGN KEY (CreatedBy) REFERENCES Users (Id)
);

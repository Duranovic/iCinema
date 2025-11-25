-- Initialize iCinema database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'iCinema')
BEGIN
    CREATE DATABASE iCinema;
END
GO


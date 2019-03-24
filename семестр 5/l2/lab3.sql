use SHOP_GAMES
go

-- ФУНКЦИИ
-- Скалярная функция
-- вывести количество игр с выбранным жанром
create function dbo.CountOfGame(@Genre nvarchar(20))
    returns int
with SCHEMABINDING
as
begin
    DECLARE @count INT
    select @count=count(GId)
    from dbo.Game
    where GGenre=@Genre
    return @count;
end
go

select dbo.CountOfGame('Action') as 'Count'
go

drop FUNCTION dbo.CountOfGame
go

-- Подставляемая табличная функция
-- Функция возвращает список клиентов, которые купили игру, вышедшую после выбранного года
create function dbo.ListOfClient(@Age int)
    returns TABLE
as return (
    select Client.ClId, Client.clName, client.clsurname, game.gtitle, game.gyear
    from Client join Game on Client.ClId = Game.GId
    where GYear > @Age
)
GO

select * from ListOfClient(2016)
drop FUNCTION ListOfClient
GO

-- Многооператорная табличная функция
-- Функция возвращает список игр, разработчики которых из заданной страны
create function dbo.DeveloperCountries(@country nvarchar(30))
    returns @tbl table(id int primary key, title nvarchar(40), developer nvarchar(30), country nvarchar(30))
    as 
    BEGIN
        insert into @tbl
        select game.gid, game.gtitle, developer.devtitle, developer.devcountry
        from game join developer on game.devid = developer.devid
        where developer.devcountry = @country
        return
    END
GO

select * from DeveloperCountries('Russia')
drop FUNCTION DeveloperCountries
GO

-- Рекурсивную функцию или функцию с рекурсивным ОТВ
create function dbo.Writeallrec()
returns table as return (
    WITH Write(DevTitle, DevCountry, LEVEL) AS (
    SELECT D.DevTitle, D.DevCountry, 1 AS LEVEL
    FROM Developer AS D
    WHERE DevId = 1
    UNION ALL

    SELECT D.DevTitle, D.DevCountry, LEVEL+1
    FROM Developer AS D INNER JOIN Write AS W ON D.DevId = W.LEVEL+1
) 
SELECT * FROM Write
)
GO

SELECT * from dbo.WriteAllrec()
drop function dbo.Writeallrec


-----------------------------------------------------------------------------------------------------------


-- Хранимую процедуру без параметров или с параметрами
-- Выводит количество клиентов с заданным именем и средний возраст
create procedure dbo.FindNames @name NVARCHAR(20) output AS
BEGIN
    select clname, clage
    from client
    where clname = 'Kira'

    set @name = @@ROWCOUNT
    return (select avg(clage) from client) --// ???
END
GO

declare @count int, @avg INT
exec @avg = dbo.FindNames @count output
select @count "Count", @avg "avg age"

drop PROCEDURE dbo.FindNames


-- Рекурсивную хранимую процедуру или хранимую процедур с рекурсивным ОТВ
create PROCEDURE dbo.WriteAll as
WITH Write(DevTitle, DevCountry, LEVEL) AS (
    SELECT D.DevTitle, D.DevCountry, 1 AS LEVEL
    FROM Developer AS D
    WHERE DevId = 1
    UNION ALL

    SELECT D.DevTitle, D.DevCountry, LEVEL+1
    FROM Developer AS D INNER JOIN Write AS W ON D.DevId = W.LEVEL+1
) 
SELECT * FROM Write;
go

exec dbo.WriteAll 

drop PROCEDURE WriteAll


-- Хранимую процедуру с курсором
-- вывод названия игр
-- Объявляем переменную
CREATE PROCEDURE dbo.findcl 
AS
--объявляем переменные
DECLARE @title varchar(20)
--объявляем курсор
DECLARE cur CURSOR FOR 
SELECT gtitle FROM game
--открываем курсор
OPEN cur
--считываем данные первой строки в наши переменные
FETCH NEXT FROM cur INTO @title
--если данные в курсоре есть, то заходим в цикл
--и крутимся там до тех пор, пока не закончатся строки в курсоре
WHILE @@FETCH_STATUS = 0
BEGIN
    print @title
	--считываем следующую строку курсора
	FETCH NEXT FROM cur INTO @title
END
--закрываем курсор
CLOSE cur
DEALLOCATE cur
go

exec dbo.findcl 
drop PROCEDURE findcl


--  Хранимую процедуру доступа к метаданным
CREATE PROCEDURE does_not
WITH EXECUTE AS OWNER  
AS  
BEGIN  
SELECT name  
FROM sys.objects   
WHERE name = 'Client'   
END;  
GO  

exec dbo.does_not
drop procedure does_not

-----------------------------------------------------------------------------------------------------------

-- DML триггер AFTER
create trigger YearPlatform 
on dbo.Platform
after insert
as
if exists (select *
    from Platform
    join inserted as i
    on platform.plId = i.plId
    where Platform.PlYear > 2020)
BEGIN
RAISERROR ('Некорректный год выхода платформы. Платформа еще не вышла.', 16, 1);
ROLLBACK TRANSACTION;
RETURN 
END;
GO

-- DML триггер INSTEAD OF
--drop TRIGGER ClientPhone
create trigger ClientPhone
on dbo.client
instead of insert
AS
BEGIN
RAISERROR ('Ошибка. Запрещен ввод данных в данную таблицу.', 16, 1);
RETURN 
END;
GO

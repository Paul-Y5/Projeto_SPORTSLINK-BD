-- Drop all foreign key constraints
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += '
ALTER TABLE [' + s.name + '].[' + t.name + '] DROP CONSTRAINT [' + f.name + '];'
FROM sys.foreign_keys f
JOIN sys.tables t ON f.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id;

EXEC sp_executesql @sql;

-- Disable foreign key constraints temporarily (optional if you're manually ordering correctly)
-- EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Delete from child tables first
DELETE FROM Achievement_Unlock;
DELETE FROM Game_Purchase;
DELETE FROM Purchase;
DELETE FROM GameStats;
DELETE FROM Review;
DELETE FROM Developer;
DELETE FROM Game_Genre;
DELETE FROM Achievement;
DELETE FROM Friendship;

-- Then delete from mid-level tables
DELETE FROM Game;
DELETE FROM Franchise;
DELETE FROM Company;

-- Finally, delete from independent tables
DELETE FROM [User];

-- Re-enable constraints (optional if disabled above)
-- EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL';


-- Drop all triggers
SET @sql = '';
SELECT @sql += '
DROP TRIGGER [' + s.name + '].[' + o.name + '];'
FROM sys.objects o
JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE type = 'TR';

EXEC sp_executesql @sql;

-- Drop all tables
SET @sql = '';
SELECT @sql += '
DROP TABLE [' + s.name + '].[' + t.name + '];'
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id;

EXEC sp_executesql @sql;

-- Drop all views
SET @sql = '';
SELECT @sql += '
DROP VIEW [' + s.name + '].[' + v.name + '];'
FROM sys.views v
JOIN sys.schemas s ON v.schema_id = s.schema_id;

EXEC sp_executesql @sql;

-- Drop all stored procedures
SET @sql = '';
SELECT @sql += '
DROP PROCEDURE [' + s.name + '].[' + p.name + '];'
FROM sys.procedures p
JOIN sys.schemas s ON p.schema_id = s.schema_id;

EXEC sp_executesql @sql;

-- Drop all scalar functions
SET @sql = '';
SELECT @sql += '
DROP FUNCTION [' + s.name + '].[' + f.name + '];'
FROM sys.objects f
JOIN sys.schemas s ON f.schema_id = s.schema_id
WHERE f.type IN ('FN', 'IF', 'TF');

EXEC sp_executesql @sql;

-- Optional: drop all user-defined types
-- SET @sql = '';
-- SELECT @sql += '
-- DROP TYPE [' + s.name + '].[' + t.name + '];'
-- FROM sys.types t
-- JOIN sys.schemas s ON t.schema_id = s.schema_id
-- WHERE t.is_user_defined = 1;

-- EXEC sp_executesql @sql;

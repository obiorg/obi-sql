USE [OBI]

-------------------------------------------------------------------------------
-- CREATE TABLE mach_drivers
--
-- Description : inject the predefine driver for the system
-------------------------------------------------------------------------------
GO
INSERT INTO [dbo].[mach_drivers]  ([deleted], [driver], [designation])
     VALUES (0, 'S7300_S7400', 'S7-300 / S7-400'),
			(0, 'S71200', 'S7-1200'),
			(0, 'S71500', 'S7-1500'),
			(0, 'IM151', 'IM151-8F')
GO
RAISERROR (N'==> Table [mach_drivers] created !',10,1) WITH NOWAIT




-------------------------------------------------------------------------------
-- CREATE TABLE [tags_types]
--
-- Description : inject default known type by the system
-------------------------------------------------------------------------------
GO
INSERT INTO [dbo].[tags_types] ([deleted] ,[type] ,[designation] ,[bit] ,[byte] ,[word] ,[group])
     VALUES (0 ,'Bool' ,'Boolean', 1, 0, 0, 'siemens'),
			(0 ,'DateTime' ,'Date Time', 64, 8, 4, 'siemens'),
			(0 ,'DInt' ,'Double Int', 32, 4, 0, 'siemens'),
			(0 ,'Int' ,'Integer', 16, 2, 1, 'siemens'),
			(0 ,'LReal' ,'Long Real', 0, 0, 0, 'siemens'),
			(0 ,'Real' ,'Real', 64, 8, 4, 'siemens'),
			(0 ,'SInt' ,'Small Int', 8, 1, 0, 'siemens'),
			(0 ,'UDInt' ,'Unsigned Double  Integer', 16, 2, 1, 'siemens'),
			(0 ,'UInt' ,'Unsigned Integer', 0, 0, 0, 'siemens'),
			(0 ,'USInt' ,'Unsigned Small Integer', 0, 0, 0, 'siemens'),
			(0 ,'WString' ,'Wide String', 0, 0, 0, 'siemens'),
			(0 ,'Array' ,'Array', 0, 0, 0, 'siemens')
GO
RAISERROR (N'==> Table [tags_types] created !',10,1) WITH NOWAIT




-------------------------------------------------------------------------------
-- CREATE TABLE [tags_memories]
--
-- Description : inject default known type by the system
-------------------------------------------------------------------------------
GO
INSERT INTO [dbo].tags_memories ([deleted] ,[name] ,[comment])
     VALUES (0, 'local', 'local data'),
			(0, 'db', 'data bloc')
GO
RAISERROR (N'==> Table tags_memories created !',10,1) WITH NOWAIT





-------------------------------------------------------------------------------
-- CREATE TABLE [pers_method]
--
-- Description : inject default persistence method
-------------------------------------------------------------------------------
INSERT INTO [dbo].[pers_method]([deleted] ,[name] ,[comment])
     VALUES (0 , 'standard', 'this method save data in persistence standard all new data in a new row')
GO
RAISERROR (N'==> Table pers_method created !',10,1) WITH NOWAIT






 -------------------------------------------------------------------------------
-- CREATE TABLE [meas_comparators]
--
-- Description :  >, >=, <, <=, !=, <>
-------------------------------------------------------------------------------
INSERT INTO [dbo].[meas_comparators] ([symbol], [name])
     VALUES ('>',	'Strictement supérieure'),
			('>=',	'Supérieure ou égale'),
			('<',	'Strictement inférieure'),
			('<=',	'Strictement supérieure'),
			('!=',	'Différent de'),
			('<>',	'Différent de')
GO
RAISERROR (N'==> Table meas_comparators created !',10,1) WITH NOWAIT
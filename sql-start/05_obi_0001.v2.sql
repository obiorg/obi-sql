
USE OBI;
GO


-------------------------------------------------------------------------------
--
-- CREATE TABLE tags_lists_types
--
-- Description : 
-- tags lists type refer to a default list type of system in order to know 
-- which type the user refers to
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS tags_lists_types;
GO
CREATE TABLE tags_lists_types (
  id		INT	IDENTITY(1,1) UNIQUE,				-- Type of style 0: <number, string> 1: <number, pathImg>, 
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- informations
  designation	varchar(255)	DEFAULT NULL,		-- 
  comment		VARCHAR(512)	DEFAULT NULL,		-- detail of list content comment

  
  -- MANAGING KEYS
  CONSTRAINT pk_tags_lists_types_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
);

GO
CREATE TRIGGER tgr_tags_lists_types_changed ON tags_lists_types
	AFTER UPDATE AS UPDATE tags_lists_types
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_tags_lists_types_id ON tags_lists_types (id ASC);
CREATE INDEX i_tags_lists_types_designation ON tags_lists_types ([designation] ASC);
CREATE INDEX i_tags_lists_types_created ON tags_lists_types (created ASC);
CREATE INDEX i_tags_lists_types_changed ON tags_lists_types (changed ASC);
GO 
RAISERROR (N'==> Table tags_lists_types created !',10,1) WITH NOWAIT
GO

INSERT INTO [dbo].[tags_lists_types] ([designation],[comment])
     VALUES ('Text', 'Specify a list text to be show'),
			('Image', 'Specify a list of image find by pathname');	
GO
RAISERROR (N'==> Table tags_lists_types filled !',10,1) WITH NOWAIT
GO








-------------------------------------------------------------------------------
--
-- CREATE TABLE tags_lists
--
-- Description : 
-- tags lists refer to a list description of a tags: allow and refer to a detail
-- of a list content defined by predefined int
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS tags_lists;
GO
CREATE TABLE tags_lists (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company]		INT				NOT NULL,
  [type]		INT				DEFAULT NULL,			-- Type of style 0: <number, string> 1: <number, pathImg>, 

  -- List informations
  [list]		varchar(45)		NOT NULL,				-- 
  designation	varchar(255)	DEFAULT NULL,			-- 
  comment		VARCHAR(512)	DEFAULT NULL,			-- detail of list content comment

  
  -- MANAGING KEYS
  CONSTRAINT pk_tags_lists_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_tags_lists_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_tags_lists_type FOREIGN KEY ([type]) REFERENCES tags_lists_types (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_tags_lists_changed ON tags_lists
	AFTER UPDATE AS UPDATE tags_lists
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_tags_lists_id ON tags_lists (id ASC);
CREATE UNIQUE INDEX ui_tags_lists_company_list ON tags_lists (company asc,  [list] asc);
CREATE INDEX i_tags_lists_company ON tags_lists ([company] ASC);
CREATE INDEX i_tags_lists_type ON tags_lists ([type] ASC);
CREATE INDEX i_tags_lists_list ON tags_lists ([list] ASC);
CREATE INDEX i_tags_lists_created ON tags_lists (created ASC);
CREATE INDEX i_tags_lists_changed ON tags_lists (changed ASC);
GO 
RAISERROR (N'==> Table tags_lists created !',10,1) WITH NOWAIT


-------------------------------------------------------------------------------
--
-- CREATE TABLE tags_lists_content
--
-- Description : 
-- tags lists content provide content of a list by a pair of integer associate
-- a defined string or path image
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS tags_lists_content;
GO
CREATE TABLE tags_lists_content (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company] INT NOT NULL,
  [list]	INT NOT NULL,

  -- Ethernet informations
  [content]		INT				NOT NULL,			-- 
  [value]		varchar(255)	DEFAULT '',			-- 
  [default]		BIT DEFAULT		0,					-- Indicate if currently row is default row
  [width]		FLOAT(53) 		DEFAULT 1.0,		-- Width in case of image
  [height]		FLOAT(53) 		DEFAULT 1.0,		-- Height in case of image
  comment		VARCHAR(512)	DEFAULT NULL,			-- detail of list content comment

  
  -- MANAGING KEYS
  CONSTRAINT pk_tags_lists_content_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_tags_lists_content_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_tags_lists_content_list FOREIGN KEY ([list]) REFERENCES tags_lists (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_tags_lists_content_changed ON tags_lists_content
	AFTER UPDATE AS UPDATE tags_lists_content
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_tags_lists_content_id ON tags_lists_content (id ASC);
CREATE UNIQUE INDEX ui_tags_lists_content_company_list ON tags_lists_content (company asc, [list] asc, [content] asc);
CREATE INDEX i_tags_lists_content_company ON tags_lists_content ([company] ASC);
CREATE INDEX i_tags_lists_content_list ON tags_lists_content ([list] ASC);
CREATE INDEX i_tags_lists_content_content ON tags_lists_content ([content] ASC);
CREATE INDEX i_tags_lists_content_created ON tags_lists_content (created ASC);
CREATE INDEX i_tags_lists_content_changed ON tags_lists_content (changed ASC);
GO 
RAISERROR (N'==> Table tags_lists_content created !',10,1) WITH NOWAIT









-------------------------------------------------------------------------------
--
-- ALTERATE TABLE TAGS
--
-- Description : 
-- Add column that will allow to associate a list to a defined value
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
ALTER TABLE dbo.tags
	-- Add new column list
	ADD [list] INT DEFAULT NULL,
	
	-- Manage foreign key
	CONSTRAINT fk_tags_lists FOREIGN KEY ([list]) REFERENCES tags_lists (id) ON UPDATE NO ACTION
	;
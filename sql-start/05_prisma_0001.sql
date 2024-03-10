

-------------------------------------------------------------------------------
--
-- CREACTION DE LA BASE DE DONNEE OBI
--
-------------------------------------------------------------------------------
--USE master;
--GO
--DROP DATABASE IF EXISTS OBI
--GO
--IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'OBI')
--	BEGIN
--		RAISERROR (N'Table OBI not exists !',10,1) WITH NOWAIT
--    	USE master;
--		CREATE DATABASE OBI
--    END;
--GO

--USE OBI;
--GO


USE PrismaDB
GO

-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE REGIONS
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS regions;
GO
CREATE TABLE regions (
  id INT NOT NULL IDENTITY(1,1) UNIQUE,
  [name] varchar(100)   NOT NULL,
  translations text  ,
  created_at datetime NULL DEFAULT NULL,
  updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  flag bit NOT NULL DEFAULT '1',
  wikiDataId varchar(255)   DEFAULT NULL ,
  PRIMARY KEY (id)
)


-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE SUBREGIONS
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS subregions;
GO
CREATE TABLE subregions (
  id INT NOT NULL IDENTITY(1,1) UNIQUE,
  [name] varchar(100)   NOT NULL,
  translations text  ,
  region_id INT NOT NULL,
  created_at datetime NULL DEFAULT NULL,
  updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  flag bit NOT NULL DEFAULT '1',
  wikiDataId varchar(255)   DEFAULT NULL ,
  PRIMARY KEY (id),
  CONSTRAINT subregion_continent_final FOREIGN KEY (region_id) REFERENCES regions (id)
)
GO
CREATE INDEX subregion_continent ON subregions (region_id ASC);
GO 




-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE COUNTRIES
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS countries;
GO
CREATE TABLE countries (
  id INT NOT NULL IDENTITY(1,1) UNIQUE,
  [name] varchar(100)   NOT NULL,
  iso3 char(3)   DEFAULT NULL,
  numeric_code char(3)   DEFAULT NULL,
  iso2 char(2)   DEFAULT NULL,
  phonecode varchar(255)   DEFAULT NULL,
  capital varchar(255)   DEFAULT NULL,
  currency varchar(255)   DEFAULT NULL,
  currency_name varchar(255)   DEFAULT NULL,
  currency_symbol varchar(255)   DEFAULT NULL,
  tld varchar(255)   DEFAULT NULL,
  native varchar(255)   DEFAULT NULL,
  region varchar(255)   DEFAULT NULL,
  region_id INT DEFAULT NULL,
  subregion varchar(255)   DEFAULT NULL,
  subregion_id INT DEFAULT NULL,
  nationality varchar(255)   DEFAULT NULL,
  timezones text  ,
  translations text  ,
  latitude decimal(10,8) DEFAULT NULL,
  longitude decimal(11,8) DEFAULT NULL,
  emoji varchar(191)   DEFAULT NULL,
  emojiU varchar(191)   DEFAULT NULL,
  created_at datetime NULL DEFAULT NULL,
  updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  flag bit NOT NULL DEFAULT '1',
  wikiDataId varchar(255)   DEFAULT NULL ,
  PRIMARY KEY (id),

  CONSTRAINT country_continent_final FOREIGN KEY (region_id) REFERENCES regions (id),
  CONSTRAINT country_subregion_final FOREIGN KEY (subregion_id) REFERENCES subregions (id)
)
GO
CREATE  INDEX country_continent ON countries (region_id ASC);
CREATE  INDEX country_subregion ON countries (subregion_id ASC);
GO 




-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE STATES
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS states;
GO
CREATE TABLE states (
  id INT NOT NULL IDENTITY(1,1) UNIQUE,
  name varchar(255)  NOT NULL,
  country_id INT NOT NULL,
  country_code char(2)  NOT NULL,
  fips_code varchar(255)  DEFAULT NULL,
  iso2 varchar(255)  DEFAULT NULL,
  [type] varchar(191)  DEFAULT NULL,
  latitude decimal(10,8) DEFAULT NULL,
  longitude decimal(11,8) DEFAULT NULL,
  created_at datetime NULL DEFAULT NULL,
  updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  flag bit NOT NULL DEFAULT '1',
  wikiDataId varchar(255)  DEFAULT NULL ,
  PRIMARY KEY (id),
  CONSTRAINT country_region_final FOREIGN KEY (country_id) REFERENCES countries (id)
) 
GO
CREATE INDEX country_region ON states (country_id ASC);
GO 


-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE CITIES
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS cities;
GO
CREATE TABLE cities(
  id INT NOT NULL IDENTITY(1,1) UNIQUE,
  [name] varchar(255)  NOT NULL,
  state_id INT NOT NULL,
  state_code varchar(255)  NOT NULL,
  country_id INT NOT NULL,
  country_code char(2)  NOT NULL,
  latitude decimal(10,8) NOT NULL,
  longitude decimal(11,8) NOT NULL,
  created_at datetime NOT NULL DEFAULT GETDATE(),
  updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  flag bit NOT NULL DEFAULT '1',
  wikiDataId varchar(255)  DEFAULT NULL ,
  PRIMARY KEY (id),
  CONSTRAINT cities_ibfk_1 FOREIGN KEY (state_id) REFERENCES states (id),
  CONSTRAINT cities_ibfk_2 FOREIGN KEY (country_id) REFERENCES countries (id)
)
GO
CREATE INDEX cities_test_ibfk_1 ON cities (state_id ASC);
CREATE INDEX cities_test_ibfk_2 ON cities (country_id ASC);
GO  




-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE ENTITIES
--
-- Description : 
-- Entities contains all possible entities that want to be manage by the database
-- usualy there is only one. The other one are for training purpose. 
--
-- Exemple(s) :
-- an entity can be : GROUPE CASTEL
--	entity : GC
--	designation : Groupe Castel
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS entities;
GO
CREATE TABLE entities (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT NOT NULL DEFAULT 0 ,
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

  entity		VARCHAR(45)		UNIQUE NOT NULL ,
  designation	varchar(255)	DEFAULT NULL ,
  
  -- builded year of entities
  builded		INT DEFAULT YEAR(GETDATE()) CHECK (builded >= 1900),
  -- specified if it is the main entities of all defined
  main			BIT DEFAULT 0,
  activated		BIT DEFAULT 1,
  -- path file name of entities logo
  logoPath		VARCHAR(512) DEFAULT NULL,	

  -- country, state, city base on existing world database
  country		INT DEFAULT NULL,
  [state]		INT DEFAULT NULL,
  [city]		INT DEFAULT NULL
  
  -- MANAGING KEYS
  CONSTRAINT pk_entities_entity PRIMARY KEY CLUSTERED (entity asc),

  -- Foreign keys
  CONSTRAINT fk_entities_country FOREIGN KEY (country) REFERENCES countries (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_entities_state FOREIGN KEY ([state]) REFERENCES states (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_entities_city FOREIGN KEY ([city]) REFERENCES dbo.cities (id) ON UPDATE NO ACTION
  
);

GO
CREATE TRIGGER tgr_entities_changed ON entities
	AFTER UPDATE AS UPDATE entities
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_entities_id ON entities (id ASC);
CREATE UNIQUE INDEX ui_entities_entity ON entities (entity ASC);

CREATE INDEX i_entities_created ON entities (created ASC);
CREATE INDEX i_entities_changed ON entities (created ASC);
GO  








-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE BUSINESSES
--
-- Description : 
-- Businesses contains all possible businesses of a defined entities each 
-- entities can have only one business of same brand. 
--
-- Dev : 
-- / ! \ When code of entity is change this one will be cascade
--
-- Exemple(s) :
-- an business can be : The main corpore that can include many of company BRALICO
--	business : BLC
--	designation : Boisson Rachfra�chissance du Congo
--
-- an business can be : An other brand of coorporate in same area different product
--  business : SARIS
--  designation : Soci�t� Agricole de Raffinage Industriel du Sucre du Congo
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS businesses;
GO
CREATE TABLE businesses (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT NOT NULL DEFAULT 0 ,
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

  business		VARCHAR(45)		UNIQUE NOT NULL ,
  designation	varchar(255)	DEFAULT NULL ,
  
  -- builded year of businesses
  builded		INT DEFAULT YEAR(GETDATE()) CHECK (builded >= 1900),
  -- specified if it is the main businesses of all defined
  main			BIT DEFAULT 0,
  activated		BIT DEFAULT 1,
  -- path file name of businesses logo
  logoPath		VARCHAR(512) DEFAULT NULL,	

  -- country, state, city base on existing world database
  country		INT DEFAULT NULL,
  [state]		INT DEFAULT NULL,
  [city]		INT DEFAULT NULL,
  
  -- entity to which refer the business
  entity		VARCHAR(45)	NOT NULL,

  -- MANAGING KEYS
  CONSTRAINT pk_businesses_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
  CONSTRAINT fk_businesses_country FOREIGN KEY (country) REFERENCES countries (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_businesses_state FOREIGN KEY ([state]) REFERENCES states (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_businesses_city FOREIGN KEY ([city]) REFERENCES cities (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_businesses_entity FOREIGN KEY (entity) REFERENCES entities (entity) ON UPDATE CASCADE
  
);

GO
CREATE TRIGGER tgr_businesses_changed ON businesses
	AFTER UPDATE AS UPDATE businesses
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_businesses_id ON businesses (id ASC);
CREATE UNIQUE INDEX ui_businesses_business ON businesses (entity ASC, business ASC);

CREATE INDEX i_businesses_created ON businesses (created ASC);
CREATE INDEX i_businesses_changed ON businesses (created ASC);
GO  











-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE COMPANIES
--
-- Description : 
-- Companies contains all possible companies of a defined business which is also
-- child of a entities. Different entities can refer to same name code of business
-- and name but will differt by id. 
-- entities can have only one company of same brand. 
--
-- Dev : 
-- / ! \ When code of entity is change this one will be cascade
--
-- Exemple(s) :
-- an company can be : The main corpore that can include many of company BRALICO
--	company : BLC
--	designation : Boisson Rachfra�chissance du Congo
--
-- an company can be : An other brand of coorporate in same area different product
--  company : SARIS
--  designation : Soci�t� Agricole de Raffinage Industriel du Sucre du Congo
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS companies;
GO
CREATE TABLE companies (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT NOT NULL DEFAULT 0 ,
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

  company		VARCHAR(45)		UNIQUE NOT NULL ,
  designation	varchar(255)	DEFAULT NULL ,
  
  -- builded year of companies
  builded		INT DEFAULT YEAR(GETDATE()) CHECK (builded >= 1900),
  -- specified if it is the main companies of all defined
  main			BIT DEFAULT 0,
  activated		BIT DEFAULT 1,
  -- path file name of companies logo
  logoPath		VARCHAR(512) DEFAULT NULL,	

  -- country, state, city base on existing world database
  [state]		INT DEFAULT NULL,
  [city]		INT DEFAULT NULL,
  
  -- business id where entity and company are specified
  business		INT	NOT NULL,

  -- MANAGING KEYS
  CONSTRAINT pk_companies_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
  CONSTRAINT fk_companies_state FOREIGN KEY ([state]) REFERENCES states (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_companies_city FOREIGN KEY ([city]) REFERENCES cities (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_companies_business FOREIGN KEY (business) REFERENCES businesses (id) ON UPDATE NO ACTION
  
);

GO
CREATE TRIGGER tgr_companies_changed ON companies
	AFTER UPDATE AS UPDATE companies
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_companies_id ON companies (id ASC);
CREATE UNIQUE INDEX ui_companies_company ON companies (business ASC, company ASC);

CREATE INDEX i_companies_created ON companies (created ASC);
CREATE INDEX i_companies_changed ON companies (created ASC);
GO  






-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE ???
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS [users];
GO
CREATE TABLE [dbo].[users](
	id		INT	IDENTITY(1,1) UNIQUE,
	deleted	BIT NOT NULL DEFAULT 0 ,
	created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
	changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

	[name]	varchar(45)		NOT NULL,
	[email] varchar(255)	DEFAULT NULL,
	[emailVerified]		[datetime]	DEFAULT (getdate()),
	[image] varchar(1024)	DEFAULT (NULL)

  -- MANAGING KEYS
  CONSTRAINT pk_user_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
);

GO
CREATE TRIGGER tgr_users_changed ON users
	AFTER UPDATE AS UPDATE users
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_users_id ON users (id ASC);
CREATE INDEX ui_users_name ON users (name ASC);
CREATE INDEX ui_users_email ON users (email ASC);

CREATE INDEX i_users_created ON users (created ASC);
CREATE INDEX i_users_changed ON users (created ASC);
GO  








-------------------------------------------------------------------------------
--
-- CREACTION DE LA TABLE ???
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
--GO
--DROP TABLE IF EXISTS ???;
--GO





-------------------------------------------------------------------------------
--
-- Table structure for table doc_explorer
--
--GO
--DROP TABLE IF EXISTS doc_explorer;
--GO
--CREATE TABLE doc_explorer (
--  dc_id INT NOT NULL IDENTITY,
--  dc_company VARCHAR(45) NOT NULL ,
--  dc_processus VARCHAR(45)NOT NULL ,
--  dc_type VARCHAR(45)NOT NULL ,
--  dc_designation varchar(255) DEFAULT NULL ,
--  dc_version varchar(45) DEFAULT NULL ,
--  dc_comment text,
--  dc_link varchar(512) NOT NULL ,
--  dc_approuved date DEFAULT NULL ,
--  dc_activated BIT NOT NULL DEFAULT 1 ,
--  dc_created datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
--  dc_changed datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
--  CONSTRAINT PK_doc_explorer_dc PRIMARY KEY CLUSTERED (dc_id, dc_company, dc_processus, dc_type),
--  CONSTRAINT dc_company FOREIGN KEY (dc_company) REFERENCES company (c_company) ON UPDATE NO ACTION,
--  CONSTRAINT dc_processus FOREIGN KEY (dc_processus) REFERENCES processus (p_processus) ON UPDATE CASCADE,
--  CONSTRAINT dc_type FOREIGN KEY (dc_type) REFERENCES doc_type (dct_type) ON UPDATE CASCADE
--)
--GO
--CREATE TRIGGER tgr_doc_explorer_dc_changed ON doc_explorer
--	AFTER UPDATE AS UPDATE doc_explorer
--	SET dc_changed = GETDATE()
--	WHERE dc_id IN (SELECT DISTINCT dc_id FROM Inserted)
--GO
--CREATE UNIQUE INDEX ui_dc_id ON doc_explorer (dc_id ASC);
--CREATE INDEX i_company ON doc_explorer (dc_company, dc_processus, dc_link);
--CREATE INDEX i_doc_type ON doc_explorer (dc_type);
--CREATE INDEX i_processus ON doc_explorer (dc_processus);
--GO  



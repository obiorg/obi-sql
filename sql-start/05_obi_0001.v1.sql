

-------------------------------------------------------------------------------
--
-- CREATION DE LA BASE DE DONNEE OBI
--
-------------------------------------------------------------------------------
USE master;

DECLARE @kill varchar(8000) = '';  
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
FROM sys.dm_exec_sessions
WHERE database_id  = db_id('OBI')

EXEC(@kill);

GO
DROP DATABASE IF EXISTS OBI
GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'OBI')
	BEGIN
		RAISERROR (N'Table OBI not exists !',10,1) WITH NOWAIT
    	USE master;
		CREATE DATABASE OBI
    END;
GO

USE OBI;
GO


-------------------------------------------------------------------------------
--
-- CREATION DE LA TABLE loc_regions
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS loc_regions;
GO
CREATE TABLE loc_regions (
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
-- CREATION DE LA TABLE loc_subregions
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS loc_subregions;
GO
CREATE TABLE loc_subregions (
  id INT NOT NULL IDENTITY(1,1) UNIQUE,
  [name] varchar(100)   NOT NULL,
  translations text  ,
  region_id INT NOT NULL,
  created_at datetime NULL DEFAULT NULL,
  updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  flag bit NOT NULL DEFAULT '1',
  wikiDataId varchar(255)   DEFAULT NULL ,
  PRIMARY KEY (id),
  CONSTRAINT loc_subregion_continent_final FOREIGN KEY (region_id) REFERENCES loc_regions (id)
)
GO
CREATE INDEX loc_subregion_continent ON loc_subregions (region_id ASC);
GO 




-------------------------------------------------------------------------------
--
-- CREATION DE LA TABLE loc_countries
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS loc_countries;
GO
CREATE TABLE loc_countries (
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

  CONSTRAINT country_continent_final FOREIGN KEY (region_id) REFERENCES loc_regions (id),
  CONSTRAINT country_subregion_final FOREIGN KEY (subregion_id) REFERENCES loc_subregions (id)
)
GO
CREATE  INDEX country_continent ON loc_countries (region_id ASC);
CREATE  INDEX country_subregion ON loc_countries (subregion_id ASC);
GO 




-------------------------------------------------------------------------------
--
-- CREATION DE LA TABLE loc_states
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS loc_states;
GO
CREATE TABLE loc_states (
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
  CONSTRAINT country_region_final FOREIGN KEY (country_id) REFERENCES loc_countries (id)
) 
GO
CREATE INDEX country_region ON loc_states (country_id ASC);
GO 


-------------------------------------------------------------------------------
--
-- CREATION DE LA TABLE loc_cities
--
-- Description : 
-- 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS loc_cities;
GO
CREATE TABLE loc_cities(
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
  CONSTRAINT loc_cities_ibfk_1 FOREIGN KEY (state_id) REFERENCES loc_states (id),
  CONSTRAINT loc_cities_ibfk_2 FOREIGN KEY (country_id) REFERENCES loc_countries (id)
)
GO
CREATE INDEX loc_cities_test_ibfk_1 ON loc_cities (state_id ASC);
CREATE INDEX loc_cities_test_ibfk_2 ON loc_cities (country_id ASC);
GO  


-------------------------------------------------------------------------------
--
-- CREATION DE LA TABLE locations
--
-- Description : 
-- location allow to group and define a unique point of identification
-- base on loc_regions, loc_subregions, loc_countries, loc_states, loc_cities, road, number, 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS locations;
GO
CREATE TABLE locations (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  [location] varchar(45)  DEFAULT NULL,
  designation varchar(255)  DEFAULT NULL,

  -- Arrange as location group
  [group]	varchar(45)		DEFAULT NULL, 

  country	INT NOT NULL,
  [state]	INT NOT NULL,
  [city]	INT NOT NULL,

  [address]	VARCHAR(255)	DEFAULT NULL,
  address1	VARCHAR(255)	DEFAULT NULL,
  address3	VARCHAR(255)	DEFAULT NULL,

  [bloc]	varchar(45)		DEFAULT NULL,
  [floor]	INT				DEFAULT NULL,
  [number]	varchar(45)		DEFAULT NULL,

  
  -- MANAGING KEYS
  CONSTRAINT pk_locations_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
  CONSTRAINT fk_locations_country FOREIGN KEY (country) REFERENCES loc_countries (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_locations_state FOREIGN KEY (state) REFERENCES loc_states (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_locations_city FOREIGN KEY (city) REFERENCES loc_cities (id) ON UPDATE NO ACTION, 
);

GO
CREATE TRIGGER tgr_locations_changed ON locations
	AFTER UPDATE AS UPDATE locations
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_locations_id ON locations (id ASC);

CREATE INDEX i_locations_location ON locations (location ASC);
CREATE INDEX i_locations_country ON locations (country ASC);
CREATE INDEX i_locations_state ON locations (state ASC);
CREATE INDEX i_locations_city ON locations (city ASC);
CREATE INDEX i_locations_created ON locations (created ASC);
CREATE INDEX i_locations_changed ON locations (changed ASC);
GO  




-------------------------------------------------------------------------------
--
-- CREATION DE LA TABLE ENTITIES
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
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

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
  [location]	INT DEFAULT NULL,
  
  -- MANAGING KEYS
  CONSTRAINT pk_entities_entity PRIMARY KEY CLUSTERED (entity asc),

  -- Foreign keys
  CONSTRAINT fk_entities_location FOREIGN KEY (location) REFERENCES locations (id) ON UPDATE NO ACTION
  
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
CREATE INDEX i_entities_changed ON entities (changed ASC);
GO  








-------------------------------------------------------------------------------
--
-- CREATION DE LA TABLE BUSINESSES
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
--	designation : Boisson Rachfraîchissance du Congo
--
-- an business can be : An other brand of coorporate in same area different product
--  business : SARIS
--  designation : Société Agricole de Raffinage Industriel du Sucre du Congo
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS businesses;
GO
CREATE TABLE businesses (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

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
  [location]	INT DEFAULT NULL,
  
  -- entity to which refer the business
  entity		VARCHAR(45)	NOT NULL,

  -- MANAGING KEYS
  CONSTRAINT pk_businesses_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
  CONSTRAINT fk_businesses_location FOREIGN KEY (location) REFERENCES locations (id) ON UPDATE NO ACTION,
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
CREATE INDEX i_businesses_changed ON businesses (changed ASC);
GO  











-------------------------------------------------------------------------------
--
-- CREATION DE LA TABLE COMPANIES
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
--	designation : Boisson Rachfraîchissance du Congo
--
-- an company can be : An other brand of coorporate in same area different product
--  company : SARIS
--  designation : Société Agricole de Raffinage Industriel du Sucre du Congo
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS companies;
GO
CREATE TABLE companies (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

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
  [location]	INT DEFAULT NULL,
  
  -- business id where entity and company are specified
  business		INT	NOT NULL,

  -- MANAGING KEYS
  CONSTRAINT pk_companies_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
  CONSTRAINT fk_companies_location FOREIGN KEY (location) REFERENCES locations (id) ON UPDATE NO ACTION,
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
CREATE INDEX i_companies_changed ON companies (changed ASC);
GO  


















-------------------------------------------------------------------------------
--
-- CREATE TABLE user_hashing_algorithms
--
-- Description : 
-- user_hashing_algorithms refers to hashing algorithms
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_hashing_algorithms;
GO
CREATE TABLE user_hashing_algorithms (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  algorithmName	VARCHAR(10)		NOT NULL ,
  designation	varchar(255)	DEFAULT NULL ,
  
  
  -- MANAGING KEYS
  CONSTRAINT pk_user_hashing_algorithms_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys

);

GO
CREATE TRIGGER tgr_user_hashing_algorithms_changed ON user_hashing_algorithms
	AFTER UPDATE AS UPDATE user_hashing_algorithms
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_hashing_algorithms_id ON user_hashing_algorithms (id ASC);
CREATE INDEX i_user_hashing_algorithms_name ON user_hashing_algorithms (algorithmName ASC);
CREATE INDEX i_user_hashing_algorithms_created ON user_hashing_algorithms (created ASC);
CREATE INDEX i_user_hashing_algorithms_changed ON user_hashing_algorithms (changed ASC);
GO  



-------------------------------------------------------------------------------
--
-- CREATE TABLE user_email_verified
--
-- Description : 
-- user_email_verified refers to email validation status
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_email_verified;
GO
CREATE TABLE user_email_verified (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  statusDescription	VARCHAR(45)	 DEFAULT NULL,
  
  -- MANAGING KEYS
  CONSTRAINT pk_user_email_verified_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys

);

GO
CREATE TRIGGER tgr_user_email_verified_changed ON user_email_verified
	AFTER UPDATE AS UPDATE user_email_verified
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_email_verified_id ON user_email_verified (id ASC);
CREATE INDEX i_user_email_verified_statusDescription ON user_email_verified (statusDescription ASC);
CREATE INDEX i_user_email_verified_created ON user_email_verified (created ASC);
CREATE INDEX i_user_email_verified_changed ON user_email_verified (changed ASC);
GO  


-------------------------------------------------------------------------------
--
-- CREATE TABLE user_login_data
--
-- Description : 
-- user login data contain user informations such as login name, password hash
-- mean create by specific alogirthm, password salt mean specific string to 
-- unsured no user with same hashed password, hashalgorithmid refer to the 
-- algorithm used.
-- store email address, email validation status, confirmation token and 
-- timestamp of generation token,
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_login_data;
GO
CREATE TABLE user_login_data (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Minimal connection mecanism
  loginName		VARCHAR(20)		NOT NULL,
  passwordHash	varchar(255)	NOT NULL,
  passwordSalt	varchar(255)	NOT NULL,
  hashAlgorithm	INT				NOT NULL,
  
  -- email / token mecanism
  [email]				varchar(255)	NOT NULL,
  [emailVerified]		INT				NULL,
  [tokenConfirmation]	varchar(255)	NULL,
  [tokenGenerationTime]	datetime		NULL,

  -- recovery mecanism
  [tokenPasswordRecovery]	varchar(255) DEFAULT NULL,
  [tokenTimeRecovery]		datetime DEFAULT NULL,
  
  -- avatar
  [image]				varchar(1024)	DEFAULT (NULL),

  -- MANAGING KEYS
  CONSTRAINT pk_user_login_data_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
  CONSTRAINT fk_user_login_data_hashAlgorithm FOREIGN KEY ([hashAlgorithm]) REFERENCES user_hashing_algorithms (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_user_login_data_emailStatus FOREIGN KEY ([emailVerified]) REFERENCES user_email_verified (id) ON UPDATE NO ACTION,

);

GO
CREATE TRIGGER tgr_user_login_data_changed ON user_login_data
	AFTER UPDATE AS UPDATE user_login_data
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_login_data_id ON user_login_data (id ASC);
CREATE INDEX i_user_login_data_loginName ON user_login_data (loginName ASC);
CREATE INDEX i_user_login_data_email ON user_login_data (email ASC);
CREATE INDEX i_user_login_data_created ON user_login_data (created ASC);
CREATE INDEX i_user_login_data_changed ON user_login_data (changed ASC);
GO  












-------------------------------------------------------------------------------
--
-- CREATE TABLE user_external_providers
--
-- Description : 
-- user_external_providers refers providers to connect to web content over 
-- existing credentials.
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_external_providers;
GO

CREATE TABLE user_external_providers (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  [name]	VARCHAR(45)	 NOT NULL,
  [wsEndPoint]	VARCHAR(255)	 DEFAULT NULL,
  
  -- MANAGING KEYS
  CONSTRAINT pk_user_external_providers_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys

);

GO
CREATE TRIGGER tgr_user_external_providers_changed ON user_external_providers
	AFTER UPDATE AS UPDATE user_external_providers
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_external_providers_id ON user_external_providers (id ASC);
CREATE INDEX i_user_external_providers_statusDescription ON user_external_providers ([name] ASC);
CREATE INDEX i_user_external_providers_created ON user_external_providers (created ASC);
CREATE INDEX i_user_external_providers_changed ON user_external_providers (changed ASC);
GO  




-------------------------------------------------------------------------------
--
-- CREATE TABLE user_login_data_external
--
-- Description : 
-- user login data external contain external provider infos
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_login_data_external;
GO
CREATE TABLE user_login_data_external (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- provider mecanism
  [externalProvider]	INT NOT NULL,
  [tokenExternalProvider]	varchar(255) NOT NULL,
  

  -- MANAGING KEYS
  CONSTRAINT pk_user_login_data_external_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
  CONSTRAINT fk_user_login_data_external_externalProvider FOREIGN KEY ([externalProvider]) REFERENCES user_external_providers (id) ON UPDATE NO ACTION,

);

GO
CREATE TRIGGER tgr_user_login_data_external_changed ON user_login_data_external
	AFTER UPDATE AS UPDATE user_login_data_external
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_login_data_external_id ON user_login_data_external (id ASC);
CREATE INDEX i_user_login_data_external_loginName ON user_login_data_external ([externalProvider] ASC);
CREATE INDEX i_user_login_data_external_created ON user_login_data_external (created ASC);
CREATE INDEX i_user_login_data_external_changed ON user_login_data_external (changed ASC);
GO  









-------------------------------------------------------------------------------
--
-- CREATE TABLE user_permissions
--
-- Description : 
-- user permissions refer to application permissions to allow different acces
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_permissions;
GO
CREATE TABLE user_permissions (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- 
  [name]		VARCHAR(45)		NOT NULL,
  [designation]	VARCHAR(255)	NULL,
  [parent]		INT				NULL,		-- indicate parent id, null if not
 

  -- MANAGING KEYS
  CONSTRAINT pk_user_permissions_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
  CONSTRAINT fk_user_permissions_parent FOREIGN KEY ([parent]) REFERENCES user_permissions (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_user_permissions_changed ON user_permissions
	AFTER UPDATE AS UPDATE user_permissions
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_permissions_id ON user_permissions (id ASC);
CREATE INDEX i_user_permissions_name ON user_permissions ([name] ASC);
CREATE INDEX i_user_permissions_designation ON user_permissions (designation ASC);
CREATE INDEX i_user_permissions_parent ON user_permissions (parent ASC);
CREATE INDEX i_user_permissions_created ON user_permissions (created ASC);
CREATE INDEX i_user_permissions_changed ON user_permissions (changed ASC);
GO  







-------------------------------------------------------------------------------
--
-- CREATE TABLE user_roles
--
-- Description : 
-- user roles refer to a list of groups of permissions
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_roles;
GO
CREATE TABLE user_roles (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Application limit
  entity		varchar(45) NULL,
  business		INT NULL,
  comapny		INT NULL,

  [name]		varchar(45) NOT NULL,	-- group name
  [description] varchar(255) NULL,		-- short description


  -- MANAGING KEYS
  CONSTRAINT pk_user_roles_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
  CONSTRAINT fk_user_roles_entity FOREIGN KEY (entity) REFERENCES entities (entity) ON UPDATE NO ACTION,
  CONSTRAINT fk_user_roles_buisiness FOREIGN KEY (business) REFERENCES businesses (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_user_roles_company FOREIGN KEY (comapny) REFERENCES companies (id) ON UPDATE NO ACTION,


 );

GO
CREATE TRIGGER tgr_user_roles_changed ON user_roles
	AFTER UPDATE AS UPDATE user_roles
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_roles_id ON user_roles (id ASC);
CREATE INDEX i_user_roles_entity ON user_roles (entity ASC);
CREATE INDEX i_user_roles_business ON user_roles (business ASC);
CREATE INDEX i_user_roles_comapny ON user_roles (comapny ASC);
CREATE INDEX i_user_roles_ent_bui_com ON user_roles (entity ASC, business ASC, comapny ASC);
CREATE INDEX i_user_roles_name ON user_roles ([name] ASC);
CREATE INDEX i_user_roles_description ON user_roles ([description] ASC);
CREATE INDEX i_user_roles_created ON user_roles (created ASC);
CREATE INDEX i_user_roles_changed ON user_roles (changed ASC);
GO  




-------------------------------------------------------------------------------
--
-- CREATE TABLE user_role_permissions
--
-- Description : 
-- user role permissions refer to a list of role which should allow to group 
-- permissions. This make thing easy to apply same access rules to different users
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_role_permissions;
GO
CREATE TABLE user_role_permissions (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  
  -- Application limit
  entity		varchar(45) NULL,
  business		INT NULL,
  comapny		INT NULL,

  permission	INT NOT NULL,
  [role]		INT NOT NULL,


  -- MANAGING KEYS
  CONSTRAINT pk_user_role_permissions_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  -- Foreign keys
  CONSTRAINT fk_user_role_permissions_entity FOREIGN KEY (entity) REFERENCES entities (entity) ON UPDATE NO ACTION,
  CONSTRAINT fk_user_role_permissions_buisiness FOREIGN KEY (business) REFERENCES businesses (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_user_role_permissions_company FOREIGN KEY (comapny) REFERENCES companies (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_user_role_permissions_permission FOREIGN KEY (permission) REFERENCES user_permissions (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_user_role_permissions_role FOREIGN KEY ([role]) REFERENCES user_roles (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_user_role_permissions_changed ON user_role_permissions
	AFTER UPDATE AS UPDATE user_role_permissions
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_role_permissions_id ON user_role_permissions (id ASC);
CREATE INDEX i_user_role_permissions_entity ON user_role_permissions (entity ASC);
CREATE INDEX i_user_role_permissions_business ON user_role_permissions (business ASC);
CREATE INDEX i_user_role_permissions_comapny ON user_role_permissions (comapny ASC);
CREATE INDEX i_user_role_permissions_ent_bui_com ON user_roles (entity ASC, business ASC, comapny ASC);
CREATE INDEX i_user_role_permissions_permission ON user_role_permissions (permission ASC);
CREATE INDEX i_user_role_permissions_role ON user_role_permissions ([role] ASC);
CREATE INDEX i_user_role_permissions_created ON user_role_permissions (created ASC);
CREATE INDEX i_user_role_permissions_changed ON user_role_permissions (changed ASC);
GO  











-------------------------------------------------------------------------------
--
-- CREATE TABLE user_account
--
-- Description : 
-- user account refer to main account informations about user which are mandatory
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_account;
GO
CREATE TABLE user_account (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Name
  firstName		VARCHAR(45)		NOT NULL,
  lastName		varchar(45)		NOT NULL,
  middleName	varchar(45)		NULL,
  initialLetter	varchar(45)		NULL,
  
  -- complements
  [genre]					char(1)			NOT NULL,
  [dateOfBirth]				date			NOT NULL,

  -- MANAGING KEYS
  CONSTRAINT pk_user_account_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys
);

GO
CREATE TRIGGER tgr_user_account_changed ON user_account
	AFTER UPDATE AS UPDATE user_account
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_account_id ON user_account (id ASC);
CREATE INDEX i_user_account_firstName ON user_account (firstName ASC);
CREATE INDEX i_user_account_lastName ON user_account (lastName ASC);
CREATE INDEX i_user_account_genre ON user_account (genre ASC);
CREATE INDEX i_user_account_dateOfBirth ON user_account (dateOfBirth ASC);
CREATE INDEX i_user_account_created ON user_account (created ASC);
CREATE INDEX i_user_account_changed ON user_account (changed ASC);
GO  





-------------------------------------------------------------------------------
--
-- CREATE TABLE user_account_role
--
-- Description : 
-- user account role refer to user associated with roles 
--
-- Exemple(s) :
-- see https://vertabelo.com/blog/user-authentication-module/ for mecanism
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS user_account_role;
GO
CREATE TABLE user_account_role (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  
  [user]		INT NOT NULL,
  [role]		INT NOT NULL,


  -- MANAGING KEYS
  CONSTRAINT pk_user_account_role_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  -- Foreign keys
  CONSTRAINT fk_user_account_role_user FOREIGN KEY ([user]) REFERENCES user_account (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_user_account_role_role FOREIGN KEY ([role]) REFERENCES user_roles (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_user_account_role_changed ON user_account_role
	AFTER UPDATE AS UPDATE user_account_role
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_user_account_role_id ON user_account_role (id ASC);
CREATE INDEX i_user_account_role_user ON user_account_role ([user] ASC);
CREATE INDEX i_user_account_role_role ON user_account_role ([role] ASC);
CREATE INDEX i_user_account_role_created ON user_account_role (created ASC);
CREATE INDEX i_user_account_role_changed ON user_account_role (changed ASC);
GO  






-------------------------------------------------------------------------------
--
-- CREATE TABLE mach_drivers
--
-- Description : 
-- Pour accéder aux contrôleurs de bas niveau, cela requière la validation d’un
-- support de communication (méthode de communication). Nous décrirons cela par
-- un driver.
-- Un driver va permettre de décrire le moyen utiliser pour atteindre et entrer
-- en communication avec une machine

--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS mach_drivers;
GO
CREATE TABLE mach_drivers (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  
  [driver]		varchar(15) not null,
  [designation]	varchar(255) DEFAULT NULL,


  -- MANAGING KEYS
  CONSTRAINT pk_mach_drivers_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  -- Foreign keys
);

GO
CREATE TRIGGER tgr_mach_drivers_changed ON mach_drivers
	AFTER UPDATE AS UPDATE mach_drivers
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_mach_drivers_id ON mach_drivers (id ASC);
CREATE INDEX i_mach_drivers_type ON mach_drivers ([driver] ASC);
CREATE INDEX i_mach_drivers_designation ON mach_drivers ([designation] ASC);
CREATE INDEX i_mach_drivers_created ON mach_drivers (created ASC);
CREATE INDEX i_mach_drivers_changed ON mach_drivers (changed ASC);
GO  





-------------------------------------------------------------------------------
--
-- CREATE TABLE machines
--
-- Description : 
-- machines refer to a description access to machine. Do note mix machine and
-- equipement which are totally to different concept. 
-- Machine olding information regarding contrôler (CPU)
-- For MQTT please see https://www.hivemq.com/blog/implementing-mqtt-in-java/
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS machines;
GO
CREATE TABLE machines (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company] INT NOT NULL,

  -- Ethernet informations
  [address]	VARCHAR(512)	NOT NULL,	-- can be ip address or url in case of mqtt or webook system defined by 
  [mask]	VARCHAR(15) DEFAULT NULL,	-- NOT USE
  [dns]		VARCHAR(45)	DEFAULT NULL,	-- NOT USE

  [ipv6]	VARCHAR(45)	DEFAULT NULL,	-- NOT USE
  [port]	INT DEFAULT 0,				-- NOT USE

  [name]	VARCHAR(45) DEFAULT NULL,

  -- Rack system as default
  rack		INT DEFAULT 1,	
  slot		INT Default 2,
  [driver]	INT NOT NULL,

  -- MQTT related options informations
  mqqt		bit DEFAULT 0,						-- mqtt indicate machine is mqtt
  mqqt_user	VARCHAR(45)	DEFAULT NULL,			-- mqtt option username
  mqqt_password	VARCHAR(512)	DEFAULT NULL,	-- mqtt option password as code   

  -- Webhook 
  webhook			bit DEFAULT 0,				-- Indicate URL is a webhook
  webhook_secret	varchar(512)	DEFAULT NULL,	-- webhook endpointSecret  https://groups.google.com/a/lists.stripe.com/g/api-discuss/c/dSUfiwjEMsI / https://dev.to/jackynote/a-step-by-step-guide-to-implement-webhook-workflows-in-flight-booking-systems-1lpm / https://slack.dev/java-slack-sdk/guides/incoming-webhooks

  -- Other informations
  [bus]		INT DEFAULT 0,				-- 
  [description]	VARCHAR(512) DEFAULT NULL,	-- More comment


  -- MANAGING KEYS
  CONSTRAINT pk_machines_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_machines_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_machines_driver FOREIGN KEY ([driver]) REFERENCES mach_drivers (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_machines_changed ON machines
	AFTER UPDATE AS UPDATE machines
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_machines_id ON machines (id ASC);
CREATE INDEX i_machines_company ON machines ([company] ASC);
CREATE INDEX i_machines_address ON machines ([address] ASC);
CREATE INDEX i_machines_company_address ON machines (company asc, [address] ASC);
CREATE INDEX i_machines_created ON machines (created ASC);
CREATE INDEX i_machines_changed ON machines (changed ASC);
GO  






-------------------------------------------------------------------------------
--
-- CREATE TABLE alarm_groups
--
-- Description : 
-- alarm group refer to a grouping of alarm of same kind or element
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS alarm_groups;
GO
CREATE TABLE alarm_groups (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company] INT NOT NULL,

  -- Ethernet informations
  [group]		varchar(45)		NOT NULL,			-- 
  comment		VARCHAR(512)	DEFAULT NULL,		-- detail comment

  
  -- MANAGING KEYS
  CONSTRAINT pk_alarm_groups_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_alarm_groups_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_alarm_groups_changed ON alarm_groups
	AFTER UPDATE AS UPDATE alarm_groups
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_alarm_groups_id ON alarm_groups (id ASC);
CREATE UNIQUE INDEX ui_alarm_groups_company_group ON alarm_groups (company asc, [group] asc);
CREATE INDEX i_alarm_groups_company ON alarm_groups ([company] ASC);
CREATE INDEX i_alarm_groups_group ON alarm_groups ([group] ASC);
CREATE INDEX i_alarm_groups_created ON alarm_groups (created ASC);
CREATE INDEX i_alarm_groups_changed ON alarm_groups (changed ASC);
GO  












-------------------------------------------------------------------------------
--
-- CREATE TABLE alarm_render
--
-- Description : 
-- alarm render refer to a style of rendering alarm
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS alarm_render;
GO
CREATE TABLE alarm_render (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company] INT NOT NULL,

  -- Ethernet informations
  [render]		varchar(45)		NOT NULL,					--  short code
  [name]		varchar(255)	DEFAULT NULL,				-- specify name
  [color]		varchar(45)		DEFAULT '255;255;0',		-- text color yellow
  [background]	varchar(45)		DEFAULT '255;0;0',			-- background color red
  [blink]		bit				DEFAULT 0,					-- enable blinking
  [colorBlink]	varchar(45)		DEFAULT '255;0;0',			-- text color yellow
  [backgroundBlink]	varchar(45)		DEFAULT '255;255;0',	-- text color yellow
  comment		VARCHAR(512)	DEFAULT NULL,		-- detail comment

  
  -- MANAGING KEYS
  CONSTRAINT pk_alarm_render_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_alarm_render_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_alarm_render_changed ON alarm_render
	AFTER UPDATE AS UPDATE alarm_render
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_alarm_render_id ON alarm_render (id ASC);
CREATE UNIQUE INDEX ui_alarm_render_company_group ON alarm_render (company asc, [render] asc);
CREATE INDEX i_alarm_render_company ON alarm_render ([company] ASC);
CREATE INDEX i_alarm_render_render ON alarm_render ([render] ASC);
CREATE INDEX i_alarm_render_created ON alarm_render (created ASC);
CREATE INDEX i_alarm_render_changed ON alarm_render (changed ASC);
GO  











-------------------------------------------------------------------------------
--
-- CREATE TABLE alarm_classes
--
-- Description : 
-- alarm classes refer to a class of alarm like warning, errors, system,...
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS alarm_classes;
GO
CREATE TABLE alarm_classes (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company] INT NOT NULL,

  -- Ethernet informations
  [class]		varchar(45)		NOT NULL,			-- 
  [name]		varchar(255)	DEFAULT NULL,		-- 
  [render]		INT DEFAULT NULL,					-- rendering style
  comment		VARCHAR(512)	DEFAULT NULL,		-- detail comment

  
  -- MANAGING KEYS
  CONSTRAINT pk_alarm_classes_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_alarm_classes_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_alarm_classes_alarm_render FOREIGN KEY (render) REFERENCES alarm_render (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_alarm_classes_changed ON alarm_classes
	AFTER UPDATE AS UPDATE alarm_classes
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_alarm_classes_id ON alarm_classes (id ASC);
CREATE UNIQUE INDEX ui_alarm_classes_company_class ON alarm_classes (company asc, [class] asc);
CREATE INDEX i_alarm_classes_company ON alarm_classes ([company] ASC);
CREATE INDEX i_alarm_classes_class ON alarm_classes ([class] ASC);
CREATE INDEX i_alarm_classes_created ON alarm_classes (created ASC);
CREATE INDEX i_alarm_classes_changed ON alarm_classes (changed ASC);
GO  





-------------------------------------------------------------------------------
--
-- CREATE TABLE alarms
--
-- Description : 
-- alarms refer to a alam definition corresponding to a symbol and default expression
-- a path file csv where to find language to use. 
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS alarms;
GO
CREATE TABLE alarms (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company]		INT NOT NULL,

  -- Ethernet informations
  [alarm]		varchar(45)		NOT NULL,			-- symbolic name
  [name]		varchar(255)	DEFAULT NULL,		-- Name of alarme (definition)
  [descirption]	varchar(512)	DEFAULT NULL,		-- default text description (text alarm)
  [group]		INT DEFAULT NULL,					-- associated group
  [class]		INT DEFAULT NULL,					-- class of alarm (error, warning, information,...)
  [language]	INT DEFAULT NULL,					-- specify default language number
  comment		VARCHAR(512)	DEFAULT NULL,		-- detail comment

  
  -- MANAGING KEYS
  CONSTRAINT pk_alarms_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_alarms_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_alarms_alarm_group FOREIGN KEY ([group]) REFERENCES alarm_groups (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_alarms_alarm_class FOREIGN KEY (class) REFERENCES alarm_classes (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_alarms_changed ON alarms
	AFTER UPDATE AS UPDATE alarms
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_alarms_id ON alarms (id ASC);
CREATE UNIQUE INDEX ui_alarms_company_alarm ON alarms (company asc, [alarm] asc);
CREATE INDEX i_alarms_company ON alarms ([company] ASC);
CREATE INDEX i_alarms_alarm ON alarms ([alarm] ASC, [group] asc, class asc);
CREATE INDEX i_alarms_created ON alarms (created ASC);
CREATE INDEX i_alarms_changed ON alarms (changed ASC);
GO  










-------------------------------------------------------------------------------
--
-- CREATE TABLE tags_tables
--
-- Description : 
-- tags tables refer to a grouper of tags in order to allow to regroup element
-- in the tag register
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS tags_tables;
GO
CREATE TABLE tags_tables (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company] INT NOT NULL,

  -- Ethernet informations
  [table]		varchar(45)		NOT NULL,			-- 
  designation	varchar(255)	DEFAULT NULL,		-- 
  comment		VARCHAR(512)	DEFAULT NULL,		-- tag comment

  
  -- MANAGING KEYS
  CONSTRAINT pk_tags_tables_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_tags_tables_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_tags_tables_changed ON tags_tables
	AFTER UPDATE AS UPDATE tags_tables
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_tags_tables_id ON tags_tables (id ASC);
CREATE UNIQUE INDEX ui_tags_tables_company_table ON tags_tables (company asc, [table] asc);
CREATE INDEX i_tags_tables_company ON tags_tables ([company] ASC);
CREATE INDEX i_tags_tables_table ON tags_tables ([table] ASC);
CREATE INDEX i_tags_tables_created ON tags_tables (created ASC);
CREATE INDEX i_tags_tables_changed ON tags_tables (changed ASC);
GO  







-------------------------------------------------------------------------------
--
-- CREATE TABLE tags_types
--
-- Description : 
-- tags types refer to type of tags in way of int, bool, double, string from
-- CPU controller
-- Manage by system
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS tags_types;
GO
CREATE TABLE tags_types (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Type information
  [type]		varchar(45) NOT NULL,			-- INT, REAL, BOOL,...
  designation	varchar(45) DEFAULT NULL,	-- tag 
  [bit]			INT DEFAULT 0,		-- tag identify number of bit
  [byte]		INT DEFAULT 0,		-- tag identify number of byte
  [word]		INT DEFAULT 0,		-- tag identify number of word

  -- family 
  [group]		VARCHAR(45)	DEFAULT 'std',		-- Regroup type ex: by brand like family
  
  -- MANAGING KEYS
  CONSTRAINT pk_tags_types_id PRIMARY KEY CLUSTERED (id asc),

);

GO
CREATE TRIGGER tgr_tags_types_changed ON tags_types
	AFTER UPDATE AS UPDATE tags_types
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_tags_types_id ON tags_types (id ASC);
CREATE INDEX i_tags_types_type ON tags_types ([type] ASC);
CREATE INDEX i_tags_types_group ON tags_types ([group] ASC);
CREATE INDEX i_tags_types_created ON tags_types (created ASC);
CREATE INDEX i_tags_types_changed ON tags_types (changed ASC);
GO  






-------------------------------------------------------------------------------
--
-- CREATE TABLE tags_memories
--
-- Description : 
-- tags memories refer to area of memomries requested to reach local, db,...
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS tags_memories;
GO
CREATE TABLE tags_memories (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- area memories informations
  [name]	varchar(45) NOT NULL,			-- local, db,...
  comment	varchar(255) DEFAULT NULL,		 
  
  -- MANAGING KEYS
  CONSTRAINT pk_tags_memories_id PRIMARY KEY CLUSTERED (id asc),

);

GO
CREATE TRIGGER tgr_tags_memories_changed ON tags_memories
	AFTER UPDATE AS UPDATE tags_memories
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_tags_memories_id ON tags_memories (id ASC);
CREATE INDEX i_tags_memories_name ON tags_memories ([name] ASC);
CREATE INDEX i_tags_memories_created ON tags_memories (created ASC);
CREATE INDEX i_tags_memories_changed ON tags_memories (changed ASC);
GO  









-------------------------------------------------------------------------------
--
-- CREATE TABLE tags
--
-- Description : 
-- tags refer to one autoamtise data collect from a controller defined by 
-- machines
--
-- Exemple(s) :
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS tags;
GO
CREATE TABLE tags (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company] INT NOT NULL,

  -- informations
  [table]	INT NULL,					-- tag table
  [name]	VARCHAR(255) NOT NULL,		-- tag name


  machine	INT NOT NULL,				-- tag connection to machine
  [type]	INT NOT NULL,				-- tag type
  memory	INT NOT NULL,				-- tag memory "Local" or "Data Bloc"

  db		INT	NULL DEFAULT 0,		-- tag data bloc number ex DB50
  byte		INT NULL DEFAULT 0,		-- tag data bloc byte	ex DBW20, DBD20, DBX20 - depending on type and memory
  [bit]		INT NULL DEFAULT 0,		-- tag data bloc bit	ex .0 .1 .2 .3 .4 .5 .6 .7

  -- Collecting data
  active	bit NULL DEFAULT 0,				-- Idicate if activate for collecting
  cycle		INT NULL DEFAULT 1,				-- tag acquisition cycle in second
  delta		bit NULL DEFAULT 0,				-- value will be collecting only if delta is applied

  -- Value of delta when set
  deltaFloat	FLOAT(53) NULL DEFAULT 0.0,		-- indicate double value as absolute for a delta variation in case of delta activation 
  deltaInt		INT NULL DEFAULT 0,				-- indicate integer value as absolute for a delta variation in case of delta activation 
  deltaBool	INT NULL DEFAULT 0,					-- detecting delta (0>on reverse, 1>on up 0 to 1, 2>on down 1 to 0 NB : any is not take in account - you need to disbale delta)
  deltaDateTime	bigint NULL DEFAULT 0,			-- delta second in order to accept collectigng
 
  -- Valeur collectées
  vFloat	FLOAT(53) NULL DEFAULT 0.0,		-- indicate double value
  vInt		INT NULL DEFAULT 0,				-- Indicate  an int value
  vBool		bit	NULL DEFAULT 0,				-- Indicate an boolean value
  vStr		varchar(255),					-- Indicate a varachar value
  vDateTime	datetime NULL DEFAULT CURRENT_TIMESTAMP, -- Indicate a value collecting as datetime
  vStamp	datetime NULL DEFAULT CURRENT_TIMESTAMP, -- Stamping time of collecting data

  -- Default behavior
  vDefault			bit NULL DEFAULT 0,				-- Enable if activae default value use
  vFloatDefault		FLOAT(53) NULL DEFAULT 0.0,		-- indicate double value
  vIntDefault		INT NULL DEFAULT 0,				-- Indicate  an int value
  vBoolDefault		bit	NULL DEFAULT 0,				-- Indicate an boolean value
  vStrDefault		varchar(255),					-- Indicate a varachar value
  vDateTimeDefault	datetime NULL DEFAULT CURRENT_TIMESTAMP, -- Indicate a value collecting as datetime
  vStampDefault 	datetime NULL DEFAULT CURRENT_TIMESTAMP, -- Stamping time of collecting data
	
  -- Indicate a counter data
  [counter]			bit DEFAULT 0,					-- indicate a counter data
  [counterType]		INT DEFAULT 0,					-- 0 > Incrémental + Décremental + Reset, 1 > Incrémental + Reset, 2 > Decremental + Reset, 3 > Incrémental + Décremental, 4 > Incrémental, 5 > Decremental

  -- Instrument 
  [mesure]			bit DEFAULT 0,					-- Indicate a mesure data
  [mesureMin]		FLOAT(53) NULL DEFAULT 0.0,		-- specify mesure range min
  [mesureMax]		FLOAT(53) NULL DEFAULT 1.0,		-- specify mesure range min

  -- MQTT related options informations
  mqqt_topic		VARCHAR(512)	DEFAULT NULL,	-- mqtt topic specify which topics will give this informations and unsure client is created to receive this informations

  -- webhook
  webhook			VARCHAR(512)	DEFAULT NULL,	-- webhook data to access referenced by string separated by ":" 

  -- formula 
  [formula]			bit DEFAULT 0,					-- Indicate a formula tag
  [formCalculus]	VARCHAR(4096)	DEFAULT NULL,	-- indicate formula description
  [forProcessing]	INT DEFAULT NULL,				-- identicate when processing 0 > any change value, 1 > all value change, 

  -- Error State
  error				bit NULL DEFAULT 0,			-- Indique an error exist on the collection
  errorMsg			varchar(512) DEFAULT NULL,	-- Indique a message regarding error detected
  errorStamp		datetime NULL DEFAULT CURRENT_TIMESTAMP, --  -- Indicate when error was last specifying

    
  -- Alarm
  alarmEnable		bit NULL DEFAULT 0,				-- Indicate this tag is an alarm
  alarm 			INT NULL DEFAULT 0,				-- Indicate alarm number or reference

  -- Persistence
  persistence		bit NULL DEFAULT 0,			-- Indicate persistence activate or not / Note need to check cross persistence connection
  persOffsetEnable	bit NULL DEFAULT 0,			-- Indicate if offset need to be take while persistence apply
  persOffsetFloat	FLOAT(53) NULL DEFAULT 0.0,		-- indicate double value
  persOffsetInt		INT NULL DEFAULT 0,				-- Indicate  an int value
  persOffsetBool	bit	NULL DEFAULT 0,				-- Indicate an boolean value
  persOffsetDateTime	datetime NULL DEFAULT CURRENT_TIMESTAMP, -- Indicate a value collecting as datetime
  

  [comment]	VARCHAR(512) DEFAULT NULL,	-- More comment

  -- MANAGING KEYS
  CONSTRAINT pk_tags_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_tags_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_tags_table FOREIGN KEY ([table]) REFERENCES tags_tables (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_tags_machine FOREIGN KEY (machine) REFERENCES machines (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_tags_type FOREIGN KEY ([type]) REFERENCES tags_types (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_tags_memory FOREIGN KEY (memory) REFERENCES tags_memories (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_tags_alarms FOREIGN KEY (alarm) REFERENCES alarms (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_tags_changed ON tags
	AFTER UPDATE AS UPDATE tags
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_tags_id ON tags (id ASC);
CREATE INDEX i_tags_company ON tags ([company] ASC);
CREATE INDEX i_tags_tables ON tags ([table] ASC);
CREATE INDEX i_tags_name ON tags ([name] asc);
CREATE INDEX i_tags_machine ON tags ([machine] asc);
CREATE INDEX i_tags_type ON tags ([type] asc);
CREATE INDEX i_tags_memory ON tags ([memory] asc);
CREATE INDEX i_tags_db ON tags (db asc);
CREATE INDEX i_tags_byte ON tags (byte asc);
CREATE INDEX i_tags_created ON tags (created ASC);
CREATE INDEX i_tags_changed ON tags (changed ASC);
GO  







-------------------------------------------------------------------------------
--
-- CREATE TABLE pers_method
--
-- Description : 
-- peristence method refer to a technique to persist data over the system
-- this is system table
--
-- Exemple(s) : a method can be saving data as define tags in value in time
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS pers_method;
GO
CREATE TABLE pers_method (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- area memories informations
  [name]	varchar(45) NOT NULL,			
  comment	varchar(512) DEFAULT NULL,		 
  
  -- MANAGING KEYS
  CONSTRAINT pk_pers_method_id PRIMARY KEY CLUSTERED (id asc),

);

GO
CREATE TRIGGER tgr_pers_method_changed ON pers_method
	AFTER UPDATE AS UPDATE pers_method
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_pers_method_id ON pers_method (id ASC);
CREATE INDEX i_pers_method_name ON pers_method ([name] ASC);
CREATE INDEX i_pers_method_created ON pers_method (created ASC);
CREATE INDEX i_pers_method_changed ON pers_method (changed ASC);
GO  



-------------------------------------------------------------------------------
--
-- CREATE TABLE persistence
--
-- Description : 
-- peristence refer to association in between tags and available persistence 
-- technique used for this tags
--
-- Exemple(s) : 
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS persistence;
GO
CREATE TABLE persistence (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company] INT NOT NULL,


  -- area memories informations
  [tag]		INT NOT NULL,					-- refer to a tag element
  [method]	INT NOT NULL,					-- refer to a method of persistence
  activate	BIT NULL DEFAULT 0,				-- indicate if this persistence is activated
  comment	varchar(512) DEFAULT NULL,		 
  
  -- MANAGING KEYS
  CONSTRAINT pk_persistence_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_persistence_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_persistence_tag FOREIGN KEY ([tag]) REFERENCES tags (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_persistence_method FOREIGN KEY ([method]) REFERENCES pers_method (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_persistence_changed ON persistence
	AFTER UPDATE AS UPDATE persistence
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_persistence_id ON persistence (id ASC);
CREATE UNIQUE INDEX ui_persistence_company_tag_method ON persistence (company ASC, tag asc, method asc);
CREATE INDEX i_persistence_tag ON persistence ([tag] ASC);
CREATE INDEX i_persistence_method ON persistence ([method] ASC);
CREATE INDEX i_persistence_created ON persistence (created ASC);
CREATE INDEX i_persistence_changed ON persistence (changed ASC);
GO  










-------------------------------------------------------------------------------
--
-- CREATE TABLE pers_standard
--
-- Description : 
-- peristence standard refer to standard saving data for in tags a new one 
-- comming will be put bellow the preview tag. Can be fast loaded
--
-- Exemple(s) : 
-- 
-------------------------------------------------------------------------------
GO
DROP TABLE IF EXISTS pers_standard;
GO
CREATE TABLE pers_standard (
  id		INT	IDENTITY(1,1) UNIQUE,
  deleted	BIT  DEFAULT 0 ,
  created	datetime NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NULL DEFAULT CURRENT_TIMESTAMP ,

  -- Bussiness information
  [company] INT NOT NULL,

  
  -- tag informations
  [tag]		INT NOT NULL,					-- tag information
   
  -- value informations
  vFloat	FLOAT(53) NULL DEFAULT 0.0,		-- indicate double value
  vInt		INT NULL DEFAULT 0,				-- Indicate  an int value
  vBool		bit	NULL DEFAULT 0,				-- Indicate an boolean value
  vStr		varchar(255),					-- Indicate a varachar value
  vDateTime	datetime NULL DEFAULT CURRENT_TIMESTAMP, -- Indicate a value collecting as datetime
  vStamp	datetime NULL DEFAULT CURRENT_TIMESTAMP, -- Stamping time of collecting data

  -- managing state
  stampStart	datetime NULL DEFAULT CURRENT_TIMESTAMP, -- Stamp beginning of state On
  stampEnd		datetime NULL DEFAULT CURRENT_TIMESTAMP, -- Stamp beginning of state Off
  tbf			FLOAT(22) NULL DEFAULT 0.0,				 -- indicate defference between prcededing s
  ttr			FLOAT(22) NULL DEFAULT 0.0,

  -- Error State
  error				bit NULL DEFAULT 0,			-- Indique an error exist on the collection
  errorMsg			varchar(512) DEFAULT NULL,	-- Indique a message regarding error detected

  -- Compute related to stamp
  
  -- MANAGING KEYS
  CONSTRAINT pk_pers_standard_id PRIMARY KEY CLUSTERED (id asc),

  -- Foreign keys  
  CONSTRAINT fk_pers_standard_company FOREIGN KEY (company) REFERENCES companies (id) ON UPDATE NO ACTION,
  CONSTRAINT fk_pers_standard_tag FOREIGN KEY ([tag]) REFERENCES tags (id) ON UPDATE NO ACTION,
);

GO
CREATE TRIGGER tgr_pers_standard_changed ON pers_standard
	AFTER UPDATE AS UPDATE pers_standard
	SET changed = GETDATE()
	WHERE id IN (SELECT DISTINCT id FROM Inserted)
GO
CREATE UNIQUE INDEX ui_pers_standard_id ON pers_standard (id ASC);
CREATE INDEX ui_pers_standard_company_tag ON pers_standard (company ASC, tag asc);
CREATE INDEX i_pers_standard_tag ON pers_standard ([tag] ASC);
CREATE INDEX i_pers_standard_vFloat ON pers_standard (vFloat ASC);
CREATE INDEX i_pers_standard_vInt ON pers_standard (vInt ASC);
CREATE INDEX i_pers_standard_vBool ON pers_standard (vBool ASC);
CREATE INDEX i_pers_standard_vStr ON pers_standard (vStr ASC);
CREATE INDEX i_pers_standard_vDateTime ON pers_standard (vDateTime ASC);
CREATE INDEX i_pers_standard_vStamp ON pers_standard (vStamp ASC);
CREATE INDEX i_pers_standard_created ON pers_standard (created ASC);
CREATE INDEX i_pers_standard_changed ON pers_standard (changed ASC);
GO  




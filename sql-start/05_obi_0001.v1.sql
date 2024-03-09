

-------------------------------------------------------------------------------
--
-- CREACTION DE LA BASE DE DONNEE OBI
--
-------------------------------------------------------------------------------
USE master;
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
  deleted	BIT  DEFAULT 0 ,
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

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
CREATE INDEX i_user_hashing_algorithms_changed ON user_hashing_algorithms (created ASC);
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

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
CREATE INDEX i_user_email_verified_changed ON user_email_verified (created ASC);
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

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
CREATE INDEX i_user_login_data_changed ON user_login_data (created ASC);
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

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
CREATE INDEX i_user_external_providers_changed ON user_external_providers (created ASC);
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

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
CREATE INDEX i_user_login_data_external_changed ON user_login_data_external (created ASC);
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

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
CREATE INDEX i_user_permissions_changed ON user_permissions (created ASC);
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

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
CREATE INDEX i_user_roles_changed ON user_roles (created ASC);
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  
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
CREATE INDEX i_user_role_permissions_changed ON user_role_permissions (created ASC);
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,

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
CREATE INDEX i_user_account_changed ON user_account (created ASC);
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
  created	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  changed	datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  
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
CREATE INDEX i_user_account_role_changed ON user_account_role (created ASC);
GO  


USE [Master]
GO



----------------------------------------
-- SQL SOUND-BASED MATCHING (SOUNDEX) --
----------------------------------------



-----------------------
-- HOW SOUNDEX WORKS --
------------------------------------------------------------------------------------------------------------------------------

-- THE FIRST CHARACTER OF THE STRING WILL BE USED TO INITIATE MATCH-MAKING
-- THE LETTERS A, E, I, O, U, H, W, AND Y ARE IGNORED (UNLESS THEY ARE THE FIRST CHARACTER OF THE STRING)

-- THE SOUNDEX FUNCTION IS NOT CASE SENSITIVE

-- THE SOUNDEX FUNCTION WILL RETURN A FOUR-CHARACTER ALPHA-NUMERIC OUTPUT
       -- THE FIRST CHARACTER WILL BE BASED ON THE FIRST CHARACTER INPUT STRING
       -- THE SECOND THROUGH FOURTH CHARACTERS WILL BE BASED ON NUMBERS THAT REPRESENT THE LETTERS IN THE EXPRESSION

------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------
-- 01 - CREATE TEMPORARY TABLE FOR MASTER LIST --
--------------------------------------------------------------------------------------------

IF OBJECT_ID('[TempDB].[dbo].[#Master]') IS NOT NULL
DROP TABLE [#Master];

CREATE TABLE [#Master]
      (
       [Test_Batch]           SMALLINT      NOT NULL
      ,[Master_Description]   VARCHAR(30)   NOT NULL
      );



INSERT INTO [#Master] ([Test_Batch], [Master_Description]) VALUES (1, 'January');
INSERT INTO [#Master] ([Test_Batch], [Master_Description]) VALUES (2, 'June');
INSERT INTO [#Master] ([Test_Batch], [Master_Description]) VALUES (3, 'July');

--------------------------------------------------------------------------------------------



/*

SELECT [Test_Batch]
      ,[Master_Description]
  FROM [#Master]
 ORDER BY [Test_Batch] ASC;

*/



--------------------------------------------------
-- 02 - CREATE TEMPORARY TABLE FOR FAULTY INPUT --
---------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('[TempDB].[dbo].[#Input]') IS NOT NULL
DROP TABLE [#Input];

CREATE TABLE [#Input]
      (
       [Input_Sequence]      SMALLINT      NOT NULL IDENTITY(1,1)
      ,[Test_Batch]          SMALLINT      NOT NULL
      ,[Input_Description]   VARCHAR(30)   NOT NULL
      );



INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'January');    -- CORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'Jnuary');     -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'Janury');     -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'Januarie');   -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'Jnuary');     -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'Januarry');   -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'Janurrie');   -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'Jnry');       -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'Jan');        -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (1, 'Januay');     -- INCORRECT SPELLING

INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (2, 'June');       -- CORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (2, 'Jun');        -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (2, 'Jum');        -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (2, 'Jn');         -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (2, 'Junne');      -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (2, 'Junu');       -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (2, 'Joene');      -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (2, 'Jne');        -- INCORRECT SPELLING

INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (3, 'July');       -- CORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (3, 'Jul');        -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (3, 'Jly');        -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (3, 'Jl');         -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (3, 'Jully');      -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (3, 'Julie');      -- INCORRECT SPELLING
INSERT INTO [#Input] ([Test_Batch], [Input_Description]) VALUES (3, 'Jullie');     -- INCORRECT SPELLING

---------------------------------------------------------------------------------------------------------------------



/*

SELECT [Test_Batch]
      ,[Input_Description]
  FROM [#Input]
 ORDER BY [Test_Batch] ASC
      ,[Input_Sequence] ASC;

*/



---------------------------------------------------
-- 03 - GENERATE SOUND-BASED MATCH-MAKING OUTPUT --
------------------------------------------------------------------------------------------------------------------------

SELECT [Input].[Test_Batch]                                        AS [Input_Batch]
      ,[Input].[Input_Description]                                 AS [Input_Description]
      ,SOUNDEX([Input].[Input_Description])                        AS [Input_Description_Sound]

      ,[Master].[Master_Description]                               AS [Master_Description]
      ,SOUNDEX([Master].[Master_Description])                      AS [Master_Description_Sound]

      ,(CASE WHEN [Input].[Test_Batch] = [Master].[Test_Batch]
             THEN 'Correct'
             ELSE 'Incorrect'
             END)                                                  AS [Output_Validation]

  FROM [#Input] AS [Input]

       LEFT JOIN [#Master] AS [Master]
              ON SOUNDEX([Master].[Master_Description]) = SOUNDEX([Input].[Input_Description])

 ORDER BY [Input].[Test_Batch] ASC
      ,[Input].[Input_Sequence] ASC;

------------------------------------------------------------------------------------------------------------------------






------------------------------------
-- APPENDIX A: HOMOPHONE ANALYSIS --
------------------------------------------------------------------------------------------------

/*

IF OBJECT_ID('[TempDB].[dbo].[#Test]') IS NOT NULL
DROP TABLE [#Test];

CREATE TABLE [#Test]
      (
       [Input_Sequence]      SMALLINT      NOT NULL IDENTITY(1,1)
      ,[Test_Batch]          SMALLINT      NOT NULL
      ,[Input_Description]   VARCHAR(30)   NOT NULL
      );



INSERT INTO [#Test] ([Test_Batch], [Input_Description]) VALUES (1, 'See');
INSERT INTO [#Test] ([Test_Batch], [Input_Description]) VALUES (1, 'Sea');

INSERT INTO [#Test] ([Test_Batch], [Input_Description]) VALUES (2, 'By');
INSERT INTO [#Test] ([Test_Batch], [Input_Description]) VALUES (2, 'Buy');
INSERT INTO [#Test] ([Test_Batch], [Input_Description]) VALUES (2, 'Bye');

INSERT INTO [#Test] ([Test_Batch], [Input_Description]) VALUES (3, 'Flour');
INSERT INTO [#Test] ([Test_Batch], [Input_Description]) VALUES (3, 'Flower');



SELECT [Test_Batch]                  AS [Test_Batch]
      ,[Input_Description]           AS [Input_Description]
      ,SOUNDEX([Input_Description])  AS [Input_Description_Sound]
  FROM [#Test]
 ORDER BY [Test_Batch] ASC
      ,[Input_Sequence] ASC;

*/

------------------------------------------------------------------------------------------------

GO
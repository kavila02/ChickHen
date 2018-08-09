CREATE TABLE [dbo].[Message_DefaultValues] (
    [Message_DefaultValuesID] INT            IDENTITY (1, 1) NOT NULL,
    [URLPrefix]               NVARCHAR (255) NULL,
    [SolutionPath]            NVARCHAR (255) NULL,
    [SubjectPrefix]           NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([Message_DefaultValuesID] ASC)
);


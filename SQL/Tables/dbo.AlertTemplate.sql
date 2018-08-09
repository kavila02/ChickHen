CREATE TABLE [dbo].[AlertTemplate] (
    [AlertTemplateID] INT            IDENTITY (1, 1) NOT NULL,
    [alertBody]       NVARCHAR (MAX) NULL,
    [AlertName]       NVARCHAR (100) NULL,
    [SortOrder]       SMALLINT       NULL,
    [IsActive]        BIT            NULL,
    [alertSubject]    NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([AlertTemplateID] ASC)
);


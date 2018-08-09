CREATE TABLE [dbo].[FoldersToExclude] (
    [FoldersToExcludeID] INT             IDENTITY (1, 1) NOT NULL,
    [FullName]           NVARCHAR (2000) NULL,
    PRIMARY KEY CLUSTERED ([FoldersToExcludeID] ASC)
);


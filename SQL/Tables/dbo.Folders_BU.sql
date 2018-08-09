CREATE TABLE [dbo].[Folders_BU] (
    [FolderID]       INT           IDENTITY (1, 1) NOT NULL,
    [FullName]       VARCHAR (900) NULL,
    [Name]           VARCHAR (250) NULL,
    [ParentFolderID] INT           NULL
);


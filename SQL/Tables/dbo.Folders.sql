CREATE TABLE [dbo].[Folders] (
    [FolderID]       INT           IDENTITY (1, 1) NOT NULL,
    [FullName]       VARCHAR (900) NULL,
    [Name]           VARCHAR (250) NULL,
    [ParentFolderID] INT           NULL,
    PRIMARY KEY CLUSTERED ([FolderID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Folders_FullName]
    ON [dbo].[Folders]([FullName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Folders_ParentFolderID]
    ON [dbo].[Folders]([ParentFolderID] ASC);


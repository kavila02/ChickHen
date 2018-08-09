CREATE TABLE [dbo].[Files] (
    [FileID]   INT           IDENTITY (1, 1) NOT NULL,
    [FullName] VARCHAR (900) NULL,
    [Name]     VARCHAR (250) NULL,
    [FolderID] INT           NULL,
    PRIMARY KEY CLUSTERED ([FileID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Files_FullName]
    ON [dbo].[Files]([FullName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Files_FolderID]
    ON [dbo].[Files]([FolderID] ASC);


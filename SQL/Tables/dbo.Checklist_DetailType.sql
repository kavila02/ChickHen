CREATE TABLE [dbo].[Checklist_DetailType] (
    [Checklist_DetailTypeID] INT            IDENTITY (1, 1) NOT NULL,
    [Checklist_DetailType]   NVARCHAR (255) NULL,
    [SortOrder]              INT            NULL,
    [Active]                 BIT            NULL,
    PRIMARY KEY CLUSTERED ([Checklist_DetailTypeID] ASC)
);


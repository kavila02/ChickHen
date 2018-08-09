CREATE TABLE [dbo].[Detail_Status] (
    [Detail_StatusID] INT            IDENTITY (1, 1) NOT NULL,
    [Detail_Status]   NVARCHAR (255) NULL,
    [SortOrder]       INT            NULL,
    [IsActive]        BIT            NULL,
    PRIMARY KEY CLUSTERED ([Detail_StatusID] ASC)
);


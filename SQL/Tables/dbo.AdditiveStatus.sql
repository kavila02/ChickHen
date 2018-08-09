CREATE TABLE [dbo].[AdditiveStatus] (
    [AdditiveStatusID] INT           IDENTITY (1, 1) NOT NULL,
    [AdditiveStatus]   NVARCHAR (50) NULL,
    [SortOrder]        INT           NULL,
    [IsActive]         BIT           NULL,
    PRIMARY KEY CLUSTERED ([AdditiveStatusID] ASC)
);


CREATE TABLE [dbo].[ProductBreed] (
    [ProductBreedID]    INT             IDENTITY (1, 1) NOT NULL,
    [ProductBreed]      NVARCHAR (255)  NULL,
    [SortOrder]         INT             NULL,
    [IsActive]          BIT             NULL,
    [NumberOfWeeks]     NUMERIC (19, 2) NULL,
    [WeeksHatchToHouse] INT             NULL,
    PRIMARY KEY CLUSTERED ([ProductBreedID] ASC)
);


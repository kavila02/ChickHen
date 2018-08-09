CREATE TABLE [dbo].[Hatchery] (
    [HatcheryID] INT            IDENTITY (1, 1) NOT NULL,
    [Hatchery]   NVARCHAR (255) NULL,
    [SortOrder]  INT            NULL,
    [IsActive]   BIT            NULL,
    PRIMARY KEY CLUSTERED ([HatcheryID] ASC)
);


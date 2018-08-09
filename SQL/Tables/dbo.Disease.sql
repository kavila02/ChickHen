CREATE TABLE [dbo].[Disease] (
    [DiseaseID]   INT           IDENTITY (1, 1) NOT NULL,
    [DiseaseName] VARCHAR (100) NULL,
    [SortOrder]   INT           NULL,
    [IsActive]    BIT           NULL,
    PRIMARY KEY CLUSTERED ([DiseaseID] ASC)
);


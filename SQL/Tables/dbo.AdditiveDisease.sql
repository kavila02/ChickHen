CREATE TABLE [dbo].[AdditiveDisease] (
    [AdditiveDiseaseID] INT IDENTITY (1, 1) NOT NULL,
    [AdditiveID]        INT NULL,
    [DiseaseID]         INT NULL,
    PRIMARY KEY CLUSTERED ([AdditiveDiseaseID] ASC),
    FOREIGN KEY ([AdditiveID]) REFERENCES [dbo].[Additive] ([AdditiveID]),
    FOREIGN KEY ([DiseaseID]) REFERENCES [dbo].[Disease] ([DiseaseID])
);


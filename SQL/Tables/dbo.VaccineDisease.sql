CREATE TABLE [dbo].[VaccineDisease] (
    [VaccineDiseaseID] INT IDENTITY (1, 1) NOT NULL,
    [VaccineID]        INT NULL,
    [DiseaseID]        INT NULL,
    PRIMARY KEY CLUSTERED ([VaccineDiseaseID] ASC),
    FOREIGN KEY ([DiseaseID]) REFERENCES [dbo].[Disease] ([DiseaseID]),
    FOREIGN KEY ([VaccineID]) REFERENCES [dbo].[Vaccine] ([VaccineID])
);


GO
CREATE NONCLUSTERED INDEX [IX_VaccineDisease_DiseaseID]
    ON [dbo].[VaccineDisease]([DiseaseID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_VaccineDisease_VaccineID]
    ON [dbo].[VaccineDisease]([VaccineID] ASC);


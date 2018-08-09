CREATE TABLE [dbo].[VaccineScheduleVaccine] (
    [VaccineScheduleVaccineID] INT IDENTITY (1, 1) NOT NULL,
    [VaccineScheduleID]        INT NULL,
    [VaccineID]                INT NULL,
    PRIMARY KEY CLUSTERED ([VaccineScheduleVaccineID] ASC),
    FOREIGN KEY ([VaccineID]) REFERENCES [dbo].[Vaccine] ([VaccineID]),
    FOREIGN KEY ([VaccineScheduleID]) REFERENCES [dbo].[VaccineSchedule] ([VaccineScheduleID])
);


GO
CREATE NONCLUSTERED INDEX [IX_VaccineScheduleVaccine_VaccineID]
    ON [dbo].[VaccineScheduleVaccine]([VaccineID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_VaccineScheduleVaccine_VaccineScheduleID]
    ON [dbo].[VaccineScheduleVaccine]([VaccineScheduleID] ASC);


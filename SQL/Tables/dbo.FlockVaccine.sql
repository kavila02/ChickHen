CREATE TABLE [dbo].[FlockVaccine] (
    [FlockVaccineID]    INT             IDENTITY (1, 1) NOT NULL,
    [FlockID]           INT             NULL,
    [VaccineID]         INT             NULL,
    [VaccineStatusID]   INT             NULL,
    [FlockVaccineNotes] NVARCHAR (4000) NULL,
    [ScheduledDate]     DATE            NULL,
    [CompletedDate]     DATE            NULL,
    PRIMARY KEY CLUSTERED ([FlockVaccineID] ASC),
    FOREIGN KEY ([FlockID]) REFERENCES [dbo].[Flock] ([FlockID]),
    FOREIGN KEY ([VaccineID]) REFERENCES [dbo].[Vaccine] ([VaccineID]),
    FOREIGN KEY ([VaccineStatusID]) REFERENCES [dbo].[VaccineStatus] ([VaccineStatusID])
);


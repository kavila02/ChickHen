CREATE TABLE [dbo].[FlockChecklist_Detail_Vaccine] (
    [FlockChecklist_Detail_VaccineID] INT IDENTITY (1, 1) NOT NULL,
    [FlockChecklist_DetailID]         INT NULL,
    [VaccineID]                       INT NULL,
    PRIMARY KEY CLUSTERED ([FlockChecklist_Detail_VaccineID] ASC),
    FOREIGN KEY ([FlockChecklist_DetailID]) REFERENCES [dbo].[FlockChecklist_Detail] ([FlockChecklist_DetailID]),
    FOREIGN KEY ([VaccineID]) REFERENCES [dbo].[Vaccine] ([VaccineID])
);


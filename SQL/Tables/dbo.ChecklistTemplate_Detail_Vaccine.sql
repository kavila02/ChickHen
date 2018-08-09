CREATE TABLE [dbo].[ChecklistTemplate_Detail_Vaccine] (
    [ChecklistTemplate_Detail_VaccineID] INT IDENTITY (1, 1) NOT NULL,
    [ChecklistTemplate_DetailID]         INT NULL,
    [VaccineID]                          INT NULL,
    PRIMARY KEY CLUSTERED ([ChecklistTemplate_Detail_VaccineID] ASC),
    FOREIGN KEY ([ChecklistTemplate_DetailID]) REFERENCES [dbo].[ChecklistTemplate_Detail] ([ChecklistTemplate_DetailID]),
    FOREIGN KEY ([VaccineID]) REFERENCES [dbo].[Vaccine] ([VaccineID])
);


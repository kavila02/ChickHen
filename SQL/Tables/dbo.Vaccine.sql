CREATE TABLE [dbo].[Vaccine] (
    [VaccineID]            INT            IDENTITY (1, 1) NOT NULL,
    [VaccineName]          NVARCHAR (255) NULL,
    [ActiveStartDate]      DATE           NULL,
    [ActiveEndDate]        DATE           NULL,
    [ReplacementVaccineID] INT            NULL,
    [SortOrder]            INT            NULL,
    PRIMARY KEY CLUSTERED ([VaccineID] ASC)
);


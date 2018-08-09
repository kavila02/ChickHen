CREATE TABLE [dbo].[VaccineStatus] (
    [VaccineStatusID] INT           IDENTITY (1, 1) NOT NULL,
    [VaccineStatus]   NVARCHAR (50) NULL,
    [SortOrder]       SMALLINT      NULL,
    [IsActive]        BIT           NULL,
    PRIMARY KEY CLUSTERED ([VaccineStatusID] ASC)
);


CREATE TABLE [dbo].[VaccineSchedule] (
    [VaccineScheduleID] INT            IDENTITY (1, 1) NOT NULL,
    [VaccineSchedule]   NVARCHAR (255) NULL,
    [SortOrder]         INT            NULL,
    [IsActive]          BIT            NULL,
    PRIMARY KEY CLUSTERED ([VaccineScheduleID] ASC)
);


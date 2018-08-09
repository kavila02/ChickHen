CREATE TABLE [dbo].[FlockPulletGrower] (
    [FlockPulletGrowerID]   INT          IDENTITY (1, 1) NOT NULL,
    [FlockID]               INT          NULL,
    [PulletGrowerID]        INT          NULL,
    [ExpectedNumberToHouse] INT          NULL,
    [TotalHoused]           INT          NULL,
    [AgeAtHousing]          INT          NULL,
    [NPIP]                  VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([FlockPulletGrowerID] ASC),
    FOREIGN KEY ([FlockID]) REFERENCES [dbo].[Flock] ([FlockID]),
    FOREIGN KEY ([PulletGrowerID]) REFERENCES [dbo].[PulletGrower] ([PulletGrowerID])
);


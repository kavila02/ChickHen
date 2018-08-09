CREATE TABLE [dbo].[FlockAdditive] (
    [FlockAdditiveID]    INT            IDENTITY (1, 1) NOT NULL,
    [FlockID]            INT            NULL,
    [AdditiveID]         INT            NULL,
    [AdditiveStatusID]   INT            NULL,
    [FlockAdditiveNotes] NVARCHAR (255) NULL,
    [StartDate]          DATE           NULL,
    [EndDate]            DATE           NULL,
    PRIMARY KEY CLUSTERED ([FlockAdditiveID] ASC),
    FOREIGN KEY ([AdditiveID]) REFERENCES [dbo].[Additive] ([AdditiveID]),
    FOREIGN KEY ([AdditiveStatusID]) REFERENCES [dbo].[AdditiveStatus] ([AdditiveStatusID]),
    FOREIGN KEY ([FlockID]) REFERENCES [dbo].[Flock] ([FlockID])
);


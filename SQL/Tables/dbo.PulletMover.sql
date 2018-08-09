CREATE TABLE [dbo].[PulletMover] (
    [PulletMoverID] INT            IDENTITY (1, 1) NOT NULL,
    [PulletMover]   NVARCHAR (255) NULL,
    [SortOrder]     INT            NULL,
    [IsActive]      BIT            NULL,
    PRIMARY KEY CLUSTERED ([PulletMoverID] ASC)
);


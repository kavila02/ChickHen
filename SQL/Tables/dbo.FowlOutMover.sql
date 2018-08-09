CREATE TABLE [dbo].[FowlOutMover] (
    [FowlOutMoverID] INT            IDENTITY (1, 1) NOT NULL,
    [FowlOutMover]   NVARCHAR (255) NULL,
    [SortOrder]      INT            NULL,
    [IsActive]       BIT            NULL,
    PRIMARY KEY CLUSTERED ([FowlOutMoverID] ASC)
);


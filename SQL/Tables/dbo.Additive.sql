CREATE TABLE [dbo].[Additive] (
    [AdditiveID]         INT            IDENTITY (1, 1) NOT NULL,
    [Additive]           NVARCHAR (100) NULL,
    [ApprovedForColony]  BIT            NULL,
    [ApprovedForAviary]  BIT            NULL,
    [ApprovedForOrganic] BIT            NULL,
    [IsActive]           BIT            NULL,
    [SortOrder]          INT            NULL,
    PRIMARY KEY CLUSTERED ([AdditiveID] ASC)
);


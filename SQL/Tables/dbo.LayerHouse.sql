CREATE TABLE [dbo].[LayerHouse] (
    [LayerHouseID]       INT             IDENTITY (1, 1) NOT NULL,
    [LocationID]         INT             NULL,
    [LayerHouseName]     NVARCHAR (255)  NULL,
    [YearBuilt]          NVARCHAR (50)   NULL,
    [HouseStyle]         NVARCHAR (255)  NULL,
    [CageSizeNotes]      NVARCHAR (255)  NULL,
    [CubicInchesInCage]  VARCHAR (255)   NULL,
    [SquareInchesInCage] VARCHAR (255)   NULL,
    [NumberCages]        VARCHAR (255)   NULL,
    [DrinkersPerCage]    INT             NULL,
    [BirdCapacity]       INT             NULL,
    [CageHeight]         VARCHAR (255)   NULL,
    [CageWidth]          VARCHAR (255)   NULL,
    [CageDepth]          VARCHAR (255)   NULL,
    [PEQAPNumber]        VARCHAR (50)    NULL,
    [BirdCapacityBrown]  INT             NULL,
    [BirdsPerHouse]      NUMERIC (19, 1) NULL,
    [SortOrder]          INT             NULL,
    PRIMARY KEY CLUSTERED ([LayerHouseID] ASC),
    FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Location] ([LocationID])
);


GO
CREATE NONCLUSTERED INDEX [IX_LayerHouse_LocationID]
    ON [dbo].[LayerHouse]([LocationID] ASC);


CREATE TABLE [csb].[PagePart] (
    [PagePartID]         INT           IDENTITY (1, 1) NOT NULL,
    [PagePartTypeID]     INT           NOT NULL,
    [XmlScreenID]        VARCHAR (255) NULL,
    [IsReadOnly]         BIT           NOT NULL,
    [IsViewableDefault]  BIT           NOT NULL,
    [IsUpdatableDefault] BIT           NOT NULL,
    [MenuID]             VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([PagePartID] ASC),
    FOREIGN KEY ([PagePartTypeID]) REFERENCES [csb].[PagePartType] ([PagePartTypeID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PagePart_XmlScreenID]
    ON [csb].[PagePart]([XmlScreenID] ASC);


CREATE TABLE [dbo].[ChecklistTemplate] (
    [ChecklistTemplateID] INT            IDENTITY (1, 1) NOT NULL,
    [TemplateName]        NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([ChecklistTemplateID] ASC)
);


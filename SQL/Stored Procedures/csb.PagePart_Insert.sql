
CREATE PROCEDURE [csb].[PagePart_Insert]
	@PagePartID int = 0 output
	, @PagePartTypeID int = 0
	, @XmlScreenID varchar(255)
	, @IsReadOnly bit = 0
	, @IsViewableDefault bit = 0
	, @IsUpdatableDefault bit = 0
AS
	IF NOT EXISTS (SELECT 1 FROM csb.PagePart WHERE XmlScreenID = @XmlScreenID)
	BEGIN
		DECLARE @OutputTable AS TABLE ( PagePartID int )

		INSERT INTO csb.PagePart (
			PagePartTypeID
			, XmlScreenID
			, IsReadOnly
			, IsViewableDefault
			, IsUpdatableDefault
		)
		OUTPUT Inserted.PagePartID INTO @OutputTable
		VALUES (
			@PagePartTypeID
			, @XmlScreenID
			, @IsReadOnly
			, @IsViewableDefault
			, @IsUpdatableDefault
		)

		SELECT TOP 1 @PagePartID = PagePartID FROM @OutputTable
	END
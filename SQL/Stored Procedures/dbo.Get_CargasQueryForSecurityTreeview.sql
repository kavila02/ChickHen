/* ----------------------- END CORE TABLES/PROCEDURES ----------------------- */

/* ----------------------- BEGIN SECURITY TABLES/PROCEDURES ----------------------- */
create PROC [dbo].[Get_CargasQueryForSecurityTreeview]
AS
	SELECT DISTINCT
		rowID = 'CargasQuery' --+ convert(varchar(50), CargasQueryFavoriteIdentifier)
		, parentID = 'CargasQuery'
		, nodeValue = '' --convert(varchar(50), CargasQueryFavoriteIdentifier)
		, displayValue = '' --Name
		, linkValue = '' --convert(varchar(50), CargasQueryFavoriteIdentifier) + '&p=CargasQuery'  --type=printPreview, name=''
		, screenValue = 'ResourceSecurity'
		, Level = 2
		, orderby = '' --Name
	--FROM csiCargasQueryFavorite
	WHERE 1 = 0
CREATE PROCEDURE csb.DiscoverParameterNames
	@ProcedureName varchar(255)
AS

DECLARE @NumPeriods int = LEN(@ProcedureName) - LEN(REPLACE(@ProcedureName,'.',''))

SELECT
	Name = PARAMETER_NAME
	, Type = DATA_TYPE
	, Length = CHARACTER_MAXIMUM_LENGTH
FROM
	information_schema.parameters
WHERE
	(@NumPeriods=0 AND SPECIFIC_NAME = @ProcedureName)
	OR (@NumPeriods=1 AND SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME = @ProcedureName)
	OR (@NumPeriods=2 AND SPECIFIC_CATALOG + '.' + SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME = @ProcedureName)
ORDER BY ORDINAL_POSITION
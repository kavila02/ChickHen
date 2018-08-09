
CREATE PROCEDURE [csb].[SupportInterval_GetList]
AS
	SELECT
		si.Name
		, si.SupportIntervalID
	FROM csb.SupportInterval si
	ORDER BY si.MinuteCount
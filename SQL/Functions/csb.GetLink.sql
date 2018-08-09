
CREATE FUNCTION [csb].[GetLink] (
	@template varchar(max)
	, @screen varchar(max)
	, @detailScreen varchar(max)
	, @id int
	, @text varchar(max)
)
RETURNS varchar(max)
AS
BEGIN
	RETURN '<a href="' + @template + '?screenID=' + @screen 
		+ '&detailScreenID=' + @detailScreen + '&p=' + cast(@id AS varchar) 
		+ '">' + @text + '</a>'
END
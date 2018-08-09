
CREATE PROC [dbo].[Get_SecurityScreenForScreenIDPreProcess]
	@screenID varchar(255)
AS
	SELECT ReferenceType='forward', p='&p=' + @screenID 

	/*
	select ReferenceType='forward', p=IsNull(convert(varchar(50),MenuIdentifier), '') + '&p=' + @screenID 
	from csiScreen s left outer join csiMenu m on s.csiScreenID = m.csiScreenID
	where s.id = @screenID
	*/
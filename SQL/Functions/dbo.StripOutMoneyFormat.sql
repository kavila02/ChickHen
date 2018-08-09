create function [dbo].[StripOutMoneyFormat] (@Nbr varchar(255))
returns money
as
begin
	--return convert(money, replace(replace(replace(replace(@Nbr, '$', ''), ',', ''), ')', ''), '(', '-'))
	DECLARE @outputstring varchar(255), @returnValue money, @isNegative bit
	SET @outputstring = @Nbr 
	if charindex('-',@Nbr,1) > 0 or charindex('(',@Nbr,1) > 0
	begin
		select @isNegative = 1
	end

	DECLARE @pos int 
	SET @pos = PATINDEX('%[^0-9.-]%', @outputstring) 

	WHILE (@pos > 0) 
	BEGIN 
		SET @outputstring = STUFF(@outputstring, @pos, 1, '') 
		SET @pos = PATINDEX('%[^0-9.]%', @outputstring) 
	END

	--if more than one decimal only keep the last one
	if LEN(@outputstring) - LEN(replace(@outputstring,'.','')) > 1
	begin
		select @outputstring = REVERSE(REPLACE(SUBSTRING(REVERSE(@outputstring),1 + CHARINDEX('.',REVERSE(@outputstring),1),LEN(@outputstring)),'.',''))
			+ REVERSE(SUBSTRING(REVERSE(@outputstring),1,CHARINDEX('.',REVERSE(@outputstring),1)))
	end

	if @isNegative = 1
	begin
		select @returnValue = convert(money,'-' + @outputstring)
	end
	else
	begin
		select @returnValue = convert(money,@outputstring)
	end

	RETURN @returnValue
end
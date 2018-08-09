
create function dbo.FormatIntComma (@Nbr int)
returns varchar(50)
as
begin

	declare @WhatsLeft varchar(50)
	declare @Return varchar(50)
	declare @Change numeric(2,2)
	declare @Negative bit
	select @Negative = 0

	if @Nbr < 0 
	begin
		set @Negative = 1
		set @Nbr = ABS(@Nbr)
	end

	set @WhatsLeft = @Nbr
	set @Return = ''

	while @WhatsLeft <> ''
	begin
		if len(@WhatsLeft) > 3
		begin
			set @Return = ',' + right(@WhatsLeft,3) + @Return
			set @WhatsLeft = left(@WhatsLeft, len(@WhatsLeft) - 3)
		end
		else
		begin
			set @Return = @WhatsLeft + @Return
			set @WhatsLeft = ''
		end
	end

	
	if @Negative = 1
	begin
		set @Return = '-' + @Return 
	end

	return @Return
end
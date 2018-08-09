
CREATE function [dbo].[FormatNumeric] (@Nbr Numeric(19,2))
returns varchar(50)
as
begin

	declare @WhatsLeft varchar(50)
	declare @Return varchar(50)
	declare @Change numeric(2,2)
	declare @Negative bit
	select @Negative = 0

	set @Nbr = round(@Nbr,2)
	

	if @Nbr < 0 
	begin
		set @Negative = 1
		set @Nbr = ABS(@Nbr)
	end
	set @Change = round(@Nbr, 2) - Floor(@Nbr)

	set @WhatsLeft = cast(cast(floor(@Nbr) as int) as varchar)
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

	set @Return = @Return + right(cast(@Change as varchar), 3)

	if @Negative = 1
	begin
		set @Return = '-' + @Return 
	end
	
	return @Return
end
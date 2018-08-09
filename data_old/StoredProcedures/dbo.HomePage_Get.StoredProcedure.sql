if exists (Select 1 from sys.objects where name = 'HomePage_Get' and type='P')
begin
	drop proc HomePage_Get
end
go

create proc HomePage_Get
@UserName nvarchar(255) = ''
AS

select @UserName as UserName
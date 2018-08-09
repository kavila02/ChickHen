if exists (select 1 from sys.procedures where name = 'RecipientType_Lookup')
begin
	drop proc RecipientType_Lookup
end

go

create proc RecipientType_Lookup
AS

select 'To:',1
union all select 'CC:',2
union all select 'BCC:',3

GO
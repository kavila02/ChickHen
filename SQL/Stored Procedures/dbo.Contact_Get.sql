




create proc [dbo].[Contact_Get]
@ContactID int = null
,@IncludeNew bit = 1
As

select
	ContactID
	, ContactName
	, PrimaryEmailAddress
	, SecondaryEmailAddress
	, PhoneNumber
	, Active
from Contact
where IsNull(@ContactID,ContactID) = ContactID
union all
select
	ContactID = convert(int,0)
	, ContactName = convert(nvarchar(255),null)
	, PrimaryEmailAddress = convert(nvarchar(255),null)
	, SecondaryEmailAddress = convert(nvarchar(255),null)
	, PhoneNumber = convert(nvarchar(20),null)
	, Active = convert(bit,1)
where @IncludeNew = 1
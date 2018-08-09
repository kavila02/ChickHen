

CREATE PROC csb.ScreenSecurityDefaultPermissions
AS

SELECT '', 0
UNION SELECT 'Deny', -1 
UNION SELECT 'Allow', 1
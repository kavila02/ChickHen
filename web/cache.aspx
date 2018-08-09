<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="cache.aspx.vb" Inherits="csiTemplates.Cache" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
	<title>Solution Builder Cache</title>
</head>
<body>
<form id="rasForm" runat="server">
<input type="hidden" name="clear" value="y" />
<hr />
<div>
	Caching is <span id="rasCacheStatus" runat="server"></span>.
</div>
<div>
	Cache contains <span id="rasCacheCount" runat="server"></span> objects.
</div>
<hr />
<input type="submit" value="Clear Cache" OnServerClick="rasClearCache_OnServerClick" id="rasClearCache" runat="server" />
<input type="submit" value="Toggle Cache Status" OnServerClick="rasToggleCacheStatus_OnServerClick" id="rasToggleCacheStatus" runat="server" />
<hr />
<table id="rasCacheTable" border="1" runat="server">
  <tr>
    <th>Key</th>
    <th>Value</th>
  </tr>
</table>
</form>
</body>
</html>

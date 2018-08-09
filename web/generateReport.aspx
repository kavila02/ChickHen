<%@ Page Language="vb" AutoEventWireup="false" Codebehind="generateReport.aspx.vb" Inherits="csiTemplates.generateReport" MasterPageFile="CSB.Master" %>
<%@ Register TagPrefix="csiHC" Namespace="csi.Framework.HeaderControls" Assembly="csi.Framework, Version=1.0.0.0, Culture=neutral, PublicKeyToken=de0d09fc386f12e2" %>
<%@ Register TagPrefix="csiLC" Namespace="csi.Framework.LayoutControls" Assembly="csi.Framework, Version=1.0.0.0, Culture=neutral, PublicKeyToken=de0d09fc386f12e2" %>
<%@ MasterType VirtualPath = "~/CSB.master"%>


<asp:Content ID="headerContent" runat="server" ContentPlaceHolderID="head">
                
</asp:Content>
    <asp:Content ID="leftContent" runat="server" ContentPlaceHolderID="leftContent">
        <div id="navBarLeft" runat="server"></div> <!-- End navBarLeft -->
    </asp:Content>
    <asp:Content ID="mainContent" runat="server" ContentPlaceHolderID="mainContent">
		<csiHC:ErrorDisplay id="errorGrid" runat="server" />
		<asp:Label id="lblHeader" runat="server" CssClass="headerLabel"></asp:Label><br/>
		<span id="lblPopupLink" runat="server" />
		<br />
		<csiLC:FormView id="fvReportParams" runat="server" />
		<div><span class="datalabel">Report Format: </span><asp:DropDownList id="ReportFormat" runat="server"></asp:DropDownList></div>
		<asp:Button id="btnRunReport" runat="server" text="Preview Report" CssClass="button" />
		<asp:Button id="btnCancel" runat="server" text="Cancel" CssClass="button" />
		<input id="redirectURL" type="hidden" name="redirectURL" runat="server" /> <input id="selectedMenu" type="hidden" name="selectedMenu" runat="server" />
		<input id="currentScreenID" type="hidden" name="currentScreenID" runat="server" />
    </asp:Content>

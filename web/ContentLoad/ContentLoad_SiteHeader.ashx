<%@ WebHandler Language="VB" Class="csbAngular_GetSiteHeader" %>

Imports System
Imports System.Web
Imports csi.Framework.ScreenData
Imports csi.Framework.Web
Imports csi.Framework.Security
Imports csi.Framework.ScreenDefinition
Imports csi.Framework.Utility
Imports System.Collections
Imports System.IO

Public Class csbAngular_GetSiteHeader : Implements IHttpHandler, IReadOnlySessionState

    Private _parameters As Parameters

    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim thisStringWriter As New StringWriter()
        Dim output As New HtmlTextWriter(thisStringWriter)
        
        _parameters = New Parameters(context.Request)
        
        Dim currentPath As String = HttpRuntime.AppDomainAppVirtualPath

        Dim SiteLogo = New HtmlAnchor()
        Dim SiteTitle = New HtmlAnchor()

        Dim XSHeaderDisplay = ConfigurationManager.AppSettings("XSHeaderDisplay").ToLower()

        'depricate? PRC- I controll this on the appBar using the mobile class
        'If Not ConfigurationManager.AppSettings("XSHeaderDisplay").ToLower() Is Nothing Then
        '    If XSHeaderDisplay = "title" Then
        '        SiteLogo.Attributes.Item("class") = "hidden-xs "
        '    ElseIf XSHeaderDisplay = "logo" Then
        '        SiteTitle.Attributes.Item("class") = "hidden-xs "
        '    End If
        '    ' Otherwise we don't hide anything
        'End If

        If Not ConfigurationManager.AppSettings("HideSiteLogo").ToLower() = "true" Then
            Dim logoPath As String = "images/logoSB.png"
            If Not ConfigurationManager.AppSettings("SiteLogo") Is Nothing Then
                logoPath = ConfigurationManager.AppSettings("SiteLogo")
            End If

            SiteLogo.ID = "SiteLogo"
            SiteLogo.Attributes.Item("href") = currentPath
            SiteLogo.Attributes.Item("class") = SiteLogo.Attributes.Item("class") + "navbar-brand"
            SiteLogo.InnerHtml = "<img id=""siteLogoImage"" src=""" & logoPath & """ alt="""" />"

            'SiteBrand.Controls.Add(SiteLogo)
            SiteLogo.RenderControl(output)
        End If

        If Not ConfigurationManager.AppSettings("HideSiteTitle").ToLower() = "true" Then
            If Not ConfigurationManager.AppSettings("SiteTitle") Is Nothing Then
                SiteTitle.ID = "SiteTitle"
                SiteTitle.Attributes.Item("href") = currentPath
                SiteTitle.Attributes.Item("class") = SiteTitle.Attributes.Item("class") + "navbar-brand"
                Dim SiteTitleString As String = ConfigurationManager.AppSettings("SiteTitle")
                If SiteTitleString.ToLower().StartsWith("fieldname") Then
                    Dim data As Data = New Data
                    Dim siteTitleData As System.Data.DataSet = data.GetDataSetFromProvider(Common.ReplaceVariables(ConfigurationManager.AppSettings("SiteTitleData"), _parameters.Array, context))
                    If Not siteTitleData Is Nothing Then
                        If siteTitleData.Tables.Count() > 0 Then
                            If siteTitleData.Tables(0).Rows.Count() > 0 Then
                                SiteTitleString = siteTitleData.Tables(0).Rows(0).Item(ConfigurationManager.AppSettings("SiteTitle").ToLower().Replace("fieldname ", "").Replace("fieldname=", "")).ToString()
                            End If
                        End If
                    End If
                End If
                SiteTitle.InnerHtml = SiteTitleString
                'SiteBrand.Controls.Add(SiteTitle)
                SiteTitle.RenderControl(output)
            Else
                'SiteBrand.Controls.Add(SiteLogo)
                SiteLogo.RenderControl(output)
            End If
        End If
        
        context.Response.Write(thisStringWriter.ToString())

    End Sub

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class
<%@ WebHandler Language="VB" Class="csbAngular_GetTabsForScreen" %>

Imports System
Imports System.Web
Imports System.Collections
Imports csi.Framework.ScreenData
Imports csi.Framework.Web
Imports csi.Framework.Security
Imports csi.Framework.ScreenDefinition
Imports csi.Framework.Utility


Public Class csbAngular_GetTabsForScreen : Implements IHttpHandler


    Private sParameter As String


    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "text/html"
        Dim sScreenID As String
        Dim sbTabContentHTML As StringBuilder = New StringBuilder("")
        Dim sNewRecordEventObject As String


        Dim oParameter As Object = context.Request.Params("p")
        If oParameter Is Nothing Then
            sParameter = ""
        Else
            sParameter = CType(oParameter, String)
        End If


        'if screen id is sent in...pull from there
        If context.Request.QueryString("ScreenID") > "" Then
            sScreenID = context.Request.QueryString("ScreenID")
            'Dim _mainScreenItem As ScreenItem
            'Dim _userName As String = Common.UserName(context)

            '_mainScreenItem = TemplateUtility.CheckAccess(_userName)

            Dim detailReferences As System.Collections.Generic.IList(Of ScreenItem) = Common.GetScreenReferences(sScreenID, "detail")
            Dim detailReference As ScreenItem
            If Not detailReferences Is Nothing Then

                'TODO:  change the way the tabs are id'd from number to screen id
                '    :  send out a tab container 'directive' instead of the div...
                '

                context.Response.Write("<md-tabs md-dynamic-height md-border-bottom>")
                For Each detailReference In detailReferences
                    If Not detailReference.DisplayStyle = "NoTab" Then
                        detailReference.CheckAccess(context.Server.MapPath(""))
                        If detailReference.AllowAccess Then


                            'context.Response.Write("<md-tab label=""")
                            'context.Response.Write(detailReference.DisplayName)
                            'context.Response.Write(" ({{data.detailRecords[0].")
                            'context.Response.Write(detailReference.ID.ToString())
                            'context.Response.Write(".length}})")
                            'context.Response.Write(""" >")

                            context.Response.Write("<md-tab>")
                            context.Response.Write("<md-tab-label>")

                            If detailReference.DisplayName.StartsWith("htmlfile") Then
                                Dim htmlPath As String = detailReference.DisplayName.Substring(9)
                                If IO.Path.GetExtension(htmlPath) = ".html" Then
                                    context.Response.TransmitFile(htmlPath)
                                Else
                                    context.Response.Write(detailReference.DisplayName)
                                End If
                            Else
                                context.Response.Write(detailReference.DisplayName)
                            End If
                            context.Response.Write(" ({{data.detailRecords[0].")
                            context.Response.Write(detailReference.ID.ToString())
                            context.Response.Write(".length")
                            If (detailReference.DisplayStyle.IndexOf("count") >= 0) Then
                                context.Response.Write(detailReference.DisplayStyle.Substring(detailReference.DisplayStyle.IndexOf("count") + 5))
                            End If
                            context.Response.Write("}})")

                            'add an "add record icon" if new record reference exists
                            sNewRecordEventObject = getTabNewRecordValue(detailReference.ID.ToString(), context)
                            If sNewRecordEventObject > "" Then
                                context.Response.Write("<md-button ng-click=""data.additionalActionsClick(")
                                context.Response.Write(sNewRecordEventObject.Replace("""", "'"))
                                context.Response.Write(") "" style=""vertical-align: middle; font-size: inherit; height: 24px; min-height:24px; line-height: 24px; margin: 0px; min-width: inherit; width: auto; margin-left:16px"">")
                                context.Response.Write("<i class=""material-icons"" style=""font-size: 20px; "">control_point</i></md-button>")
                            End If

                            context.Response.Write("</md-tab-label>")
                            context.Response.Write("<md-tab-body>")
                            context.Response.Write("<md-content>")

                            context.Response.Write("<form-tab-content data='data' this-record='data.detailRecords[0].")
                            context.Response.Write(detailReference.ID.ToString())
                            context.Response.Write("' screen-id='")
                            context.Response.Write(detailReference.ID.ToString())
							context.Response.Write("' page-size='")
                            Dim pageSize As String = "20"
                            'DisplayStyle="paging:all"
                            'DisplayStyle="paging:100"
                            'DisplayStyle="paging:100;hidepaging:true;etc"
                            If Not detailReference.DisplayStyle Is Nothing AndAlso detailReference.DisplayStyle.IndexOf("paging") > -1 Then
                                Dim pagingSubstring As String = detailReference.DisplayStyle.Substring(detailReference.DisplayStyle.ToLower().IndexOf("paging") + 7)
                                If pagingSubstring.StartsWith("all") Then
                                    pageSize = "500"
                                Else
                                    If pagingSubstring.IndexOf(";") > -1 Then
                                        pageSize = pagingSubstring.Substring(0, pagingSubstring.IndexOf(";"))
                                    Else
                                        pageSize = pagingSubstring
                                    End If
                                End If
                            End If
                            context.Response.Write(pageSize)
                            context.Response.Write("' >Stuff")
                            context.Response.Write(detailReference.ID.ToString())
                            context.Response.Write("</form-tab-content>")
                            context.Response.Write("</md-content>")
                            context.Response.Write("</md-tab-body>")

                            context.Response.Write("</md-tab>")
                        End If

                    End If

                Next
                context.Response.Write("</md-tabs>")


            End If

        End If

    End Sub

    Private Function getTabNewRecordValue(sDetailScreenID As String, context As HttpContext) As String
        Dim sResult As StringBuilder = New StringBuilder("")

        Dim ScreenItemList As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        Dim csiSI As ScreenItem
        Dim headerLinkURL As String

        ScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sDetailScreenID, "new record", Common.UserName(Context))
        If Not ScreenItemList Is Nothing AndAlso ScreenItemList.Count > 0 Then
            csiSI = ScreenItemList.Item(0)

            'sParameter is not working. For some reason it's not getting values
            'Fortunately we can pass in {{data.record.fieldName}} to use fields from the header
            Dim linkFields As ArrayList = New ArrayList
            'For i As Integer = 0 To linkFields.Count
            '    linkFields(i) = "{{thisRecord." & linkFields(i) & "}}"
            'Next
            For Each linkField As String In csiSI.LinkFields
                'linkField = "{{thisRecord." & linkField.ToString() & "}}"
                linkFields.Add("{{data.record." & linkField.ToString() & "}}")
            Next

            Dim linkFieldParameter As String = String.Join("&p=", linkFields.ToArray())

            'headerLinkURL = csi.Framework.Utility.Common.ScreenReader.RenderHREF(csiSI.ID, False, sParameter.Replace(",", "&p="), Common.UserName(context))
            headerLinkURL = csi.Framework.Utility.Common.ScreenReader.RenderHREF(csiSI.ID, False, linkFieldParameter, Common.UserName(context))
            If headerLinkURL > "" Then
                sResult.Append("{")

                '{action: blah, data: url}
                sResult.Append("""action"":")
                'base this value on the type
                Select Case csiSI.DisplayStyle
                    Case "redirect"
                        sResult.Append("""link""")

                    Case "inline"
                        sResult.Append("""popup""")
                    Case "lightbox"
                        sResult.Append("""popup""")
                    Case Else
                        sResult.Append("""link""")

                End Select


                sResult.Append(",""data"":")
                'write out the URL            
                sResult.Append("""")
                sResult.Append(headerLinkURL)
                sResult.Append("""")


                sResult.Append("}")

            End If

        End If

        Return sResult.ToString

    End Function


    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class
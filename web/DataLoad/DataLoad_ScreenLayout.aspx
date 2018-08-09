<%@ Import Namespace="csi.Framework.ScreenData" %>
<%@ Import Namespace="csi.Framework.Security" %>
<%@ Import Namespace="csi.Framework.Utility" %>
<%@ Import Namespace="System.Xml" %>
<script language="VB" runat="server">

    'Private _xmlGlobalFileName As String = ConfigurationManager.AppSettings("xmlGlobal")
    Private _xmlFormLayoutFileName As String = ""
    'Private _xmlGlobal As XmlDocument
    Private _xmlFormLayout As XmlDocument
    Dim paramArrayValues() As String
    Dim paramArrayValuesCombined(0) As String
    Dim thisFramework As csi.Framework.Utility.Data = New csi.Framework.Utility.Data
    Dim _DEFAULT_FIND_BUTTON_DISPLAY As String = "Get Data"

    Sub Page_Load(Sender As Object, E As EventArgs)

        Dim sScreenID = Request.Params("screenID")
        Dim csiSR As ScreenReader = New ScreenReader()
        Dim csiSI As ScreenItem
        Dim mainScreenItem As ScreenItem
        Dim sectionNodes As XmlNodeList
        Dim sectionNode As XmlNode
        Dim fieldNode As XmlNode
        Dim thisFP As UIFieldProperty
        Dim alNodes As System.Collections.Generic.IList(Of XmlNode) = New System.Collections.Generic.List(Of XmlNode)
        Dim sFieldName As String
        Dim ScreenItemList As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        Dim bAutoPostBack As Boolean = False
        Dim headerLinkURL As String
        Dim isForm As Boolean = False
        Dim sectionDisplayStyle As String = ""
        Dim doNotLoadFindSQLResultsOnGet As String = ""

        Dim oParameter As Object = Request.Params("p")
        Dim sParameter As String
        If oParameter Is Nothing Then
            sParameter = ""
        Else
            sParameter = CType(oParameter, String)
        End If

        Dim oIsForm As Object = Request.Params("isForm")
        If Not oIsForm Is Nothing Then
            isForm = CType(oIsForm, Boolean)
        End If

        'gather parameters
        'need to parse the request.inputstream
        ''Dim streamRead As IO.StreamReader = New IO.StreamReader(Request.InputStream)
        Dim JSON_DictionaryLength As Integer = 0



        'get screen references of type detail

        mainScreenItem = csiSR.Item(sScreenID, Common.UserName(Context))
        'Paging needs to use the list screen item, other stuff uses the main form if there's a find sql
        Dim listScreenItem As ScreenItem = mainScreenItem
        ScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "detail", Common.UserName(Context))


        Dim sectionInfo As String = ""
        Dim collapsableIndex As Integer = 0
        'Get section information from header- this is where paging has been stored in previous solutions
        Dim mainXmlFormLayoutFileName As String = mainScreenItem.FormatXML

        If mainXmlFormLayoutFileName.EndsWith(".xml") Then
            Dim listXmlFormLayout As XmlDocument = Common.GetXMLDoc(Context.Server.MapPath(mainXmlFormLayoutFileName), HttpRuntime.Cache)
            Dim listSectionNodes As XmlNodeList = listXmlFormLayout.SelectNodes("fieldList/section")
            If Not listSectionNodes(0) Is Nothing AndAlso Not listSectionNodes(0).Attributes("displayStyle") Is Nothing Then
                sectionDisplayStyle = listSectionNodes(0).Attributes("displayStyle").Value.ToString()
            End If
        End If

        If Not isForm Then
            Dim csiFindReferences As System.Collections.Generic.List(Of ScreenItem) = csiSR.References(mainScreenItem.ID, "findSQL", Common.UserName(Context))
            If Not csiFindReferences Is Nothing AndAlso csiFindReferences.Count > 0 Then
                mainXmlFormLayoutFileName = csiFindReferences.Item(0).FormatXML
            End If
        End If
        If mainXmlFormLayoutFileName.EndsWith(".xml") Then
            Dim mainXmlFormLayout As XmlDocument = Common.getXMLDoc(Context.Server.MapPath(mainXmlFormLayoutFileName), HttpRuntime.Cache)

            Dim mainSectionNodes As XmlNodeList = mainXmlFormLayout.SelectNodes("fieldList/section")
            For Each mainSectionNode As XmlNode In mainSectionNodes
                'this is only used for paging, so moving this up
                'If Not mainSectionNode.Attributes("displayStyle") Is Nothing Then
                '    sectionDisplayStyle = mainSectionNode.Attributes("displayStyle").Value.ToString()
                'End If
                If Not mainSectionNode.Attributes("collapsed") Is Nothing Then
                    If sectionInfo = "" Then
                        sectionInfo = ", ""sectionInfo"": [{""" & collapsableIndex.ToString() & """:"""
                        If CBool(mainSectionNode.Attributes("collapsed").Value) Then
                            sectionInfo = sectionInfo & "0"
                        Else
                            sectionInfo = sectionInfo & "1"
                        End If
                        sectionInfo = sectionInfo & """}"
                    Else
                        sectionInfo = sectionInfo & ",{""" & collapsableIndex.ToString() & """:"""
                        If CBool(mainSectionNode.Attributes("collapsed").Value) Then
                            sectionInfo = sectionInfo & "0"
                        Else
                            sectionInfo = sectionInfo & "1"
                        End If
                        sectionInfo = sectionInfo & """}"
                    End If
                    collapsableIndex = collapsableIndex + 1
                End If
            Next
        End If

        If sectionInfo = "" Then
            sectionInfo = ", ""sectionInfo"": [{}"
        End If
        sectionInfo = sectionInfo & "]"

        'open the json object
        Response.Write("[{")

        'start with screen properties
        Response.Write("""displayName"": ")
        Response.Write("""" + Common.JSON_Encode(mainScreenItem.DisplayName) + """")

        Dim hidePaging As String = "false"
        Dim hideSearch As String = "false"

        'Paging needs to use the list screen item, other stuff uses the main form if there's a find sql
        'if this is a form or a list without find sql, mainScreenItem and listScreenItem are the same
        'if this is a list with a find sql, mainScreenItem is the find sql and listScreenItem is the list
        If Not listScreenItem.DisplayStyle Is Nothing Then
            Response.Write(", ""displayStyle"": """ & Common.JSON_Encode(listScreenItem.DisplayStyle) & """")
            If CType(listScreenItem.DisplayStyle.ToLower().Contains("hidepaging") AndAlso listScreenItem.DisplayStyle.Substring(listScreenItem.DisplayStyle.IndexOf("hidepaging") + 11, 4), Boolean) Then
                hidePaging = "true"
            End If
            If CType(listScreenItem.DisplayStyle.ToLower().Contains("hidesearch") AndAlso listScreenItem.DisplayStyle.Substring(listScreenItem.DisplayStyle.IndexOf("hidesearch") + 11, 4), Boolean) Then
                hideSearch = "true"
            End If
        End If
        Response.Write(", ""hidePaging"": """ & hidePaging & """")
        Response.Write(", ""hideSearch"": """ & hideSearch & """")
        Response.Write(", ""sectionDisplayStyle"": """ & sectionDisplayStyle & """")
        Response.Write(sectionInfo)

        Dim reportRef As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        reportRef = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "report", Common.UserName(Context))

        Dim containsReport As Boolean = False
        If Not reportRef Is Nothing AndAlso reportRef.Count > 0 Then
            Response.Write(", ""includeReport"": ""True""")
            Response.Write(", ""reportFormat"": ""PDF""")
            Response.Write(", ""reportUrl"": """ & Common.JSON_Encode(BuildReportUrl(reportRef.Item(0))) & """")
            If reportRef.Item(0).DisplayStyle.ToLower() = "popup" Then
                Response.Write(", ""reportPopup"": ""True""")
            Else
                Response.Write(", ""reportPopup"": ""False""")
            End If
            containsReport = True
        Else
            Response.Write(", ""includeReport"": ""False""")
        End If


        Response.Write(", ""saveDisplay"": """ & mainScreenItem.SaveDisplay & """")
        Response.Write(", ""reportDisplay"": ""Preview Report""")
        Response.Write(", ""refreshDisplay"": """ & mainScreenItem.RefreshDisplay & """")
        Response.Write(", ""newRecordDisplay"": """ & mainScreenItem.NewRecordDisplay & """")
        Response.Write(", ""screenID"": """ & sScreenID & """")
        Response.Write(", ""additionalDisplay"": """ & mainScreenItem.AdditionalDisplay & """")
        Response.Write(", ""saveIcon"": """ & mainScreenItem.SaveIcon & """")
        Response.Write(", ""reportIcon"": ""insert_drive_file""")
        Response.Write(", ""refreshIcon"": """ & mainScreenItem.RefreshIcon & """")
        Response.Write(", ""newRecordIcon"": """ & mainScreenItem.NewRecordIcon & """")
        Response.Write(", ""additionalIcon"": """ & mainScreenItem.AdditionalIcon & """")

        Dim websiteTitle As String = ""
        If Not ConfigurationManager.AppSettings("websiteTitle") Is Nothing Then
            websiteTitle = ConfigurationManager.AppSettings("websiteTitle")
        Else
            websiteTitle = "Cargas"
        End If
        Response.Write(", ""websiteTitle"": """ & websiteTitle & """")

        Dim includeUserMenuSetting As Boolean = True
        If Not ConfigurationManager.AppSettings("IncludeUserNameInMenu") Is Nothing Then
            includeUserMenuSetting = CBool(ConfigurationManager.AppSettings("IncludeUserNameInMenu"))
        End If
        Dim includeUserInContext As Boolean = Not includeUserMenuSetting 'I could see this being configurable in different ways
        Response.Write(", ""includeUserInContext"": """ & includeUserInContext.ToString() & """")

        If Not mainScreenItem.DisplayStyle Is Nothing AndAlso mainScreenItem.DisplayStyle.Contains("rightAlignMenu") Then
            Response.Write(", ""menuClass"": ""align-right""")
        ElseIf Not ConfigurationManager.AppSettings("rightAlignMenu") Is Nothing AndAlso CType(ConfigurationManager.AppSettings("rightAlignMenu"), Boolean) Then
            Response.Write(", ""menuClass"": ""align-right""")
        End If




        If mainScreenItem.PageName.Contains("List.html") Then
            Response.Write(", ""pageType"": ""List""")
        ElseIf mainScreenItem.PageName.Contains("Form.html") Then
            Response.Write(", ""pageType"": ""Form""")
        Else
            Response.Write(", ""pageType"": ""Other""")
        End If

        'include save if updateXML
        Response.Write(", ""includeSave"": ")
        If mainScreenItem.UpdateXML.Length = 0 Or containsReport Or mainScreenItem.HideSave Then
            Response.Write("""False""")
            'ElseIf Not mainScreenItem.AllowUpdate Then 'This is currently always returning false
            '    'Response.Write("""False""")
        Else
            Response.Write("""True""")
        End If

        If mainScreenItem.ConfirmationMessage IsNot Nothing AndAlso mainScreenItem.ConfirmationMessage.Length > 0 Then
            Response.Write(" ,""confirmationMessage"": """)
            Response.Write(Common.JSON_Encode(mainScreenItem.ConfirmationMessage, True))
            Response.Write("""")
        End If

        Response.Write(", ""includeRefresh"": ")
        If mainScreenItem.HideRefresh Then
            Response.Write("""False""")
            'ElseIf Not mainScreenItem.AllowUpdate Then 'This is currently always returning false
            '    'Response.Write("""False""")
        Else
            Response.Write("""True""")
        End If

        Dim contextHeaderSI As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        contextHeaderSI = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "contextHeader", Common.UserName(Context))

        If Not contextHeaderSI Is Nothing AndAlso contextHeaderSI.Count > 0 Then
            Response.Write(", ""contextHeader"": ")
            Response.Write("""" + Common.JSON_Encode(contextHeaderSI.Item(0).DisplayName) + """")
            Response.Write(", ""contextHeaderClass"": ")
            Response.Write("""" + Common.JSON_Encode(contextHeaderSI.Item(0).DisplayStyle) + """")
        End If

        Dim clientScriptOnSaveRef As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        clientScriptOnSaveRef = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "clientScriptOnSave", Common.UserName(Context))

        If Not clientScriptOnSaveRef Is Nothing AndAlso clientScriptOnSaveRef.Count > 0 Then
            Response.Write(", ""clientScriptOnSave"": ")
            Response.Write("""" + Common.JSON_Encode(clientScriptOnSaveRef.Item(0).DataStatement) + """")
        End If



        Dim redirect As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        redirect = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "redirect", Common.UserName(Context))

        If Not redirect Is Nothing AndAlso redirect.Count > 0 Then
            Response.Write(", ""redirect"": ")
            Response.Write("""" + Common.JSON_Encode(Common.ScreenReader.RenderHREF(redirect.Item(0).ID, False, sParameter.Replace(",", "&p="), Common.UserName(Context))) + """")
        End If

        Dim clientScriptOnCancel As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        clientScriptOnCancel = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "clientScriptOnCancel", Common.UserName(Context))

        If Not clientScriptOnCancel Is Nothing AndAlso clientScriptOnCancel.Count > 0 Then
            Response.Write(", ""clientScriptOnCancel"": ")
            Response.Write("""" + Common.JSON_Encode(clientScriptOnCancel.Item(0).DataStatement.ToString()) + """")
        End If

        Dim clientScriptOnSave As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        clientScriptOnSave = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "clientScriptOnSave", Common.UserName(Context))

        If Not clientScriptOnSave Is Nothing AndAlso clientScriptOnSave.Count > 0 Then
            Response.Write(", ""clientScriptOnSave"": ")
            Response.Write("""" + Common.JSON_Encode(clientScriptOnSave.Item(0).DataStatement.ToString()) + """")
        End If

        'include the userName for the current user
        Response.Write(", ""UserName"": ")
        Response.Write("""" + Common.JSON_Encode(Context.User.Identity.Name) + """")

        If Not ConfigurationManager.AppSettings("doNotLoadFindSQLResultsOnGet") Is Nothing Then
            doNotLoadFindSQLResultsOnGet = CBool(ConfigurationManager.AppSettings("doNotLoadFindSQLResultsOnGet"))
        Else
            doNotLoadFindSQLResultsOnGet = False
        End If

        'ScreenItemList should still be details. We need to process the order they are saved in.
        If Not ScreenItemList Is Nothing AndAlso ScreenItemList.Count > 0 Then
            Dim asyncSave As Boolean = True
            '"additionalActions": [{ "label": " Save and Return" ,"action": "link" ,"validateForLink": false ,"displayStyle": "icon:exit_to_app" ,"data": "List.html?screenID=TransactionHeader_AIV_List&p=696812&p="},{ "label": " Return Without Saving" ,"action": "linkNoSave" ,"validateForLink": false ,"displayStyle": "icon:close" ,"data": "List.html?screenID=TransactionHeader_AIV_List&p=696812&p="}]}]
            Response.Write(", ""detailSaveOrder"": [")
            Dim isFirst As Boolean = True
            For Each csiSI In ScreenItemList
                '{ "detailScreenID" : "something", "saveOrder" : 1 }
                If Not isFirst Then
                    Response.Write(",")
                End If
                If csiSI.DisplayStyle.Contains("saveHeaderFirst") Then
                    asyncSave = False
                    Response.Write("{ ""detailScreenID"" : """ & csiSI.ID & """, ""saveOrder"" : 3  }")
                ElseIf csiSI.DisplayStyle.Contains("saveDetailFirst") Then
                    asyncSave = False
                    Response.Write("{ ""detailScreenID"" : """ & csiSI.ID & """, ""saveOrder"" : 1  }")
                Else
                    Response.Write("{ ""detailScreenID"" : """ & csiSI.ID & """, ""saveOrder"" : 3  }")
                End If
                isFirst = False
            Next
            Response.Write("]")
            Response.Write(", ""asyncSave"" : """ & asyncSave.ToString() & """")
        End If

        'check for a find control, that is not outlook style
        'or a findSQL
        ScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "findSQL", Common.UserName(Context))
        Response.Write(", ""hasFilter"": ")
        If Not ScreenItemList Is Nothing AndAlso ScreenItemList.Count > 0 Then
            Response.Write("true")
            csiSI = ScreenItemList.Item(0)

            'check screen displayName to see if find control button needs a different display name, otherwise default Get Data
            Response.Write(", ""findDisplayName"": ")
            Dim findDisplayName As String = _DEFAULT_FIND_BUTTON_DISPLAY
            If Not csiSI.DisplayName Is Nothing AndAlso csiSI.DisplayName > "" Then
                findDisplayName = csiSI.DisplayName
            End If
            Response.Write("""" & findDisplayName & """")

            Response.Write(", ""findScreenID"": ")
            Response.Write("""" & csiSI.ID & """")

            'look at the format XML section node for "auto post back" and set a "hideGetDataButton" value
            _xmlFormLayoutFileName = csiSI.FormatXML
            _xmlFormLayout = Common.GetXMLDoc(Context.Server.MapPath(_xmlFormLayoutFileName), HttpRuntime.Cache)

            sectionNodes = _xmlFormLayout.SelectNodes("fieldList/section")
            For Each sectionNode In sectionNodes
                If Not sectionNode.Attributes("autoPostBack") Is Nothing AndAlso CType(sectionNode.Attributes("autoPostBack").Value, Boolean) Then
                    bAutoPostBack = True
                End If
                If Not sectionNode.Attributes("doNotLoadFindSQLResultsOnGet") Is Nothing Then
                    doNotLoadFindSQLResultsOnGet = CType(sectionNode.Attributes("doNotLoadFindSQLResultsOnGet").Value, Boolean)
                End If

            Next

            If bAutoPostBack Then
                Response.Write(", ""isAutoPostBack"": true")

            End If
        Else
            Response.Write("false")
        End If

        Response.Write(", ""doNotLoadFindSQLResultsOnGet"": ")
        Response.Write(doNotLoadFindSQLResultsOnGet.ToString().ToLower())

        'do something similar for left nav...
        Dim leftMenu As Boolean
        ScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "LeftNav", Common.UserName(Context))
        If ScreenItemList Is Nothing Then
            Dim sMenuID As String = ConfigurationManager.AppSettings("defaultLeftMenuID")
            ScreenItemList = Common.ScreenReader.References(sMenuID, "menu", Common.UserName(Context))
            leftMenu = True
        End If

        'Dim eff As EffectivePermission = Common.SecurityProvider.GetEffectivePermission(ScreenItemList(0).ID, "screen", Common.UserName(Context))

        If Not ScreenItemList Is Nothing Then
            ScreenItemList(0).CheckAccess("")
        End If

        Response.Write(", ""hasLeftNav"": ")

        If Not ScreenItemList Is Nothing AndAlso ScreenItemList.Count > 0 AndAlso ScreenItemList(0).AllowAccess Then
            Response.Write("true")
            Response.Write(", ""leftNavHeader"":")
            Response.Write("""")
            Response.Write(ScreenItemList.Item(0).DisplayName)
            Response.Write("""")

            'if there is a numeric displayStyle then output as leftNavFlexWidth
            If ScreenItemList.Item(0).DisplayStyle > "" AndAlso IsNumeric(ScreenItemList.Item(0).DisplayStyle) Then
                Response.Write(", ""leftNavFlexWidth"":")
                Response.Write("""")
                Response.Write(ScreenItemList.Item(0).DisplayStyle)
                Response.Write("""")
            Else
                'default to 30                
                Response.Write(", ""leftNavFlexWidth"":")
                Response.Write("""")
                Response.Write("30")
                Response.Write("""")

            End If

        Else
            Response.Write("false")
        End If

        'check for displaySettings type of reference
        'displaySettings
        ScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "displaySettings", Common.UserName(Context))
        If Not ScreenItemList Is Nothing AndAlso ScreenItemList.Count > 0 Then
            For Each displayItem As ScreenItem In ScreenItemList
                If displayItem.DisplayStyle = "NoMenu" Then
                    Response.Write(", ""noMenu"": true")
                ElseIf displayItem.DisplayStyle = "NoContext" Then
                    Response.Write(", ""noContext"": true")
                ElseIf displayItem.DisplayStyle = "NoLeftMenu" Then
                    Response.Write(", ""noLeftMenu"": true")
                End If
            Next
        End If
        'Response.Write(", ""noMenu"": true")

        Dim additionalActionFirst As Boolean = True
        'check for additional processes and add to that object
        ScreenItemList = New System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        Dim tempScreenItemList As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)

        tempScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "additionalProcess", Common.UserName(Context))
        If Not tempScreenItemList Is Nothing Then
            ScreenItemList.AddRange(tempScreenItemList)
        End If

        tempScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "popupLink", Common.UserName(Context))
        If Not tempScreenItemList Is Nothing Then
            ScreenItemList.AddRange(tempScreenItemList)
        End If

        tempScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "link", Common.UserName(Context))
        If Not tempScreenItemList Is Nothing Then
            ScreenItemList.AddRange(tempScreenItemList)
        End If

        tempScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "linkNoSave", Common.UserName(Context))
        If Not tempScreenItemList Is Nothing Then
            ScreenItemList.AddRange(tempScreenItemList)
        End If

        tempScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "newWindow", Common.UserName(Context))
        If Not tempScreenItemList Is Nothing Then
            ScreenItemList.AddRange(tempScreenItemList)
        End If

        tempScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "newWindowNoSave", Common.UserName(Context))
        If Not tempScreenItemList Is Nothing Then
            ScreenItemList.AddRange(tempScreenItemList)
        End If

        tempScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "refreshMenus", Common.UserName(Context))
        If Not tempScreenItemList Is Nothing Then
            ScreenItemList.AddRange(tempScreenItemList)
        End If

        If Not ScreenItemList Is Nothing AndAlso ScreenItemList.Count > 0 Then
            Response.Write(", ""additionalActions"": [")
            'process each one
            'get the parameter set...so can pass into the url
            For Each csiSI In ScreenItemList
                Dim currentParameter As String = ""
                If Not csiSI.LinkFields Is Nothing AndAlso csiSI.LinkFields.Count > 0 Then
                    For Each linkField As String In csiSI.LinkFields
                        If currentParameter = "" Then
                            currentParameter = "{{thisRecord." + linkField + "}}"
                        Else
                            currentParameter = currentParameter + "," + "{{thisRecord." + linkField + "}}"
                        End If
                    Next
                End If
                If currentParameter = "" Then
                    currentParameter = sParameter
                End If
                headerLinkURL = Common.JSON_Encode(Common.ScreenReader.RenderHREF(csiSI.ID, False, currentParameter.Replace(",", "&p="), Common.UserName(Context)))
                If headerLinkURL > "" Then

                    If Not additionalActionFirst Then
                        Response.Write(",")

                    End If

                    additionalActionFirst = False

                    Response.Write("{")
                    Response.Write(" ""label"": "" ")
                    Response.Write(Common.JSON_Encode(csiSI.DisplayName))
                    Response.Write("""")

                    'make this smarter based on the url.....
                    'for now, just make the action link
                    'at least one other possiblity = "call page" which would post to the dataload, and refresh page data
                    If headerLinkURL.StartsWith("javascript:") Then
                        Response.Write(" ,""action"": ""evalData""")
                    ElseIf csiSI.ItemType = "popupLink" Then
                        Response.Write(" ,""action"": ""popup""")
                    ElseIf csiSI.ItemType = "additionalProcess" AndAlso isForm Then
                        Response.Write(" ,""action"": ""executeCommand""")
                    ElseIf csiSI.ItemType = "linkNoSave" Then
                        Response.Write(" ,""action"": ""linkNoSave""")
                    ElseIf csiSI.ItemType = "newWindow" Then
                        Response.Write(" ,""action"": ""newWindow""")
                    ElseIf csiSI.ItemType = "newWindowNoSave" Then
                        Response.Write(" ,""action"": ""newWindowNoSave""")
                    ElseIf csiSI.ItemType = "refreshMenus" Then
                        Response.Write(" ,""action"": ""refreshMenus""")
                    Else
                        Response.Write(" ,""action"": ""link""")
                    End If

                    Response.Write(" ,""validateForLink"": " & csiSI.validateForLink.ToString().ToLower())

                    If csiSI.ConfirmationMessage IsNot Nothing AndAlso csiSI.ConfirmationMessage.Length > 0 Then
                        Response.Write(" ,""confirmationMessage"": """)
                        Response.Write(Common.JSON_Encode(csiSI.ConfirmationMessage, True))
                        Response.Write("""")
                    End If

                    Response.Write(" ,""displayStyle"": """)
                    If Not csiSI.DisplayStyle Is Nothing Then
                        Response.Write(Common.JSON_Encode(csiSI.DisplayStyle, True))
                    End If
                    Response.Write("""")

                    Response.Write(" ,""data"": """)
                    If csiSI.ItemType = "additionalProcess" AndAlso isForm Then
                        Response.Write(csiSI.ID)
                        'look for redirect reference inside additionalProcess screen definition. If found, pass it in.
                        Dim redirectScreenItemList As List(Of ScreenItem) = csi.Framework.Utility.Common.ScreenReader.References(csiSI.ID, "redirect", Common.UserName(Context))
                        If Not redirectScreenItemList Is Nothing AndAlso redirectScreenItemList.Count > 0 Then
                            Dim redirectScreen As ScreenItem = redirectScreenItemList.Item(0)

                            Response.Write("""")
                            Response.Write(" ,""additionalProcessRedirectUrl"": """)
                            Response.Write(Common.JSON_Encode(Common.ScreenReader.RenderHREF(redirectScreen.ID, False, currentParameter.Replace(",", "&p="), Common.UserName(Context))))

                        End If
                    Else
                        Response.Write(headerLinkURL)
                    End If
                    Response.Write("""")


                    Response.Write("}")

                    'HeaderContainerHTML.Append("<a href=""" + headerLinkURL + """ class=""additionalProcessButton"" >")
                    'HeaderContainerHTML.Append(csiSI.DisplayName)
                    'HeaderContainerHTML.Append("</a>")
                End If

            Next

            'close the array
            Response.Write("]")

        End If



        'check for new record reference
        'do something similar for left nav...
        ScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "new record", Common.UserName(Context))
        If Not ScreenItemList Is Nothing AndAlso ScreenItemList.Count > 0 Then
            csiSI = ScreenItemList.Item(0)
            headerLinkURL = Common.JSON_Encode(Common.ScreenReader.RenderHREF(csiSI.ID, False, sParameter.Replace(",", "&p="), Common.UserName(Context)))
            If headerLinkURL > "" Then
                Response.Write(", ""newRecord"": {")

                '{action: blah, data: url}
                Response.Write("""action"":")
                'base this value on the type
                Select Case csiSI.DisplayStyle
                    Case "redirect"
                        Response.Write("""link""")

                    Case "inline"
                        Response.Write("""popup""")
                    Case "lightbox"
                        Response.Write("""popup""")
                    Case Else
                        Response.Write("""popup""")

                End Select


                Response.Write(",""data"":")
                'write out the URL            
                Response.Write("""")
                Response.Write(headerLinkURL)
                Response.Write("""")


                Response.Write("}")

            End If

        End If


        'close the json object
        Response.Write("}]")

    End Sub





    Private Sub DefaultApplicationVariableHashTable()
        Dim thisHashTable As Hashtable

        If Context.Session("applicationVariable") Is Nothing Then
            thisHashTable = New Hashtable

        Else

            thisHashTable = CType(Context.Session("applicationVariable"), Hashtable)

        End If

        If Not thisHashTable.ContainsKey("UserName") Then
            thisHashTable.Add("UserName", Context.User.Identity.Name)
        ElseIf thisHashTable.Item("UserName").ToString = "" Then
            thisHashTable.Item("UserName") = Context.User.Identity.Name
        End If
        'For now, slam in a UserDate for testing againsts Creamery
        If Not thisHashTable.ContainsKey("UserDate") Then
            thisHashTable.Add("UserDate", New Date().ToString("MM/dd/yyyy"))
        ElseIf thisHashTable.Item("UserDate").ToString = "" Then
            thisHashTable.Item("UserDate") = New Date().ToString("MM/dd/yyyy")
        End If

        Context.Session("applicationVariable") = thisHashTable
    End Sub



    Private Function BuildReportUrl(csiSI As ScreenItem) As String

        If csiSI Is Nothing Then
            Return ""
        End If
        'default from config
        Dim sViewer As String = "reportViewerAR.aspx"
        If Not ConfigurationManager.AppSettings.Item("defaultReportViewer") Is Nothing Then
            sViewer = ConfigurationManager.AppSettings.Item("defaultReportViewer")
        End If

        'extensions from config
        If csiSI.PageName.LastIndexOf(".") > 0 And csiSI.PageName.LastIndexOf(".") < csiSI.PageName.Length Then
            Dim reportExt As String = csiSI.PageName.Substring(csiSI.PageName.LastIndexOf(".") + 1, csiSI.PageName.Length - csiSI.PageName.LastIndexOf(".") - 1)
            If Not ConfigurationManager.AppSettings.Item(reportExt) Is Nothing Then
                sViewer = ConfigurationManager.AppSettings.Item(reportExt)
            End If
        End If


        'displayStyle from report
        If csiSI.DisplayStyle > "" And csiSI.DisplayStyle <> "always visible" And csiSI.DisplayStyle <> "popup" Then
            sViewer = csiSI.DisplayStyle
        End If

        If Request.Params("Viewer") > "" Then
            sViewer = Request.Params("Viewer")
        End If

        Dim sURL As StringBuilder = New StringBuilder("")
        sURL.Append(sViewer)
        sURL.Append("?screenID=")
        sURL.Append(csiSI.ID)
        sURL.Append("&Report=")
        sURL.Append(csiSI.PageName)
        sURL.Append("&ReportFormat={{data.screenPropertySet.reportFormat}}")


        Dim csiSIRefs As List(Of ScreenItem) = Common.ScreenReader.References(csiSI.ID, "exportFile", Common.UserName(Context))
        If Not csiSIRefs Is Nothing Then
            For Each thisSI As ScreenItem In csiSIRefs
                If thisSI.LinkFields.Count >= 1 Then
                    sURL.Append("&fileNameField=")
                    sURL.Append(thisSI.LinkFields(0))
                End If
                If thisSI.LinkFields.Count >= 2 Then
                    sURL.Append("&displayRecordField=")
                    sURL.Append(thisSI.LinkFields(1))
                End If
                Exit For
            Next
        End If

        ' Get the report parameters
        'Dim thisParamDoc As XmlDocument = fvReportParams.MapToXML(csiSI.UpdateXML)
        'For Each thisNode As XmlNode In thisParamDoc.ChildNodes(0).ChildNodes
        '    sURL.Append("&p=")
        '    sURL.Append(thisNode.InnerXml.Replace("#", "%23"))
        'Next thisNode

        'parameters will be added on report rendering when it calls DataSend/DataSend_MapUpdateXml.ashx
        'sURL.Append("&p=")

        ' Register script to open report in new window
        ' Or open the report in the same window
        ' PRC: Removed all this Code. If need it back, please reference generateReport.aspx.vb lines 296-376


        Return sURL.ToString()

    End Function


</script>

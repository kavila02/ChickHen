<%@ WebHandler Language="VB" Class="csbAngular_GetListContentForScreen" %>

Imports System
Imports System.Web
Imports csi.Framework.ScreenData
Imports csi.Framework.Web
Imports csi.Framework.Security
Imports csi.Framework.ScreenDefinition
Imports csi.Framework.Utility
Imports System.Xml
Imports System.Text.RegularExpressions
Imports csi.Framework.InputControls
Imports System.IO


Public Class csbAngular_GetListContentForScreen : Implements IHttpHandler, IReadOnlySessionState

    Private _xmlGlobalFileName As String = ConfigurationManager.AppSettings("xmlGlobal")
    Private _xmlFormLayoutFileName As String = ""
    Private _xmlFormLayoutFileNameSecondary As String = ""
    Private _xmlGlobal As XmlDocument
    Private _xmlFormLayout As XmlDocument
    Private _fieldDataPrefix As String = "data.firstRow()"
    Private _fieldDataHeaderPrefix As String = "data.firstRow()"
    Private _thisSchema As System.Data.DataTable

    Private formReadOnly As Boolean = False
    Private fieldReadOnly As Boolean = False

    Dim isListTemplate As Boolean
    Dim isCalendar As Boolean = False

    Dim thisScreenReader As csi.Framework.ScreenData.ScreenReader = csi.Framework.Utility.Common.ScreenReader
    Dim sScreenID As String
    Dim thisFramework As csi.Framework.Utility.Data

    Dim _userName As String

    Dim _mainScreenItem As ScreenItem

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest


        sScreenID = context.Request.QueryString("ScreenID")

        _userName = Common.UserName(context)
        _mainScreenItem = TemplateUtility.CheckAccess(_userName)
        _xmlFormLayoutFileName = _mainScreenItem.FormatXML

        If _xmlFormLayoutFileName.Contains("|") Then
            _xmlFormLayoutFileName = _xmlFormLayoutFileName.Split("|").GetValue(0).ToString()
            _xmlFormLayoutFileNameSecondary = _xmlFormLayoutFileName.Split("|").GetValue(1).ToString()
        End If
        If System.IO.Path.GetExtension(_xmlFormLayoutFileName) = ".html" Then
            context.Response.TransmitFile(_xmlFormLayoutFileName)
            If Not _xmlFormLayoutFileNameSecondary Is Nothing AndAlso _xmlFormLayoutFileNameSecondary > "" Then
                context.Response.TransmitFile(_xmlFormLayoutFileNameSecondary)
            End If
            context.Response.End()
            Exit Sub
        End If

        _xmlGlobal = Common.getXMLDoc(context.Server.MapPath(_xmlGlobalFileName), HttpRuntime.Cache)
        _xmlFormLayout = Common.getXMLDoc(context.Server.MapPath(_xmlFormLayoutFileName), HttpRuntime.Cache)


        Dim isCalendarParam As String = context.Request.QueryString("isCalendar")

        If Not isCalendarParam Is Nothing AndAlso isCalendarParam.ToLower() = "true" Then
            isCalendar = True
        End If

        If Not context.Request.QueryString("isListTemplate") Is Nothing Then
            isListTemplate = CType(context.Request.QueryString("isListTemplate"), Boolean)
        Else
            isListTemplate = False
        End If



        'schema request here

        'get the data schema for checking of data types
        Dim dataStatement As String = _mainScreenItem.DataStatement
        Dim sql As String
        Dim paramArrayValues() As String
        Dim paramArrayValuesCombined(0) As String
        Dim streamRead As IO.StreamReader = New IO.StreamReader(context.Request.InputStream)
        Dim JSON_DictionaryLength As Integer = 0

        context.Request.InputStream.Position = 0
        Dim sJSON As String = streamRead.ReadToEnd()
        Dim JSON_StringDictionary As StringDictionary = JSON_ParseSimpleToDictionary(sJSON)
        streamRead.Close()
        streamRead.Dispose()
        context.Response.ContentType = "text/html"
        If dataStatement > "" Then

            'let's replace the parameters in our schema call
            Dim csiSI_Find As ScreenItem
            Dim csiFindReferences As System.Collections.Generic.List(Of ScreenItem)
            Dim csiSI As ScreenItem = thisScreenReader.Item(sScreenID, Common.UserName(context))

            csiFindReferences = thisScreenReader.References(csiSI.ID, "findSQL", Common.UserName(context))
            If Not csiFindReferences Is Nothing AndAlso csiFindReferences.Count > 0 Then
                csiSI_Find = csiFindReferences.Item(0)
            End If
            'if this is a findSQL reference type then switch the screenID
            If Not csiSI_Find Is Nothing Then
                csiSI = csiSI_Find


                Dim findDataStatement As String = csiSI_Find.DataStatement
                If findDataStatement IsNot Nothing AndAlso findDataStatement.Length > 0 Then
                    thisFramework = New Data
                    findDataStatement = Common.ReplaceVariables(findDataStatement, CType(context.Session("applicationVariable"), Hashtable))

                    If context.Request.Params("p") IsNot Nothing Then
                        Dim currentParameters As Parameters = New Parameters(context.Request)
                        paramArrayValues = currentParameters.Array

                        Array.Resize(paramArrayValuesCombined, paramArrayValuesCombined.Length + paramArrayValues.Length)
                        paramArrayValues.CopyTo(paramArrayValuesCombined, JSON_DictionaryLength)
                        Try
                            findDataStatement = String.Format(findDataStatement, paramArrayValuesCombined)
                        Catch ex As Exception

                        End Try
                    Else

                    End If


                    sJSON = thisFramework.SQL_To_JSON(findDataStatement, False)
                    'Response.Write(sJSON)
                    'if the sql is returned, it has a [] around it...strip that off
                    If sJSON.Length > 1 AndAlso sJSON.StartsWith("[") Then
                        sJSON = sJSON.Substring(1, sJSON.Length - 2)
                    End If
                    JSON_StringDictionary = JSON_ParseSimpleToDictionary(sJSON)

                End If
            End If

            If Not JSON_StringDictionary Is Nothing Then
                JSON_DictionaryLength = JSON_StringDictionary.Count

                Array.Resize(paramArrayValuesCombined, JSON_StringDictionary.Count)

                csiFindReferences = thisScreenReader.References(sScreenID, "findSQL", Common.UserName(context))
                If Not csiSI_Find Is Nothing Then
                    Dim iLinkFieldCount As Integer = 0
                    For Each sLinkField As String In csiSI_Find.LinkFields
                        'add values to the parameter array in this order
                        'Response.Write(sLinkField)
                        paramArrayValuesCombined(iLinkFieldCount) = JSON_StringDictionary.Item(sLinkField).ToString()
                        iLinkFieldCount += 1
                    Next
                End If

            End If

            'end new stuff for parameters

            dataStatement = csi.Framework.Utility.Common.ReplaceVariables(dataStatement, CType(context.Session("applicationVariable"), Hashtable))
            If context.Request.Params("p") IsNot Nothing Then
                Dim currentParameters As Parameters = New Parameters(context.Request)
                paramArrayValues = currentParameters.Array
                'paramArrayValues = CType(context.Request.Params("p"), String).Split(New Char() {CChar(",")})

                Array.Resize(paramArrayValuesCombined, paramArrayValuesCombined.Length + paramArrayValues.Length)
                paramArrayValues.CopyTo(paramArrayValuesCombined, JSON_DictionaryLength)
                Try
                    sql = String.Format(dataStatement, paramArrayValuesCombined)
                Catch ex As Exception
                    sql = dataStatement
                End Try

                'PRC 1/3/18 I think this was before we passed find parameters into the schema.
                'sql = Regex.Replace(dataStatement, "'{[0-9]}'", "NULL")
            Else
                sql = dataStatement
                Dim debug As String
            End If

            thisFramework = New Data
            'always test for thisSchema existing, since  it might not
            Try
                _thisSchema = thisFramework.SQL_To_SchemaOnly(sql)
            Catch ex As Exception

            End Try


        End If


        Dim headerContent As StringBuilder = New StringBuilder()
        Dim rowContent As StringBuilder = New StringBuilder()
        Dim advancedFindContent As StringBuilder = New StringBuilder()
        Dim listContent As StringBuilder = New StringBuilder()

        buildHtmlContent(headerContent, advancedFindContent, rowContent, listContent)

        If isCalendar Then
            ProcessCalendar(context, headerContent, rowContent, listContent)
        End If


        'context.Response.Write("<table class=""table table-striped table-bordered table-condensed md-default-theme"">")

        If _xmlFormLayoutFileName.Contains("|") Then
            _xmlFormLayoutFileName = _xmlFormLayoutFileName.Split("|").GetValue(0).ToString()
            _xmlFormLayoutFileNameSecondary = _xmlFormLayoutFileName.Split("|").GetValue(1).ToString()
        End If
        If System.IO.Path.GetExtension(_xmlFormLayoutFileName) = ".html" Then
            context.Response.TransmitFile(_xmlFormLayoutFileName)
            If Not _xmlFormLayoutFileNameSecondary Is Nothing AndAlso _xmlFormLayoutFileNameSecondary > "" Then
                context.Response.TransmitFile(_xmlFormLayoutFileNameSecondary)
            End If
            context.Response.End()
            Exit Sub
        End If

        If Not isCalendar Then

            context.Response.Write("<thead>")
            context.Response.Write("<tr>")

            context.Response.Write(headerContent)
            If isListTemplate Then
                context.Response.Write(advancedFindContent.ToString())
            End If

            'ProcessHeaderRow(context)
            context.Response.Write("</tr>")
            context.Response.Write("</thead>")

            If isListTemplate Then
                context.Response.Write("<tr table-content-main-row=""table-content-main-row"" dir-paginate=""thisRecord in data.records | filter:(data.searchString||data.searchArray) | filter:data.advancedFilter | orderBy: data.sortString:data.sortReverse | itemsPerPage: data.pageSize "" current-page=""data.currentPage"">")
            Else
                context.Response.Write("<tr table-content-row=""table-content-row"" screen-id=""" & sScreenID & """ table-screen-id=""" & sScreenID & """ pagination-id=""" & sScreenID & """ dir-paginate=""thisRecord in theseRecords | orderBy: theseRecords.sortString:theseRecords.sortReverse | itemsPerPage: pageSize "" current-page=""theseRecords.currentPage"">")
            End If
            'ProcessDataRow(context)
            context.Response.Write(rowContent.ToString())
            context.Response.Write(listContent.ToString())
            context.Response.Write("</tr>")

            ' context.Response.Write("</table")
            'ProcessFooter(context)
        End If

    End Sub

    Private Sub buildHtmlContent(ByRef headerContent As StringBuilder, ByRef advancedFindContent As StringBuilder, ByRef rowContent As StringBuilder, ByRef listContent As StringBuilder)

        Dim sectionNodes As XmlNodeList
        Dim sectionNode As XmlNode
        Dim fieldNode As XmlNode
        Dim thisFP As UIFieldProperty

        Dim alNodes As System.Collections.Generic.IList(Of XmlNode) = New System.Collections.Generic.List(Of XmlNode)
        Dim sFieldName As String

        If Not isListTemplate Then
            _fieldDataPrefix = "data.detailRecords[0]." & _mainScreenItem.ID & "[0]"
            _fieldDataHeaderPrefix = "data.detailRecords[0]." & _mainScreenItem.ID & "[0]"
        Else
            _fieldDataPrefix = "thisRecord"
            _fieldDataHeaderPrefix = "data.records[0]"
        End If
        formReadOnly = Not _mainScreenItem.AllowUpdate


        sectionNodes = _xmlFormLayout.SelectNodes("fieldList/section")

        'so it seems that in divs, putting these attributes in the element are enough, as it also adds them as a class
        'in td's it does not also add them as a class, and the new css refers to all the show and hide stuff as classes
        Dim headerSizing As String = "hide-xs hide-sm"
        Dim tableSizing As String = "hide-xs hide-sm"
        Dim mobileSizing As String = "hide-gt-sm"

        Dim mobileLayoutSize As String = "medium"

        If Not sectionNodes(0).Attributes("mobileLayoutSize") Is Nothing AndAlso sectionNodes(0).Attributes("mobileLayoutSize").Value.ToString() > "" Then
            mobileLayoutSize = sectionNodes(0).Attributes("mobileLayoutSize").Value.ToString().ToLower()
        ElseIf Not ConfigurationManager.AppSettings("mobileLayoutSize") Is Nothing AndAlso ConfigurationManager.AppSettings("mobileLayoutSize") > "" Then
            mobileLayoutSize = ConfigurationManager.AppSettings("mobileLayoutSize")
        End If

        Select Case mobileLayoutSize
            Case "none"
                headerSizing = ""
                tableSizing = ""
                mobileSizing = "hide"
            Case "small"
                headerSizing = "hide-xs"
                tableSizing = "hide-xs"
                mobileSizing = "hide-gt-xs"
            Case "medium" 'this is the default, but it's here as an option nonetheless
                headerSizing = "hide-xs hide-sm"
                tableSizing = "hide-xs hide-sm"
                mobileSizing = "hide-gt-sm"
            Case "large"
                headerSizing = "hide-lt-lg"
                tableSizing = "hide-lt-lg"
                mobileSizing = "hide-lg hide-xl"
            Case Else
                headerSizing = "hide-xs hide-sm"
                tableSizing = "hide-xs hide-sm"
                mobileSizing = "hide-gt-sm"
        End Select

        If isCalendar Then
            headerSizing = ""
            tableSizing = ""
            mobileSizing = ""
        End If


        Dim columnSpan As Integer = 0
        If Not sectionNodes(0).Attributes("columnSpan") Is Nothing AndAlso IsNumeric(sectionNodes(0).Attributes("columnSpan")) Then
            columnSpan = CInt(sectionNodes(0).Attributes("columnSpan").ToString())
        End If

        Dim dataPrefix As String = "data"
        If Not isListTemplate Then
            dataPrefix = "theseRecords"
        End If


        'add the isChange column
        headerContent.Append("<th Class=""csb-smallIcon " & headerSizing & """ ng-if=""" & dataPrefix & ".numberOfRowsTouched()>0"" />")

        advancedFindContent.Append("<th style=""display: none;"" ng-init=""data.setAdvancedSearchFields([")

        listContent.Append("<td class=""" & mobileSizing & """>")
        listContent.Append("<dl class=""dl-horizontal ")
        If isCalendar Then
            listContent.Append("dl-calendar")
        End If
        listContent.Append(""">")

        'check if isChange has custom class
        Dim isChangeClass As String = ""
        If Not sectionNodes(0).Attributes("isChangeClass") Is Nothing AndAlso sectionNodes(0).Attributes("isChangeClass").Value.ToString() > "" Then
            isChangeClass = sectionNodes(0).Attributes("isChangeClass").Value.ToString()
        End If

        rowContent.Append("<td class=""csb-smallIcon " & isChangeClass & """ ng-if=""" & dataPrefix & ".numberOfRowsTouched()>0"" >")
        rowContent.Append("<md-icon ng-if=""thisRecord.thisRowHasChanged"" class=""material-icons md-icon md-accent"">mode_edit</md-icon>")
        rowContent.Append("</td>")

        For Each sectionNode In sectionNodes
            'loop through the fields in each section
            Dim oneWayBinding As String = ""
            If Not sectionNode.Attributes("readOnlyOneWayBinding") Is Nothing Then
                oneWayBinding = sectionNode.Attributes("readOnlyOneWayBinding").Value.ToString()
            End If
            For Each fieldNode In sectionNode.ChildNodes


                'if not an element node type, skip on...
                If fieldNode.NodeType <> XmlNodeType.Element Then
                    Continue For
                End If

                alNodes.Clear()
                alNodes.Add(fieldNode)
                sFieldName = fieldNode.Attributes("fieldName").Value.ToString()

                If _xmlGlobal.SelectNodes("fieldList/section/field[@fieldName='" & sFieldName & "']").Count > 0 Then
                    alNodes.Add(_xmlGlobal.SelectSingleNode("fieldList/section/field[@fieldName='" & sFieldName & "']"))
                End If

                thisFP = New UIFieldProperty(alNodes)

                Dim thisSchemaRow As System.Data.DataRow
                Dim thisSchemaRows() As System.Data.DataRow
                Dim thisSchemaRowDataType As String
                thisSchemaRowDataType = ""
                If Not _thisSchema Is Nothing Then
                    'thisSchemaRow = thisSchema.Rows.Find(thisFP.FieldName)
                    thisSchemaRows = _thisSchema.Select("ColumnName='" & thisFP.FieldName & "'")
                    If thisSchemaRows.Length > 0 Then
                        thisSchemaRow = _thisSchema.Select("ColumnName='" & thisFP.FieldName & "'")(0)
                        thisSchemaRowDataType = thisSchemaRow.Item("DataTypeName").ToString()

                    End If

                End If

                Dim formatName = thisFP.FormatName

                If formatName = "date" Or formatName = "bit" Or formatName = "boolean" Or formatName = "time" Then
                    thisSchemaRowDataType = thisFP.FormatName
                    formatName = ""
                End If
                If thisFP.IsDropDown Then
                    thisSchemaRowDataType = "dropdown"
                End If


                headerContent.Append("<th ")
                If thisFP.hidden Then
                    headerContent.Append(" ng-show=""false"" ")
                ElseIf thisFP.HideWhenNull Then
                    headerContent.Append(" ng-show=""" & _fieldDataHeaderPrefix & ".hasOwnProperty('" & thisFP.FieldName & "')"" ")
                End If
                headerContent.Append(" class=""" & thisFP.ClassName & " " & headerSizing & """")
                headerContent.Append(">")
                headerContent.Append("<div ng-click=""" & dataPrefix & ".setColumnSorting(" & dataPrefix & ", '")
                headerContent.Append(thisFP.FieldName)
                headerContent.Append("','" & thisSchemaRowDataType & "');"" tabindex=""-1"">")

                'DisplayName can be data driven
                Dim displayName As String = thisFP.DisplayName
                If displayName.ToLower().StartsWith("fieldname") Or displayName.ToLower().StartsWith("datafield") Then
                    displayName = "{{" & _fieldDataHeaderPrefix & "." & displayName.Replace("fieldname ", "").Replace("fieldName ", "").Replace("datafield ", "").Replace("dataField ", "") & "}}"
                End If

                headerContent.Append(displayName)
                headerContent.Append("<span ng-show=""" & dataPrefix & ".checkColumnSorting(" & dataPrefix & ", '")
                headerContent.Append(thisFP.FieldName)
                headerContent.Append("')!=0"" class=""csb-sortGlyph glyphicon "" ng-class=""{'glyphicon-triangle-top':" & dataPrefix & ".checkColumnSorting(" & dataPrefix & ", '")

                headerContent.Append(thisFP.FieldName)
                headerContent.Append("')<0, 'glyphicon-triangle-bottom':" & dataPrefix & ".checkColumnSorting(" & dataPrefix & ", '")
                headerContent.Append(thisFP.FieldName)
                headerContent.Append("')>0}"" ></span></div>")
                If Not thisFP.UpdateAllColumnsType Is Nothing AndAlso thisFP.UpdateAllColumnsType > "" Then
                    Dim fieldBase As InputControlBase = InputControlFactory.GetInputControl(thisFP, False, thisFP.UpdateAllColumnsType, 100, True, True, sScreenID, _userName, isListTemplate, columnSpan, "", "")
                    headerContent.Append(fieldBase.RenderString)
                End If
                headerContent.Append("</th>")

                Dim excludeFromFind As Boolean = False
                If Not fieldNode.Attributes("excludeFromFind") Is Nothing AndAlso fieldNode.Attributes("excludeFromFind").Value > "" Then
                    excludeFromFind = CType(fieldNode.Attributes("excludeFromFind").Value, Boolean)
                End If
                If Not thisFP.FieldType.ToLower().StartsWith("link") And Not thisFP.FieldType.ToLower().StartsWith("command") And Not excludeFromFind Then
                    If advancedFindContent.ToString().EndsWith("}") Then
                        advancedFindContent.Append(",")
                    End If
                    advancedFindContent.Append("{'field':'")
                    advancedFindContent.Append(thisFP.FieldName)
                    advancedFindContent.Append("', 'label':'")
                    advancedFindContent.Append(displayName)

                    advancedFindContent.Append("', 'type':'")
                    If thisFP.IsDropDown Then
                        advancedFindContent.Append("dropdown")
                    End If
                    If thisSchemaRowDataType = "date" Then
                        advancedFindContent.Append("date")
                    End If
                    advancedFindContent.Append("'")
                    advancedFindContent.Append("}")
                End If



                fieldReadOnly = thisFP.IsReadOnly

                'is this something that we depricate for simplicities sake?
                'check for this being an autoLink field
                Dim autoLinkScreen As ScreenItem

                If thisFP.DoNotAutoLink OrElse thisFP.ScreenID > "" Then
                    autoLinkScreen = Nothing
                Else
                    autoLinkScreen = Common.ScreenReader.Item(thisFP.FieldName, "autoLinkFieldName", _userName)
                End If

                'reset to link field, if you found the screen
                If Not autoLinkScreen Is Nothing Then
                    If thisFP.FieldType = "standard" Then
                        thisFP.FieldType = "link display " & thisFP.FieldName
                    End If
                    If thisFP.ScreenID = "" Then
                        thisFP.ScreenID = autoLinkScreen.ID
                    End If
                End If
                'end of possible deprication on autolink property


                listContent.Append("<dt>")

                listContent.Append(displayName)
                listContent.Append("</dt>")



                'find the right row in the schema table
                'TODO JDC
                thisSchemaRowDataType = ""
                If Not _thisSchema Is Nothing Then
                    'thisSchemaRow = thisSchema.Rows.Find(thisFP.FieldName)
                    thisSchemaRows = _thisSchema.Select("ColumnName='" & thisFP.FieldName & "'")
                    If thisSchemaRows.Length > 0 Then
                        thisSchemaRow = _thisSchema.Select("ColumnName='" & thisFP.FieldName & "'")(0)
                        thisSchemaRowDataType = thisSchemaRow.Item("DataTypeName").ToString()

                    End If

                End If

                Dim isReadOnly As Boolean = (thisFP.MultilineEdit = False Or formReadOnly Or fieldReadOnly Or thisFP.FieldType.StartsWith("command") Or thisFP.FieldType.StartsWith("link"))
                If thisFP.ReadOnlyOneWayBinding = "" Then
                    If oneWayBinding > "" Then 'section settings override field settings
                        thisFP.ReadOnlyOneWayBinding = oneWayBinding
                    ElseIf Not ConfigurationManager.AppSettings("readOnlyOneWayBinding") Is Nothing Then
                        thisFP.ReadOnlyOneWayBinding = ConfigurationManager.AppSettings("readOnlyOneWayBinding")
                    Else
                        thisFP.ReadOnlyOneWayBinding = "True"
                    End If
                End If

                Dim field As InputControlBase = InputControlFactory.GetInputControl(thisFP, isReadOnly, thisSchemaRowDataType, 100, False, True, sScreenID, _userName, isListTemplate, columnSpan, "", formatName)
                Dim className As String = thisFP.ClassName
                If thisFP.FieldType.StartsWith("link") Then
                    className = className & " csb-link-td"
                End If


                rowContent.Append("<td  ")
                If thisFP.hidden Then
                    rowContent.Append(" ng-show=""false"" ")
                ElseIf thisFP.HideWhenNull Then
                    rowContent.Append(" ng-show=""" & _fieldDataPrefix & ".hasOwnProperty('" & thisFP.FieldName & "')"" ")
                End If
                rowContent.Append(" class=""" & className & " " & tableSizing & """")
                rowContent.Append(">")
                rowContent.Append(field.RenderString().Replace(" id=""", " id=""td"))
                rowContent.Append("</td>")


                listContent.Append("<dd")
                If thisFP.hidden Then
                    listContent.Append(" ng-show=""false"" ")
                ElseIf thisFP.HideWhenNull Then
                    listContent.Append(" ng-show=""" & _fieldDataPrefix & ".hasOwnProperty('" & thisFP.FieldName & "')"" ")
                End If
                listContent.Append(" class=""" & thisFP.ClassName & """")
                listContent.Append(">")
                listContent.Append(field.RenderString())
                listContent.Append("</dd>")


            Next
        Next

        advancedFindContent.Append("])""></th>")

    End Sub


    Private Sub ProcessFooter(ByVal context As HttpContext)
        context.Response.Write("<div>")
        context.Response.Write("<dir-pagination-controls boundary-links=""true"" template-url=""TemplateHtml/dirPagination.tpl.html""></dir-pagination-controls>")
        context.Response.Write("<md-button class=""md-button ng-scope md-default-theme"" dropdown-j-s-o-n=""dropdownJSON"" ng-click=""thisExport.Export_JSON_To_Excel(data.records, 'Export List', true, data.getAdvancedSearchFieldsFiltered(), data.searchString, data.sortString, dropdownJSON)"" ng-controller=""exportToExcel as thisExport"" style=""float:right; font-size: inherit; height: 24px; min-height:24px; line-height: 24px; margin: 0px; min-width: inherit; width: auto; padding:0px;"">")
        context.Response.Write("<i class=""material-icons ng-scope"">file_download</i>")
        context.Response.Write("<div class=""md-ripple-container""></div>")
        context.Response.Write("</md-button>")
        context.Response.Write("</div>")
    End Sub

    Private Sub ProcessCalendar(ByVal context As HttpContext, ByVal headerContent As StringBuilder, ByVal rowContent As StringBuilder, ByVal listContent As StringBuilder)

        context.Response.Write("<md-content layout='column' layout-fill md-swipe-left='next()' md-swipe-right='prev()'><md-toolbar><div class='md-toolbar-tools' layout='row'><md-button class='md-icon-button' ng-click='prev()' aria-label='Previous month'><md-tooltip ng-if='::tooltips()'>Previous month</md-tooltip><i class='material-icons'>keyboard_arrow_left</i></md-button><div flex></div><h2 class='calendar-md-title'><span>{{ calendar.start | date:titleFormat:timezone }}</span></h2><div flex></div><md-button class='md-icon-button' ng-click='next()' aria-label='Next month'><md-tooltip ng-if='::tooltips()'>Next month</md-tooltip><i class='material-icons'>keyboard_arrow_right</i></md-button></div></md-toolbar><!-- agenda view --><md-content ng-if='weekLayout === columnWeekLayout' class='agenda'><div  ng-repeat='week in calendar.weeks track by $index'>")
        'beginning of agenda week aka sunday
        context.Response.Write("<div ng-if='sameMonth(day)' ng-class='{&quot;disabled&quot; : isDisabled(day), active: active === day }' ng-click='handleDayClick(day)' ng-repeat='day in week' layout='column'>")
        context.Response.Write("<md-tooltip ng-if='::tooltips()'>")
        context.Response.Write("{{ day | date:dayTooltipFormat:timezone }}")
        context.Response.Write("</md-tooltip>")
        context.Response.Write("<div>")
        context.Response.Write("{{ day | date:dayFormat:timezone }}")
        context.Response.Write("</div>")
        'context.Response.Write("<div flex compile='dataService.data[dayKey(day)]'>")

        context.Response.Write("<table class=""table table-striped table-bordered table-condensed md-default-theme"">")

        'context.Response.Write("<div ng-repeat=""thisRecord in records | filter: sameDate(day,'" & _mainScreenItem.masterDateParam & "')"" style=""width:100%;"">")
        context.Response.Write(" <tr ng-repeat=""thisRecord in records | filter: sameDate(day,'" & _mainScreenItem.masterDateParam & "') "" >")
        'ProcessDataRow(context, False, True)
        context.Response.Write(listContent.ToString())
        context.Response.Write("</tr>")
        'context.Response.Write("</div>")

        context.Response.Write("</table>")

        'context.Response.Write("</div>")
        context.Response.Write("</div>")
        context.Response.Write("</div>")
        context.Response.Write("</md-content>")
        context.Response.Write("<!-- calendar view -->")
        context.Response.Write("<md-content ng-if='weekLayout !== columnWeekLayout' flex layout='column' class='calendar'><div layout='row' class='subheader'>")
        context.Response.Write("<div layout-padding class='subheader-day' flex ng-repeat='day in calendar.weeks[0]'>")
        context.Response.Write("<md-tooltip md-direction=""top"" ng-if='::tooltips()'>")
        context.Response.Write("{{ day | date:dayLabelTooltipFormat }}")
        context.Response.Write("</md-tooltip>")
        context.Response.Write("{{ day | date:dayLabelFormat }}")
        context.Response.Write("</div>")
        context.Response.Write("</div>")
        context.Response.Write("<div ng-if='week.length' class=""week"" ng-repeat='week in calendar.weeks track by $index' flex layout='row'>")
        'for each day in week
        context.Response.Write("<div class=""calendarDay"" tabindex='{{ sameMonth(day) ? (day | date:dayFormat:timezone) : 0 }}' ng-repeat='day in week track by $index' ng-click='handleDayClick(day)' flex layout=""column"" layout-padding ng-class='{&quot;disabled&quot; : isDisabled(day), &quot;active&quot;: isActive(day), &quot;md-whiteframe-12dp&quot;: hover || focus }' ng-focus='focus = true;' ng-blur='focus = false;' ng-mouseleave='hover = false' ng-mouseenter='hover = true'>")
        context.Response.Write("<md-tooltip md-direction=""top"" ng-if='::tooltips()'>")
        context.Response.Write("{{ day | date:dayTooltipFormat }}")
        context.Response.Write("</md-tooltip>")
        context.Response.Write("<div>")
        context.Response.Write("{{ day | date:dayFormat }}")
        context.Response.Write("</div>")
        'context.Response.Write("<div flex compile='dataService.data[dayKey(day)]' id='{{ day | date:dayIdFormat }}'>")

        context.Response.Write("<table class=""table table-striped table-bordered table-condensed md-default-theme"">")
        context.Response.Write("<thead>")
        context.Response.Write("<tr ng-if=""(records|filter: sameDate(day,'" & _mainScreenItem.masterDateParam & "')).length>0"">")
        'ProcessHeaderRow(context)
        context.Response.Write(headerContent.ToString())
        context.Response.Write("</tr>")
        context.Response.Write("</thead>")
        'context.Response.Write(" < tr dir-paginate=""thisRecord in records | filter: sameDate(day,'" & _mainScreenItem.masterDateParam & "') | orderBy: Data.sortString : Data.sortReverse | itemsPerPage: Data.pageSize "" current-page=""data.currentPage"">")
        context.Response.Write(" <tr ng-repeat=""thisRecord in records | filter: sameDate(day,'" & _mainScreenItem.masterDateParam & "') "" >")
        'ProcessDataRow(context, True, False)
        context.Response.Write(listContent.ToString())
        context.Response.Write("</tr>")

        'context.Response.Write("<div class=""calendarDayContent"" ng-repeat=""thisRecord in records | filter:sameDate(day,'" & _mainScreenItem.masterDateParam & "')"" style=""width:100%;"">")


        'context.Response.Write("</div>")


        context.Response.Write("</table>")

        'context.Response.Write("</div>")
        'end day
        context.Response.Write("</div>")
        'end week
        context.Response.Write("</div>")
        'end calendar
        context.Response.Write("</md-content>")
        context.Response.Write("</md-content>")
    End Sub

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

    Private Function JSON_ParseSimpleToDictionary(sJSON As String) As StringDictionary

        Dim resultSD As StringDictionary = New StringDictionary()
        Dim sEntries As String()
        Dim sEntry As String
        Dim sEntryKeyValue As String()
        If sJSON.Length <= 2 Then
            Return Nothing
        End If

        'remove the []
        sJSON = sJSON.Substring(1, sJSON.Length - 2)
        sEntries = sJSON.Split(New Char() {CChar(",")})
        For Each sEntry In sEntries
            'Response.Write(sEntry)
            sEntryKeyValue = sEntry.Split(New Char() {CChar(":")})
            ''strip "" and {}
            If sEntryKeyValue(0).StartsWith("""") Then
                sEntryKeyValue(0) = sEntryKeyValue(0).Substring(1, sEntryKeyValue(0).Length - 2)
            End If
            If sEntryKeyValue(1).StartsWith("""") Then
                sEntryKeyValue(1) = sEntryKeyValue(1).Substring(1, sEntryKeyValue(1).Length - 2)
            End If
            resultSD.Add(sEntryKeyValue(0), sEntryKeyValue(1))


        Next

        Return resultSD
    End Function
End Class
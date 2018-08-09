<%@ WebHandler Language="VB" Class="csbAngular_GetFormContentForScreen" %>

Imports csi.Framework.ScreenData
Imports csi.Framework.Utility
Imports System.Xml
Imports csi.Framework.InputControls

Public Class csbAngular_GetFormContentForScreen : Implements IHttpHandler, IReadOnlySessionState

    Friend Const AUTO_COMPLETE_FIELD_TYPE_PREFIX As String = "autocomplete"
    Private Const FILE_FIELD_TYPE As String = "upload"
    Private Shared ReadOnly BOOLEAN_DATA_TYPES As String() = {"bit", "system.boolean", "boolean"}
    Public Shared ReadOnly DATE_DATA_TYPES As String() = {"datetime", "date", "system.datetime", "d"}
    Private Shared ReadOnly INTEGER_DATA_TYPES As String() = {"smallint", "int", "tinyint", "system.int32", "system.byte"}
    Private Shared ReadOnly FLOAT_DATA_TYPES As String() = {"currency", "decimal", "float", "numeric", "real", "money", "smallmoney", "system.decimal"}


    Private _xmlGlobalFileName As String = ConfigurationManager.AppSettings("xmlGlobal")
    Private _xmlFormLayoutFileName As String = ""
    Private _xmlGlobal As XmlDocument
    Private _xmlFormLayout As XmlDocument
    Dim thisScreenReader As csi.Framework.ScreenData.ScreenReader = csi.Framework.Utility.Common.ScreenReader

    Private formReadOnly As Boolean = False
    Private sectionReadOnly As Boolean = False
    Private fieldReadOnly As Boolean = False
    'Private iMaxLengthFromData As Integer = 0
    Private bAutoPostBack As Boolean = False

    Private sHrefValue As String = ""
    Private sAltHrefValue As String = ""

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest

        Dim sScreenID As String
        Dim _mainScreenItem As ScreenItem
        Dim sReferenceType As String
        Dim paramArrayValues() As String
        Dim sql As String
        Dim dataStatement As String
        Dim thisFramework As Data
        Dim thisSchema As System.Data.DataTable
        Dim thisSchemaRow As System.Data.DataRow
        Dim thisSchemaRows() As System.Data.DataRow
        'Dim thisDT As System.Data.DataTable
        'Dim thisDataType As String

        Dim thisSchemaRowDataType As String

        Dim isListTemplate As Boolean = False

        Dim sectionNodes As XmlNodeList
        Dim sectionNode As XmlNode
        Dim fieldNode As XmlNode
        Dim thisFP As UIFieldProperty

        Dim alNodes As System.Collections.Generic.IList(Of XmlNode) = New System.Collections.Generic.List(Of XmlNode)
        Dim sFieldName As String
        Dim iColumnSpanFlexBasis As Decimal = 100
        Dim iFieldColumnSpan As Integer = 1
        Dim iFieldFlexValue As Integer = 100
        Dim sSectionFontClass As String = "md-title"

        Dim isCalendarParam As String = context.Request.QueryString("isCalendar")
        Dim isCalendar As Boolean = False
        If Not isCalendarParam Is Nothing AndAlso isCalendarParam.ToLower() = "true" Then
            isCalendar = True
        End If

        sScreenID = context.Request.QueryString("ScreenID")
        sReferenceType = context.Request.QueryString("referenceType")
        context.Response.ContentType = "text/html"

        'for now just quick and dirty
        'TODO: but will want to modify the control factory? and use that?
        'TODO: otherwise deal with all the other properties....

        'get the screen
        Dim _userName As String = Common.UserName(context)
        ' ''debug
        ''context.Response.Write("<div>")
        ''context.Response.Write("UserName=")
        ''context.Response.Write(_userName)
        ''context.Response.Write("</div>")

        '_mainScreenItem = TemplateUtility.CheckAccess(_userName)


        'if referenceType has a value, pull that reference
        'otherwise, pull the main screen
        If sReferenceType > "" Then
            Dim ScreenItemList As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
            ScreenItemList = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, sReferenceType, _userName)
            If Not ScreenItemList Is Nothing AndAlso ScreenItemList.Count > 0 Then
                _mainScreenItem = ScreenItemList.Item(0)
            Else
                Exit Sub
            End If
        Else
            _mainScreenItem = TemplateUtility.CheckAccess(_userName)
        End If

        Dim reportRef As System.Collections.Generic.List(Of csi.Framework.ScreenData.ScreenItem)
        reportRef = csi.Framework.Utility.Common.ScreenReader.References(sScreenID, "report", Common.UserName(context))
        Dim reportScreen As ScreenItem
        If Not reportRef Is Nothing AndAlso reportRef.Count() > 0 Then
            reportScreen = reportRef.Item(0)
        End If

        Dim containsReport As Boolean = False
        Dim sViewer As String = "reportViewerAR.aspx"
        If Not ConfigurationManager.AppSettings.Item("defaultReportViewer") Is Nothing Then
            sViewer = ConfigurationManager.AppSettings.Item("defaultReportViewer")
        End If
        If Not reportScreen Is Nothing Then
            If reportScreen.PageName.LastIndexOf(".") > 0 And reportScreen.PageName.LastIndexOf(".") < reportScreen.PageName.Length Then
                Dim reportExt As String = reportScreen.PageName.Substring(reportScreen.PageName.LastIndexOf(".") + 1, reportScreen.PageName.Length - reportScreen.PageName.LastIndexOf(".") - 1)
                If Not ConfigurationManager.AppSettings.Item(reportExt) Is Nothing Then
                    sViewer = ConfigurationManager.AppSettings.Item(reportExt)
                End If
            End If
            If reportScreen.DisplayStyle > "" And reportScreen.DisplayStyle <> "always visible" And reportScreen.DisplayStyle <> "popup" Then
                sViewer = reportScreen.DisplayStyle
            End If
        End If
        If context.Request.Params("Viewer") > "" Then
            sViewer = context.Request.Params("Viewer")
        End If
        'Default options to all three. If DisplayStyle contains options, use those. If SSRS only use PDF and Excel
        Dim exportOptionsString = "PDF,RTF,Excel"
        If Not reportScreen Is Nothing AndAlso Not reportScreen.DisplayStyle Is Nothing AndAlso reportScreen.DisplayStyle.Replace("popup;", "").Replace("popup", "") > "" Then
            exportOptionsString = reportScreen.DisplayStyle.Replace("popup;", "").Replace("popup", "")
        End If
        If sViewer.Contains("SSRS") Then
            exportOptionsString = "PDF,Excel"
        End If
        If Not reportRef Is Nothing AndAlso reportRef.Count > 0 Then
            containsReport = True
        End If



        formReadOnly = Not _mainScreenItem.AllowUpdate And Not sReferenceType > "" And Not containsReport
        _xmlFormLayoutFileName = _mainScreenItem.FormatXML

        'if the format file extention is html, then simply stream the file
        If System.IO.Path.GetExtension(_xmlFormLayoutFileName) = ".html" Then
            context.Response.TransmitFile(_xmlFormLayoutFileName)
            context.Response.End()
            Exit Sub
        End If
        If System.IO.Path.GetExtension(_mainScreenItem.PageName) = ".ascx" Then
            context.Response.TransmitFile(_mainScreenItem.PageName)
            context.Response.End()
            Exit Sub
        End If

        'TODO: check for default read only based on security
        '_mainScreenItem.AllowUpdate

        'load the format xml        
        'TODO: deal with data driven data reader; uses the schema table...
        'TODO: load data as data reader
        'TODO: a nuance difference, maybe we don't care...but used to not show the field if not in the dataset
        'TODO: deal with 'hideWhenNULL'
        'TODO: sectionGroup...do we ever use? I say depricate!

        'TODO: end

        'DefaultApplicationVariableHashTable(context)

        'load the data in order to select control based on datatype
        dataStatement = _mainScreenItem.DataStatement
        dataStatement = csi.Framework.Utility.Common.ReplaceVariables(dataStatement, CType(context.Session("applicationVariable"), Hashtable))
        If dataStatement > "" Then
            If context.Request.Params("p") IsNot Nothing Then
                Dim currentParameters As Parameters = New Parameters(context.Request)
                paramArrayValues = currentParameters.Array
                'paramArrayValues = CType(context.Request.Params("p"), String).Split(New Char() {CChar(",")})

                'Array.Resize(paramArrayValuesCombined, paramArrayValuesCombined.Length + paramArrayValues.Length)
                'paramArrayValues.CopyTo(paramArrayValuesCombined, JSON_DictionaryLength)
                sql = String.Format(dataStatement, paramArrayValues)
            Else
                sql = dataStatement
            End If

            'thisFramework = New Data
            'thisDT = thisFramework.SQL_to_DataSet(sql).Tables(0)

            thisFramework = New Data
            'always test for thisSchema existing, since  it might not
            Try
                thisSchema = thisFramework.SQL_To_SchemaOnly(sql)
            Catch ex As Exception

            End Try

        End If

        _xmlGlobal = Common.getXMLDoc(context.Server.MapPath(_xmlGlobalFileName), HttpRuntime.Cache)
        _xmlFormLayout = Common.getXMLDoc(context.Server.MapPath(_xmlFormLayoutFileName), HttpRuntime.Cache)

        'loop through sections
        'TODO: determine HTML to layout section headers; for now just throw a div?
        sectionNodes = _xmlFormLayout.SelectNodes("fieldList/section")

        Dim collapsableIndex As Integer = -1
        Dim collapsable As Boolean = False
        For Each sectionNode In sectionNodes
            If Not sectionNode.Attributes("collapsed") Is Nothing Then
                collapsableIndex = collapsableIndex + 1
                collapsable = True
            End If
            'loop through the fields in each section
            'if it is not the first section, make the font slightly smaller and give a little more space before section
            'PRC- I don't like this. Can override with header="true" to keep the header look and feel
            If Not sectionNode.PreviousSibling Is Nothing Then
                If Not sectionNode.Attributes("header") Is Nothing AndAlso CType(sectionNode.Attributes("header").Value.ToString(), Boolean) = True Then
                    sSectionFontClass = "md-title"
                Else
                    sSectionFontClass = "md-subheader"
                End If
                context.Response.Write("<br/>")
            End If

            Dim oneWayBinding As String = ""
            If Not sectionNode.Attributes("readOnlyOneWayBinding") Is Nothing Then
                oneWayBinding = sectionNode.Attributes("readOnlyOneWayBinding").Value.ToString()
            End If


            'write out the section displayName
            If Not sectionNode.Attributes("displayType") Is Nothing AndAlso sectionNode.Attributes("displayType").Value.ToString().ToLower().StartsWith("htmlfile") Then
                context.Response.TransmitFile(sectionNode.Attributes("displayType").Value.ToString().ToLower().Substring(9, sectionNode.Attributes("displayType").Value.ToString().Length() - 9))
            ElseIf Not sectionNode.Attributes("displayName") Is Nothing AndAlso sectionNode.Attributes("displayName").Value.ToString.Trim > "" Then
                context.Response.Write("<h1")

                If Not sectionNode.Attributes("ng-if") Is Nothing AndAlso sectionNode.Attributes("ng-if").Value.ToString.Trim > "" Then
                    context.Response.Write(" ng-if=""" & sectionNode.Attributes("ng-if").Value.ToString.Trim & """")
                ElseIf Not sectionNode.Attributes("ng-show") Is Nothing AndAlso sectionNode.Attributes("ng-show").Value.ToString.Trim > "" Then
                    context.Response.Write(" ng-show=""" & sectionNode.Attributes("ng-show").Value.ToString.Trim & """")
                ElseIf Not sectionNode.Attributes("visibleFieldName") Is Nothing AndAlso sectionNode.Attributes("visibleFieldName").Value.ToString.Trim > "" Then
                    If Not sectionNode.Attributes("visibleFieldValue") Is Nothing AndAlso sectionNode.Attributes("visibleFieldValue").Value.ToString.Trim > "" Then
                        Dim visibleFieldName As String = sectionNode.Attributes("visibleFieldName").Value.ToString.Trim
                        Dim visibleFieldValue As String = sectionNode.Attributes("visibleFieldValue").Value.ToString.Trim
                        context.Response.Write(" ng-show=""thisRecord." & visibleFieldName & "==")
                        If visibleFieldValue.ToLower().StartsWith("fieldname") Then
                            context.Response.Write("thisRecord." & visibleFieldValue.Substring(10))
                        Else
                            context.Response.Write("'" & visibleFieldValue & "'")
                        End If
                        context.Response.Write(""" ")
                    End If
                End If

                context.Response.Write(" class=""")
                If collapsable Then
                    context.Response.Write("headerInline ")
                End If
                context.Response.Write(sSectionFontClass)
                context.Response.Write(""" flex=""95""")
                If Not sectionNode.Attributes("ng-click") Is Nothing AndAlso sectionNode.Attributes("ng-click").Value.ToString.Trim > "" Then
                    context.Response.Write(" ng-click=""" & "parentData.changeFunction('" & sectionNode.Attributes("ng-click").Value() & "','fieldName',true, thisRecord, 'fieldName');" & """")
                End If


                If Not sectionNode.Attributes("displayType") Is Nothing AndAlso sectionNode.Attributes("displayType").Value.ToString.Trim = "html" Then
                    context.Response.Write(" ng-bind-html=""" & sectionNode.Attributes("displayName").Value() & " | unsafe""")
                Else
                    context.Response.Write(">")
                    context.Response.Write(sectionNode.Attributes("displayName").Value())
                End If
                context.Response.Write("</h1>")
                If collapsable Then
                    context.Response.Write("<a href="""" ng-click=""parentData.sectionShowHide(" & collapsableIndex.ToString() & ")"">")

                    context.Response.Write("<i class=""material-icons"" ")
                    context.Response.Write("ng-if=""parentData.screenPropertySet.sectionInfo[" & collapsableIndex.ToString() & "][" & collapsableIndex.ToString() & "] == '0'""")
                    context.Response.Write(" >keyboard_arrow_right</i>")

                    context.Response.Write("<i class=""material-icons"" ")
                    context.Response.Write("ng-if=""parentData.screenPropertySet.sectionInfo[" & collapsableIndex.ToString() & "][" & collapsableIndex.ToString() & "] == '1'""")
                    context.Response.Write(" >keyboard_arrow_down</i>")

                    context.Response.Write("</a>")
                End If

            End If

            Dim sectionMobileLayoutSizing As String = ConfigurationManager.AppSettings("mobileLayoutSize")
            If Not sectionNode.Attributes("mobileLayoutSize") Is Nothing AndAlso sectionNode.Attributes("mobileLayoutSize").Value.ToString.Trim > "" Then
                sectionMobileLayoutSizing = sectionNode.Attributes("mobileLayoutSize").Value.ToString()
            End If

            Dim layout As String = "layout-xs=""column"" layout-sm=""column"""
            If sectionMobileLayoutSizing.ToLower() = "xs" Or sectionMobileLayoutSizing.ToLower() = "extra small" Then
                layout = "layout-xs=""column"""
            ElseIf sectionMobileLayoutSizing.ToLower() = "small" Or sectionMobileLayoutSizing.ToLower() = "sm" Then
                layout = "layout-xs=""column"" layout-sm=""column"""
            ElseIf sectionMobileLayoutSizing.ToLower() = "medium" Or sectionMobileLayoutSizing.ToLower() = "md" Then
                layout = "layout-xs=""column"" layout-sm=""column"" layout-md=""column"""
            ElseIf sectionMobileLayoutSizing.ToLower() = "large" Or sectionMobileLayoutSizing.ToLower() = "lg" Then
                layout = "layout-xs=""column"" layout-sm=""column"" layout-md=""column"" layout-lg=""column"""
            ElseIf sectionMobileLayoutSizing.ToLower() = "none" Or sectionMobileLayoutSizing.ToLower() = "" Then
                layout = ""
            Else 'small
                layout = "layout-xs=""column"" layout-sm=""column"""
            End If

            context.Response.Write("<div layout=""row"" " & layout & " layout-wrap class=""formSection""")
            If isCalendar Then
                context.Response.Write("flex=""100""")
            End If
            If collapsable Then
                context.Response.Write(" ng-show=""parentData.screenPropertySet.sectionInfo[" & collapsableIndex.ToString() & "][" & collapsableIndex.ToString() & "] == '1'""")
            ElseIf Not sectionNode.Attributes("section-ng-if") Is Nothing AndAlso sectionNode.Attributes("section-ng-if").Value.ToString.Trim > "" Then
                context.Response.Write(" ng-if=""" & sectionNode.Attributes("section-ng-if").Value.ToString.Trim & """")
            ElseIf Not sectionNode.Attributes("section-ng-show") Is Nothing AndAlso sectionNode.Attributes("section-ng-show").Value.ToString.Trim > "" Then
                context.Response.Write(" ng-show=""" & sectionNode.Attributes("section-ng-show").Value.ToString.Trim & """")

            End If
            context.Response.Write(">")

            collapsable = False


            'set the readonly flag for the section
            sectionReadOnly = False

            'check for autopostback
            bAutoPostBack = False
            If sReferenceType = "findSQL" AndAlso Not sectionNode.Attributes("autoPostBack") Is Nothing AndAlso CType(sectionNode.Attributes("autoPostBack").Value, Boolean) Then
                bAutoPostBack = True
            End If

            Dim columnSpan As Integer = 1
            'set the column span flex value
            If Not sectionNode.Attributes("columnSpan") Is Nothing Then
                columnSpan = CInt(sectionNode.Attributes("columnSpan").Value())
                iColumnSpanFlexBasis = Math.Round(100 / columnSpan, 5)
            Else
                iColumnSpanFlexBasis = 100
            End If

            Dim fieldContent As StringBuilder = New StringBuilder()


            For Each fieldNode In sectionNode.ChildNodes
                'create uiFP

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
                'Instantiate a new field property for the current field.
                'The constructor of UIFieldProperty gets all the values of the attributes in the Format XML
                thisFP = New UIFieldProperty(alNodes)
                'The constructor of UIFieldProperty gets all the values of the attributes in the Format XML
                'thisDataType = ""
                'iMaxLengthFromData = 0
                'If Not thisDT Is Nothing Then
                '    If thisDT.Columns.Contains(sFieldName) Then
                '        thisDataType = thisDT.Columns(sFieldName).DataType.FullName
                '        'this appears to be bogus
                '        iMaxLengthFromData = thisDT.Columns(sFieldName).MaxLength
                '    Else
                '        'if not in the data set, then do not include in the result
                '        Continue For
                '    End If
                'End If

                thisSchemaRowDataType = ""
                If Not thisSchema Is Nothing Then
                    'thisSchemaRow = thisSchema.Rows.Find(thisFP.FieldName)
                    thisSchemaRows = thisSchema.Select("ColumnName='" & thisFP.FieldName & "'")
                    If thisSchemaRows.Length > 0 Then
                        thisSchemaRow = thisSchema.Select("ColumnName='" & thisFP.FieldName & "'")(0)
                        thisSchemaRowDataType = thisSchemaRow.Item("DataTypeName").ToString()

                    End If

                End If

                'check the read only status
                fieldReadOnly = (thisFP.IsReadOnly Or sectionReadOnly Or formReadOnly Or thisFP.FieldType.StartsWith("command") Or thisFP.FieldType.StartsWith("link"))
                Dim sfieldNameMask As String = "{{thisRecord." & thisFP.FieldName & "}}"

                Dim formatName = thisFP.FormatName

                If formatName = "date" Or formatName = "bit" Or formatName = "boolean" Then
                    thisSchemaRowDataType = thisFP.FormatName
                    formatName = ""
                End If

                If bAutoPostBack Then
                    thisFP.AutoPostBack = True
                End If

                'changed sScreenID to _mainScreenItem.ID in case this is a findSQL format xml
                If thisFP.ReadOnlyOneWayBinding = "" Then
                    If oneWayBinding > "" Then 'section settings override field settings
                        thisFP.ReadOnlyOneWayBinding = oneWayBinding
                    ElseIf Not ConfigurationManager.AppSettings("readOnlyOneWayBinding") Is Nothing Then
                        thisFP.ReadOnlyOneWayBinding = ConfigurationManager.AppSettings("readOnlyOneWayBinding")
                    Else
                        thisFP.ReadOnlyOneWayBinding = "True"
                    End If
                End If

                Dim field As InputControlBase = InputControlFactory.GetInputControl(thisFP, fieldReadOnly, thisSchemaRowDataType, 100, False, False, _mainScreenItem.ID, Common.UserName(context), isListTemplate, columnSpan, sectionMobileLayoutSizing, formatName)
                fieldContent.Append(field.RenderString)





                If thisFP.Padding > 0 Then
                    iFieldFlexValue = CInt(Math.Round(iColumnSpanFlexBasis * thisFP.Padding))
                    If iFieldFlexValue > 100 Or iFieldFlexValue = 0 Then
                        iFieldFlexValue = 100
                    End If

                    fieldContent.Append("<div flex=""")
                    fieldContent.Append(iFieldFlexValue.ToString())
                    fieldContent.Append(""" flex-sm=""100""></div>")

                End If


            Next 'End Field Loop


            If isCalendar Then

                context.Response.Write("<md-content layout='column' layout-fill md-swipe-left='next()' md-swipe-right='prev()'><md-toolbar><div class='md-toolbar-tools' layout='row'><md-button class='md-icon-button' ng-click='prev()' aria-label='Previous month'><md-tooltip ng-if='::tooltips()'>Previous month</md-tooltip><md-icon md-svg-icon='md-tabs-arrow'></md-icon></md-button><div flex></div><h2 class='calendar-md-title'><span>{{ calendar.start | date:titleFormat:timezone }}</span></h2><div flex></div><md-button class='md-icon-button' ng-click='next()' aria-label='Next month'><md-tooltip ng-if='::tooltips()'>Next month</md-tooltip><md-icon md-svg-icon='md-tabs-arrow' class='moveNext'></md-icon></md-button></div></md-toolbar><!-- agenda view --><md-content ng-if='weekLayout === columnWeekLayout' class='agenda'><div  ng-repeat='week in calendar.weeks track by $index'>")
                'beginning of agenda week aka sunday
                context.Response.Write("<div ng-if='sameMonth(day)' ng-class='{&quot;disabled&quot; : isDisabled(day), active: active === day }' ng-click='handleDayClick(day)' ng-repeat='day in week' layout='column'>")
                context.Response.Write("<md-tooltip ng-if='::tooltips()'>")
                context.Response.Write("{{ day | date:dayTooltipFormat:timezone }}")
                context.Response.Write("</md-tooltip>")
                context.Response.Write("<div>")
                context.Response.Write("{{ day | date:dayFormat:timezone }}")
                context.Response.Write("</div>")
                'context.Response.Write("<div flex compile='dataService.data[dayKey(day)]'>")

                context.Response.Write("<div ng-repeat=""thisRecord in records | filter:sameDate(day,'" & _mainScreenItem.masterDateParam & "')"" style=""width:100%;"">")
                context.Response.Write(fieldContent.ToString())
                context.Response.Write("</div>")

                'context.Response.Write("</div>")
                context.Response.Write("</div>")
                context.Response.Write("</div>")
                context.Response.Write("</md-content>")
                context.Response.Write("<!-- calendar view -->")
                context.Response.Write("<md-content ng-if='weekLayout !== columnWeekLayout' flex layout='column' class='calendar'><div layout='row' class='subheader'>")
                context.Response.Write("<div layout-padding class='subheader-day' flex ng-repeat='day in calendar.weeks[0]'>")
                context.Response.Write("<md-tooltip ng-if='::tooltips()'>")
                context.Response.Write("{{ day | date:dayLabelTooltipFormat }}")
                context.Response.Write("</md-tooltip>")
                context.Response.Write("{{ day | date:dayLabelFormat }}")
                context.Response.Write("</div>")
                context.Response.Write("</div>")
                context.Response.Write("<div ng-if='week.length' class=""week"" ng-repeat='week in calendar.weeks track by $index' flex layout='row'>")
                'for each day in week
                context.Response.Write("<div class=""calendarDay"" tabindex='{{ sameMonth(day) ? (day | date:dayFormat:timezone) : 0 }}' ng-repeat='day in week track by $index' ng-click='handleDayClick(day)' flex layout=""column"" layout-padding ng-class='{&quot;disabled&quot; : isDisabled(day), &quot;active&quot;: isActive(day), &quot;md-whiteframe-12dp&quot;: hover || focus }' ng-focus='focus = true;' ng-blur='focus = false;' ng-mouseleave='hover = false' ng-mouseenter='hover = true'>")
                context.Response.Write("<md-tooltip ng-if='::tooltips()'>")
                context.Response.Write("{{ day | date:dayTooltipFormat }}")
                context.Response.Write("</md-tooltip>")
                context.Response.Write("<div>")
                context.Response.Write("{{ day | date:dayFormat }}")
                context.Response.Write("</div>")
                'context.Response.Write("<div flex compile='dataService.data[dayKey(day)]' id='{{ day | date:dayIdFormat }}'>")

                context.Response.Write("<div class=""calendarDayContent"" ng-repeat=""thisRecord in records | filter:sameDate(day,'" & _mainScreenItem.masterDateParam & "')"" style=""width:100%;"">")
                context.Response.Write(fieldContent.ToString())
                context.Response.Write("</div>")

                'context.Response.Write("</div>")
                'end day
                context.Response.Write("</div>")
                'end week
                context.Response.Write("</div>")
                'end calendar
                context.Response.Write("</md-content>")
                context.Response.Write("</md-content>")
            Else
                context.Response.Write(fieldContent.ToString())
            End If



            context.Response.Write("</div>")
        Next 'End Section Loop



        If containsReport And exportOptionsString.ToLower() <> "none" Then
            context.Response.Write("<div layout=""row"" layout-sm=""column"" layout-wrap>")
            context.Response.Write("<md-input-container flex-gt-sm=""100"" class="""">")
            context.Response.Write("<label for=""reportFormat"" Class="" md-no-float csb-md-simulate-has-value"">")
            context.Response.Write("Report Format")
            context.Response.Write("</label>")
            context.Response.Write("<md-Select ")
            'context.Response.Write("ng-change= ""parentData.changeFunction('updateReportType({screenPropertySet},{listItem})','reportFormat{{$index}}',true, thisRecord, 'reportFormat');"" ")
            context.Response.Write("ng-model=""parentData.screenPropertySet.reportFormat"" ")
            context.Response.Write("name=""reportFormat"" ")
            context.Response.Write("id=""reportFormat"" ")
            context.Response.Write("Class="" md-input "">")
            Dim options As String() = Split(exportOptionsString, ",")
            For Each exportOption As String In options
                context.Response.Write("<md-Option value=""" & exportOption & """ >" & exportOption & "</md-Option>")
            Next
            context.Response.Write("</md-Select>")
            context.Response.Write("</md-input-container>")
            context.Response.Write("</div>")
        End If


    End Sub

    Private Shared Function isType(dataType As String, dataTypes As System.Collections.Generic.IEnumerable(Of String)) As Boolean
        Return dataTypes.Contains(dataType.ToLower())

    End Function

    'Private Sub DefaultApplicationVariableHashTable(ByVal thisContext As HttpContext)
    '    Dim thisHashTable As Hashtable

    '    If thisContext.Session("applicationVariable") Is Nothing Then
    '        thisHashTable = New Hashtable

    '    Else

    '        thisHashTable = CType(thisContext.Session("applicationVariable"), Hashtable)

    '    End If

    '    If Not thisHashTable.ContainsKey("UserName") Then
    '        thisHashTable.Add("UserName", thisContext.User.Identity.Name)
    '    ElseIf thisHashTable.Item("UserName").ToString = "" Then
    '        thisHashTable.Item("UserName") = thisContext.User.Identity.Name
    '    End If

    '    'For now, slam in a UserDate for testing againsts Creamery
    '    If Not thisHashTable.ContainsKey("UserDate") Then
    '        thisHashTable.Add("UserDate", New Date().ToString("MM/dd/yyyy"))
    '    ElseIf thisHashTable.Item("UserDate").ToString = "" Then
    '        thisHashTable.Item("UserDate") = New Date().ToString("MM/dd/yyyy")
    '    End If


    '    thisContext.Session("applicationVariable") = thisHashTable
    'End Sub



    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class
<%@ WebHandler Language="VB" Class="AsyncFileUploadHandler" %>

Imports System.IO
Imports System.Xml
Imports System.Data



'JDC TODO:
'much of this should probably be refactored for the new screen and screen factory stuff...

Public Class AsyncFileUploadHandler
    Implements System.Web.IHttpHandler

    Private _ScreenItem As csi.Framework.ScreenData.ScreenItem
    Private _thisDS As DataSet


    Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        ' Write your handler implementation here.

        Dim sScreenID As String = context.Request.QueryString("ScreenID")

        If sScreenID Is Nothing OrElse sScreenID = "" Then
            Throw New System.Exception("A screen ID was not provided in the format xml.")
            Return
        End If
        _ScreenItem = csi.Framework.Utility.Common.ScreenReader.Item(sScreenID, "")
        'get the data if there is data to get
        If _ScreenItem.DataStatement > "" Then
            Dim currentParameters As csi.Framework.Utility.Parameters = New csi.Framework.Utility.Parameters(context.Request)
            Dim paramArrayValues = currentParameters.Array
            'Dim paramArrayValues As String() = sParameter.Split(New Char() {CType(",", Char)})
            _thisDS = csi.Framework.Utility.Data.GetDataSet(_ScreenItem.DataStatement, paramArrayValues)

        End If

        'Check if overwrite is a field in the form. If it is, use it to overwrite.
        'If it's not, check displayStyle for "overwrite:"
        Dim overwrite As String = "false"
        Dim overridePath As String = ""
        Dim overrideFileName As String = ""

        For Each sFormElement As String In context.Request.Form.Keys
            If sFormElement = "overwrite" Then
                overwrite = context.Request.Form("overwrite")
            End If
            If sFormElement = "Path" Then
                overridePath = context.Request.Form("Path")
                If overridePath.StartsWith("\") Then
                    overridePath = overridePath.Substring(1)
                End If
                overridePath = Path.GetDirectoryName(overridePath)
            End If
            If sFormElement = "FileName" Then
                overrideFileName = context.Request.Form("FileName")
            End If
        Next


        Dim thisPathName As String = GetPathName(context, overridePath)


        For Each thisFilePointer As String In context.Request.Files
            Dim f As HttpPostedFile = context.Request.Files(thisFilePointer)
            Dim fileSize As Integer = f.ContentLength
            Dim thisFileName As String = overrideFileName
            If overrideFileName = "" Then
                thisFileName = System.IO.Path.GetFileName(f.FileName)
            End If


            'uniquify filename
            Dim overwriteAll As String = UCase(Left(_ScreenItem.DisplayStyle, 10))
            If overwriteAll <> "OVERWRITE:" And overwrite.ToLower() = "false" Then
                thisFileName = GetUniqueFileName(thisFileName, thisPathName)
            Else
                '    If (File.Exists(thisPathName & "\" & thisFileName)) Then
                '        File.Delete(thisPathName & "\" & thisFileName)
                '    End If
            End If


            'Dim SaveLocation1 As String = thisPathName & "\" & context.Request.Form("AttachmentType") & thisFileName
            Dim SaveLocation1 As String = thisPathName & "\" & thisFileName
            context.Response.Write(SaveLocation1)
            f.SaveAs(SaveLocation1)

            SaveChanges(context, SaveLocation1, f, thisFileName)


        Next

    End Sub

    ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

    Private Function GetPathName(ByVal context As HttpContext, overridePath As String) As String

        Dim pathName As String = overridePath

        Dim userName As String = context.User.Identity.Name
        Dim pathCheck As String = UCase(Right(_ScreenItem.DisplayStyle, 9))
        Dim overwrite As String = UCase(Left(_ScreenItem.DisplayStyle, 10))
        Dim displayStyle As String = _ScreenItem.DisplayStyle
        If overwrite = "OVERWRITE:" Then
            displayStyle = displayStyle.Substring(10, displayStyle.Length - 10)
        End If

        If pathName = "" Then
            Select Case pathCheck
                Case "USERNAME_"
                    pathName = Path.GetDirectoryName(displayStyle) & "\" & Replace(userName, "\", "_")
                Case "USERNAME\"
                    pathName = Left(displayStyle, (Len(displayStyle) - 10)) & "\" & userName
                Case Else
                    pathName = displayStyle
            End Select
        End If


        If Not pathName.StartsWith("\\") And pathName.Substring(1, 2) <> ":\" Then
            pathName = context.Server.MapPath(pathName)
            'pathName = System.Web.HttpContext.Current.Server.MapPath(pathName)
        End If


        If Not Directory.Exists(pathName) Then
            Directory.CreateDirectory(pathName)
        End If


        Return pathName

    End Function

    Private Function GetUniqueFileName(thisFileName As String, thisFilePath As String) As String

        Dim n = 0
        Dim UnderScore As Integer = 1
        Dim tempFN As String = Path.GetFileNameWithoutExtension(thisFileName)
        Do While File.Exists(thisFilePath & "\" & thisFileName)
            n = n + 1
            If n > 1 Then
                Do While (UnderScore) > 0
                    UnderScore = InStr(tempFN, "_")
                    tempFN = Right(tempFN, (Len(tempFN) - UnderScore) - 1)
                Loop
                thisFileName = Left(thisFileName, Len(tempFN) + 1) & Path.GetExtension(thisFileName)
            End If
            thisFileName = Path.GetFileNameWithoutExtension(thisFileName) & "_" & n & Path.GetExtension(thisFileName)
        Loop

        Return thisFileName

    End Function

    Private Sub SaveChanges(ByVal context As HttpContext, SaveLocation As String, f As HttpPostedFile, savedFileName As String)

        Dim thisFormToXML As csi.Framework.ScreenData.FormToXML = New csi.Framework.ScreenData.FormToXML()
        'Dim sXML As String
        Dim doc As XmlDocument


        thisFormToXML.XMLTemplateFileName = context.Server.MapPath(_ScreenItem.UpdateXML)

        'map detail screen to XML
        Dim thisHT As Hashtable = New Hashtable()
        'why not use full path name
        Dim pathName As String = SaveLocation.Replace(context.Server.MapPath(""), "")
        Dim driveName As String = context.Server.MapPath("")

        'hard coded now for Interface...4/8/13 11:18 PM
        pathName = Right(pathName, Len(pathName) - InStr(pathName, "\Documents"))
        driveName = Left(driveName, InStr(driveName, "\Documents"))

        'Dim displayName As String = f.FileName
        'Dim Attdescription As String = fileDescription.Value
        'Dim sAttachmentType As String = AttachmentType.Value.ToString()

        'add hard-coded values
        'thisHT.Add("Path", pathName)
        thisHT.Add("Path", pathName)
        thisHT.Add("DisplayName", savedFileName)
        thisHT.Add("DriveName", driveName)
        thisHT.Add("FileSize", f.ContentLength)

        'add all the file attributes
        thisHT.Add("FileName", savedFileName)
        thisHT.Add("ContentLength", f.ContentLength)
        thisHT.Add("ContentType", f.ContentType)
        'add all the data row values
        If _thisDS IsNot Nothing Then
            For Each _dataRow As DataRow In _thisDS.Tables(0).Rows
                For Each _field As DataColumn In _thisDS.Tables(0).Columns
                    If thisHT.ContainsKey(_field.ColumnName) Then
                        If _field.ColumnName <> "Path" And _field.ColumnName <> "FileName" Then
                            thisHT(_field.ColumnName) = _dataRow.Item(_field.ColumnName).ToString()
                        End If
                    Else
                        thisHT.Add(_field.ColumnName, _dataRow.Item(_field.ColumnName).ToString())
                    End If
                Next
            Next
        End If

        'add the form values

        For Each sFormElement As String In context.Request.Form.Keys
            If thisHT.ContainsKey(sFormElement) Then
                thisHT(sFormElement) = context.Request.Form(sFormElement)
            Else
                thisHT.Add(sFormElement, context.Request.Form(sFormElement))
            End If
        Next
        'thisHT.Add("AttachmentType", sAttachmentType)
        'thisHT.Add("FileDescription", Attdescription)


        doc = thisFormToXML.MapToXML(thisHT)

        thisHT = Nothing

        Dim cConnect As csi.Framework.ScreenData.cConnect = New csi.Framework.ScreenData.cConnect()
        Dim bStatus As Boolean = cConnect.Execute(doc)

        If Not bStatus Then
            'write out error...
            'needs testing

        End If


    End Sub



End Class
<%@ WebHandler Language="VB" Class="csbAngular_GetMenu" %>

Imports System
Imports System.Web
Imports csi.Framework.ScreenData
Imports csi.Framework.Web
Imports csi.Framework.Security
Imports csi.Framework.ScreenDefinition
Imports csi.Framework.Utility
Imports System.Xml
Imports System.Collections
Imports System.IO
Imports System.Data

Public Class csbAngular_GetMenu : Implements IHttpHandler, IReadOnlySessionState

    Private _menuID As String = "mainMenu"
    Private _isLeftMenu As Boolean = False
    '-------------------I can see these being configurable in URL-----------------------
    'This is only used for if left menu is included in main menu. If this is the leftMenu call, it will be passed in menuID
    Private _leftMenuID As String = "leftMenu"
    Private _includeLeftMenuInMainMenu As Boolean = True
    Private _xmlLeftMenu As XmlDocument
    Private _xmlLeftMenuFileName As String = ConfigurationManager.AppSettings("xmlLeftMenu")
    '---------------------------------------------------------------------

    Private _MenuScreenID As String = ConfigurationManager.AppSettings("defaultMenuID")
    Private thisContext As HttpContext
    Private _userName As String = ""
    Private _xmlMenu As XmlDocument
    Private _xmlMenuFileName As String = "~\" & ConfigurationManager.AppSettings("xmlMenu")
    Private _securityMenuScreenID As String = "SecurityScreenForScreenIDPreProcess"


    Private _includeUserMenu As Boolean = True

    'don't think I actually need these
    Private _bIncludeMouseMenuEvent As Boolean = False
    Private _bUseLinkByPost As Boolean = False
    Private _defaultParameter As String = ""


    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        thisContext = context
        Dim overrideMenuAppSettingKey As String = context.Request.QueryString("menuAppSettingKey")
        Dim includeUserMenuSetting As String = context.Request.QueryString("IncludeUserNameInMenu")
        If includeUserMenuSetting Is Nothing Then
            includeUserMenuSetting = ConfigurationManager.AppSettings("IncludeUserNameInMenu")
        End If
        Dim isLeftMenuParam As String = context.Request.QueryString("isLeftMenu")
        If Not isLeftMenuParam Is Nothing Then
            _isLeftMenu = CType(isLeftMenuParam, Boolean)
        End If

        If Not overrideMenuAppSettingKey Is Nothing Then
            _xmlMenuFileName = ConfigurationManager.AppSettings(overrideMenuAppSettingKey)
            _includeUserMenu = False
            _menuID = overrideMenuAppSettingKey

        End If
        If Not includeUserMenuSetting Is Nothing Then
            _includeUserMenu = CBool(includeUserMenuSetting)
        End If


        _userName = thisContext.User.Identity.Name


        'add back logic to dynamically add menu based on screen ID?
        If _xmlMenu Is Nothing AndAlso Not _isLeftMenu Then
            _xmlMenu = Common.getXMLDoc(context.Server.MapPath(_xmlMenuFileName), HttpRuntime.Cache)
        End If
        If _xmlLeftMenu Is Nothing AndAlso Not _xmlLeftMenuFileName Is Nothing Then
            _xmlLeftMenu = Common.getXMLDoc(context.Server.MapPath(_xmlLeftMenuFileName), HttpRuntime.Cache)
        End If

        'do we want to/need to implement the refresh flag process
        'caching on the server for change of the menu folder
        'or does angular handle client caching better

        'for now, just write it out

        Dim thisStringWriter As New StringWriter()

        Dim output As New HtmlTextWriter(thisStringWriter)

        If Not _xmlLeftMenu Is Nothing AndAlso Not _xmlMenu Is Nothing Then
            RenderNodesToList(_xmlMenu.SelectNodes("menuList/*"), output, True, _xmlLeftMenu.SelectNodes("menuList/*"), "")
        ElseIf Not _xmlLeftMenu Is Nothing Then
            RenderNodesToList(_xmlLeftMenu.SelectNodes("menuList/*"), output, True, _xmlLeftMenu.SelectNodes("menuList/*"), "")
        ElseIf Not _isLeftMenu Then
            RenderNodesToList(_xmlMenu.SelectNodes("menuList/*"), output, True, Nothing, "")
        End If

        If Not thisStringWriter Is Nothing Then
            context.Response.Write(thisStringWriter.ToString())
        End If


    End Sub


    Private Sub RenderNodesToList(theseNodes As XmlNodeList, output As HtmlTextWriter, isFirstNode As Boolean, secondList As XmlNodeList, className As String)
        Dim securityMethod As String = ConfigurationManager.AppSettings("SecurityMethod")
        If securityMethod Is Nothing Then
            securityMethod = ""
        End If
        Dim bDebug As Boolean = False
        If ConfigurationManager.AppSettings("debugMenu") = "true" Then
            bDebug = True
        End If

        ''Add logged in user to the top level menu if the web.config contains the IncludeUserNameInMenu key and the value is set to true
        'If ConfigurationManager.AppSettings("IncludeUserNameInMenu") = "true" And Not _usernameNodeAdded Then
        '    Dim usernameDisplay As String = "<span id='userNameContainer' class='userNameContainer'>Logged in as " & _userName.Substring(_userName.IndexOf("\") + 1) & "</span>"
        '    output.Write(usernameDisplay)
        '    _usernameNodeAdded = True
        'End If



        ' Create the opening unordered list tag
        ' JDC - Edit:  could make a bit more general by using the control ID as the id...
        output.WriteBeginTag("ul ")


        'If isFirstNode Then
        output.WriteAttribute("id", _menuID)
        output.WriteAttribute("class", className)
        '    'this was for simple menu/bootstrap
        '    'Dim barClass As String = If(_isLeftMenu, "nav-sidebar sm sm-vertical sm-simple-vertical", "navbar-nav sm sm-simple")
        '    'output.WriteAttribute("class", "nav " + barClass)
        '    'output.WriteAttribute("class", "nav navbar-nav")
        'End If
        output.Write(HtmlTextWriter.TagRightChar)

        If Not secondList Is Nothing And Not _isLeftMenu Then
            RenderNodesToList(secondList, output, False, Nothing, "showMobile")
        End If


        'For i As Integer = 0 To theseNodes.Count - 1
        For Each thisNode As XmlNode In theseNodes

            Dim bProcessNode As Boolean = True
            'Dim thisNode As XmlNode = theseNodes.Item(i)

            Dim menuId As String = ""
            Dim sClassName As String = ""

            If thisNode.NodeType = XmlNodeType.Comment Then
                bProcessNode = False
            Else
                'sNodeLevel = getNodeLevel(thisNode)
                'Dim sPopupName As String = getPopupName(thisNode)
                menuId = Common.ResolveNodeValue(thisNode, "menuID", "")
                ' Get the class, if no class exists set it to the node name
                sClassName = ""

                If Not thisNode.Attributes.GetNamedItem("className") Is Nothing Then
                    sClassName = thisNode.Attributes.GetNamedItem("className").Value
                End If

                If Not thisNode.Attributes.GetNamedItem("defaultParameter") Is Nothing Then
                    _defaultParameter = thisNode.Attributes.GetNamedItem("defaultParameter").Value
                End If

                'if the class is menudivider, bounce out.
                'this was a pre-kendu menu aspect to give the appearance of a menu divider
                If sClassName = "menudivider" Then
                    bProcessNode = False
                End If
            End If

            If bProcessNode Then

                ' Get the screen id
                Dim sScreenID As String
                If thisNode.Attributes.GetNamedItem("ScreenID") Is Nothing Then
                    sScreenID = ""
                Else
                    sScreenID = thisNode.Attributes.GetNamedItem("ScreenID").Value
                End If
                If bDebug Then
                    Common.WriteEntryToLogFile(thisContext.Server.MapPath("menuLog.txt"), Now.ToString("MM/dd/yyyy hh:mm:ss.fff") & " " & "Got ScreenID: " & sScreenID)
                End If

                Dim bHasAccess As Boolean = True
                If securityMethod = "SecurityProvider" Then
                    If bDebug Then
                        Common.WriteEntryToLogFile(thisContext.Server.MapPath("menuLog.txt"), Now.ToString("MM/dd/yyyy hh:mm:ss.fff") & " Using new security - User Name: " & _userName)
                        Common.WriteEntryToLogFile(thisContext.Server.MapPath("menuLog.txt"), Now.ToString("MM/dd/yyyy hh:mm:ss.fff") & " Using new security - menuID: " & menuID)
                    End If
                    Dim eff As csi.Framework.Security.EffectivePermission = Common.SecurityProvider.GetEffectivePermission(menuID, "menu", _userName)
                    If eff.ReadPermission = csi.Framework.Security.Permission.Deny Then
                        bHasAccess = False
                    End If
                    If bDebug Then
                        Common.WriteEntryToLogFile(thisContext.Server.MapPath("menuLog.txt"), Now.ToString("MM/dd/yyyy hh:mm:ss.fff") & " Using new security - menu item security" & "Has Access: " & bHasAccess.ToString)
                    End If
                ElseIf securityMethod = "DatabaseSecurityProvider" Then
                    Dim isViewable As Boolean = True
                    Dim allowUpdate As Boolean = True
                    DatabaseSecurityProvider.CheckAccessForMenuID(menuID, isViewable, allowUpdate)
                    If Not isViewable Then
                        bHasAccess = False
                    End If
                End If
                If sScreenID > "" And bHasAccess Then
                    ' This check the security to see if the user should have access or not

                    _bIncludeMouseMenuEvent = False
                    Dim csiSI As ScreenItem
                    csiSI = Common.ScreenReader.Item(sScreenID, Common.UserName(thisContext))
                    If csiSI Is Nothing Then
                        bHasAccess = False
                    Else
                        csiSI.CheckAccess(thisContext.Server.MapPath(""))
                        If bDebug Then
                            Common.WriteEntryToLogFile(thisContext.Server.MapPath("menuLog.txt"), Now.ToString("MM/dd/yyyy hh:mm:ss.fff") & " screen security" & "Has Access: " & csiSI.AllowAccess.ToString)
                        End If
                        bHasAccess = bHasAccess And csiSI.AllowAccess
                    End If
                End If
                If bDebug Then
                    Common.WriteEntryToLogFile(thisContext.Server.MapPath("menuLog.txt"), Now.ToString("MM/dd/yyyy hh:mm:ss.fff") & " " & "Has Access: " & bHasAccess.ToString)
                End If

                If bHasAccess Then
                    If bDebug Then
                        Common.WriteEntryToLogFile(thisContext.Server.MapPath("menuLog.txt"), Now.ToString("MM/dd/yyyy hh:mm:ss.fff") & " " & "Writing node.  Node level: ")
                    End If


                    output.WriteBeginTag("li")
                    output.WriteAttribute("class", If(sClassName > "", sClassName + " ", "") + If(thisNode.HasChildNodes, If(isFirstNode, "has-sub", "has-sub"), ""))
                    output.Write(HtmlTextWriter.TagRightChar)

                    Dim sTarget As String
                    If thisNode.Attributes("target") Is Nothing Then
                        sTarget = ""
                    Else
                        sTarget = thisNode.Attributes("target").Value
                    End If
                    Dim sAccessKey As String = ""
                    If Not thisNode.Attributes("accessKey") Is Nothing Then
                        sAccessKey = thisNode.Attributes("accessKey").Value
                    End If

                    If sScreenID > "" AndAlso Not thisNode.HasChildNodes Then
                        output.Write(Common.ScreenReader.RenderLink(sScreenID, _
                            thisNode.Attributes.GetNamedItem("displayName").Value, _
                            _bIncludeMouseMenuEvent, _bUseLinkByPost, _defaultParameter, sTarget, Common.UserName(thisContext)) _
                            , sAccessKey, True)
                    Else
                        output.WriteBeginTag("a")
                        'output.WriteAttribute("class", "menu-nolink")
                        output.Write(HtmlTextWriter.TagRightChar)
                        output.Write(thisNode.Attributes.GetNamedItem("displayName").Value)
                        'If isFirstNode And thisNode.HasChildNodes Then
                        '    output.WriteBeginTag("span")
                        '    output.WriteAttribute("class", "caret")
                        '    output.Write(HtmlTextWriter.TagRightChar)
                        '    output.WriteEndTag("span")
                        'End If
                        output.WriteEndTag("a")
                    End If

                    If bDebug Then
                        Common.WriteEntryToLogFile(thisContext.Server.MapPath("menuLog.txt"), Now.ToString("MM/dd/yyyy hh:mm:ss.fff") & " " & "Done with this node")
                    End If

                    If Not thisNode.HasChildNodes Then
                        output.WriteEndTag("li")
                    Else
                        If bDebug Then
                            Common.WriteEntryToLogFile(thisContext.Server.MapPath("menuLog.txt"), Now.ToString("MM/dd/yyyy hh:mm:ss.fff") & " " & "Calling renderNodesToList for children")
                        End If
                        RenderNodesToList(thisNode.ChildNodes, output, False, Nothing, "")
                        output.WriteEndTag("li")

                        ' ''If sNodeLevel = "0" Then
                        ' ''    ' handle first level
                        ' ''    output.Write("<div class='menuPopup'")
                        ' ''    output.Write(" id='")
                        ' ''    output.Write(thisNode.Attributes.GetNamedItem("displayName").Value)
                        ' ''    output.Write("' menuType='popup'>")
                        ' ''    RenderNodesToList(thisNode.ChildNodes, output, False)
                        ' ''    output.Write("</div></div>")
                        ' ''Else
                        ' ''    ' handle all other
                        ' ''    output.Write("<div class='hvrzone'></div>")
                        ' ''    output.Write("<div class='")
                        ' ''    output.Write(thisNode.ChildNodes(0).LocalName)
                        ' ''    output.Write("' id='")
                        ' ''    output.Write(sPopupName)
                        ' '' ''    output.Write("' menuType='popup'>")
                        ''RenderNodesToList(thisNode.ChildNodes, output, False)
                        ' ''    output.Write("</div>")
                        ' ''End If
                        ''output.Write("</li>")
                    End If
                End If
            End If
        Next

        If _includeUserMenu And isFirstNode Then
            WriteUserMenu(output)
        ElseIf isFirstNode And Not _isLeftMenu Then
            writeSecurityLink(output)
        End If

        output.WriteEndTag("ul")


    End Sub

    Private Sub WriteUserMenu(output As HtmlTextWriter)

        '<li><span id="AuthUser">{{data.screenPropertySet.UserName}}</span><span class="caret"></span></li>
        output.WriteBeginTag("li")
        output.WriteAttribute("class", "has-sub")
        output.Write(HtmlTextWriter.TagRightChar)
        output.WriteBeginTag("a")
        output.WriteAttribute("id", "AuthUser")
        output.Write(HtmlTextWriter.TagRightChar)
        output.Write(_userName)
        output.WriteEndTag("a")
        output.WriteBeginTag("ul")
        output.Write(HtmlTextWriter.TagRightChar)

        '<li><a href="javascript:showInDialog('csbAngularFormTemplate.aspx?screenID=UserTable_Form&p=-1&p={{data.screenPropertySet.UserName}}', 'User Form', 600,500)">User Profile</a></li>
        output.WriteBeginTag("li")
        output.Write(HtmlTextWriter.TagRightChar)
        output.WriteBeginTag("a")
        Dim userFormPopupSize = ConfigurationManager.AppSettings("UserFormPopupSize")
        If userFormPopupSize Is Nothing OrElse userFormPopupSize = "" Then
            userFormPopupSize = "600,500"
        End If
        output.WriteAttribute("href", "javascript:showInDialog('Form.html?screenID=UserTable_Form&p=-1&p=" & _userName & "', 'User Form'," & userFormPopupSize & ")")
        output.Write(HtmlTextWriter.TagRightChar)
        output.Write("User Profile")
        output.WriteEndTag("a")
        output.WriteEndTag("li")

        '<li><a href="Login.aspx?action=logout">Logout...</a></li>
        output.WriteBeginTag("li")
        output.Write(HtmlTextWriter.TagRightChar)
        output.WriteBeginTag("a")
        output.WriteAttribute("href", "Login.aspx?action=logout")
        output.Write(HtmlTextWriter.TagRightChar)
        output.Write("Logout...")
        output.WriteEndTag("a")
        output.WriteEndTag("li")

        '<li class="divider"></li>
        output.WriteBeginTag("li")
        output.WriteAttribute("class", "divider")
        output.Write(HtmlTextWriter.TagRightChar)
        output.WriteEndTag("li")

        '<li id="editLink" class="currentVersionLink"></li>

        writeSecurityLink(output)

        '<li id="helpLink" class="currentVersionLink"></li>
        '<li class="divider"></li>
        '<li class="disabled"><a class="menu-nolink">Version: 2015.03.23</a></li>
        output.WriteEndTag("ul")
        output.WriteEndTag("li")
    End Sub

    Private Sub writeSecurityLink(output As HtmlTextWriter)
        Dim securityMethod As String = ConfigurationManager.AppSettings("SecurityMethod")
        If securityMethod Is Nothing Then
            securityMethod = ""
        End If
        Dim hasSecurityAccess As Boolean = True
        If securityMethod = "SecurityProvider" Then
            Dim eff As csi.Framework.Security.EffectivePermission = Common.SecurityProvider.GetEffectivePermission(_securityMenuScreenID, "menu", _userName)
            If eff.ReadPermission = csi.Framework.Security.Permission.Deny Then
                hasSecurityAccess = False
            End If
        End If
        If hasSecurityAccess Then
            ' This check the security to see if the user should have access or not
            Dim csiSI As ScreenItem
            csiSI = Common.ScreenReader.Item(_securityMenuScreenID, Common.UserName(thisContext))
            If csiSI Is Nothing Then
                hasSecurityAccess = False
            Else
                csiSI.CheckAccess(thisContext.Server.MapPath(""))
                hasSecurityAccess = hasSecurityAccess And csiSI.AllowAccess
            End If
        End If
        If hasSecurityAccess Then
            output.Write("<li id=""securityLink"" class=""currentVersionLink""><a href=""runProcess.aspx?screenID=" & _securityMenuScreenID & "&p={{screenID}}&p=0"" target='editWindow' title='Secure Current Screen'><img src=""images/lock.png"" /></a></li>")
        End If
    End Sub



    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class
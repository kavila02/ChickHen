<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="CSB2018.Login" %>
<!DOCTYPE html>
<meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width">
<html xmlns="http://www.w3.org/1999/xhtml" ng-app="csbLoginAngular">
    <head>
    <title>Login</title>
    <link rel="icon" href="solution/images/favicon.ico">

    <!--script files to include-->
    <script type="text/javascript" src="js/jquery/jquery-1.11.2.min.js"></script>
    <script type="text/javascript" src="js/jquery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="js/jquery/jquery.validate.js"></script>

    <script type="text/javascript" src='js/solution-builder.js'></script>
    <script type="text/javascript" src='solution/custom.js'></script>
    <script src="js/quartzMenu.js"></script>


    <!--Angular Stuff-->
    <script src="js/angularjs/angular.min.js"></script>
    <script src="js/dirPagination.js"></script>

    <script src="js/angularjs/angular-animate.min.js"></script>
    <script src="js/angularjs/angular-aria.min.js"></script>
    <script src="js/angularjs/angular-messages.min.js"></script>
    <script src="js/angularjs/angular-material.min.js"></script>

    <script src="js/angularjs/ngStorage.js"></script>
        
    <link rel="stylesheet" href="css/jquery-ui.min.css" />


    <link href="css/bootstrap.min.css" rel="stylesheet" />

    <link rel="stylesheet" href="css/angular-material.min.css">
    <link rel="stylesheet" href="css/angular-material.font.css">

    <link rel="stylesheet" href="css/solutionBuilder.css">
    <link rel="stylesheet" href="solution/custom.css" type="text/css" />
    <link href="css/quartzMenu.css" rel="stylesheet" />

    <!--solution script file-->
    <script src="js/csbAngularUI.js"></script>
    <script src="js/csbAngularForm.js"></script>

    <script src="js/textAngular/textAngular-rangy.min.js" type="text/javascript"></script>
    <script src="js/textAngular/textAngular-sanitize.min.js" type="text/javascript"></script>
    <script src="js/textAngular/textAngular.min.js" type="text/javascript"></script>
    <link rel="stylesheet" href="css/textAngular.css">

    <link rel="stylesheet" href="css/angular-material-calendar.min.css">
    <script src="js/angular-material-calendar.js" type="text/javascript"></script>
    
	<link rel="stylesheet" href="//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css">

    <style ng-controller="initializeCargasCSS as initCSS" csb-material-design-css>
    </style>
    <script type="text/javascript" src="js/sha256.js"></script>
    <script src="js/csbAngularLogin.js"></script>

    </head>
    <body id="MasterBody" runat="server" ng-controller="DataController as data">

        <form method="post" runat="server" id="mainForm" class="form-horizontal" ng-submit="data.setLocalStorage()" novalidate>
            <div id="content" class="row">
                <div id="login-form" class="col-xs-8 col-xs-offset-2 col-sm-4 col-sm-offset-4">
                    <h1 class="form-signin-heading">Please sign in</h1>
            
                    <br />
                    <div id="lblMessage" class="alert alert-danger hidden" role="alert" runat="server"></div>
                    <label id="inputUsernameLabel" for="inputUsername" runat="server">Username</label>
                    <asp:TextBox runat="server" ID="inputUsername" CssClass="form-control" placeholder="Enter your username" required="required" autofocus="autofocus"></asp:TextBox>
                    <div id="lblUsernameFooter" runat="server"></div>
                    <span id="PasswordSpan" runat="server">
                        <br />
                        <label id="inputPasswordLabel" for="inputPassword" runat="server">Password</label>
                        <asp:TextBox runat="server" ID="inputPassword" TextMode="Password" CssClass="form-control" placeholder="Enter your password" required="required"></asp:TextBox>
                        <asp:HiddenField runat="server" ID="inputHashedPassword" Value="" />
                        <div id="lblPasswordFooter" runat="server"></div>
                    </span>
                    <br />
                    <asp:Button id="btnLogin" CssClass="btn btn-lg btn-primary btn-block login-button" type="submit" Text="Sign in" runat="server" ng-click="data.setLocalStorage()" ></asp:Button>
                    <div id="lblSignInFooter" runat="server"></div>
                    <br />
                    <div id="lblForgotPasswordDiv" runat="server">
                        <a id="LoginForgotPasswordLink" ng-click="showForgotPasswordDialog($event);">Forgot / Reset Password?</a>
                    </div>
                    <asp:HiddenField runat="server" ID="ForgotPasswordEmail" Value="" />
                </div>
            </div>

	        <input id="redirectURL" type="hidden" name="redirectURL" runat="server" /> <input id="selectedMenu" type="hidden" name="selectedMenu" runat="server" />
	        <input id="currentScreenID" type="hidden" name="currentScreenID" runat="server" />
	        <input id="saveDataChangedState" type="hidden" name="saveDataChangedState" runat="server" />
            <input id="inputPasswordSalted" type="hidden" name="inputPasswordSalted" runat="server" value=""/>
            <input id="token" type="hidden" name="token" runat="server" value="" ng-model="data.token" />
          
            <script type="text/javascript">
                <% if (ConfigurationManager.AppSettings["UserAuthenticationMethod"] == "SQL") { %>
                    $(function () {
                        sessionStorage.clear();

                        $('form#mainForm').submit(function (event) {
                            if ($('#inputUsername').val().length > 0 && $('#inputPassword').val().length > 0) {
                                $('.login-button').addClass('disabled').val("Signing in...");
                                if ($('#inputPasswordSalted').val() != "1") {
                                    event.preventDefault();
                                    $.ajax({
                                        type: 'POST',
                                        url: '<%= HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + ResolveUrl("~/") %>DataLoad/DataLoad.aspx?screenID=LoginValidate&p=' + $('#inputUsername').val(),
                                        dataType: 'json',
                                        //data: {
                                        //    screenID: 'LoginValidate',
                                        //    resultType: 'json',
                                        //    p: $('#inputUsername').val(),
                                        //    p: '',
                                        //}
                                    }).done(function (results) {
                                        if (results[0].UserPasswordSalt) {                                
                                            var hashedValue = CryptoJS.SHA256($('#inputPassword').val() + results[0].UserPasswordSalt).toString(CryptoJS.enc.Base64);
                                            $('#inputHashedPassword').val(hashedValue); 
                                            $('#inputPassword').val('hidden');
                                            isSubmitInProgress = false;
                                            $('form#mainForm').unbind('submit').submit();
                                        } else {
                                            $('#lblMessage').html("Error: " + results[0].ErrorMessage);
                                            $('#lblMessage').removeClass("hidden");
                                            $('.login-button').removeClass('disabled').val("Sign in");
                                        }
                                    }).fail(function (jqXHR, textStatus) {
                                        $('#lblMessage').html("Request error: (" + jqXHR.status + ") " + jqXHR.statusText);
                                        $('#lblMessage').removeClass("hidden");
                                        $('.login-button').removeClass('disabled').val("Sign in");

                                    });
                                }
                            }
                        });
                    });
                <% } else { %>
                    $(function () {
                        $('form#mainForm').submit(function (event) {
                            if ($('#inputUsername').val().length > 0 && $('#inputPassword').val().length > 0) {
                                $('.login-button').addClass('disabled').val("Signing in...");
                                if ($('#inputPasswordSalted').val() != "1") {
                                    event.preventDefault();
                                    $.ajax({
                                        type: 'POST',
                                        url: '<%= ConfigurationManager.AppSettings["WebServiceSignOnEndpoint"] %>',
                                        dataType: 'json',
                                        data: { username: $('#inputUsername').val(), password: $('#inputPassword').val() }
                                    }).done(function (results) {
                                        if (results.token) {                                    
                                            $('#token').val(results.token);
                                            $('#subscriberId').val(results.user.subscriberId);               
                                            $('#inputPassword').val('hidden');
                                            isSubmitInProgress = false;
                                            $('form#mainForm').unbind('submit').submit();
                                        } else {
                                            $('#lblMessage').html("Error: " + results[0].ErrorMessage);
                                            $('#lblMessage').removeClass("hidden");
                                            $('.login-button').removeClass('disabled').val("Sign in");
                                        }
                                    }).fail(function (jqXHR, textStatus) {
                                        $('#lblMessage').html("Request error: (" + jqXHR.status + ") " + jqXHR.statusText);
                                        $('#lblMessage').removeClass("hidden");
                                        $('.login-button').removeClass('disabled').val("Sign in");

                                    });
                                }
                            }
                        });
                    });  
                <% } %>
                                     
                function forgotPasswordLinkClick() {
                    alert('click!');
                    //showInDialog('TemplateHTML\LoginGetOneTime.html', 'Forgot Password', 600, 500);
                    showInDialog('Form.html', 'User Form', 600, 500);
                    alert('done');
                }
            </script>
        </form>
    </body>
</html>
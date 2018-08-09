
(function () {
   
    
    var app=angular.module('csbLoginAngular', ['ngMaterial', 'ngStorage', 'csbAngularUI']);

    app.controller('DataController', ['$http', '$scope', '$sessionStorage', '$location', '$window', '$mdDialog', '$timeout', function ($http, $scope, $localStorage, $location, $window, $mdDialog, $timeout) {
        var data = this;
        data.localStorage = $localStorage;
        data.LoginMessage = "";
        data.UserName = "";
        data.Password = "";
        data.ResponseData = {};
        data.action = $location.search().action;
        if (data.action == "logout") {
            var sURL = 'DataLoad\DataLoad.aspx?screenID=FormsLogout&p=&resultType=json';
            $http({
                method: 'get',
                url: sURL

            }).then(function (response) {

            });
        }
        data.Login = function () {
            if (data.UserName.length > 0 && data.Password.length > 0) {

                $('.login-button').addClass('disabled').val("Signing in...");
                //ABOS login
                $http({
                    method: 'POST',
                    url: 'http://8.39.160.52:82/SignIn',
                    data: { "username": data.UserName, "password": data.Password }
                }).then(function (response) {
                    //login success
                    data.ResponseData = response.data
                    data.LoginMessage = "";
                    // store stuff
                    $localStorage.token = response.data.token;
                    $localStorage.subscriberId = response.data.user.subscriberId;
                    //validate password against SolutionBuilder User table
                    //$http({
                    //    method: 'GET',
                    //    url: 'FormsLogin.aspx?screenID=LoginValidate&resultType=json&p=' + encodeURIComponent(data.UserName)
                    //    //{'screenID': 'LoginValidate', 'resultType': 'json', 'p': data.UserName}       
                    //}).then(function (response) {
                    //    //got salt. log in user
                    //    if (response.data[0].UserPasswordSalt) {
                    var hashedValue = CryptoJS.SHA256(data.Password).toString(CryptoJS.enc.Base64);
                    data.loginurl = 'FormsLogin.aspx?screenID=FormsLogin&resultType=json&p=' + data.UserName + '&p=' + hashedValue
                    $http({
                        method: 'GET',
                        url: data.loginurl
                    }).then(function (response) {
                        //if user is authenticated redirect
                        $window.location.href = '/Provision.html';

                    }, function (response) {
                        //login failed.
                        data.LoginMessage = response.statusText + ". " + response.data.msg;
                        $('.login-button').removeClass('disabled').val("Sign in");
                    });

                    //}
                    //},function (response) {
                    //    //problem getting salt
                    //    data.LoginMessage=response.statusText+". "+response.data.msg;
                    //    $('.login-button').removeClass('disabled').val("Sign in");
                    //});   



                }, function (response) {
                    //problem with ABOS login
                    data.LoginMessage = response.statusText + ". " + response.data.msg;
                    $('.login-button').removeClass('disabled').val("Sign in");
                });
            }

        };

        $scope.showForgotPasswordDialogEvent = null;
        $scope.showForgotPasswordDialog = function (ev) {
            $scope.showForgotPasswordDialogEvent = ev;
            var confirm = $mdDialog.prompt()
                .title('One-Time Password Link')
                .textContent(forgotPasswordText)
                .placeholder(usernameLabel)
                .ariaLabel(usernameLabel)
                .targetEvent(ev)
                .required(true)
                .ok('Send Link')
                .cancel('Cancel');

            $mdDialog.show(confirm).then(function (result) {
                $('#ForgotPasswordEmail').val(result);
                $('#inputUsername').val('');
                $('#inputPassword').val('');
                $('#inputHashedPassword').val('');
                $timeout(function () {
                    $('#mainForm').submit()
                }, 0);
            }, function () { });
        }


        function sendOneTimeLink(result) {
            //$('#ForgotPasswordEmail').val(result);
            //setTimeout($('#mainForm').submit(), 0);
            //$('#mainForm').submit();
            /*
            $.ajax({
                type: 'POST',
                url: 'DataLoad\DataLoad.aspx',
                dataType: 'json',
                data: {
                    screenID: 'LoginResetPassword'
                    , resultType: 'json'
                    , p: result
                }
            }).done(function (results) {
                $mdDialog.show(
                    $mdDialog.alert()
                        .clickOutsideToClose(true)
                        .title('Link Sent Successfully')
                        .textContent('If your email address is on file you will receive a link to login and reset your password.')
                        .ariaLabel('Link Sent Successfully')
                        .ok('OK')
                        .targetEvent($scope.showForgotPasswordDialogEvent)
                );
            }).fail(function (jqXHR, textStatus) {
                $mdDialog.show(
                    $mdDialog.alert()
                        .clickOutsideToClose(true)
                        .title('Link Sending Failed!')
                        .textContent(textStatus)
                        .ariaLabel('Link Sending Failed!')
                        .ok('OK')
                        .targetEvent($scope.showForgotPasswordDialogEvent)
                );
            });
            */
        }


        deleteCachedMenu();

        function deleteCachedMenu() {
            //change the caching setting
            //var sURL = 'CarjaxClassicJSON_FieldData.aspx?screenID=TimeLogLast10&p=&resultType=json';
            delete $localStorage.menuHTML;
        }
    }]);
})();

(function () {

    var injectParams = ['$scope', '$location', '$routeParams', '$window', 'constants', 'userService'];

    var LoginController = function ($scope, $location, $routeParams, $window, constants, userService) {

        $scope.userName = null;
        $scope.password = null;

        function init(){
            if($routeParams.exit != null)
                $scope.deleteToken();
            else if($routeParams.user != null && $routeParams.auth != null)
                $scope.ssoLogin($routeParams.user, $routeParams.auth);
        }

        $scope.login = function () {
            userService.login($scope.userName, $scope.password);
        };

        $scope.ssoLogin = function (userName, encodedAuth) {
            userService.ssoLogin(userName, encodedAuth);
        };

        $scope.deleteToken = function () {
            userService.deleteToken();
        };

        init();
    };

    LoginController.$inject = injectParams;

    angular.module('accord.ly').controller('LoginController', LoginController);

}());
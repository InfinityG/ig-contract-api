(function () {

    var injectParams = ['$scope', '$location', '$routeParams', '$window', 'userService', 'registrationService'];

    var LoginController = function ($scope, $location, $routeParams, $window, userService, registrationService) {

        $scope.firstName = null;
        $scope.lastName = null;
        $scope.userName = null;
        $scope.password = null;
        $scope.mobile = null;
        $scope.role = null;
        $scope.roles = ['coach', 'leader', 'facilitator', 'caregiver'];
        $scope.context = null;

        function init(){
            if($routeParams.exit != null)
                $scope.deleteToken();
            else
                $scope.context = userService.getContext();
        }

        $scope.roleSelected = function(role){
            $scope.role = role;
        };

        $scope.login = function () {
            userService.login($scope.userName, $scope.password);
        };

        $scope.deleteToken = function () {
            userService.deleteToken();
        };

        $scope.register = function (firstName, lastName, userName, password, mobile, role) {
            registrationService.register(firstName, lastName, userName, password, mobile, role);
        };

        init();
    };

    LoginController.$inject = injectParams;

    angular.module('accord.ly').controller('LoginController', LoginController);

}());
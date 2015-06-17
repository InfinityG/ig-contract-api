(function () {

    var injectParams = ['$scope', '$rootScope', '$location', '$routeParams', '$window', 'userService'];

    var HeaderController = function ($scope, $rootScope, $location, $routeParams, $window, userService) {

        $scope.userName = null;

        function init(){
            var context = userService.getContext();

            if(context != null) {
                console.debug(context.username);
                $scope.userName = context.username;
            }
        }

        var loginEventListener = $rootScope.$on('loginEvent', function (event, args) {
            $scope.userName = args.username;
        });

        var logoutEventListener = $rootScope.$on('logoutEvent', function (event, args) {
            $scope.userName = null;
        });

        //clean up rootScope listener
        $scope.$on('$destroy', function() {
            loginEventListener();
            logoutEventListener();
        });

        init();
    };

    HeaderController.$inject = injectParams;

    angular.module('accord.ly').controller('HeaderController', HeaderController);

}());
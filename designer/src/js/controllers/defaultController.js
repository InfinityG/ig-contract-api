(function () {

        var injectParams = ['$scope', '$location', '$compile', 'userService'];

        var DefaultController = function ($scope, $location, userService) {

            function init() {
                var context = userService.getContext();

                if (context == null || context == '')
                    $location.path('/login');
            }

            init();
        };

        DefaultController.$inject = injectParams;

        angular.module('accord.ly').controller('DefaultController', DefaultController);

    }()
);
(function () {

        var injectParams = ['$scope', '$location', '$compile'];

        var DefaultController = function ($scope, $location, $compile) {

            $scope.conditionData = [];

            //init();
        };

        DefaultController.$inject = injectParams;

        angular.module('accord.ly').controller('DefaultController', DefaultController);

    }()
);
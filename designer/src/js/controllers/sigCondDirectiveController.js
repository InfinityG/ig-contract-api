(function () {

        var injectParams = ['$scope'];

        var SigCondDirectiveController = function ($scope) {
            $scope.collapsed = true;
        };

        SigCondDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('SigCondDirectiveController', SigCondDirectiveController);

    }()
);
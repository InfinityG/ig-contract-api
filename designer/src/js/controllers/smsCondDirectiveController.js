(function () {

        var injectParams = ['$scope'];

        var SmsCondDirectiveController = function ($scope) {
            $scope.collapsed = true;
        };

        SmsCondDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('SmsCondDirectiveController', SmsCondDirectiveController);

    }()
);
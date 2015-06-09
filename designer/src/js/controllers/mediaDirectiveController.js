(function () {

        var injectParams = ['$scope'];

        var MediaDirectiveController = function ($scope) {
            $scope.collapsed = true;

            $scope.remove = function(){
                //TODO: clear the model from the service;
                $element.remove();
            };
        };

        MediaDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('MediaDirectiveController', MediaDirectiveController);

    }()
);
(function () {

        var injectParams = ['$scope'];

        var MediaController = function ($scope) {
            $scope.collapsed = true;

            $scope.remove = function(){
                //TODO: clear the model from the service;
                $element.remove();
            };
        };

        MediaController.$inject = injectParams;

        angular.module('accord.ly').controller('MediaController', MediaController);

    }()
);
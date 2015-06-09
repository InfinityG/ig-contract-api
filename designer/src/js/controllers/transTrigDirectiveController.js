/**
 * Created by grant on 05/06/2015.
 */
(function () {

        var injectParams = ['$scope'];

        var TransTrigDirectiveController = function ($scope) {
            $scope.collapsed = true;

            $scope.remove = function(){
                //TODO: clear the model from the service;
                $element.remove();
            };
        };

        TransTrigDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('TransTrigDirectiveController', TransTrigDirectiveController);

    }()
);
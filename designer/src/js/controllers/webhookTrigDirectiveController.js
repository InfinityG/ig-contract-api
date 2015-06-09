/**
 * Created by grant on 05/06/2015.
 */
(function () {

        var injectParams = ['$scope'];

        var WebhookTrigDirectiveController = function ($scope) {
            $scope.collapsed = true;

            $scope.remove = function(){
                //TODO: clear the model from the service;
                $element.remove();
            };
        };

        WebhookTrigDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('WebhookTrigDirectiveController', WebhookTrigDirectiveController);

    }()
);
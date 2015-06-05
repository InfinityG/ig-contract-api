/**
 * Created by grant on 05/06/2015.
 */
(function () {

        var injectParams = ['$scope'];

        var WebhookTrigDirectiveController = function ($scope) {
            $scope.collapsed = true;
        };

        WebhookTrigDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('WebhookTrigDirectiveController', WebhookTrigDirectiveController);

    }()
);
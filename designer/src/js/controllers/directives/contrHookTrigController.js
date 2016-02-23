/**
 * Created by grant on 05/06/2015.
 */
(function () {

        var injectParams = ['$scope', '$element', 'viewModelService', 'modelIndexService'];

        var ContrHookTrigController = function ($scope, $element, viewModelService, modelIndexService) {

            $scope.collapsed = true;
            $scope.transFields = null;
            $scope.webhook = null;

            function init(){
                //get the fields for the UI
                $scope.transFields = viewModelService.viewModel.triggers.webhook.fields;

                //get the model from the index
                $scope.webhook = modelIndexService.modelElementIndex[$scope.id];
            }

            init();
        };

        ContrHookTrigController.$inject = injectParams;

        angular.module('accord.ly').controller('ContrHookTrigController', ContrHookTrigController);

    }()
);
/**
 * Created by grant on 05/06/2015.
 */
(function () {

        var injectParams = ['$scope', '$element', 'viewModelService', 'modelIndexService'];

        var ContrTransTrigController = function ($scope, $element, viewModelService, modelIndexService) {
            $scope.collapsed = true;
            $scope.transFields = null;
            $scope.transaction = null;

            function init(){
                //get the fields for the UI
                $scope.transFields = viewModelService.viewModel.triggers.transaction.fields;

                //get the model from the index
                $scope.transaction = modelIndexService.modelElementIndex[$scope.contractId];

            }

            init();
        };

        ContrTransTrigController.$inject = injectParams;

        angular.module('accord.ly').controller('ContrTransTrigController', ContrTransTrigController);

    }()
);
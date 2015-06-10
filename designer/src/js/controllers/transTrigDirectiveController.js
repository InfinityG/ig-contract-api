/**
 * Created by grant on 05/06/2015.
 */
(function () {

        var injectParams = ['$scope', '$element', 'modelService'];

        var TransTrigDirectiveController = function ($scope, $element, modelService) {
            $scope.collapsed = true;
            $scope.transFields = null;
            $scope.transaction = null;

            function init(){
                //get the fields for the UI
                $scope.transFields = modelService.viewModel.triggers.transaction.fields;

                //get the model from the index
                var indexItem = modelService.modelElementIndex[$scope.templateId];

                if(indexItem != null)
                    $scope.transaction = modelService.modelElementIndex[$scope.templateId].model;
            }

            $scope.fromSelected = function (key, value) {
                $scope.transaction.from_place_holder = key;
            };

            $scope.toSelected = function (key, value) {
                $scope.transaction.to_place_holder = key;

                console.debug(JSON.stringify(modelService.templateModel));
            };

            $scope.remove = function(){
                //delete the model
                var parentConditionId = modelService.modelElementIndex[$scope.templateId].parentId;
                modelService.deleteTransaction(parentConditionId, $scope.transaction.id);

                //delete the element
                $element.remove();

                console.debug(JSON.stringify(modelService.templateModel));
            };

            init();
        };

        TransTrigDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('TransTrigDirectiveController', TransTrigDirectiveController);

    }()
);
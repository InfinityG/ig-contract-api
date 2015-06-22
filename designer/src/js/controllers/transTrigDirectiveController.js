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
                $scope.transaction = modelService.modelElementIndex[$scope.templateId];

            }

            $scope.fromSelected = function (key, value) {
                $scope.transaction.meta.from = key;
            };

            $scope.toSelected = function (key, value) {
                $scope.transaction.meta.to = key;

                console.debug(JSON.stringify(modelService.baseTemplateModel));
            };

            $scope.remove = function(){
                //delete the model
                var parentConditionId = $scope.templateId.split('_')[0].split(':')[1];
                modelService.deleteTransaction(parentConditionId, $scope.transaction.id);

                //delete the element
                $element.remove();

                console.debug(JSON.stringify(modelService.baseTemplateModel));
            };

            init();
        };

        TransTrigDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('TransTrigDirectiveController', TransTrigDirectiveController);

    }()
);
/**
 * Created by grant on 05/06/2015.
 */
(function () {

        var injectParams = ['$scope', '$element', 'templateModelService', 'viewModelService', 'modelIndexService'];

        var TemplTransTrigController = function ($scope, $element, templateModelService, viewModelService,
                                                 modelIndexService) {
            $scope.collapsed = true;
            $scope.transFields = null;
            $scope.transaction = null;

            function init(){
                //get the fields for the UI
                $scope.transFields = viewModelService.viewModel.triggers.transaction.fields;

                //get the model from the index
                $scope.transaction = modelIndexService.modelElementIndex[$scope.templateId];

            }

            $scope.fromSelected = function (key, value) {
                $scope.transaction.meta.from = key;
            };

            $scope.toSelected = function (key, value) {
                $scope.transaction.meta.to = key;
            };

            $scope.remove = function(){
                //delete the model
                var parentConditionId = $scope.templateId.split('_')[0].split(':')[1];
                templateModelService.deleteTransaction(parentConditionId, $scope.transaction.id);

                //delete the element
                $element.remove();
            };

            init();
        };

        TemplTransTrigController.$inject = injectParams;

        angular.module('accord.ly').controller('TemplTransTrigController', TemplTransTrigController);

    }()
);
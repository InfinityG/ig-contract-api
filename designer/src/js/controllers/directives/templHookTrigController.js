/**
 * Created by grant on 05/06/2015.
 */
(function () {

        var injectParams = ['$scope', '$element', 'templateModelService', 'viewModelService', 'modelIndexService'];

        var TemplHookTrigController = function ($scope, $element, templateModelService, viewModelService,
                                                modelIndexService) {

            $scope.collapsed = true;
            $scope.transFields = null;
            $scope.webhook = null;

            function init(){
                //get the fields for the UI
                $scope.transFields = viewModelService.viewModel.triggers.webhook.fields;

                //get the model from the index
                $scope.webhook = modelIndexService.modelElementIndex[$scope.templateId];
            }

            $scope.fromSelected = function (key, value) {
                $scope.webhook.from_place_holder = key;
            };

            $scope.toSelected = function (key, value) {
                $scope.transaction.to_place_holder = key;
            };

            $scope.remove = function(){
                //delete the model
                var parentConditionId = $scope.templateId.split('_')[0].split(':')[1];
                templateModelService.deleteWebhook(parentConditionId, $scope.webhook.id);

                //delete the element
                $element.remove();
            };

            init();
        };

        TemplHookTrigController.$inject = injectParams;

        angular.module('accord.ly').controller('TemplHookTrigController', TemplHookTrigController);

    }()
);
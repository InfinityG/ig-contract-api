(function () {

        var injectParams = ['$scope', '$element', 'templateModelService', 'viewModelService', 'modelIndexService'];

        var TemplSmsCondController = function ($scope, $element, templateModelService, viewModelService,
                                               modelIndexService) {
            $scope.collapsed = true;
            $scope.smsFields = null;

            $scope.condition = null;

            function init(){
                //view model
                $scope.smsFields = viewModelService.viewModel.conditions.sms.fields;

                //get the model from the index - this will have been created when the item was dropped
                $scope.condition = modelIndexService.modelElementIndex[$scope.templateId];
            }

            $scope.fromSelected = function (key, value) {
                $scope.condition.meta.sub_type = key;
            };

            $scope.remove = function(){
                templateModelService.removeCondition($scope.condition.external_id);
                $element.remove();
            };

            init();

        };

        TemplSmsCondController.$inject = injectParams;

        angular.module('accord.ly').controller('TemplSmsCondController', TemplSmsCondController);

    }()
);
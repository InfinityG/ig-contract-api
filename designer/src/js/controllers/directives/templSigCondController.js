(function () {

        var injectParams = ['$scope', '$element', 'templateModelService', 'viewModelService', 'modelIndexService'];

        var TemplSigCondController = function ($scope, $element, templateModelService, viewModelService,
                                               modelIndexService) {

            $scope.collapsed = true;
            $scope.sigFields = null;

            $scope.condition = null;

            function init(){
                //view model
                $scope.sigFields = viewModelService.viewModel.conditions.signature.fields;

                //get the model from the index
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

        TemplSigCondController.$inject = injectParams;

        angular.module('accord.ly').controller('TemplSigCondController', TemplSigCondController);

    }()
);
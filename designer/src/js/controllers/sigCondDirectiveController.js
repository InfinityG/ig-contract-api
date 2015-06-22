(function () {

        var injectParams = ['$scope', '$element', 'modelService'];

        var SigCondDirectiveController = function ($scope, $element, modelService) {

            $scope.collapsed = true;
            $scope.sigFields = null;

            $scope.condition = null;

            function init(){
                //view model
                $scope.sigFields = modelService.viewModel.conditions.signature.fields;

                //get the model from the index
                $scope.condition = modelService.modelElementIndex[$scope.templateId];
            }

            $scope.fromSelected = function (key, value) {
                $scope.condition.meta.sub_type = key;

            };

            $scope.remove = function(){
                modelService.removeCondition($scope.condition.id);
                $element.remove();

                console.debug(JSON.stringify(modelService.baseTemplateModel));
            };

            init();

        };

        SigCondDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('SigCondDirectiveController', SigCondDirectiveController);

    }()
);
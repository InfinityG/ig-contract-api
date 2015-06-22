(function () {

        var injectParams = ['$scope', '$element', 'templateModelService'];

        var ContrSigCondController = function ($scope, $element, templateModelService) {

            $scope.collapsed = true;
            $scope.sigFields = null;

            $scope.condition = null;

            function init(){
                //view model
                $scope.sigFields = templateModelService.viewModel.conditions.signature.fields;

                //get the model from the index
                $scope.condition = templateModelService.modelElementIndex[$scope.templateId];
            }

            init();

        };

        ContrSigCondController.$inject = injectParams;

        angular.module('accord.ly').controller('ContrSigCondController', ContrSigCondController);

    }()
);
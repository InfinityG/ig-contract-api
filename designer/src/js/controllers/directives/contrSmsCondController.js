(function () {

        var injectParams = ['$scope', '$element', 'viewModelService', 'modelIndexService'];

        var ContrSmsCondController = function ($scope, $element, viewModelService, modelIndexService) {

            $scope.collapsed = true;
            $scope.sigFields = null;

            $scope.condition = null;

            function init(){
                //view model
                $scope.sigFields = viewModelService.viewModel.conditions.signature.fields;

                //get the model from the index
                $scope.condition = modelIndexService.modelElementIndex[$scope.id];
            }

            init();

        };

        ContrSmsCondController.$inject = injectParams;

        angular.module('accord.ly').controller('ContrSmsCondController', ContrSmsCondController);

    }()
);
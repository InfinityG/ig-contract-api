(function () {

        var injectParams = ['$scope', '$element', 'modelService'];

        var SigCondDirectiveController = function ($scope, $element, modelService) {

            $scope.collapsed = true;
            $scope.sigFields = null;

            $scope.condition = null;

            $scope.signature = null;
            $scope.sigDescription = null;

            function init(){
                //view model
                $scope.sigFields = modelService.viewModel.conditions.signature.fields;

                //get the model from the index
                $scope.condition = modelService.modelElementIndex[$scope.templateId];
            }

            $scope.typeSelected = function (key, value) {

                if($scope.dropActive == true) {

                    $scope.signature.place_holder = key;
                    $scope.sigDescription = value;

                    console.debug(JSON.stringify(modelService.templateModel));
                }
            };

            $scope.remove = function(){
                modelService.removeCondition($scope.condition.id);
                $element.remove();

                console.debug(JSON.stringify(modelService.templateModel));
            };

            init();

        };

        SigCondDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('SigCondDirectiveController', SigCondDirectiveController);

    }()
);
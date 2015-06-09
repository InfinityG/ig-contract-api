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

                if($scope.dropActive == true) {
                    //condition
                    $scope.condition = modelService.createClone(modelService.conditionModel);

                    //add the signature model to the condition
                    $scope.signature = modelService.createClone(modelService.signatureModel);
                    $scope.condition.signatures.push($scope.signature);

                    //add the condition to the master model
                    modelService.addCondition($scope.condition);
                    console.debug('Model updated');
                }
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
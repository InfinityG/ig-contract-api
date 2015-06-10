(function () {

        var injectParams = ['$scope', '$element', 'modelService'];

        var SmsCondDirectiveController = function ($scope, $element, modelService) {
            $scope.collapsed = true;
            $scope.smsFields = null;

            $scope.condition = null;
            $scope.signature = null;
            $scope.smsDescription = null;

            function init(){
                //view model
                //$scope.smsFields = modelService.viewModel.conditions.sms.fields;
                //
                //if($scope.dropActive == true) {
                //    //condition
                //    $scope.condition = modelService.createClone(modelService.conditionModel);
                //
                //    //add the signature model to the condition
                //    $scope.signature = modelService.createClone(modelService.signatureModel);
                //    $scope.condition.signatures.push($scope.signature);
                //
                //    //add the condition to the master model
                //    modelService.addCondition($scope.condition);
                //    console.debug('Model updated');
                //}
            }

            $scope.typeSelected = function (key, value) {

                if($scope.dropActive == true) {

                    $scope.signature.place_holder = key;
                    $scope.smsDescription = value;

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

        SmsCondDirectiveController.$inject = injectParams;

        angular.module('accord.ly').controller('SmsCondDirectiveController', SmsCondDirectiveController);

    }()
);
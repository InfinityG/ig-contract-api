(function () {

        var injectParams = ['$scope', '$element', 'modelService'];

        var SmsCondDirectiveController = function ($scope, $element, modelService) {
            $scope.collapsed = true;
            $scope.smsFields = null;

            $scope.condition = null;

            function init(){
                //view model
                $scope.smsFields = modelService.viewModel.conditions.sms.fields;

                //get the model from the index - this will have been created when the item was dropped
                $scope.condition = modelService.modelElementIndex[$scope.templateId];
            }

            $scope.fromSelected = function (key, value) {
                $scope.condition.place_holder = key;

                console.debug(JSON.stringify(modelService.templateModel));
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
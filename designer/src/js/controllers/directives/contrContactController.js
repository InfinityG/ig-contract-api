//
//{
//    'id' : null,
//    'username' : null,
//    'first_name' : null,
//    'last_name' : null,
//    'role' : null,
//    'public_key' : null,
//    'registrar' : null,
//    'mobile_number' : null
//}

(function () {

        var injectParams = ['$scope', '$element', 'viewModelService', 'modelIndexService'];

        var ContrContactController = function ($scope, $element, viewModelService, modelIndexService) {

            $scope.collapsed = true;
            $scope.contFields = null;

            $scope.contact = null;

            function init(){
                //view model
                $scope.contFields = viewModelService.viewModel.conditions.signature.fields;

                //get the model from the index
                $scope.contact = modelIndexService.contactModelElementIndex[$scope.contactId];

                console.debug('Contact data: ' + JSON.stringify($scope.contact));
            }

            init();

        };

        ContrContactController.$inject = injectParams;

        angular.module('accord.ly').controller('ContrContactController', ContrContactController);

    }()
);
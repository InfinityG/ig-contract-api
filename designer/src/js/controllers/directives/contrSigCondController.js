(function () {

        var injectParams = ['$scope', '$element', 'viewModelService', 'contactService',
                                'contractModelService', 'modelIndexService'];

        var ContrSigCondController = function ($scope, $element, viewModelService, contactService,
                                               contractModelService, modelIndexService) {

            $scope.collapsed = true;
            $scope.sigFields = null;

            $scope.condition = null;
            $scope.contacts = null;

            function init(){
                //view model
                $scope.sigFields = viewModelService.viewModel.conditions.signature.fields;

                //get the model from the index
                $scope.condition = modelIndexService.modelElementIndex[$scope.contractId];

                if($scope.condition.meta.sub_type == 'all')
                    $scope.assignAllSignatures();
            }

            $scope.assignAllSignatures = function(){
                $scope.contacts = contactService.getContacts();

                contractModelService.addContactsToParticipants($scope.contacts);
                contractModelService.addSignaturesToCondition($scope.condition, $scope.contacts);
                contractModelService.raiseModelChanged();
            };

            init();

        };

        ContrSigCondController.$inject = injectParams;

        angular.module('accord.ly').controller('ContrSigCondController', ContrSigCondController);

    }()
);
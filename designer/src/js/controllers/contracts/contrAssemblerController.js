(function () {

        var injectParams = ['$scope', '$rootScope', '$location', '$route', '$routeParams',
            'userService', 'contractModelService', 'contractService', 'contactService',
            'modelIndexService', 'localStorageService'];

        var ContrAssemblerController = function ($scope, $rootScope, $location, $route, $routeParams,
                                                 userService, contractModelService, contractService,
                                                 contactService, modelIndexService, localStorageService) {

            $scope.context = null;
            $scope.template = null;
            $scope.contract = null;
            $scope.contacts = null;
            $scope.stringifiedModel = {'json':null};

            function init(){
                $scope.context = userService.getContext();

                if ($scope.context == null || $scope.context == '')
                    $location.path('/login');
                else {
                    $routeParams.templateId != null ? loadData($routeParams.templateId) : loadData();
                }
            }

            function loadData(templateId){
                $scope.template = localStorageService.getTemplate($scope.context.userId, templateId);

                //clone the template to be modified as a contract
                $scope.contract = contractModelService.createClone($scope.template);
                $scope.contract.name = null;
                $scope.contract.description = null;

                //set the current contract on the contractModelService
                contractModelService.setCurrentContract($scope.contract);

                //get the contacts
                $scope.loadContacts();

                //rebuild the current model index
                modelIndexService.rebuildIndex($scope.contract);

                //now rebuild the view
                contractService.buildContractFromModel($scope.contract);

                $scope.updateText();
            }

            $scope.loadContacts = function(){
                $scope.contacts = contactService.getContacts();
                modelIndexService.rebuildContactIndex($scope.contacts);
            };

            $scope.updateText = function(){
                $scope.stringifiedModel.json = contractModelService.stringifyModel($scope.contract);
            };

            $scope.saveContract = function(){
                localStorageService.saveContract($scope.context.userId, $scope.contract);
                $route.reload();
            };

            var modelEventListener = $rootScope.$on('contractModelEvent', function (event, args) {
                $scope.updateText();
            });

            //clean up rootScope listeners
            $scope.$on('$destroy', function() {
                modelEventListener();
            });

            init();
        };

        ContrAssemblerController.$inject = injectParams;

        angular.module('accord.ly').controller('ContrAssemblerController', ContrAssemblerController);

    }()
);
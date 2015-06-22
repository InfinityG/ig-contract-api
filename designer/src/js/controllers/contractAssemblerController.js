(function () {

        var injectParams = ['$scope', '$rootScope', '$location', '$route', '$routeParams',
            'userService', 'templateModelService', 'templateService', 'localStorageService'];

        var ContractAssemblerController = function ($scope, $rootScope, $location, $route, $routeParams,
                                                   userService, templateModelService, templateService, localStorageService) {

            $scope.context = null;
            $scope.template = null;
            $scope.contract = null;
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
                if (templateId == null) {
                    //$scope.template = modelService.createTemplate();
                    //modelService.setCurrentTemplate($scope.template);
                } else {
                    $scope.template = localStorageService.getTemplate($scope.context.userId, templateId);

                    //clone the template to be modified as a contract
                    $scope.contract = templateModelService.createClone($scope.template);
                }

                $scope.updateText();
            }

            $scope.updateText = function(){
                $scope.stringifiedModel.json = templateModelService.stringifyModel($scope.contract);
            };

            $scope.saveTemplate = function(){
                localStorageService.saveTemplate($scope.context.userId, $scope.template);
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

        ContractAssemblerController.$inject = injectParams;

        angular.module('accord.ly').controller('ContractAssemblerController', ContractAssemblerController);

    }()
);
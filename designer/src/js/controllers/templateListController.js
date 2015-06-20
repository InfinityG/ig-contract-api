(function () {

        var injectParams = ['$scope', '$location', 'userService', 'localStorageService'];

        var TemplateListController = function ($scope, $location, userService, localStorageService) {

            $scope.context = null;
            $scope.templates = null;
            $scope.stringifiedModel = null;

            function init(){
                $scope.context = userService.getContext();

                if ($scope.context == null || $scope.context == '')
                    $location.path('/login');
                else
                    loadData();
            }

            function loadData(){
                $scope.templates = localStorageService.getTemplates($scope.context.userId);
            }

            $scope.deleteTemplate = function(externalId){
                localStorageService.deleteTemplate($scope.context.userId, externalId);
                loadData();
            };

            init();
        };

        TemplateListController.$inject = injectParams;

        angular.module('accord.ly').controller('TemplateListController', TemplateListController);

    }()
);
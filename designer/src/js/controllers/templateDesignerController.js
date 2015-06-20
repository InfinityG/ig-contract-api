(function () {

        var injectParams = ['$scope', '$rootScope', '$location', '$route', '$routeParams',
                                'userService', 'modelService', 'templateService', 'localStorageService'];

        var TemplateDesignerController = function ($scope, $rootScope, $location, $route, $routeParams,
                                                    userService, modelService, templateService, localStorageService) {

            $scope.context = null;
            $scope.template = null;
            $scope.stringifiedModel = {'json':null};

            function init(){
                $scope.context = userService.getContext();

                if ($scope.context == null || $scope.context == '')
                    $location.path('/login');
                else {
                    $routeParams.id != null ? loadData($routeParams.id) : loadData();
                }
            }

            function loadData(templateId){
                if (templateId == null) {
                    $scope.template = modelService.createTemplate();
                    modelService.setCurrentTemplate($scope.template);
                } else {
                    $scope.template = localStorageService.getTemplate($scope.context.userId, templateId);
                    modelService.setCurrentTemplate($scope.template);
                    modelService.rebuildIndex();

                    //now rebuild the view
                    templateService.rebuildTemplateFromModel();
                }

                $scope.updateText();
            }

            $scope.updateText = function(){
                $scope.stringifiedModel.json = modelService.stringifyModel($scope.template);
            };

            $scope.saveTemplate = function(){
                localStorageService.saveTemplate($scope.context.userId, $scope.template);
                //loadData();
                $route.reload();
            };

            var modelEventListener = $rootScope.$on('templateModelEvent', function (event, args) {
                $scope.updateText();
            });

            //clean up rootScope listeners
            $scope.$on('$destroy', function() {
                modelEventListener();
            });

            init();
        };

        TemplateDesignerController.$inject = injectParams;

        angular.module('accord.ly').controller('TemplateDesignerController', TemplateDesignerController);

    }()
);
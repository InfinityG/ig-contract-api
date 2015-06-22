(function () {

        var injectParams = ['$scope', '$rootScope', '$location', '$route', '$routeParams',
                                'userService', 'templateModelService', 'templateService', 'localStorageService'];

        var TemplateDesignerController = function ($scope, $rootScope, $location, $route, $routeParams,
                                                    userService, templateModelService, templateService, localStorageService) {

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
                    $scope.template = templateModelService.createTemplate();
                    templateModelService.setCurrentTemplate($scope.template);
                } else {
                    $scope.template = localStorageService.getTemplate($scope.context.userId, templateId);
                    templateModelService.setCurrentTemplate($scope.template);
                    templateModelService.rebuildIndex();

                    //now rebuild the view
                    templateService.rebuildTemplateFromModel();
                }

                $scope.updateText();
            }

            $scope.updateText = function(){
                $scope.stringifiedModel.json = templateModelService.stringifyModel($scope.template);
            };

            $scope.saveTemplate = function(){
                localStorageService.saveTemplate($scope.context.userId, $scope.template);
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
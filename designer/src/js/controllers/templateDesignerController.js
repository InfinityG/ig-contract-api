(function () {

        var injectParams = ['$scope', '$location', 'userService', 'modelService'];

        var TemplateDesignerController = function ($scope, $location, userService, modelService) {

            $scope.template = null;
            $scope.stringifiedModel = null;

            function init(){
                var context = userService.getContext();

                if (context == null || context == '')
                    $location.path('/login');
                else
                    loadData();
            }

            function loadData(){
                $scope.template = modelService.templateModel;
                $scope.stringifiedModel = modelService.stringifiedModel;
            }

            $scope.conditionData = [];

            $scope.updateText = function(){
              modelService.stringifyModel();
            };

            init();
        };

        TemplateDesignerController.$inject = injectParams;

        angular.module('accord.ly').controller('TemplateDesignerController', TemplateDesignerController);

    }()
);
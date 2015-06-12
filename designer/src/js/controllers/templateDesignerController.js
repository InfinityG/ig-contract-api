(function () {

        var injectParams = ['$scope', '$location', '$compile'];

        var TemplateDesignerController = function ($scope, $location, $compile) {

            $scope.conditionData = [];

            //init();
        };

        TemplateDesignerController.$inject = injectParams;

        angular.module('accord.ly').controller('TemplateDesignerController', TemplateDesignerController);

    }()
);
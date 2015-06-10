(function () {

    var signatureCondition = function () {

        return {
            templateUrl: 'sigCondTemplate.html',
            restrict: 'E',
            scope:{
                showRemoveButton:'=',
                dropActive:'=',
                templateId:'@'
            },
            link: function postLink(scope, element, attrs) {
                element[0].childNodes[0].id = scope.templateId;
            }
        };
    };

    angular.module('accord.ly').directive('signatureCondition', signatureCondition);
})();
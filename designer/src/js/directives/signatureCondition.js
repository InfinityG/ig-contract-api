(function () {

    var signatureCondition = function () {

        return {
            templateUrl: 'sigCondTemplate.html',
            restrict: 'E',
            link: function postLink(scope, element, attrs) {
                //element.innerHTML(template);
            }
        };
    };

    angular.module('accord.ly').directive('signatureCondition', signatureCondition);
})();
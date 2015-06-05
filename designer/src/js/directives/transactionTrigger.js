//http://blog.parkji.co.uk/2013/08/11/native-drag-and-drop-in-angularjs.html

(function () {

    var transactionTrigger = function () {

        return {
            templateUrl: 'transTrigTemplate.html',
            restrict: 'E',
            link: function postLink(scope, element, attrs) {
                //element.text(template);
            }
        };
    };

    angular.module('accord.ly').directive('transactionTrigger', transactionTrigger);
})();
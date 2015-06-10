//http://blog.parkji.co.uk/2013/08/11/native-drag-and-drop-in-angularjs.html

(function () {

    var transactionTrigger = function () {

        return {
            templateUrl: 'transTrigTemplate.html',
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

    angular.module('accord.ly').directive('transactionTrigger', transactionTrigger);
})();
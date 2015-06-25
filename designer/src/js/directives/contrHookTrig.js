
(function () {

    var contrHookTrig = function () {

        return {
            templateUrl: 'contrHookTrig.html',
            restrict: 'E',
            scope:{
                showRemoveButton:'=',
                dropActive:'=',
                contractId:'@'
            },
            link: function postLink(scope, element, attrs) {
                element[0].childNodes[0].id = scope.contractId;
            }
        };
    };

    angular.module('accord.ly').directive('contrHookTrig', contrHookTrig);
})();
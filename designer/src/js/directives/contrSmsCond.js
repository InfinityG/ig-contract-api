
(function () {

    var injectParams = ['contractService', 'modelIndexService'];

    var contrSmsCond = function (contractService, modelIndexService) {

        return {
            templateUrl: 'contrSmsCond.html',
            restrict: 'E',
            scope:{
                showRemoveButton:'=',
                dropActive:'=',
                contractId:'@'
            },
            link: function postLink(scope, element, attrs) {
                element[0].childNodes[0].id = scope.contractId;

                //check if the model has any child triggers (used for rebuilding a saved condition)
                var condition = modelIndexService.modelElementIndex[scope.contractId];

                if ((condition != null && condition.trigger != null) &&
                    ((condition.trigger.transactions.length > 0) || (condition.trigger.webhooks.length > 0))) {
                    contractService.rebuildNestedElementsFromModel(scope.contractId, element, condition);
                }
            }
        };
    };

    contrSmsCond.$inject = injectParams;

    angular.module('accord.ly').directive('contrSmsCond', contrSmsCond);
})();
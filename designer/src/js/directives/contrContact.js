(function () {

    var injectParams = ['contactService', 'modelIndexService'];

    var contrContact = function (contactService, modelIndexService) {

        return {
            templateUrl: 'contrContact.html',
            restrict: 'E',
            scope: {
                showRemoveButton: '=',
                dropActive: '=',
                contactId: '@'
            },
            link: function postLink(scope, element, attrs) {
                //set the id of the top element in the template HTML
                element[0].childNodes[0].id = scope.contactId;

                ////check if the model has any child triggers (used for rebuilding a saved condition)
                //var condition = modelIndexService.modelElementIndex[scope.contractId];
                //
                //if ((condition != null && condition.trigger != null) &&
                //    ((condition.trigger.transactions.length > 0) || (condition.trigger.webhooks.length > 0))) {
                //    contractService.rebuildNestedElementsFromModel(scope.contractId, element, condition);
                //}
            }
        };
    };

    contrContact.$inject = injectParams;

    angular.module('accord.ly').directive('contrContact', contrContact);
})();
(function () {

    var injectParams = ['contractService', 'modelIndexService'];

    var contrContact = function (contractService, modelIndexService) {

        return {
            templateUrl: 'contrContact.html',
            restrict: 'E',
            scope: {
                showRemoveButton: '=',
                dropActive: '=',
                id: '@'
            },
            link: function postLink(scope, element, attrs) {
                //set the id of the top element in the template HTML
                element[0].childNodes[0].id = scope.id;

                //var condition = modelIndexService.modelElementIndex[scope.contractId];
                //console.debug('Conditionid: ' + condition.id);
                //
                //if (condition != null) {
                //    contractService.createContactElement(scope.contractId, element, condition);
                //}
            }
        };
    };

    contrContact.$inject = injectParams;

    angular.module('accord.ly').directive('contrContact', contrContact);
})();
(function () {

    var injectParams = ['templateModelService', 'templateService'];

    var signatureCondition = function (templateModelService, templateService) {

        return {
            templateUrl: 'sigCondTemplate.html',
            restrict: 'E',
            scope: {
                showRemoveButton: '=',
                dropActive: '=',
                templateId: '@'
            },
            link: function postLink(scope, element, attrs) {
                //set the id of the top element in the template HTML
                element[0].childNodes[0].id = scope.templateId;

                //check if the model has any child triggers (used for rebuilding a saved condition)
                var condition = templateModelService.modelElementIndex[scope.templateId];

                if ((condition != null && condition.trigger != null) &&
                    ((condition.trigger.transactions.length > 0) || (condition.trigger.webhooks.length > 0))) {
                    templateService.rebuildNestedElementsFromModel(scope.templateId, element, condition);
                }
            }
        };
    };

    signatureCondition.$inject = injectParams;

    angular.module('accord.ly').directive('signatureCondition', signatureCondition);
})();
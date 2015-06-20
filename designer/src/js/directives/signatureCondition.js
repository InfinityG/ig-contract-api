(function () {

    var injectParams = ['modelService', 'templateService'];

    var signatureCondition = function (modelService, templateService) {

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

                console.debug('In sig condition!');

                //check if the model has any child triggers (used for rebuilding a saved condition)
                var condition = modelService.modelElementIndex[scope.templateId];

                console.debug(JSON.stringify(condition));

                if ((condition != null && condition.trigger != null) &&
                    ((condition.trigger.transactions.length > 0) || (condition.trigger.webhooks.length > 0))) {
                    console.debug('Children detected in sig condition!');
                    templateService.rebuildNestedElementsFromModel(scope.templateId, element, condition);
                }
            }
        };
    };

    signatureCondition.$inject = injectParams;

    angular.module('accord.ly').directive('signatureCondition', signatureCondition);
})();
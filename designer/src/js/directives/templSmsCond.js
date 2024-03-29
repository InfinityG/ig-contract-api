//http://blog.parkji.co.uk/2013/08/11/native-drag-and-drop-in-angularjs.html

(function () {

    var injectParams = ['templateService', 'modelIndexService'];

    var templSmsCond = function (templateService, modelIndexService) {

        return {
            templateUrl: 'templSmsCond.html',
            restrict: 'E',
            scope:{
                showRemoveButton:'=',
                dropActive:'=',
                templateId:'@'
            },
            link: function postLink(scope, element, attrs) {
                element[0].childNodes[0].id = scope.templateId;

                //check if the model has any child triggers (used for rebuilding a saved condition)
                var condition = modelIndexService.modelElementIndex[scope.templateId];

                if ((condition != null && condition.trigger != null) &&
                    ((condition.trigger.transactions.length > 0) || (condition.trigger.webhooks.length > 0))) {
                    templateService.rebuildNestedElementsFromModel(scope.templateId, element, condition);
                }
            }
        };
    };

    templSmsCond.$inject = injectParams;

    angular.module('accord.ly').directive('templSmsCond', templSmsCond);
})();
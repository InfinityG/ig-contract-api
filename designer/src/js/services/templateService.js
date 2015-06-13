/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$rootScope', '$compile', 'modelService'];

    var templateServiceFactory = function ($rootScope, $compile, modelService) {
        var factory = {};

        factory.handleDrop = function (itemParent, item, directiveId, target) {
            var itemId = item.id;
            var parentId = itemParent.id;
            var targetId = target.id;

            //dont create new element if parent and target are the same
            if (parentId == targetId)
                return;

            //ensure that only conditions (not triggers) are allowed in the main template
            if ((itemId.indexOf('Trig:') > -1) && (targetId.indexOf('Contract') > -1))
                return;

            //don't allow conditions inside conditions
            if ((itemId.indexOf('Cond:') > -1) && (factory.searchParentTree(target, 'Cond:') != null))
                return;

            factory.insertItem(item, directiveId, target);
        };

        // TODO: finish this!
        factory.moveItem = function (item, directiveId, target) {
            angular.element(target).append(item);
        };

        //http://stackoverflow.com/questions/16656735/insert-directive-programatically-angular
        factory.insertItem = function (item, directiveId, target) {

            var model;
            var elementId;

            if (item.id.indexOf('Cond:') > -1) {    // condition elements id format: eg 'SigCond:1'
                model = factory.createConditionModel();
                elementId = item.id + model.id;
            }

            if (item.id.indexOf('Trig:') > -1) {    // id format: eg 'SigCond:1_HookTrig:1'

                var conditionId = factory.searchParentTree(target, 'Cond:').id;
                var conditionModelId = conditionId.split(':')[1];

                //this will create a trigger if there isn't one; there is only 1 per condition
                factory.createTriggerModel(conditionModelId);

                var trigType = item.id.split('Trig')[0];

                switch (trigType) {
                    case 'Trans':
                        model = factory.createTransactionModel(conditionModelId);
                        break;
                    case 'Hook':
                        model = factory.createWebhookModel(conditionModelId);
                        break;
                    default:
                        break;
                }

                elementId = conditionId + '_' + item.id + model.id;
            }

            //add to the index for easy access from controllers
            modelService.addElementToModelIndex(elementId, model);

            factory.createElement(target, directiveId, elementId);
        };

        factory.createElement = function (target, directiveName, elementId) {

            var newElement = angular.element(document.createElement(directiveName))
                                .attr('drop-active', 'true')
                                .attr('template_id', elementId);

            $compile(newElement)($rootScope);

            angular.element(target).append(newElement);

            console.debug('UPDATED MODEL: ' + JSON.stringify(modelService.templateModel));
        };

        factory.searchParentTree = function (el, idString) {
            while (el.parentNode) {
                el = el.parentNode;
                if ((el.id != null) && (el.id.indexOf(idString) > -1))
                    return el;
            }
            return null;
        };

        factory.createConditionModel = function () {
            var condition = modelService.createCondition();
            modelService.addCondition(condition);
            return condition;
        };

        // one trigger per condition
        factory.createTriggerModel = function (conditionModelId) {
            var trigger = modelService.getTrigger(conditionModelId);

            if (trigger == null) {
                trigger = modelService.createTrigger();
                modelService.addTrigger(conditionModelId, trigger);
            }

            return trigger;
        };

        factory.createTransactionModel = function (conditionModelId) {
            var transaction = modelService.createTransaction();
            return modelService.addTransactionToTrigger(conditionModelId, transaction);
        };

        factory.createWebhookModel = function (conditionModelId) {
            var webhook = modelService.createWebhook();
            return modelService.addWebhookToTrigger(conditionModelId, webhook);
        };

        return factory;
    };

    templateServiceFactory.$inject = injectParams;

    angular.module('accord.ly').factory('templateService', templateServiceFactory);

}());
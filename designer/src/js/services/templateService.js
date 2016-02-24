/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$rootScope', '$compile', 'templateModelService', 'modelIndexService'];

    var templateServiceFactory = function ($rootScope, $compile, templateModelService, modelIndexService) {
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

            console.log('templateServuce, insertItem:::', item, directiveId, target);

            var model;
            var elementId;

            if (item.id.indexOf('Cond:') > -1) {    // condition elements id format: eg 'SigCond:1'
                var condType = item.id.split('Cond')[0];

                switch(condType){
                    case 'Sms':
                        model = factory.createConditionModel('sms');
                        break;
                    case 'Sig':
                        model = factory.createConditionModel('signature');
                        break;
                    default:
                        break;
                }

                elementId = item.id + model.external_id;
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

                elementId = conditionId + '_' + item.id + model.external_id;
            }

            //add to the index to enable dictionary access from controllers
            modelIndexService.addElementToModelIndex(elementId, model);
            var element = factory.createDirectiveElement(directiveId, elementId);
            factory.insertElement(target, element);
        };

        factory.rebuildTemplateFromModel = function(){
            // get the current model
            var templateModel = templateModelService.currentTemplate;

            var rootElement = document.getElementById('TemplateTarget');

            //iterate through the conditions
            for(var x=0; x<templateModel.conditions.length; x++){
                var condition = templateModel.conditions[x];
                var conditionElement;
                var elementId;

                switch(condition.meta.type){
                    case 'sms':
                        elementId = 'SmsCond:' + condition.external_id;
                        conditionElement = factory.createSmsConditionElement(condition.external_id);
                        break;
                    case 'signature':
                        elementId = 'SigCond:' + condition.external_id;
                        conditionElement = factory.createSignatureConditionElement(condition.external_id);
                        break;
                    default:
                        break;
                }

                factory.insertElement(rootElement, conditionElement);
            }
        };

        factory.rebuildNestedElementsFromModel = function(parentElementId, parentElement, model){
            var triggerRootElement = parentElement.find('#TriggerPanel')[0];
            var element;

            if(model.trigger != null) {

                for (var i = 0; i < model.trigger.transactions.length; i++) {
                    var transaction = model.trigger.transactions[i];
                    element = factory.createTransactionTriggerElement(parentElementId, transaction.external_id);
                    factory.insertElement(triggerRootElement, element);
                }

                for (var x = 0; x < model.trigger.webhooks.length; x++) {
                    var webhook = model.trigger.webhooks[x];
                    element = factory.createWebhookTriggerElement(parentElementId, webhook.external_id);
                    factory.insertElement(triggerRootElement, element);
                }
            }
        };

        factory.insertElement = function (target, element) {
            var compiledElement = $compile(element)($rootScope);
            angular.element(target).append(element);
            return compiledElement;
        };

        /*
         Helpers
         */

        factory.createSignatureConditionElement = function(modelId){
            var elementId = 'SigCond:' + modelId;
            return factory.createDirectiveElement('templ-sig-cond', elementId);
        };

        factory.createSmsConditionElement = function(modelId){
            var elementId = 'SmsCond:' + modelId;
            return factory.createDirectiveElement('templ-sms-cond', elementId);
        };

        factory.createTransactionTriggerElement = function(conditionElementId, modelId){
            var elementId = conditionElementId + '_TransTrig:' + modelId;
            return factory.createDirectiveElement('templ-trans-trig', elementId);
        };

        factory.createWebhookTriggerElement = function(conditionElementId, modelId){
            var elementId = conditionElementId + '_HookTrig:' + modelId;
            return factory.createDirectiveElement('templ-hook-trig', elementId);
        };

        factory.createConditionSignatureElement = function(conditionElementId, modelId){
            var elementId = conditionElementId + '_Sig:' + modelId;
            return factory.createDirectiveElement('templ-sig', elementId);
        };

        factory.createDirectiveElement = function(directiveName, elementId){

            console.log('creating directive element:::', directiveName, elementId);

            return angular.element(document.createElement(directiveName))
                .attr('drop-active', 'true')
                .attr('template_id', elementId);
        };

        factory.searchParentTree = function (el, idString) {
            while (el.parentNode) {
                el = el.parentNode;
                if ((el.id != null) && (el.id.indexOf(idString) > -1))
                    return el;
            }
            return null;
        };

        /*
         CREATION OF MODEL INSTANCES
         */

        factory.createConditionModel = function (type) {
            var condition = templateModelService.createCondition();
            condition.meta.type = type;
            templateModelService.addCondition(condition);
            return condition;
        };

        // one trigger per condition
        factory.createTriggerModel = function (conditionModelId) {
            var trigger = templateModelService.getTrigger(conditionModelId);

            if (trigger == null) {
                trigger = templateModelService.createTrigger();
                templateModelService.addTrigger(conditionModelId, trigger);
            }

            return trigger;
        };

        factory.createTransactionModel = function (conditionModelId) {
            var transaction = templateModelService.createTransaction();
            return templateModelService.addTransactionToTrigger(conditionModelId, transaction);
        };

        factory.createWebhookModel = function (conditionModelId) {
            var webhook = templateModelService.createWebhook();
            return templateModelService.addWebhookToTrigger(conditionModelId, webhook);
        };

        return factory;
    };

    templateServiceFactory.$inject = injectParams;

    angular.module('accord.ly').factory('templateService', templateServiceFactory);

}());
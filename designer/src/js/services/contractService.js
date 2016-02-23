/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$rootScope', '$compile', 'contractModelService', 'modelIndexService'];

    var contractServiceFactory = function ($rootScope, $compile, contractModelService, modelIndexService) {
        var factory = {};

        factory.handleDrop = function (itemParent, item, directiveId, target) {
            var itemId = item.id;
            var parentId = itemParent.id;
            var targetId = target.id;

            //dont create new element if parent and target are the same
            if (parentId == targetId)
                return;

            //don't allow contacts inside contacts
            if ((itemId.indexOf('Cont:') > -1) && (factory.searchParentTree(target, 'Cont:') != null))
                return;

            factory.insertItem(item, directiveId, target);
        };

        //http://stackoverflow.com/questions/16656735/insert-directive-programatically-angular
        factory.insertItem = function (item, directiveId, target) {

            var modelId = item.id.split(':')[1];
            var conditionId = factory.searchParentTree(target, 'Cond:').id.split(':')[1];

            factory.createContactModel(conditionId, modelId);

            var element = factory.createContactElement(modelId);
            factory.insertElement(target, element);
        };

        factory.buildContractFromModel = function(contractModel){
            var rootElement = document.getElementById('ContractTarget');

            console.debug(JSON.stringify(contractModel));

            //iterate through the conditions
            for(var x=0; x<contractModel.conditions.length; x++){
                var condition = contractModel.conditions[x];
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

        // signatures are at the same level as triggers within the condition
        factory.rebuildContactElementsFromModel = function(parentElementId, parentElement, model){
            var contactRootElement = parentElement.find('#ContactPanel')[0];
            var element;

            if(model.signatures.length > 0) {

                for (var i = 0; i < model.signatures.length; i++) {
                    var signature = model.signatures[i];
                    element = factory.createContactElement(parentElementId, signature.external_id);
                    factory.insertElement(contactRootElement, element);
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
            return factory.createDirectiveElement('contr-sig-cond', elementId);
        };

        factory.createSmsConditionElement = function(modelId){
            var elementId = 'SmsCond:' + modelId;
            return factory.createDirectiveElement('contr-sms-cond', elementId);
        };

        factory.createContactElement = function (modelId) {
            var elementId = 'Cont:' + modelId;
            return factory.createDirectiveElement('contr-contact', elementId);
        };

        factory.createTransactionTriggerElement = function(conditionElementId, modelId){
            var elementId = conditionElementId + '_TransTrig:' + modelId;
            return factory.createDirectiveElement('contr-trans-trig', elementId);
        };

        factory.createWebhookTriggerElement = function(conditionElementId, modelId){
            var elementId = conditionElementId + '_HookTrig:' + modelId;
            return factory.createDirectiveElement('contr-hook-trig', elementId);
        };

        factory.createDirectiveElement = function(directiveName, elementId){
            return angular.element(document.createElement(directiveName))
                .attr('id', elementId);
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

        factory.createContactModel = function (conditionId, contactModelId) {
            var contact = contractModelService.createContact(contactModelId);
            contractModelService.addContactToParticipants(contact);
            contractModelService.addSignatureToCondition(conditionId, contact);

            return contact;

        };

        return factory;
    };

    contractServiceFactory.$inject = injectParams;


    angular.module('accord.ly').factory('contractService', contractServiceFactory);

}());
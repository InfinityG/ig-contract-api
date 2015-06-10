/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$rootScope', '$compile', 'modelService'];

    var templateServiceFactory = function ($rootScope, $compile, modelService) {
        var factory = {};

        factory.handleDrop = function (itemParent, item, target) {
            console.debug('ItemParent: ' + itemParent.id + ', Item: ' + item.id + ', Target: ' + target.id);

            //dont create new element if parent and target are the same
            if (itemParent.id == target.id)
                return;

            //ensure that only conditions (not triggers) are allowed in the main template
            if ((item.id.toLowerCase().indexOf('trigger') > -1) && (target.id.toLowerCase().indexOf('contract') > -1))
                return;

            //don't allow conditions inside conditions
            if ((item.id.toLowerCase().indexOf('condition') > -1) && (factory.searchParentTree(target, 'condition') != null))
                return;

            factory.insertItem(itemParent, item, target);
        };

        // TODO: finish this!
        factory.moveItem = function (itemParent, item, target) {
            angular.element(target).append(item);
        };

        //http://stackoverflow.com/questions/16656735/insert-directive-programatically-angular
        factory.insertItem = function (itemParent, item, target) {

            var directiveName = factory.getDirectiveName(item.id);
            var conditionModelId;
            var elementId;

            // are we dropping a condition?
            if (item.id.toLowerCase().indexOf('conditionpanel') > -1) {
                conditionModelId = factory.createConditionModel();
                elementId = item.id + '_' + conditionModelId;
            }

            // are we dropping a trigger into a condition?
            if (item.id.toLowerCase().indexOf('triggerpanel') > -1) {
                var conditionId = factory.searchParentTree(target, 'conditionpanel').id;
                conditionModelId = conditionId.split('_')[1];
                elementId = conditionId + '_' + item.id;

                factory.createTriggerModel(conditionModelId);

                //what type of trigger is this?
                if(item.id.toLowerCase().indexOf('transaction') > -1){
                    //create the model
                    var transaction = factory.createTransactionModel(conditionModelId);
                    //add to the index for easy access from controllers
                    modelService.addElementToModelIndex(elementId, conditionModelId, transaction);
                }
            }

            factory.createElement(target, directiveName, elementId);
        };

        factory.createElement = function (target, directiveName, elementId) {
            var newElement = angular.element(document.createElement(directiveName));

            newElement.attr('drop-active', 'true');
            newElement.attr('template_id', elementId);

            $compile(newElement)($rootScope);

            //append the new element to the target element
            angular.element(target).append(newElement);

            console.debug('UPDATED MODEL: ' + JSON.stringify(modelService.templateModel));
        };

        factory.getDirectiveName = function (itemName) {
            switch (itemName) {
                case 'signatureConditionPanel':
                    return 'signature-condition';
                case 'smsConditionPanel':
                    return 'sms-condition';
                case 'smsTriggerPanel':
                    return 'sms-trigger';
                case 'emailTriggerPanel':
                    return 'email-trigger';
                case 'transactionTriggerPanel':
                    return 'transaction-trigger';
                case 'webhookTriggerPanel':
                    return 'webhook-trigger';
                case 'mediaPanel':
                    return "media";
                default:
                    return null;
            }
        };

        factory.searchParentTree = function (el, idString) {
            while (el.parentNode) {
                el = el.parentNode;
                if ((el.id != null) && (el.id.toLowerCase().indexOf(idString) > -1))
                    return el;
            }
            return null;
        };

        factory.createConditionModel = function () {
            var model = modelService.createCondition();
            return modelService.addCondition(model);
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

        factory.createTransactionModel = function(conditionModelId){
            var transaction = modelService.createTransaction();
            return modelService.addTransactionToTrigger(conditionModelId, transaction);
        };

        return factory;
    };

    templateServiceFactory.$inject = injectParams;

    angular.module('accord.ly').factory('templateService', templateServiceFactory);

}());
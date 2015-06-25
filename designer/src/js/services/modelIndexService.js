/**
 * Created by grant on 19/01/2015.

 * This service is used for the creation and assembly of models.
 * It is NOT used for storing model instances - this is handled by the localStorageService
 */

(function () {

    var injectParams = ['$http', '$rootScope'];

    var modelIndexFactory = function ($http, $rootScope) {

        var factory = {};

        // index should only contain the key:value pairs related to the currently loaded template
        factory.modelElementIndex = {};
        factory.contactModelElementIndex = {};

        // index should only contain the key:value pairs related to the currently loaded template
        factory.rebuildIndex = function (rootModel) {
            factory.modelElementIndex = {};

            if (rootModel != null && rootModel.conditions.length > 0) {
                for (var x = 0; x < rootModel.conditions.length; x++) {
                    var currentCondition = rootModel.conditions[x];
                    var conditionKey;

                    switch (currentCondition.meta.type) {
                        case 'sms':
                            conditionKey = 'SmsCond:' + currentCondition.external_id;
                            break;
                        case 'signature':
                            conditionKey = 'SigCond:' + currentCondition.external_id;
                            break;
                    }

                    factory.addElementToModelIndex(conditionKey, currentCondition);

                    if (currentCondition.trigger != null) {
                        if (currentCondition.trigger.transactions != null) {
                            for (var i = 0; i < currentCondition.trigger.transactions.length; i++) {
                                var currentTransaction = currentCondition.trigger.transactions[i];
                                var triggerKey = conditionKey + '_TransTrig:' + currentTransaction.external_id;
                                factory.addElementToModelIndex(triggerKey, currentTransaction);
                            }
                        }

                        if (currentCondition.trigger.webhooks != null) {
                            for (var i = 0; i < currentCondition.trigger.webhooks.length; i++) {
                                var currentWebhook = currentCondition.trigger.webhooks[i];
                                var webhookKey = conditionKey + '_HookTrig:' + currentWebhook.external_id;
                                factory.addElementToModelIndex(webhookKey, currentWebhook);
                            }
                        }
                    }
                }
            }
        };

        factory.rebuildContactIndex = function (contacts) {
            factory.contactModelElementIndex = {};

            for(var x=0; x<contacts.length; x++){
                factory.addElementToContactModelIndex('Cont:' + contacts[x].id, contacts[x]);
            }
        };

        factory.addElementToModelIndex = function (elementId, model) {
            factory.modelElementIndex[elementId] = model;
        };

        factory.addElementToContactModelIndex = function (elementId, model) {
            factory.contactModelElementIndex[elementId] = model;
        };

        return factory;
    };

    modelIndexFactory.$inject = injectParams;

    angular.module('accord.ly').factory('modelIndexService', modelIndexFactory);

}());
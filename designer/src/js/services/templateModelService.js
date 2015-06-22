/**
 * Created by grant on 19/01/2015.

 * This service is used for the creation and assembly of models.
 * It is NOT used for storing model instances - this is handled by the localStorageService
 */

(function () {

    var injectParams = ['$http', '$rootScope'];

    var templateModelFactory = function ($http, $rootScope) {

        var factory = {};

        // index should only contain the key:value pairs related to the currently loaded template
        factory.modelElementIndex = {};

        // the current template instance
        factory.currentTemplate = null;

        /*
         Base models to clone
         */

        factory.baseTemplateModel = {
            'external_id': null,
            'name': null,
            'description': null,
            'conditions': [],
            'signatures': [],
            'media': []
        };

        factory.signatureModel = {
            'external_id': '',
            'meta': {
                'type': null,
                'sub_type': null
            }
            //'participant_external_id': '',
            //'delegated_by_external_id': '',
            //'value': '',
            //'digest': ''
        };

        factory.transactionModel = {
            'external_id': '',
            'amount': '',
            'meta': {
                'from': null,
                'to': null
            }
        };

        factory.webhookModel = {
            'external_id': '',
            'uri': ''
        };

        factory.triggerModel = {
            'external_id': '',
            'transactions': [],
            'webhooks': [],
            'meta': {
                'type': null,
                'sub_type': null
            }
        };

        factory.conditionModel = {
            'external_id': null,
            'name': null,
            'description': null,
            'signatures': [],
            'trigger': null,
            'meta': {
                'type': null,
                'sub_type': null
            }
        };

        /*
         Models used for UI field values
         */

        factory.viewModel =
        {
            'conditions': {
                'signature': {
                    'fields': {
                        'single': 'Single participant',
                        'specific': 'Specific participants',
                        'all_group': 'All participants in a group',
                        'all': 'All participants',
                        'external': 'External system'
                    }
                },
                'sms': {
                    'fields': {
                        'single': 'Single participant',
                        'specific': 'Specific participants',
                        'all_group': 'All participants in a group',
                        'all': 'All participants'
                    }
                }
            }
            ,
            'triggers': {
                'transaction': {
                    'fields': {
                        'from': {
                            'creator': 'Creator wallet',
                            'specific': 'Specific participant wallet'
                        },
                        'to': {
                            'specific': 'Specific participant wallet',
                            'all': 'All participant wallets'
                        },
                        'amount': 'Amount'
                    }
                }
                ,
                'webhook': {
                    'fields': {
                        'url': 'Url',
                        'auth_header': 'Auth Header',
                        'action': 'Action',
                        'payload': 'Payload'
                    }
                }
            }

        };

        factory.createClone = function (type) {
            return JSON.parse(JSON.stringify(type));
        };

        /*
         Main template
         */

        factory.createTemplate = function () {
            return factory.createClone(factory.baseTemplateModel);
        };

        factory.setCurrentTemplate = function (template) {
            factory.currentTemplate = template;
        };

        // index should only contain the key:value pairs related to the currently loaded template
        factory.rebuildIndex = function () {
            factory.modelElementIndex = {};

            if (factory.currentTemplate != null && factory.currentTemplate.conditions.length > 0) {
                for (var x = 0; x < factory.currentTemplate.conditions.length; x++) {
                    var currentCondition = factory.currentTemplate.conditions[x];
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

        /*
         Conditions
         */

        factory.createCondition = function () {
            return factory.createClone(factory.conditionModel);
        };

        factory.addCondition = function (condition) {
            condition.external_id = factory.currentTemplate.conditions.length + 1;
            factory.currentTemplate.conditions.push(condition);

            raiseModelChanged();

            return condition.external_id;
        };

        factory.getCondition = function (conditionId) {
            for (var x = 0; x < factory.currentTemplate.conditions.length; x++) {
                if (factory.currentTemplate.conditions[x].external_id == conditionId)
                    return factory.currentTemplate.conditions[x];
            }

            return null;
        };

        factory.removeCondition = function (conditionId) {
            for (var x = 0; x < factory.currentTemplate.conditions.length; x++) {
                if (factory.currentTemplate.conditions[x].external_id == conditionId) {
                    factory.currentTemplate.conditions.splice(x, 1);
                    break;
                }
            }

            raiseModelChanged();
        };

        /*
         Triggers
         */

        factory.createTrigger = function () {
            return factory.createClone(factory.triggerModel);
        };

        factory.addTrigger = function (conditionId, trigger) {
            var condition = factory.getCondition(conditionId);

            if (condition != null)
                condition.trigger = trigger;

            raiseModelChanged();
        };

        factory.getTrigger = function (conditionId) {
            var condition = factory.getCondition(conditionId);

            if (condition != null)
                return condition.trigger;

            return null;
        };

        factory.removeTrigger = function (conditionId) {
            var condition = factory.getCondition(conditionId);

            if (condition != null)
                condition.trigger = null;

            raiseModelChanged();
        };

        /*
         Transactions
         */

        factory.createTransaction = function () {
            return factory.createClone(factory.transactionModel);
        };

        factory.addTransactionToTrigger = function (conditionId, transaction) {
            var condition = factory.getCondition(conditionId);

            if (condition != null) {
                var trigger = condition.trigger;

                if (trigger != null) {
                    transaction.external_id = trigger.transactions.length + 1;
                    trigger.transactions.push(transaction);

                    raiseModelChanged();

                    return transaction;
                }
            }

            return null;
        };

        factory.getTransaction = function (conditionId, transactionId) {
            var condition = factory.getCondition(conditionId);

            if (condition != null) {
                var trigger = condition.trigger;

                for (var x = 0; x < trigger.transactions.length; x++) {
                    if (trigger.transactions[x].external_id == transactionId)
                        return trigger.transactions[x];
                }
            }

            return null;
        };

        factory.deleteTransaction = function (parentConditionId, transactionId) {
            var condition = factory.getCondition(parentConditionId);

            if (condition != null) {

                for (var x = 0; x < condition.trigger.transactions.length; x++) {
                    if (condition.trigger.transactions[x].external_id == transactionId) {
                        condition.trigger.transactions.splice(x, 1);
                        break;
                    }
                }
            }

            raiseModelChanged();
        };

        /*
         Webhooks
         */

        factory.createWebhook = function () {
            return factory.createClone(factory.webhookModel);
        };

        factory.addWebhookToTrigger = function (conditionId, webhook) {
            var condition = factory.getCondition(conditionId);

            if (condition != null) {
                var trigger = condition.trigger;

                if (trigger != null) {
                    webhook.external_id = trigger.webhooks.length + 1;
                    trigger.webhooks.push(webhook);

                    raiseModelChanged();

                    return webhook;
                }
            }

            return null;
        };

        factory.getWebhook = function (conditionId, webhookId) {
            var condition = factory.getCondition(conditionId);

            if (condition != null) {
                var trigger = condition.trigger;

                for (var x = 0; x < trigger.webhooks.length; x++) {
                    if (trigger.webhooks[x].external_id == webhookId)
                        return trigger.webhooks[x];
                }
            }

            return null;
        };

        factory.deleteWebhook = function (parentConditionId, webhookId) {
            var condition = factory.getCondition(parentConditionId);

            if (condition != null) {
                for (var x = 0; x < condition.trigger.webhooks.length; x++) {
                    if (condition.trigger.webhooks[x].external_id == webhookId) {
                        condition.trigger.webhooks.splice(x, 1);
                        break;
                    }
                }
            }

            raiseModelChanged();
        };

        /*
         Model-element index (the model field simply stores a reference to the original model,
         so there is no memory overhead)
         */

        factory.addElementToModelIndex = function (elementId, model) {
            factory.modelElementIndex[elementId] = model;
        };

        factory.stringifyModel = function (model) {
            return JSON.stringify(model, null, 2);
        };

        /*
         Events
         */

        function raiseModelChanged() {
            $rootScope.$broadcast('templateModelEvent', null);
        }

        //factory.init();

        return factory;
    };

    templateModelFactory.$inject = injectParams;

    angular.module('accord.ly').factory('templateModelService', templateModelFactory);

}());
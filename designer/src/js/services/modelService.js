/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', '$location'];

    var modelFactory = function ($http, $rootScope, $location) {
        var factory = {};

        factory.modelElementIndex = {};

        factory.templateModel = {'name': null, 'description': null, 'conditions': [], 'signatures': [], 'media': []};

        factory.stringifiedModel = {'json':null};

        factory.signatureModel = {
            'id': '',
            'place_holder': ''
            //'participant_external_id': '',
            //'delegated_by_external_id': '',
            //'value': '',
            //'digest': ''
        };

        factory.transactionModel = {
            'id': '',
            'from_place_holder': '',
            'to_place_holder': '',
            'amount': ''
        };

        factory.webhookModel = {
            'id': '',
            'uri': ''
        };

        factory.triggerModel = {
            'id': '',
            'transactions': [],
            'webhooks': []
        };

        factory.conditionModel = {
            'id': '',
            'name': '',
            'description': '',
            'sequence_number': '',
            'signatures': [],
            'status': '',
            'trigger': null,
            'expires': ''
        };

        factory.viewModel =
        {
            'conditions': {
                'signature': {
                    'fields': {
                        'sig_single': 'Single participant',
                        'sig_specific': 'Specific participants',
                        'sig_all_group': 'All participants in a group',
                        'sig_all': 'All participants',
                        'sig_external': 'External system'
                    }
                },
                'sms': {
                    'fields': {
                        'sms_single': 'Single participant',
                        'sms_specific': 'Specific participants',
                        'sms_all_group': 'All participants in a group',
                        'sms_all': 'All participants'
                    }
                }
            }
            ,
            'triggers': {
                'transaction': {
                    'fields': {
                        'from_creator': 'Creator wallet',
                        'from_specific': 'Specific participant wallet',
                        'to_specific': 'Specific participant wallet',
                        'to_all': 'All participant wallets',
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
         Conditions
         */

        factory.createCondition = function () {
            return factory.createClone(factory.conditionModel);
        };

        factory.addCondition = function (condition) {
            condition.id = factory.templateModel.conditions.length + 1;
            factory.templateModel.conditions.push(condition);

            factory.stringifyModel();

            return condition.id;
        };

        factory.getCondition = function (conditionId) {
            for (var x = 0; x < factory.templateModel.conditions.length; x++) {
                if (factory.templateModel.conditions[x].id == conditionId)
                    return factory.templateModel.conditions[x];
            }

            return null;
        };

        factory.removeCondition = function (conditionId) {
            for (var x = 0; x < factory.templateModel.conditions.length; x++) {
                if (factory.templateModel.conditions[x].id == conditionId) {
                    factory.templateModel.conditions.splice(x, 1);
                    break;
                }
            }

            factory.stringifyModel();
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

            factory.stringifyModel();
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

            factory.stringifyModel();
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
                    transaction.id = trigger.transactions.length + 1;
                    trigger.transactions.push(transaction);

                    factory.stringifyModel();

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
                    if (trigger.transactions[x].id == transactionId)
                        return trigger.transactions[x];
                }
            }

            return null;
        };

        factory.deleteTransaction = function (parentConditionId, transactionId) {
            var condition = factory.getCondition(parentConditionId);

            if (condition != null) {
                console.debug('Condition id: ' + parentConditionId + ', Transaction id: ' + transactionId);

                for (var x = 0; x < condition.trigger.transactions.length; x++) {
                    if (condition.trigger.transactions[x].id == transactionId) {
                        condition.trigger.transactions.splice(x, 1);
                        break;
                    }
                }
            }

            factory.stringifyModel();
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
                    webhook.id = trigger.webhooks.length + 1;
                    trigger.webhooks.push(webhook);

                    factory.stringifyModel();

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
                    if (trigger.webhooks[x].id == webhookId)
                        return trigger.webhooks[x];
                }
            }

            return null;
        };

        factory.deleteWebhook = function (parentConditionId, webhookId) {
            var condition = factory.getCondition(parentConditionId);

            if (condition != null) {
                for (var x = 0; x < condition.trigger.webhooks.length; x++) {
                    if (condition.trigger.webhooks[x].id == webhookId) {
                        condition.trigger.webhooks.splice(x, 1);
                        break;
                    }
                }
            }

            factory.stringifyModel();
        };

        /*
         Model-element index (the model field simply stores a reference to the original model,
         so there is no memory overhead)
         */

        factory.addElementToModelIndex = function (elementId, model) {
            factory.modelElementIndex[elementId] = model;
        };

        factory.stringifyModel = function(){
            factory.stringifiedModel.json = JSON.stringify(factory.templateModel, null, 2);
            console.debug(factory.stringifiedModel.josn);
        };

        factory.init = function () {
            factory.stringifyModel();
        };

        factory.init();

        return factory;
    };

    modelFactory.$inject = injectParams;

    angular.module('accord.ly').factory('modelService', modelFactory);

}());
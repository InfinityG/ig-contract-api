/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', '$location'];

    var modelFactory = function ($http, $rootScope, $location) {
        var factory = {};

        factory.modelElementIndex = {};

        factory.templateModel = {'conditions': [], 'signatures': [], 'media': []};

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

                    return transaction;
                }
            }

            return null;
        };

        factory.getTransaction = function(conditionId, transactionId){
           var condition = factory.getCondition(conditionId);

            if (condition != null) {
                var trigger = condition.trigger;

                for(var x=0; x<trigger.transactions.length; x++){
                    if(trigger.transactions[x].id == transactionId)
                        return trigger.transactions[x];
                }
            }

            return null;
        } ;

        factory.deleteTransaction = function(parentConditionId, transactionId){
            var condition = factory.getCondition(parentConditionId);

            if(condition != null){
                console.debug('Condition id: ' + parentConditionId + ', Transaction id: ' + transactionId);

                for(var x=0; x<condition.trigger.transactions.length; x++){
                    if(condition.trigger.transactions[x].id == transactionId) {
                        condition.trigger.transactions.splice(x, 1);
                        break;
                    }
                }
            }
        };

        /*
        Model-element index
         */

        factory.addElementToModelIndex = function(elementId, parentModelId, model){
            factory.modelElementIndex[elementId] = {'parentId':parentModelId, 'model':model};
        };

        factory.init = function () {

        };

        return factory;
    };

    modelFactory.$inject = injectParams;

    angular.module('accord.ly').factory('modelService', modelFactory);

}());
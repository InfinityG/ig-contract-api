/**
 * Created by grant on 19/01/2015.

 * This service is used for the creation and assembly of models.
 * It is NOT used for storing model instances - this is handled by the localStorageService
 */

(function () {

    var injectParams = ['$http', '$rootScope', 'contactService'];

    var contractModelFactory = function ($http, $rootScope, contactService) {

        var factory = {};

        // the current template instance
        factory.currentContract = null;

        factory.createClone = function (type) {
            return JSON.parse(JSON.stringify(type));
        };

        factory.setCurrentContract = function (contract) {
            factory.currentContract = contract;
        };

        /*
         Conditions
         */

        factory.getCondition = function (conditionId) {
            for (var x = 0; x < factory.currentContract.conditions.length; x++) {
                if (factory.currentContract.conditions[x].external_id == conditionId)
                    return factory.currentContract.conditions[x];
            }

            return null;
        };

        /*
         Triggers
         */

        factory.getTrigger = function (conditionId) {
            var condition = factory.getCondition(conditionId);

            if (condition != null)
                return condition.trigger;

            return null;
        };

        /*
         Transactions
         */

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

        /*
         Webhooks
         */

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

        /* Contacts */

        factory.createContact = function(contactId){
            var contact = contactService.getContact(contactId);
            return factory.createClone(contact);
        };

        factory.addContactsToParticipants = function (contacts) {
            for (var x = 0; x < contacts.length; x++) {
                factory.addContactToParticipants(contacts[x]);
            }
        };

        factory.addContactToParticipants = function (contact) {
            var currentParticipants = factory.currentContract.participants;

            //skip participant if it already exists
            for (var i = 0; i < currentParticipants.length; i++) {
                if (currentParticipants[i].external_id == contact.id)
                    return;
            }

            var participant = {
                'external_id': contact.id,
                'public_key': contact.public_key
            };

            currentParticipants.push(participant);
        };


        /* Signatures */

        factory.addSignaturesToCondition = function (conditionId, contacts) {
            var condition = factory.getCondition(conditionId);

            for (var x = 0; x < contacts.length; x++) {

                var signature = {
                    'participant_external_id': contacts[x].id
                };

                condition.signatures.push(signature);
            }
        };

        factory.addSignatureToCondition = function (conditionId, contact) {
            var condition = factory.getCondition(conditionId);

            var signature = {
                    'participant_external_id': contact.id
            };

            condition.signatures.push(signature);

            raiseModelChanged();
        };

        /* JSON stringification */

        factory.stringifyModel = function (model) {
            return JSON.stringify(model, null, 2);
        };

        /*
         Events
         */

        function raiseModelChanged() {
            $rootScope.$broadcast('contractModelEvent', null);
        }

        return factory;
    };

    contractModelFactory.$inject = injectParams;

    angular.module('accord.ly').factory('contractModelService', contractModelFactory);

}());
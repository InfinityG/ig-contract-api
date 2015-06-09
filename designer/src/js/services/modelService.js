/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', '$location'];

    var modelFactory = function ($http, $rootScope, $location) {
        var factory = {};

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
            'from_participant_external_id': '',
            'to_participant_external_id': '',
            'amount': '',
            'currency': '',
            'status': '',
            'ledger_transaction_hash': ''
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

        factory.addCondition = function (condition) {
            condition.id = factory.templateModel.conditions.length + 1;
            factory.templateModel.conditions.push(condition);
        };

        factory.removeCondition = function (conditionId) {
            for (var x = 0; x < factory.templateModel.conditions.length; x++) {
                if (factory.templateModel.conditions[x].id == conditionId) {
                    factory.templateModel.conditions.splice(x, 1);
                    break;
                }
            }
        };

        factory.init = function () {

        };

        return factory;
    };

    modelFactory.$inject = injectParams;

    angular.module('accord.ly').factory('modelService', modelFactory);

}());
/**
 * Created by grant on 19/01/2015.

 * This service is used for the creation and assembly of models.
 * It is NOT used for storing model instances - this is handled by the localStorageService
 */

(function () {

    var viewModelFactory = function () {

        var factory = {};

        /*
         Models used for UI field values
         */

        factory.viewModel =
        {
            'conditions': {
                'signature': {
                    'fields': {
                        //'creator': 'Agreement creator',
                        'single': 'Single contact',
                        'multiple': 'Multiple contacts',
                        //'all_group': 'All contacts in a group',
                        'all': 'All contacts',
                        //'external': 'External system'
                    }
                },
                'sms': {
                    'fields': {
                        'single': 'Single contact',
                        'multiple': 'Multiple contacts',
                        //'all_group': 'All contacts in a group',
                        'all': 'All contacts'
                    }
                }
            }
            ,
            'triggers': {
                'transaction': {
                    'fields': {
                        'from': {
                            'creator': 'Creator wallet',
                            'specific': 'Specific contact wallet'
                        },
                        'to': {
                            'specific': 'Specific contact wallet',
                            'all': 'All contact wallets'
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

       //factory.init();

        return factory;
    };

    angular.module('accord.ly').factory('viewModelService', viewModelFactory);

}());
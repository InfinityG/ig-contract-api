/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', 'config', 'userService', 'localStorageService'];

    var contactFactory = function ($http, $rootScope, config, userService, localStorageService) {

        var identityBase = config.identityHost, factory = {};

        factory.getContacts = function () {
            var context = userService.getContext();
            var userId = context.userId;

            return localStorageService.getContacts(userId);
        };

        factory.refreshContacts = function (userId, username) {
            return $http.get(identityBase + '/users/associations/' + username, {'withCredentials': false})
                .then(function (response) {
                    var data = response.data;
                    localStorageService.saveContacts(userId, data);

                    $rootScope.$broadcast('contactsEvent', {
                        type: 'Success',
                        status: response.status,
                        message: 'Contacts updated'
                    });
                });
        };

        return factory;
    };

    contactFactory.$inject = injectParams;

    angular.module('accord.ly').factory('contactService', contactFactory);

}());
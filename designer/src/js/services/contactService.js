/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', 'constants', 'userService', 'localStorageService'];

    var contactFactory = function ($http, $rootScope, constants, userService, localStorageService) {

        var identityBase = constants.idioApiHost, factory = {};

        factory.getContacts = function () {
            var context = userService.getContext();
            var userId = context.userId;

            return localStorageService.getContacts(userId);
        };

        factory.getContact = function (contactId) {
            var context = userService.getContext();
            var userId = context.userId;

            return localStorageService.getContact(userId, contactId);
        };

        factory.saveContacts = function (userId, data) {
            localStorageService.saveContacts(userId, data);
        };

        factory.refreshContacts = function (userId) {
            var context = userService.getContext();

            // this request is fired at ID-IO to retrieve the associated contacts for this user
            return $http.get(identityBase + '/connections', {
                headers: {'Authorization': context.idioToken}
            })
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
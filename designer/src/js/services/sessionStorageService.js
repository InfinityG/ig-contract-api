/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = [];

    var sessionStorageFactory = function () {

        var factory = {};

        factory.getAuthToken = function(){
            return JSON.parse(sessionStorage.getItem('accordly.token'));
        };

        factory.saveAuthToken = function(username, userId, externalId, role, token, idioToken){
            return sessionStorage.setItem('accordly.token', JSON.stringify({username: username, userId: userId,
                externalId : externalId, role: role, token: token, idioToken: idioToken}));
        };

        factory.deleteAuthToken = function(){
            return sessionStorage.removeItem('accordly.token');
        };

        return factory;
    };

    sessionStorageFactory.$inject = injectParams;

    angular.module('accord.ly').factory('sessionStorageService', sessionStorageFactory);

}());
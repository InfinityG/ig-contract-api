/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', '$location'];

    var configValue = {
        //apiHost: 'http://54.154.155.144:9000',
        //identityHost: 'http://54.154.155.144:9002',
    };

    var initializationFactory = function ($http, $rootScope, $location) {
        var factory = {};

        factory.init = function(){

        };

        return factory;
    };

    initializationFactory.$inject = injectParams;

    angular.module('accord.ly').value('config', configValue);
    angular.module('accord.ly').factory('initializationService', initializationFactory);

}());
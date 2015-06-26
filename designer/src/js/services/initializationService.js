/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', '$location', 'userService', 'contactService', 'blobService'];

    var configValue = {
        //apiHost: 'http://54.154.155.144:9000',
        //identityHost: 'http://54.154.155.144:9002',

        apiHost: 'https://accord.ly.infinity-g.com',
        identityHost: 'https://id-io.infinity-g.com',
        confirmMobile: false,
        nacl: '9612700b954743e0b38f2faff35d264c'
    };

    var initializationFactory = function ($http, $rootScope, $location, userService, contactService, blobService) {
        var factory = {};

        factory.init = function(){
            factory.start(null);
            factory.setupListener();
        };

        factory.start = function(key){
            $http.defaults.withCredentials = false; //this is so that we can use '*' in allowed-origin

            var context = userService.getContext();

            if(context != null){
                factory.initializeAuthHeaders(context);
                factory.initializeBlob(key);
            }
        };

        factory.initializeAuthHeaders = function(context){
            $http.defaults.headers.common['Authorization'] = context.token;
            //$http.defaults.withCredentials = true;
        };

        factory.initializeBlob = function(key){
            if(blobService.getBlob() == null) {
                var userBlob = blobService.getBlobTemplate(key);
                blobService.saveBlob(userBlob);
            }
        };

        //TODO: clean up $rootScope listeners
        factory.setupListener = function() {
            $rootScope.$on('loginEvent', function (event, args) {
                factory.start(args.key);
                contactService.refreshContacts(args.userId, args.username);
            });

            $rootScope.$on('contactsEvent', function (event, args) {
                console.debug('Contacts refreshed');
                $location.path('/');
            });

            $rootScope.$on('registrationEvent', function (event, args) {
                contactService.refreshContacts(args.userId, args.username);
            });
        };

        return factory;
    };

    initializationFactory.$inject = injectParams;

    angular.module('accord.ly').value('config', configValue);
    angular.module('accord.ly').factory('initializationService', initializationFactory);

}());
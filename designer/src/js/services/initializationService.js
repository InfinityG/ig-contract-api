/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', '$location', '$window', '$routeParams', 'userService',
        'contactService', 'blobService'];

    var constants = {
        //apiHost: 'https://accordly.infinity-g.com',
        apiHost: 'http://localhost:8002',
        //idioApiHost: 'https://id-io.infinity-g.com',
        idioApiHost: 'http://localhost:9002',
        idioWalletHost: 'http://localhost:8000',
        loginDomain: 'accord.ly',
        confirmMobile: false,
        nacl: '9612700b954743e0b38f2faff35d264c',
        fingerprint: null
    };

    var initializationFactory = function ($http, $rootScope, $location, $window, $routeParams, userService,
                                          contactService, blobService) {
        var factory = {};

        factory.init = function(){
            console.debug('Initializing...');

            factory.setupListener();
            factory.start(null);
        };

        factory.start = function(key){
            var context = userService.getContext();

            $http.defaults.withCredentials = false; //this is so that we can use '*' in allowed-origin

            if(context != null){
                factory.initializeAuthHeaders(context);
                factory.initializeBlob(key);
            }else {
                factory.getFingerprint();
            }
        };

        factory.getFingerprint = function(){
            new $window.Fingerprint2().get(function(result){
                constants.fingerprint = result;
            });
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

            // ensures that any change of route checks for login status
            $rootScope.$on('$locationChangeStart', function (event, next, current) {
                var context = userService.getContext();

                if(context == null && (next.indexOf('/sso/') < 0)){
                    $window.location.href = constants.idioWalletHost;
                    event.preventDefault();
                }
            });

            $rootScope.$on('loginEvent', function (event, args) {
                factory.start(args.key);
                contactService.refreshContacts(args.userId, args.username);
                $location.path('/');
            });

            $rootScope.$on('logoutEvent', function (event, args) {
                $window.location.href = constants.idioWalletHost;
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

    angular.module('accord.ly').value('constants', constants);
    angular.module('accord.ly').factory('initializationService', initializationFactory);

}());
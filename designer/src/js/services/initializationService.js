/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', '$location', '$window', '$routeParams', 'userService',
        'contactService', 'blobService'];

    var constants = {
        mockMode: true,
        //apiHost: 'https://accordly.infinity-g.com',
        apiHost: 'http://localhost:8002',
        //idioApiHost: 'https://id-io.infinity-g.com',
        idioApiHost: 'http://localhost:9002',
        idioWalletHost: 'http://localhost:8000',
        //loginDomain: 'accord.ly',
        loginDomain: 'http://localhost:8002',
        confirmMobile: false,
        nacl: '9612700b954743e0b38f2faff35d264c',
        fingerprint: null
    };

    var initializationFactory = function ($http, $rootScope, $location, $window, $routeParams, userService,
                                          contactService, blobService) {
        var factory = {};

        factory.init = function () {
            console.debug('Initializing...');

            factory.setupListener();
            factory.start(null);

            //initialise mocks
            if (constants.mockMode) {
                factory.initialiseMocks();//this gets run now - frst time
            }

        };

        factory.start = function (key) {
            var context = userService.getContext();//fetch the login credentials

            $http.defaults.withCredentials = false; //this is so that we can use '*' in allowed-origin

            if (context != null) {
                factory.initializeAuthHeaders(context);
                factory.initializeBlob(key);

                if (!constants.mockMode)
                    contactService.refreshContacts(context.userId, context.username);
            } else {
                factory.getFingerprint();//not relevant as of yet - for checking the session isnt hijacked - added as user side token
            }
        };

        factory.initialiseMocks = function () {

            // mock user context
            var userId = "12312313123";
            var userName = "TestUser";
            var externalId = "9999999";
            var token = "hef8178yn10yfn0193yf80193p8fn1";

            var context = {
                "userId": userId,
                "username": userName,
                "externalId": externalId,
                "token": token
            };

            //saves token to blob
            userService.saveToken(userName, userId, externalId, '', token, token);

            // mock contacts for user
            var contacts = [{
                "id": "558c020ba574d90018000014",
                "username": "superman",
                "first_name": "Super",
                "last_name": "Man",
                "role": null,
                "public_key": "AyI6IN34Fe24MLqkfmykpZCRGmjVuKj2Ad73A2wNC6ix",
                "status": "connected"
            }, {
                "id": "558c2fcea574d90018000016",
                "username": "brucebanner",
                "first_name": "The",
                "last_name": "Hulk",
                "role": null,
                "public_key": "AwiEaHy7TJrB/vzeMwsmPEwgCIa7GwO8Rh5YjaeJ6hv9",
                "status": "connected"
            }];

            //saves contacts to blob
            contactService.saveContacts(userId, contacts);

            $rootScope.$broadcast('loginEvent', context);// this gets consumed further down

        };

        factory.getFingerprint = function () {
            new $window.Fingerprint2().get(function (result) {
                constants.fingerprint = result;
            });
        };

        factory.initializeAuthHeaders = function (context) {
            $http.defaults.headers.common['Authorization'] = context.token;
            //$http.defaults.withCredentials = true;
        };

        factory.initializeBlob = function (key) {
            if (blobService.getBlob() == null) {
                var userBlob = blobService.getBlobTemplate(key);
                blobService.saveBlob(userBlob);
            }
        };

        //TODO: clean up $rootScope listeners
        factory.setupListener = function () {

            // ensures that any change of route checks for login status
            $rootScope.$on('$locationChangeStart', function (event, next, current) {
                var context = userService.getContext();

                if (context == null && (next.indexOf('/sso/') < 0)) {
                    console.debug('Navigating to identity provider...');
                    $window.location.href = constants.idioWalletHost;
                    event.preventDefault();
                }
            });

            $rootScope.$on('loginEvent', function (event, args) {
                factory.start(args.key);//now we have a context - so rerun
                $location.path('/');
            });

            $rootScope.$on('logoutEvent', function (event, args) {
                $window.location.href = constants.idioWalletHost;
            });

            //$rootScope.$on('contactsEvent', function (event, args) {
            //    console.debug('Contacts refreshed');
            //    $location.path('/');
            //});

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
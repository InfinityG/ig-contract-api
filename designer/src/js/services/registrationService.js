/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', '$rootScope', 'config', 'userService'];

    var registrationFactory = function ($http, $rootScope, config, userService) {

        var identityBase = config.identityHost, nacl = config.nacl, confirmMobile = config.confirmMobile, factory = {};

        factory.register = function (firstName, lastName, userName, password, mobile, role) {

            var context = userService.getContext();

            var registrar = context != null ? context.username : null;

            var userData = {first_name: firstName, last_name: lastName, username: userName, password: password,
                mobile_number: mobile, confirm_mobile: confirmMobile, role: role, registrar: registrar};

            return $http.post(identityBase + '/users', userData, {'withCredentials': false})
                .then(function (response) {
                    //var data = response.data;
                    //sessionStorageService.saveAuthToken(data.id, data.token);
                    //var cryptoKey = keyService.generateAESKey(userData.password, nacl);

                    //emit this to be used for encrypting newly generated secret signing keys
                    //$rootScope.$broadcast('registrationEvent', {userId: data.id, key: cryptoKey});

                    $rootScope.$broadcast('registrationEvent', {userId:context.userId, username:context.username});
                });
        };

        return factory;
    };

    registrationFactory.$inject = injectParams;

    angular.module('accord.ly').factory('registrationService', registrationFactory);

}());
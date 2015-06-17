/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$http', 'userService', 'keyService', 'cryptoService', 'localStorageService'];

    var blobFactory = function ($http, userService, keyService, cryptoService, localStorageService) {

        var factory = {};

        factory.getBlob = function () {
            var userId = userService.getContext().userId;
            return localStorageService.getBlob(userId);
        };

        factory.saveBlob = function (blob) {
            var context = userService.getContext();
            var userId = context.userId;

            localStorageService.saveBlob(userId,blob);
        };

        // generate a new local blob after a userId is received from registration process
        // we need a crypto key to encrypt the secret key on the signing pair
        factory.getBlobTemplate = function (cryptoKey) {
            var keys = keyService.generateSigningKeyPair();

            //encrypt the secret key
            keys.sk = cryptoService.encryptString(cryptoKey, keys.sk);

            return {
                contacts: [],
                templates:[],
                contracts: [],
                keys: keys,
                ssKeys: null,
                wallet: null

            };
        };

        return factory;
    };

    blobFactory.$inject = injectParams;

    angular.module('accord.ly').factory('blobService', blobFactory);

}());
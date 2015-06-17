(function () {
    var injectParams = ['localStorageService', 'sessionStorageService'];

    var keyFactory = function (localStorageService, sessionStorageService) {

        var factory = {};

        /*
         WALLET SECRET KEY SHARING
         */

        factory.getSplitWalletSecret = function (wallet) {
            var secret = wallet.secret;
            var result = secrets.share(secrets.str2hex(secret), 2, 2);

            //var str1 = result[0].toString('base64');
            //var str2 = result[1].toString('base64');

            return result;
        };

        factory.saveSsPair = function (ssPair) {
            var userId = sessionStorageService.getAuthToken().userId;
            localStorageService.saveSsPair(userId, ssPair);
        };

        /*
         ASYMMETRIC ENCRYPTION - ECDSA signature keys
         */

        factory.generateSigningKeyPair = function () {
            // based on CryptocoinJS (http://cryptocoinjs.com/)

            var sr = require('secure-random');
            var CoinKey = require('coinkey');

            var privateKey = sr.randomBuffer(32);
            var ck = new CoinKey(privateKey, true); // true => compressed public key / addresses

            return {pk: ck.publicKey.toString('base64'), sk: privateKey.toString('base64')};
        };

        factory.getSigningKeyPair = function () {
            var userId = sessionStorageService.getAuthToken().userId;
            return localStorageService.getKeyPair(userId);
        };

        factory.saveSigningKeyPair = function (pair) {
            var userId = sessionStorageService.getAuthToken().userId;
            localStorageService.saveKeyPair(userId, pair);
        };

        /*
         SYMMETRIC ENCRYPTION - AES key generation
         */

        factory.generateAESKey = function (password, salt) {
            // use pbkdf2 to convert variable password length to 256 bit hash,
            // split into 8 bytes of 32 bits each
            var pbkdf2 = require('pbkdf2-sha256');
            var buffer = pbkdf2(password, salt, 1, 8);
            var hash = buffer.toString();
            return factory.textToIntArray(hash);
        };

        factory.textToIntArray = function (s) {
            var ua = [];
            for (var i = 0; i < s.length; i++) {
                ua[i] = s.charCodeAt(i);
            }
            return ua;
        };

        return factory;
    };

    keyFactory.$inject = injectParams;

    angular.module('accord.ly').factory('keyService', keyFactory);

}());
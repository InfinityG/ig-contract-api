(function () {
    var injectParams = ['$rootScope'];

    var cryptoFactory = function ($rootScope) {

        var factory = {};

        /*
         SYMMETRIC ENCRYPTION - AES
         */

        factory.encryptTest = function () {
            var plainText = 'Yabb()*()*^5£%$£%$^£';
            alert('Plaintext: ' + plainText);

            var cipherText = factory.encryptString(plainText);
            alert('Ciphertext: ' + cipherText);

            var decryptedText = factory.decryptString(cipherText);
            alert('Decrypted plaintext: ' + decryptedText);
        };

        factory.encryptString = function (cryptoKey, plainText) {
            try {
                var aes = factory.getAESInstance(cryptoKey);
                var uaArr = factory.textToIntArray(plainText);

                var cipherText = '';

                //iterate through array and encrypt every block of 4
                var pos = 0;
                while (pos < uaArr.length) {
                    var block = uaArr.slice(pos, pos + 4);
                    factory.pad(block); //pad the last block if necessary
                    var encBlock = aes.encrypt(block);
                    for (var x = 0; x < encBlock.length; x++) {
                        cipherText += encBlock[x] + ',';
                    }
                    pos += 4;
                }
            } catch (e) {
                //event for modals
                $rootScope.$broadcast('encryptionEvent', {
                    type: 'Error',
                    status: 0,
                    message: "Encryption error! (" + e.message + ")"
                });
                //throw e;
                return null;
            }

            var result = cipherText.substring(0, cipherText.length - 1); //remove the last comma
            return factory.base64Encode(result);
        };

        factory.decryptString = function (cryptoKey, cipherText) {
            try {
                var aes = factory.getAESInstance(cryptoKey);
                var decodedText = factory.base64Decode(cipherText);
                var arr = decodedText.split(',');

                var result = '';

                //iterate through int array and decrypt every block of 4
                var pos = 0;
                while (pos < arr.length) {
                    var block = arr.slice(pos, pos + 4);
                    var decArr = aes.decrypt(block);
                    result += factory.intArrayToText(decArr);
                    pos += 4;
                }
            } catch (e) {
                //event for modals
                $rootScope.$broadcast('encryptionEvent', {
                    type: 'Error',
                    status: 0,
                    message: "Decryption error!"
                });
                //throw e;
                return null;
            }

            return result;
        };

        factory.validateAESKey = function(cryptoKey, cipherTextOriginal){
            var decrypted = factory.decryptString(cryptoKey, cipherTextOriginal);
            var encrypted = factory.encryptString(cryptoKey, decrypted);

            var result = (encrypted == cipherTextOriginal);

            //event for modals
            if (!result) {
                $rootScope.$broadcast('encryptionEvent', {
                    type: 'Error',
                    message: "Invalid password!"
                });
            }

            return result;
        };

        factory.getAESInstance = function (key) {
            var AES = require('aes');
            return new AES(key);
        };

        /*
         ASYMMETRIC ENCRYPTION - ECDSA SIGNATURES
         */

        factory.createMessageDigest = function (message) {
            var crypto = require('crypto');
            var buf = require('buffer');

            var msg = new buf.Buffer(message, 'utf8');
            return crypto.createHash('sha256').update(msg).digest();
        };

        factory.signMessage = function (messageDigest, privateKey) {
            var ecdsa = require('ecdsa');

            var signature = ecdsa.sign(messageDigest, privateKey);
            return ecdsa.serializeSig(signature).toString();
        };

        /*
         Helpers
         */

        factory.textToIntArray = function (s) {
            var ua = [];
            for (var i = 0; i < s.length; i++) {
                ua[i] = s.charCodeAt(i);
            }
            return ua;
        };

        factory.intArrayToText = function (ua) {
            var s = '';
            for (var i = 0; i < ua.length; i++) {
                s += String.fromCharCode(ua[i]);
            }
            return s;
        };

        factory.base64Encode = function (text) {
            var buf = require('buffer');
            var buffer = new buf.Buffer(text, 'binary');
            return buffer.toString('base64');
        };

        factory.base64Decode = function (text) {
            var buf = require('buffer');
            var buffer = new buf.Buffer(text, 'base64');
            return buffer.toString();
        };

        factory.pad = function(block){
            while(block.length < 4){
                block.push(0);
            }
        };

        return factory;
    };

    cryptoFactory.$inject = injectParams;

    angular.module('accord.ly').factory('cryptoService', cryptoFactory);

}());
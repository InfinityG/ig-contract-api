(function () {

    var injectParams = [];

    var localStorageFactory = function () {

        var factory = {};

        /*
         TEMPLATES
         */

        factory.getTemplates = function (userId) {
            var blob = factory.getBlob(userId);
            var result = blob.templates;

            result.sort(function (a, b) {
                return a.external_id - b.external_id;
            });

            return result;
        };

        factory.saveTemplate = function (userId, template) {
            var blob = factory.getBlob(userId);
            var templates = blob.templates;

            if(template.external_id != null && template.external_id > 0) {

                for (var i = 0; i < templates.length; i++) {
                    if (templates[i].external_id == template.external_id) {
                        templates.splice(i, 1);
                        templates.push(template);
                    }
                }
            }else{
                //this is a new template - set the external_id
                if (templates.length > 0)
                    template.external_id = templates[templates.length - 1].external_id + 1;
                else
                    template.external_id = 1;

                templates.push(template);
            }

            factory.saveBlob(userId, blob);
        };

        factory.getTemplate = function (userId, templateExternalId) {
            var templates = factory.getTemplates(userId);

            for (var i = 0; i < templates.length; i++) {
                if (templates[i].external_id == templateExternalId)
                    return templates[i];
            }
        };

        factory.deleteTemplate = function (userId, templateExternalId) {
            var blob = factory.getBlob(userId);
            var templates = blob.templates;

            for (var i = 0; i < templates.length; i++) {
                if (templates[i].external_id == templateExternalId) {
                    templates.splice(i, 1);
                }
            }

            factory.saveBlob(userId, blob);
        };

        /*
         CONTRACTS
         */

        factory.getContracts = function (userId) {
            var blob = factory.getBlob(userId);
            var result = blob.contracts;

            result.sort(function (a, b) {
                return a.external_id - b.external_id;
            });

            return result;
        };

        factory.saveContract = function (userId, contract) {
            var blob = factory.getBlob(userId);
            var contracts = blob.contracts;

            if(contract.external_id != 0) {
                for (var i = 0; i < contracts.length; i++) {
                    if (contracts[i].external_id == contract.external_id) {
                        contracts.splice(i, 1);
                        contracts.push(contract);
                    }
                }
            }else{
                //this is a new contract - set the external_id
                if (contracts.length > 0)
                    contract.external_id = contracts[contracts.length - 1].external_id + 1;
                else
                    contract.external_id = 1;

                contracts.push(contract);
            }

            factory.saveBlob(userId, blob);
        };

        factory.getContract = function (userId, contractExternalId) {
            var contracts = factory.getContracts(userId);

            for (var i = 0; i < contracts.length; i++) {
                if (contracts[i].external_id == contractExternalId)
                    return contracts[i];
            }
        };

        factory.deleteContract = function (userId, contractExternalId) {
            var blob = factory.getBlob(userId);
            var contracts = blob.contracts;

            for (var i = 0; i < contracts.length; i++) {
                if (contracts[i].external_id == contractExternalId) {
                    contracts.splice(i, 1);
                }
            }

            factory.saveBlob(userId, blob);
        };

        /*
         ORACLES - this is simply a list of ids that refer to contact ids
         */

        //factory.getOracles = function (userId) {
        //return JSON.parse(localStorage.getItem('accordly.oracles'));
        //
        //};
        //
        //factory.saveOracle = function (oracle) {
        //    var oracles = factory.getOracles();
        //    oracles.push(oracle);
        //    localStorage.removeItem('accordly.oracles');
        //    localStorage.setItem('accordly.oracles', JSON.stringify(oracles));
        //};

        //factory.getOracle = function(id) {
        //    var oracles = self.getOracles();
        //
        //    for (var i = 0; i < oracles.length; i++) {
        //        if (oracles[i].id == id)
        //            return oracles[i];
        //    }
        //};

        //factory.deleteOracle = function (id) {
        //    var oracles = factory.getOracles();
        //
        //    for (var i = 0; i < oracles.length; i++) {
        //        if (oracles[i] == id) {
        //            oracles.splice(i, 1);
        //            localStorage.removeItem('accordly.oracles');
        //            localStorage.setItem('accordly.oracles', JSON.stringify(oracles));
        //        }
        //    }
        //};

        /*
         CONTACTS
         */

        factory.getContacts = function (userId) {
            var blob = factory.getBlob(userId);
            var result = blob.contacts;

            result.sort(function (a, b) {
                return a.name > b.name;
            });

            return result;
        };

        factory.saveContacts = function (userId, contacts) {
            var blob = factory.getBlob(userId);
            blob.contacts = contacts;
            factory.saveBlob(userId, blob);
        };

        factory.saveContact = function (userId, contact) {
            var blob = factory.getBlob(userId);
            blob.contacts.push(contact);
            factory.saveBlob(userId, blob);
        };

        factory.getContact = function (userId, id) {
            var contacts = factory.getContacts(userId);

            for (var i = 0; i < contacts.length; i++) {
                if (contacts[i].id == id)
                    return contacts[i];
            }
        };

        factory.deleteContact = function (userId, id) {
            var blob = factory.getBlob(userId);
            var contacts = blob.contacts;

            for (var i = 0; i < contacts.length; i++) {
                if (contacts[i].id == id) {
                    contacts.splice(i, 1);
                }
            }

            factory.saveBlob(userId, blob);
        };

        /*
         KEYS
         */

        factory.saveKeyPair = function (userId, keyPair) {
            var blob = factory.getBlob(userId);
            blob.keys = keyPair;

            factory.saveBlob(userId, blob);
        };

        factory.getKeyPair = function (userId) {
            var blob = factory.getBlob(userId);
            return blob.keys;
        };

        factory.deleteKeyPair = function (userId) {
            var blob = factory.getBlob(userId);
            blob.keys = {};
            factory.saveBlob(blob);
        };

        /*
         WALLET
         */
        factory.saveWallet = function (userId, wallet) {
            var blob = factory.getBlob(userId);
            blob.wallet = wallet;
            factory.saveBlob(userId, blob);
        };

        factory.getWallet = function (userId) {
            var blob = factory.getBlob(userId);
            return blob.wallet;
        };

        factory.deleteWallet = function (userId) {
            var blob = factory.getBlob(userId);
            blob.wallet = {};
            factory.saveBlob(blob);
        };

        /*
         SS_KEYS
         */
        factory.saveSsPair = function (userId, ssPair) {
            //adds a ssPair to a user
            var blob = factory.getBlob(userId);
            blob.ssKeys[ssPair[0]] = ssPair[1];
            factory.saveBlob(userId, blob);
        };

        factory.saveSsPairs = function (userId, ssPairs) {
            //replaces all ssPairs for a user
            var blob = factory.getBlob(userId);
            blob.ssKeys = ssPairs;
            factory.saveBlob(userId, blob);
        };

        factory.getSsPairs = function (userId) {
            var blob = factory.getBlob(userId);
            return blob.ssKeys;
        };

        factory.deleteSsPair = function (userId, ssPair) {
            var blob = factory.getBlob(userId);
            delete blob.ssKeys[ssPair[0]];
            factory.saveBlob(blob);
        };

        factory.deleteSsPairs = function (userId) {
            var blob = factory.getBlob(userId);
            blob.ssKeys = {};
            factory.saveBlob(blob);
        };

        /*
         BLOBS
         */

        factory.saveBlob = function(userId, blob){
            var blobs = factory.getBlobs();

            // if no blobs array then create
            if(blobs == null)
                blobs = [];

            //replace blob if userId already exists
            for(var x=0; x<blobs.length; x++){
                if(blobs[x].userId == userId){
                    blobs.splice(x, 1);
                }
            }

            //add blob to blob array
            blobs.push({userId: userId, blob: blob});

            localStorage.removeItem('accordly.blobs');
            localStorage.setItem('accordly.blobs', JSON.stringify(blobs));
        };

        factory.deleteBlob = function(userId){
            var blobs = factory.getBlobs();

            for(var x=0; x<blobs.length; x++){
                if(blobs[x].userId == userId){
                    blobs.splice(x, 1);
                }
            }

            localStorage.removeItem('accordly.blobs');
            localStorage.setItem('accordly.blobs', JSON.stringify(blobs));
        };

        factory.getBlob = function(userId){
            var blobs = factory.getBlobs();

            if(blobs != null) {
                for (var x = 0; x < blobs.length; x++) {
                    if (blobs[x].userId == userId) {
                        return blobs[x].blob;
                    }
                }
            }

            return null;
        };

        factory.getBlobs = function(){
            var result = localStorage.getItem('accordly.blobs');
            return result != null ? JSON.parse(result) : null;
        };

        return factory;
    };

    localStorageFactory.$inject = injectParams;

    angular.module('accord.ly').factory('localStorageService', localStorageFactory);

}());
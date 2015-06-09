/**
 * Created by grant on 19/01/2015.
 */
(function () {

    var injectParams = ['$rootScope', '$compile'];

    var templateServiceFactory = function ($rootScope, $compile) {
        var factory = {};

        var templateModel = {};
        var currentConditionCount = 0;
        var currentTriggerCount = 0;

        factory.handleDrop = function (itemParent, item, target) {
            console.debug('ItemParent: ' + itemParent.id + ', Item: ' + item.id + ', Target: ' + target.id);

            //dont create new element if parent and target are the same
            if(itemParent.id == target.id)
                return;

            //ensure that only conditions (not triggers) are allowed in the main template
            if((item.id.toLowerCase().indexOf('trigger') > -1) && (target.id.toLowerCase().indexOf('contract') > -1))
                return;

            //don't allow conditions inside conditions
            if((item.id.toLowerCase().indexOf('condition') > -1) && (factory.searchParentTree(target, 'condition') != null))
                return;

            factory.insertItem(itemParent, item, target);
        };

        factory.moveItem = function(itemParent, item, target){
            angular.element(target).append(item);
        };

        //http://stackoverflow.com/questions/16656735/insert-directive-programatically-angular
        factory.insertItem = function(itemParent, item, target){

            var directiveName;
            var directiveModel;

            switch(item.id){
                case 'signatureConditionPanel':
                    directiveName = 'signature-condition';
                    directiveModel = {'id': currentConditionCount ++, 'type':'sig_condition', 'from': null};
                    break;
                case 'smsConditionPanel':
                    directiveName = 'sms-condition';
                    directiveModel = {'id': currentConditionCount ++, 'type':'sms_condition', 'from': null};
                    break;
                case 'smsTriggerPanel':
                    directiveName = 'sms-trigger';
                    directiveModel = {'id': currentTriggerCount ++, 'type':'sms_trigger', 'parentId': currentConditionCount ++, 'from': null};
                    break;
                case 'emailTriggerPanel':
                    directiveName = 'email-trigger';
                    break;
                case 'transactionTriggerPanel':
                    directiveName = 'transaction-trigger';
                    break;
                case 'webhookTriggerPanel':
                    directiveName = 'webhook-trigger';
                    break;
                case 'mediaPanel':
                    directiveName = "media";
                    break;
                default:
                    directiveName = null;

            }

            var newElement = angular.element(document.createElement(directiveName));
            //newElement.attr('show-remove-button', 'true');
            newElement.attr('drop-active', 'true');

            $compile( newElement )( $rootScope );

            //where do you want to place the new element?
            angular.element(target).append(newElement);
        };

        factory.searchParentTree = function(el, idString) {
            while (el.parentNode) {
                el = el.parentNode;
                if ((el.id != null) && (el.id.toLowerCase().indexOf(idString) > -1))
                    return el;
            }
            return null;
        };


        return factory;
    };

    templateServiceFactory.$inject = injectParams;

    angular.module('accord.ly').factory('templateService', templateServiceFactory);

}());
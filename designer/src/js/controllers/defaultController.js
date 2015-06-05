(function () {

        var injectParams = ['$scope', '$location', '$compile'];

        var DefaultController = function ($scope, $location, $compile) {

            $scope.conditionData = [
            ];

            $scope.handleDrop = function (itemParent, item, targetParent, target) {
                console.debug('ItemParent: ' + itemParent.id + ', Item: ' + item.id +
                    ', TargetParent: ' + targetParent.id + ', Target: ' + target.id);

                //dont create new element if parent and target are the same
                if(itemParent.id == target.id)
                    return;

                //ensure that only conditions (not triggers) are allowed in the main template
                if((item.id.toLowerCase().indexOf('trigger') > -1) && (target.id.toLowerCase().indexOf('contract') > -1))
                    return;

                //don't allow conditions inside conditions
                if((item.id.toLowerCase().indexOf('condition') > -1) && ($scope.searchParentTree(target, 'condition') != null))
                    return;

                $scope.insertItem(itemParent, item, target);
            };

            //http://stackoverflow.com/questions/16656735/insert-directive-programatically-angular
            $scope.insertItem = function(itemParent, item, target){

                var directiveName;

                switch(item.id){
                    case 'signatureConditionPanel':
                        directiveName = 'signature-condition';
                        break;
                    case 'smsConditionPanel':
                        directiveName = 'sms-condition';
                        break;
                    case 'smsTriggerPanel':
                        directiveName = 'sms-trigger';
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
                    default:
                        directiveName = null;

                }

                var newElement = angular.element(document.createElement(directiveName));

                $compile( newElement )( $scope );

                //where do you want to place the new element?
                angular.element(target).append(newElement);
            };

            $scope.searchParentTree = function(el, idString) {
                while (el.parentNode) {
                    el = el.parentNode;
                    if ((el.id != null) && (el.id.toLowerCase().indexOf(idString) > -1))
                        return el;
                }
                return null;
            };

            //init();
        };

        DefaultController.$inject = injectParams;

        angular.module('accord.ly').controller('DefaultController', DefaultController);

    }()
);
(function () {

        var injectParams = ['$scope', '$location'];

        var DefaultController = function ($scope, $location) {

            $scope.context = null;
            $scope.conditionCollapsed = true;
            $scope.triggerCollapsed = true;

            $scope.conditionData = [
                {
                    'id': 1,
                    'type': 'signature',
                    'title': 'Confirmed by Signature',
                    'fields': null
                },
                {
                    'id': 2,
                    'type': 'sms',
                    'title': 'Confirmed by SMS',
                    'fields': null
                }
            ];

            $scope.triggerData = [
                {
                    'id': 1,
                    'type': 'webhook',
                    'title': 'Webhook',
                    'fields': {
                        'Url': {'type': 'text', 'data': null},
                        'Header': {'type': 'text', 'data': null},
                        'Payload': {'type': 'text', 'data': null}
                    }
                },
                {
                    'id': 2,
                    'type': 'transaction',
                    'title': 'Transaction',
                    'fields': {
                        'From': {'type': 'select', 'data': ['Creator', 'Specific wallet']},
                        'To': {'type': 'select', 'data': ['All recipients', 'Specific recipient']},
                        'Amount': {'type': 'text', 'data': null}
                    }
                },
                {
                    'id': 3,
                    'type': 'email',
                    'title': 'Email',
                    'fields': {
                        'From': {'type': 'select', 'data': ['Creator', 'Specific participant']},
                        'To': {'type': 'select', 'data': ['All participants', 'Specific participant']},
                        'Keywords': {'type': 'text', 'data': null}
                    }
                }
            ];

            $scope.handleDrop = function (itemId, targetId) {
                console.debug('Item: ' + itemId + ', Target: ' + targetId);

                //TODO:
                // 1. clone original to replace it
                // 2. add item to current items
                // 3. add a button to remove the item


            };

            //init();
        };

        DefaultController.$inject = injectParams;

        angular.module('accord.ly').controller('DefaultController', DefaultController);

    }()
);
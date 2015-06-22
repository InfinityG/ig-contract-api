(function () {

    var injectParams = ['$scope', '$rootScope', '$location'];

    var ModalController = function ($scope, $rootScope, $location) {
        $scope.show = false;
        $scope.message = null;
        $scope.type = null;
        $scope.status = null;
        $scope.redirectUri = '/';

        $scope.cancelModal = function(){
            $scope.show = false;

            //redirect=false/true is set on the modalDirective when placed on a page
            if($scope.redirect){
                $location.path($scope.redirectUri);
            }
        };

        var contractEventListener = $rootScope.$on('contractEvent', function (event, args) {
            showModal(args.type, args.message, args.status, args.redirectUri);
        });

        var encryptionEventListener = $rootScope.$on('encryptionEvent', function (event, args) {
            //var message = args.type == 'Error' ? 'Invalid password' : args.message;
            showModal(args.type, args.message, 0, null);
        });

        //clean up rootScope listeners
        $scope.$on('$destroy', function() {
            contractEventListener();
            encryptionEventListener();
        });

        function showModal(type, message, status, redirectUri){
            $scope.show = true;
            $scope.type = type;
            $scope.message = message;
            $scope.status = status;
            $scope.redirectUri = redirectUri;
        }
    };

    ModalController.$inject = injectParams;

    angular.module('accord.ly').controller('ModalController', ModalController);

}());
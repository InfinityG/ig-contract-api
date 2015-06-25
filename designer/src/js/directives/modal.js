//Used for form validation
(function () {
    var modal = function () {
        return {
            restrict: 'E',
            replace: true,
            scope:{redirect:'='},
            controller: 'ModalController',
            templateUrl: 'modal.html'
        };
    };

    angular.module('accord.ly').directive('modal', modal);
})();
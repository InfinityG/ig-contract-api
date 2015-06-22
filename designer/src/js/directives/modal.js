//Used for form validation
(function () {
    var modal = function () {
        return {
            restrict: 'E',
            replace: true,
            scope:{redirect:'='},
            controller: 'ModalController',
            templateUrl: 'modalTemplate.html'
        };
    };

    angular.module('accord.ly').directive('modal', modal);
})();
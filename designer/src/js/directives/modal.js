//Used for form validation
(function () {
    var modal = function () {
        return {
            restrict: 'E',
            replace: true,
            scope:{redirect:'='},
            controller: 'ModalDirectiveController',
            templateUrl: 'modalTemplate.html'
        };
    };

    angular.module('accord.ly').directive('modal', modal);
})();
//http://blog.parkji.co.uk/2013/08/11/native-drag-and-drop-in-angularjs.html

(function () {

    var media = function () {

        return {
            templateUrl: 'mediaTemplate.html',
            restrict: 'E',
            scope:{showRemoveButton:'='},
            controller:'MediaDirectiveController',
            link: function postLink(scope, element, attrs) {
                //element.text(template);
            }
        };
    };

    angular.module('accord.ly').directive('media', media);
})();
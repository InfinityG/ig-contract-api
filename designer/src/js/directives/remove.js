//http://blog.parkji.co.uk/2013/08/11/native-drag-and-drop-in-angularjs.html

(function () {

    var remove = function () {

        return {
            restrict: 'A',
            scope: {remove: '@'},
            replace: true,
            link: function (scope, elem, attrs) {

                elem.bind('click', function (args) {

                    var targetId = args.currentTarget.attributes['remove'].value;
                    document.getElementById(targetId).remove();

                    console.debug(args.currentTarget.attributes['remove'].value);
                });
            }
        }
    };

    angular.module('accord.ly').directive('remove', remove);
})();
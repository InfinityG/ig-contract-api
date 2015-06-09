//http://blog.parkji.co.uk/2013/08/11/native-drag-and-drop-in-angularjs.html

(function () {

    var remove = function () {

        return {
            restrict: 'E',
            replace:true,
            template: "<a class='btn btn-default pull-right'>Remove</a>",
            link: function postLink(scope, elem, attrs) {
                elem.bind('click', function (args) {

                    var removeElement = this.parentNode.parentNode;
                    removeElement.remove();

                });
            }
        }
    };

    angular.module('accord.ly').directive('remove', remove);
})();
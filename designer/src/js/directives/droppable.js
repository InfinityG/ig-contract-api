//http://blog.parkji.co.uk/2013/08/11/native-drag-and-drop-in-angularjs.htmlz

(function () {
    var droppable = function() {
        return {
            scope: {
                drop: '&', // parent
                bin: '='    //bi-directional scope
            },
            link: function(scope, element) {
                // again we need the native object
                var el = element[0];

                el.addEventListener(
                    'dragover',
                    function(e) {
                        e.dataTransfer.dropEffect = 'move';
                        // allows us to drop
                        if (e.preventDefault) e.preventDefault();
                        this.classList.add('over');
                        return false;
                    },
                    false
                );

                el.addEventListener(
                    'dragenter',
                    function(e) {
                        this.classList.add('over');
                        return false;
                    },
                    false
                );

                el.addEventListener(
                    'dragleave',
                    function(e) {
                        this.classList.remove('over');
                        return false;
                    },
                    false
                );

                el.addEventListener(
                    'drop',
                    function(e) {
                        var binId = this.id;
                        var item = document.getElementById(e.dataTransfer.getData('ElementId'));
                        var itemParent = document.getElementById(e.dataTransfer.getData('ParentId'));
                        var targetParent = this.parentNode.parentNode;

                        console.debug('ItemParent: ' + itemParent.id);

                        //this.appendChild(item);

                        var self = this;

                        // call the passed drop function
                        scope.$apply(function(scope) {
                            var fn = scope.drop();
                            if ('undefined' !== typeof fn) {
                                //fn(item.id, binId);
                                fn(itemParent, item, targetParent, self);
                            }
                        });

                        //prevent event bubbling if this is a nested drop target
                        e.stopPropagation();

                    },
                    false
                );
            }
        }
    };

    angular.module('accord.ly').directive('droppable', droppable);
})();
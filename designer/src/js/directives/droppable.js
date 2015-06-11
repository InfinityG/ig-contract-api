//http://blog.parkji.co.uk/2013/08/11/native-drag-and-drop-in-angularjs.html

(function () {
    var injectParams = ['templateService'];

    var droppable = function(templateService) {
        return {
            //scope: {
            //    drop: '&', // parent
            //    bin: '='    //bi-directional scope
            //},
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
                        var target = this;

                        var item = document.getElementById(e.dataTransfer.getData('ElementId'));
                        var directiveId = e.dataTransfer.getData('DirectiveId');
                        var itemParent = document.getElementById(e.dataTransfer.getData('ParentId'));

                        templateService.handleDrop(itemParent, item, directiveId, target);

                        //prevent event bubbling if this is a nested drop target
                        e.stopPropagation();

                    },
                    false
                );
            }
        }
    };

    droppable.$inject = injectParams;

    angular.module('accord.ly').directive('droppable', droppable);
})();
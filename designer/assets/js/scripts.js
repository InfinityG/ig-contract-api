var conditionData = [
    {
        'type': 'signature',
        'fields': {
            'title': 'Confirmed by Signature'
        }
    },
    {
        'type': 'sms',
        'fields': {
            'title': 'Confirmed by SMS'
        }
    }
];

var conditionCount = 2;

var triggerData = [
    {
        'type': 'webhook'
    },
    {
        'type': 'transaction'
    },
    {
        'type': 'email'
    }
];

var triggerCount = 3;

$(document).ready(function () {
    function buildConditions() {

        $.each(conditionData, function (index, value) {
            var id = 1;
            var type = value.type;
            var panelId = type + 'InputPanel' + id;
            var title = value.fields.title;
            var collapseId = type + "Condition" + id;

            var template = "<div class='panel panel-default' id='" + panelId + "' draggable='true'" +
                "ondragstart='drag(event)'>" +
                "<div class='panel-heading'>" +
                "<h3 class='panel-title'>" + title + "</h3>" +
                "<a data-toggle='collapse' href='#" + collapseId + "' aria-expanded='false' aria-controls='smsCondition'>(details)</a>" +
                "</div> " +
                "<div class='panel-body collapse' id='" + collapseId + "'> " +
                "<div class='panel-body' id='smsInputDropTarget' ondrop='drop(event)'" +
                "ondragover='allowDrop(event)'>" +
                "[Drag your trigger here] " +
                "</div> " +
                "</div> " +
                "</div>"

            $('#conditionPanel').append(template);
        });
    }

    buildConditions();

});

var selectedConditions = [];

function allowDrop(ev) {
    ev.preventDefault();
}

function drag(ev) {
    var originId = ev.target.id;
    var element = $('#' + originId);

    var parent = element.parent();
    var originParentId = parent.attr('id');

    console.debug(originId);
    console.debug(originParentId);

    ev.dataTransfer.setData("originId", originId);
    ev.dataTransfer.setData("originParentId", originParentId);
}

function drop(ev) {
    ev.preventDefault();

    var targetId = ev.target.id;
    var targetElement = $('#' + targetId);

    var originId = ev.dataTransfer.getData("originId");
    var originParentId = ev.dataTransfer.getData("originParentId");

    var originElement = $('#' + originId);
    targetElement.append(originElement);

    //now replace the original
    replaceOriginal(originElement, originParentId);
}

function replaceOriginal(element, originParentId) {
    console.debug('Element id: ' + element.id);
    console.debug('Origin parent id: ' + originParentId);

    var clone = element.clone();

    //replace the dragged element with a new one
    var originParent = $('#' + originParentId);
    originParent.append(clone);
}

function addTrigger(trigger, conditionId) {
    $.each(selectedConditions, function (key, value) {
        if (key == conditionId) {
            value.triggers.push(trigger);
        }
    });
}

function addCondition(condition) {
    var newId = selectedConditions.length + 1;
    condition.id = newId;
    selectedConditions.push(condition);

    return newId;
}

//$("document").ready(function () {

//});

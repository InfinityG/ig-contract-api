notes:
------

suystem starts with the initialization service, service initializes user session, token etc. context hard-coded
mock mode is set, initialiseMocks is run to create a mocj context
routes living in app.js
templates are saving, but contracts are not - copy template saving pattern

tempateDesignerController
	modelIndexService - flattens object trees, quickly accesable in memory by a key instead of local storage

templateService
	- loading directives and dynamically injecting them into the angular DOM, based on the items in the modelIndexService
	- createDirectiveElement - this creates the actual view after the model has been updated (ie. via drop event)

directives pull in html as defined in src/templates - which in turn pull in controillers in src/controllers/directives

items suffixed with Element modify the view, items suffixed with model modify the models


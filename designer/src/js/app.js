(function () {
    var app = angular.module('accord.ly', ['ngRoute', 'ui.bootstrap']);

    app.config(function ($routeProvider, $httpProvider) {

        //authentication interceptor (http://beletsky.net/2013/11/simple-authentication-in-angular-dot-js-app.html)
        $httpProvider.interceptors.push('httpInterceptor');

        $routeProvider
            //.when('/wallet', {
            //    controller: 'WalletController',
            //    templateUrl: 'wallet.html',
            //    reloadOnSearch: false
            //})
            //.when('/sso', {
            //    //controller: 'LoginController',
            //    templateUrl: 'sso.html',
            //    reloadOnSearch: false
            //})
            //.when('/register', {
            //    controller: 'RegistrationController',
            //    templateUrl: 'register.html',
            //    reloadOnSearch: false
            //})
            .when('/', {
                controller: 'DefaultController',
                templateUrl: 'default.html',
                reloadOnSearch: false
            })
            .when('/templates/design/:id?', {
                controller: 'TemplateDesignerController',
                templateUrl: 'templateDesigner.html',
                reloadOnSearch: false
            })
            .when('/templates/list', {
                controller: 'TemplateListController',
                templateUrl: 'templateList.html',
                reloadOnSearch: false
            })
            .when('/contracts/assemble/:templateId?', {
                controller: 'ContractAssemblerController',
                templateUrl: 'contractAssembler.html',
                reloadOnSearch: false
            })
            .when('/login/:exit?', {
                controller: 'LoginController',
                templateUrl: 'login.html',
                reloadOnSearch: false
            });
    });

    app.run(function(initializationService){
        initializationService.init();
    });

}());
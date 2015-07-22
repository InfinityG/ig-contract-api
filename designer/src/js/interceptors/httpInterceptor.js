/**
 * Created by grant on 26/01/2015.
 */
/* based on pattern from: http://beletsky.net/2013/11/simple-authentication-in-angular-dot-js-app.html */

(function () {

    var injectParams = ['$q', '$window', '$location', '$rootScope'];

    var httpInterceptor = function ($q, $window, $location, $rootScope) {

        return {
            'response': function (response) {
                return response;
            },
            'responseError': function (rejection) {
                switch (rejection.status) {
                    case 400:
                        $rootScope.$broadcast('contractEvent', {
                                type: 'Error',
                                status: rejection.status,
                                message: rejection.data
                            }
                        );
                        break;
                    case 401:
                        $rootScope.$broadcast('contractEvent', {
                                type: 'Error',
                                status: rejection.status,
                                message: rejection.data,
                                redirectUri: '/login'
                            }
                        );
                        break;
                    case 0:
                        $rootScope.$broadcast('contractEvent', {
                            type: 'Error',
                            status: rejection.status,
                            message: 'No connection!'
                        });
                        break;
                    default :
                        $rootScope.$broadcast('contractEvent', {
                            type: 'Error',
                            status: rejection.status,
                            message: rejection.data
                        });
                        break;
                }

                return $q.reject(rejection);
            }
        };
    };

    httpInterceptor.$inject = injectParams;

    angular.module('accord.ly').factory('httpInterceptor', httpInterceptor);

}());
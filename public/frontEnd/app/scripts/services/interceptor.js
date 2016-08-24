/**
 * Created by fr3d0 on 7/23/16.
 */
'use strict';
app.factory('httpInterceptor',['localStorageService', function (localStorageService) {
    return {
        request: function (config) {

            if (localStorageService.get('encodedToken')) {
                config.headers['Authorization'] = localStorageService.get('encodedToken');
                return config;
            }else{
                return config;
            }
        },

        responseError: function(response) {
            
            return response;
        }
    };
}]);

app.config(['$httpProvider',function ($httpProvider) {
    $httpProvider.interceptors.push('httpInterceptor');
}]);
/**
 * Created by fr3d0 on 7/23/16.
 */
'use strict';

app.service('dawProcessManagerService',['$http', 'localStorageService','ENV', function($http, localStorageService,ENV) {

    var baseUrl = ENV.baseUrl;


    this.registerUser = function (newUser, succes, error) {

    };

    this.login = function (user, succes, error) {
        $http.post(baseUrl + '/api/users/login', user).success(succes).error(error);
    };

    this.countRoles = function (user, succes, error) {

    };

    this.getClassesPlaning = function (id, succes, error) {
        $http.get(baseUrl + '/api/subject_planifications/getWholeSubkectPlanning?id='+id ).success(succes).error(error);

    };
    
    this.getGlobalProgress = function (success, error){
        $http.get(baseUrl +'/api/users/globalProgress').success(success).error(error);
    }
}]);
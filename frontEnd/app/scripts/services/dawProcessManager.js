/**
 * Created by fr3d0 on 7/23/16.
 */
'use strict';

app.service('dawProcessManagerService',['$http', 'localStorageService','ENV', function($http, localStorageService,ENV) {

    var baseUrl = ENV.baseUrl;


    this.registerUser = function (newUser, succes, error) {

    };

    this.login = function (user, success, error) {
        $http.post(baseUrl + '/api/users/login', user).success(success).error(error);
    };

    this.countRoles = function (user, success, error) {

    };

    this.getClassesPlaning = function (id, success, error) {
        $http.get(baseUrl + '/api/subject_planifications/getWholeSubjectPlanning?id='+id ).success(success).error(error);
    };

    this.getSubjectsPlaning = function (success, error) {
        $http.get(baseUrl + '/api/subject_planifications/getSubjectsPlanning').success(success).error(error);
    };
    
    this.getGlobalProgress = function (success, error){
        $http.get(baseUrl +'/api/users/globalProgress').success(success).error(error);
    }
}]);
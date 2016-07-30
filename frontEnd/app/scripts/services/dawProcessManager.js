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

    this.getClassesPlaning = function (id, success, error) {
        $http.get(baseUrl + '/api/subject_planifications/getWholeSubjectPlanning?id='+id ).success(success).error(error);
    };

    this.getSubjectsPlaning = function (success, error) {
        $http.get(baseUrl + '/api/subject_planifications/getSubjectsPlanning').success(success).error(error);
    };
    
    this.getGlobalProgress = function (success, error){
        $http.get(baseUrl +'/api/users/globalProgress').success(success).error(error);
    };

    this.getSubjectList = function (idGrade, success, error) {
        $http.get(baseUrl + '/api/subjects/getSubjectByGrade?id='+idGrade).success(success).error(error);

    };
    
    this.getClassPlan = function (id, success, error) {
        $http.get(baseUrl + '/api/classes_planifications/getClassPlan?id='+id ).success(success).error(error);
    };

    this.deleteVdm = function (id, success, error) {
        $http.delete(baseUrl + '/api/vdms/'+id ).success(success).error(error);
    };

    this.addVdm = function (vdm, success, error) {
        $http.post(baseUrl + '/api/vdms/addVdm', vdm).success(success).error(error);
    };

    this.getVdmsBySubject = function (id, success, error) {
        $http.get(baseUrl + '/api/vdms/getVdmsBySubject?id='+id ).success(success).error(error);
    };

    this.getGradesWithSubjects = function (success, error) {
        $http.get(baseUrl + '/api/grades/getGradesWithSubjects').success(success),error(error);
    }
}]);
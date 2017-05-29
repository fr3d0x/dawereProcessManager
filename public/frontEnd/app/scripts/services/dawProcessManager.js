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
    
    this.getGlobalProgress = function (role, progress_type, date_from, date_to,  success, error){
        $http.get(baseUrl +'/api/users/global_progress?role='+role+'&progress_type='+progress_type+'&date_from='+date_from+'&date_to='+date_to).success(success).error(error);
    };

    this.getEmployeeProgress = function (role, success, error){
        $http.get(baseUrl +'/api/users/employee_progress?role='+role).success(success).error(error);
    };

    this.getSubjectList = function (idGrade, success, error) {
        $http.get(baseUrl + '/api/subjects/getSubjectByGrade?id='+idGrade).success(success).error(error);

    };
    
    this.getClassPlan = function (id, success, error) {
        $http.get(baseUrl + '/api/classes_planifications/getClassPlan?id='+id ).success(success).error(error);
    };

    this.deleteVdm = function (id, success, error) {
        $http.post(baseUrl + '/api/vdms/deleteVdm', id ).success(success).error(error);
    };

    this.addVdm = function (vdm, success, error) {
        $http.post(baseUrl + '/api/vdms/addVdm', vdm).success(success).error(error);
    };

    this.getVdmsBySubject = function (id, role, success, error) {
        $http.get(baseUrl + '/api/vdms/getVdmsBySubject?id='+id+'&role='+role).success(success).error(error);
    };

    this.getDawereVdms = function (success, error) {
        $http.get(baseUrl + '/api/vdms/getDawereVdms' ).success(success).error(error);
    };

    this.getGradesWithSubjects = function (success, error) {
        $http.get(baseUrl + '/api/grades/getGradesWithSubjects').success(success).error(error);
    };
    
    this.getGrades = function (success, error) {
        $http.get(baseUrl + '/api/grades').success(success).error(error);
    };
    
    this.editCP = function (cp, success, error) {
        $http.post(baseUrl + '/api/classes_planifications/editCp', cp ).success(success).error(error);
    };

    this.saveCp = function (cp, success, error) {
        $http.post(baseUrl + '/api/classes_planifications/saveCp', cp ).success(success).error(error);
    };

    this.getVdm = function (id, success, error) {
        $http.get(baseUrl + '/api/vdms/getWholeVdm?id='+id ).success(success).error(error);
    };

    this.updateVdm = function (vdm, success, error) {
        $http.post(baseUrl + '/api/vdms/updateVdm', vdm ).success(success).error(error);
    };
    
    this.getVdmsHistoryBySubject = function (id, success, error) {
        $http.get(baseUrl + '/api/vdm_changes/getVdmsChangesBySubject?id='+id ).success(success).error(error);
    };

    this.saveSubjectPlaning = function (sp, success, error) {
        $http.post(baseUrl + '/api/subject_planifications/saveSubjectPlanning', sp).success(success).error(error);
    };
    
    this.createSubject = function (data, success, error) {
        $http.post(baseUrl + '/api/subjects/createSubject', data).success(success).error(error);
    };

    this.deleteCp = function (cp, success, error) {
        $http.post(baseUrl + '/api/classes_planifications/deleteClassPlan', cp ).success(success).error(error);
    };

    this.postPdf = function (pdf, success, error) {
        $http.post(baseUrl + '/api/users/generatePdf', pdf ).success(success).error(error);
    };
    
    this.getCpHistoryBySubject = function (id, success, error) {
        $http.get(baseUrl + '/api/cp_changes/getChangesBySubject?id='+id ).success(success).error(error);
    };

    this.approveVdm = function (request, success, error) {
        $http.post(baseUrl + '/api/vdms/approveVdm', request ).success(success).error(error);
    };

    this.rejectVdm = function (request, success, error) {
        $http.post(baseUrl + '/api/vdms/rejectVdm', request ).success(success).error(error);
    };

    this.getGrades = function (success, error){
        $http.get(baseUrl + '/api/grades' ).success(success).error(error);
    };

    this.mergeClassPlans = function (request, success, error){
        $http.post(baseUrl + '/api/classes_planifications/mergeCp', request ).success(success).error(error);
    };

    this.assignSubject = function (subject, success, error) {
        $http.post(baseUrl + '/api/subjects/assignSubject', subject).success(success).error(error);

    };

    this.finish_big_file_upload = function (file_name, file_type, vdm_id, success, error) {
        $http.get(baseUrl + '/api/vdms/finish_big_files_upload?file_name='+file_name+'&file_type='+file_type+'&vdm_id='+vdm_id).success(success).error(error);

    };
}]);
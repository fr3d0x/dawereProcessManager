/**
 * Created by fr3d0 on 7/24/16.
 */
'use strict';
app.controller("dashboardController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService){

        var user = JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1]));
        if(user != null){
            if(localStorageService.get('currentRole') == null){
                for(var i=0; i< user.roles.length; i++){
                    if(user.roles[i].primary){
                        localStorageService.set('currentRole', user.roles[i].role);
                        $scope.currentRole = user.roles[i].role;
                    }
                } 
            }
        }
}]);
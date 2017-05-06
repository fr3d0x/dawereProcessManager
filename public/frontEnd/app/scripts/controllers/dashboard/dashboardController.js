/**
 * Created by fr3d0 on 7/24/16.
 */
'use strict';
app.controller("dashboardController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, $rootScope){

        var token = localStorageService.get('encodedToken');
        if(token != null){
            var user = JSON.parse(atob(token.split(".")[1]));
            if(localStorageService.get('currentRole') == null){
                for(var i=0; i< user.roles.length; i++){
                    if(user.roles[i].primary){
                        localStorageService.set('currentRole', user.roles[i].role);
                        $rootScope.currentRole = user.roles[i].role;
                    }
                } 
            }
        }

        var getGrades = function(){
            dawProcessManagerService.getGrades(function(response){
                $scope.grades = response.data;
            }, function(error){
                console.log(error)
            })
        };
        getGrades();
}]);
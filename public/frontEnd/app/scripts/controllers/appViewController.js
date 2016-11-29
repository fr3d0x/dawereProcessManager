/**
 * Created by fr3d0 on 7/24/16.
 */
'use strict';
app.controller("appViewController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, $rootScope){

        
        if(localStorageService.get('encodedToken')){
            if($rootScope.currentUser == null){
                $rootScope.currentUser = localStorageService.get('currentUser');
            }
            if(localStorageService.get('currentRole') != null){
                $rootScope.currentRole = localStorageService.get('currentRole')
            }
            $rootScope.uploadFolder = ENV.baseUploadFolder;
        }else{
            $state.go('core.login');
        }
}]);
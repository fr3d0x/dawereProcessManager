/**
 * Created by fr3d0 on 7/24/16.
 */
app.controller("appViewController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, $rootScope){



        if(localStorageService.get('encodedToken')){
            if($rootScope.currentUser == null){
                $rootScope.currentUser = localStorageService.get('currentUser');
            }
        }else{
            $state.go('core.login');
        }
}]);
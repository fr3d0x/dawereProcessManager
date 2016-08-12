/**
 * Created by dawere on 28/07/16.
 */



app.controller('headerController',['$scope', 'localStorageService', '$rootScope','ENV', 'dawProcessManagerService', '$window', function ($scope, localStorageService, $rootScope, ENV, dawProcessManagerService, $window) {

    var logoutURL = ENV.baseUrl;
    
    $scope.roles = JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1])).roles;
    $scope.logout = function(){
        localStorageService.clearAll();
    };
    
    $scope.changeRole = function(role){
        localStorageService.set('currentRole', role);
        $rootScope.currentRole = role;
    }
    

}]);

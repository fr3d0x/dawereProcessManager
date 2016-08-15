/**
 * Created by dawere on 28/07/16.
 */



app.controller('headerController',['$scope', 'localStorageService', '$rootScope','ENV', 'dawProcessManagerService', '$window', '$state', function ($scope, localStorageService, $rootScope, ENV, dawProcessManagerService, $window, $state) {

    var logoutURL = ENV.baseUrl;

    if (localStorageService.get('encodedToken') != null){
        $scope.roles = JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1])).roles;
    }
    $scope.logout = function(){
        localStorageService.clearAll();
        $state.go('app.dashboard')
    };
    
    $scope.changeRole = function(role){
        localStorageService.set('currentRole', role);
        $rootScope.currentRole = role;
    }
    

}]);

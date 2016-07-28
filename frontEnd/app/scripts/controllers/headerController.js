/**
 * Created by dawere on 28/07/16.
 */



app.controller('headerController',['$scope', 'localStorageService', '$rootScope','ENV', 'dawProcessManagerService', function ($scope, localStorageService, $rootScope, ENV, dawProcessManagerService) {

    var logoutURL = ENV.baseUrl;
    

    $scope.logout = function(){
        localStorageService.clearAll();
    };
    
    
    

}]);

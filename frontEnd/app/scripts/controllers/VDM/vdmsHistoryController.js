/**
 * Created by fr3d0 on 7/30/16.
 */
app.controller("vdmsHistoryController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter) {
        var getVdmsHixtory = function () {
            dawProcessManagerService.getVdmsHistoryBySubject($stateParams.id, function (response) {
                $scope.subject = response.data.subject;
                $scope.tableParams = new NgTableParams({}, {
                    filterOptions: {filterLayout: "horizontal"},
                    dataset: response.data.history
                });
            }, function (error) {
                alert(error);
            })
        };
        
        getVdmsHixtory();
    }]);
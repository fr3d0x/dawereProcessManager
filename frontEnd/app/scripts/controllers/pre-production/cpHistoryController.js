/**
 * Created by fr3d0 on 01/08/16.
 */
'use strict';
app.controller("cpHistoryController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter) {
        var getVdmsHixtory = function () {
            dawProcessManagerService.getCpHistoryBySubject($stateParams.id, function (response) {
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
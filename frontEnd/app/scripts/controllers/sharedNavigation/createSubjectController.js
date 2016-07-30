/**
 * Created by dawere on 29/07/16.
 */

app.controller("subjectListController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', '$rootScope',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, $rootScope){

        $scope.subject = {
            name: null,
            grade: null,
            description: null,
            first_period: null,
            second_period: null,
            third_period: null,
            goal: null
        };
        
        $scope.grades = ['Primer año', 'Segundo año','Tercer año', 'Cuarto año','Quinto año' ];

        
        var getSubjectList = function() {
            dawProcessManagerService.getSubjectList($stateParams.id, function (response) {
                $scope.subjects = response.data;
            }, function (error) {
                console.log(error);
            });
        };
        getSubjectList();

    }]);

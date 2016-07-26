/**
 * Created by fr3d0 on 7/25/16.
 */

app.controller("classesPlanificationController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, ngTableParams){
        var getClassesPlan = function(){
            dawProcessManagerService.getClassesPlaning($stateParams.id, function (response)  {
                var data = response.data;
                $scope.subject = response.data.subject;
                $scope.tableParams = new ngTableParams({
                    page: 1,            // show first page
                    count: 10,          // count per page
                    filter: {
                        name: ''       // initial filter
                    },
                    sorting: {
                        name: 'asc'     // initial sorting
                    }
                }, {
                    total: data.classesPlaning.length, // length of data
                    getData: function($defer, params) {
                        // use build-in angular filter
                        var filteredData = params.filter() ?
                            $filter('filter')(data, params.filter()) :
                            data;
                        var orderedData = params.sorting() ?
                            $filter('orderBy')(filteredData, params.orderBy()) :
                            data;

                        params.total(orderedData.length); // set total for recalc pagination
                        $defer.resolve(orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count()));
                    }
                });
            }, function(error) {
                alert(error);
            })
        };


        getClassesPlan();
    }]);

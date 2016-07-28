'use strict';

/**
 * @ngdoc overview
 * @name app
 * @description
 *
 * Main module of the application.
 */
var app = angular.module('app', [

  'ngCookies',
  'picardy.fontawesome',
  'ui.bootstrap',
  'ui.router',
  'ui.select',
  'pascalprecht.translate',
  'checklist-model',
  'angular.filter',
  'base64',
  'ngRoute',
  'config',
  'LocalStorageModule',
  'ngTable'
])
  .run(['$rootScope', '$state', '$stateParams', function($rootScope, $state, $stateParams) {
    $rootScope.$state = $state;
    $rootScope.$stateParams = $stateParams;
    $rootScope.$on('$stateChangeSuccess', function(event, toState) {

      event.targetScope.$watch('$viewContentLoaded', function () {

        angular.element('html, body, #content').animate({ scrollTop: 0 }, 200);

        setTimeout(function () {
          angular.element('#wrap').css('visibility','visible');

          if (!angular.element('.dropdown').hasClass('open')) {
            angular.element('.dropdown').find('>ul').slideUp();
          }
        }, 200);
      });
      $rootScope.containerClass = toState.containerClass;
    });
  }])

  .config(['uiSelectConfig', function (uiSelectConfig) {
    uiSelectConfig.theme = 'bootstrap';
  }])

  //angular-language
  .config(['$translateProvider', function($translateProvider) {
    $translateProvider.useStaticFilesLoader({
      prefix: 'languages/',
      suffix: '.json'
    });
    $translateProvider.useLocalStorage();
    $translateProvider.preferredLanguage('en');
  }])

  .config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {

    $urlRouterProvider.otherwise('/app/dashboard');

    $stateProvider

        .state('app', {
            url: '/app',
            controller: 'appViewController',
            templateUrl: 'views/app.html'
        })
        
        //app core pages
        .state('core', {
            abstract: true,
            url: '/core',
            template: '<div ui-view></div>'
        })
        //login
        .state('core.login', {
            url: '/login',
            controller: 'loginController',
            templateUrl: 'views/login.html'
        })
        
        .state('app.dashboard', {
            url: '/dashboard',
            controller: 'dashboardController',
            templateUrl: 'views/dashboard/dashboard.html'
        })

        .state('app.subjects', {
            url: '/subjects',
            controller: 'subjectListController',
            templateUrl: 'views/sharedNavigation/subjectList.html'
        })

        //pre-produccion
        .state('app.preProduction', {
            url: '/preProduction',
            template: '<div ui-view></div>'
        })

        .state('app.preProduction.classesPlanification', {
            url: '/classesPlanification?id',
            controller: 'classesPlanificationController',
            templateUrl: 'views/pre-produccion/classesPlanification.html'
        })



        .state('app.preProduction.editClassPlan', {
            url: '/editClassPlan?id',
            controller: 'editClassPlanController',
            templateUrl: 'views/pre-produccion/editClassPlan.html'
        })


  }]);


/**
 * Created by fr3d0 on 7/23/16.
 */
'use strict';

app.service('dawProcessManagerService',['$http', 'localStorageService','ENV', function($http, localStorageService,ENV) {

    var baseUrl = ENV.baseUrl;


    this.registerUser = function (newUser, succes, error) {

    };

    this.login = function (user, success, error) {
        $http.post(baseUrl + '/api/users/login', user).success(success).error(error);
    };

    this.countRoles = function (user, success, error) {

    };

    this.getClassesPlaning = function (id, success, error) {
        $http.get(baseUrl + '/api/subject_planifications/getWholeSubjectPlanning?id='+id ).success(success).error(error);
    };

    this.getSubjectsPlaning = function (success, error) {
        $http.get(baseUrl + '/api/subject_planifications/getSubjectsPlanning').success(success).error(error);
    };
    
    this.getGlobalProgress = function (success, error){
        $http.get(baseUrl +'/api/users/globalProgress').success(success).error(error);
    }
}]);
/**
 * Created by fr3d0 on 7/23/16.
 */
'use strict';
app.factory('httpInterceptor',['localStorageService', function (localStorageService) {
    return {
        request: function (config) {

            if (localStorageService.get('encodedToken')) {
                config.headers['Authorization'] = localStorageService.get('encodedToken');
                return config;
            }else{
                return config;
            }
        },

        responseError: function(response) {
            
            return response;
        }
    };
}]);

app.config(['$httpProvider',function ($httpProvider) {
    $httpProvider.interceptors.push('httpInterceptor');
}]);
/**
 * Created by fr3d0 on 7/23/16.
 */
'use strict';
app.service('responseHandlingService',function(){

    this.evaluate = function(status, msg){
        var title;
        var motive;

        switch (status){
            case "UNAUTHORIZED":
                title = "NO AUTORIZADO";
                motive = "warning";
                break;
            case "FAILED":
                title = "FALLIDO";
                motive = "warning";
                break;
            default :
                title = "ERROR";
                motive = "error";
                msg = "Fallo de conexion";
        }
        swal(title, msg, motive);
    }
});
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
        }else{
            $state.go('core.login');
        }
}]);
/**
 * Created by fr3d0 on 7/24/16.
 */
'use strict';
app.controller("dashboardController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService){

        var user = JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1]));
        if(user != null){
            if(localStorageService.get('currentRole') == null){
                for(var i=0; i< user.roles.length; i++){
                    if(user.roles[i].primary){
                        localStorageService.set('currentRole', user.roles[i].role);
                        $scope.currentRole = user.roles[i].role;
                    }
                } 
            }
        }
}]);
/**
 * Created by fr3d0 on 25/07/16.
 */

'use strict';
app.controller("preProductionDashboardController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService','NgTableParams',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService,NgTableParams){

        var getGlobalProgress = function(){
            dawProcessManagerService.getGlobalProgress(function (response)  {
                var data = response.data;
                $scope.tableParams = new NgTableParams({},{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: data
                });
            }, function(error) {
                alert(error);
            })
        };


        getGlobalProgress();
        
    }]);
/**
 * Created by fr3d0 on 7/23/16.
 */
'use strict';
app.controller("loginController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService){

        $scope.user = {};


        $scope.enviar = function(user) {
            if(user.username == null ||  user.password == null || user.username == "" ||  user.password == ""){

                swal({
                    title: "Aviso",
                    text: "Por favor introduzca los datos pertinentes para iniciar sesion (Nombre de usuario y contrasena)",
                    type: "error",
                    confirmButtonColor: "#2A8F6D",
                    cancelButton: false,
                    closeOnConfirm: true,
                    closeOnCancel: true
                })


            }else{
                login(user);
            }

        };

        var login = function(user){
            dawProcessManagerService.login(user, function (response) {
                if (response.status == "SUCCESS") {
                    var token = response.data;
                    localStorageService.set('encodedToken', token);
                    token = JSON.parse(atob(localStorageService.get('encodedToken').split(".")[1]));
                    var cu = {};
                    cu.username = token.username;
                    cu.name = token.name;
                    cu.email = token.email;
                    cu.cedula = token.cedula;
                    cu.profile_picture = token.profile_picture;
                    localStorageService.set('currentUser', cu);
                    if ($location.search().red != null){
                        $window.location.href = $base64.decode($location.search().red);
                        swal.close();
                    }else{
                        swal.close();
                        $state.go('app.dashboard');
                    }

                }else{
                    responseHandlingService.evaluate(response.status, response.msg)
                }
            }, function (data) {
                swal(data, "error");
            });
        };

    }]);
'use strict';

/**
 * @ngdoc function
 * @description
 * # MainCtrl
 * Controller of the app
 */

  app.controller('MainCtrl',['$scope','$http', 'localStorageService', '$window', '$state', '$rootScope', function ($scope, $http, localStorageService, $window, $state, $rootScope) {
    

    
  }]);

/**
 * Created by fr3d0 on 7/25/16.
 */
'use strict';
app.controller("classesPlanificationController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var getClassesPlan = function(){
            dawProcessManagerService.getClassesPlaning($stateParams.id, function (response)  {
                var data = response.data;
                $scope.subject = data.subject;
                $scope.tableParams = new NgTableParams({},{
                    filterOptions: { filterLayout: "horizontal" },
                    dataset: data.classesPlaning
                });
            }, function(error) {
                alert(error);
            })
        };


        getClassesPlan();
    }]);

/**
 * Created by fr3d0 on 27/07/16.
 */
'use strict';
app.controller("editClassPlanController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        
    }]);

/**
 * Created by fr3d0 on 26/07/16.
 */
'use strict';
app.controller("subjectPlannificationListController",['$scope', 'ENV', 'dawProcessManagerService', 'localStorageService', '$location', '$base64','$window','$state','$stateParams', 'responseHandlingService', 'NgTableParams', '$filter',
    function ($scope, ENV, dawProcessManagerService, localStorageService, $location, $base64, $window,$state,$stateParams, responseHandlingService, NgTableParams, $filter){
        var subjectsPlaning = function(){
            dawProcessManagerService.getSubjectsPlaning(function (response)  {
                $scope.spList = response.data;
            }, function(error) {
                alert(error);
            })
        };


        subjectsPlaning();
    }]);

/**
 * Created by fr3d0 on 26/07/16.
 */

/**
 * Created by fr3d0 on 26/07/16.
 */

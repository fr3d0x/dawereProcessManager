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
  'ngTable',
  'ngFileUpload'
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
    $translateProvider.preferredLanguage('es');
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
            url: '/subjects?id',
            controller: 'subjectListController',
            templateUrl: 'views/sharedNavigation/subjectList.html'
        })

        .state('app.createSubject', {
            url: '/createSubject',
            controller: 'createSubjectController',
            templateUrl: 'views/sharedNavigation/createSubject.html'
        })
        
        .state('app.createTeacher', {
            url: '/createTeacher',
            controller: 'createTeacherController',
            templateUrl: 'views/sharedNavigation/createTeacher.html'
        })

        //pre-production
        .state('app.preProduction', {
            url: '/preProduction',
            template: '<div ui-view></div>'
        })

        .state('app.preProduction.classesPlanification', {
            url: '/classesPlanification?id',
            controller: 'classesPlanificationController',
            templateUrl: 'views/pre-production/classesPlanification.html'
        })

        .state('app.preProduction.showClassPlan', {
            url: '/showClassPlan?id',
            controller: 'showClassPlanController',
            templateUrl: 'views/pre-production/showClassPlan.html'
        })
        
        .state('app.preProduction.createPlanification',{
            url: '/createPlanification',
            controller: 'createPlanificationController',
            templateUrl: 'views/pre-production/createPlanificationForm.html'
        })
        
        .state('app.preProduction.editClassPlan', {
            url: '/editClassPlan?id',
            controller: 'editClassPlanController',
            templateUrl: 'views/pre-production/editClassPlan.html'
        })

        .state('app.preProduction.cpHistory', {
            url: '/cpHistoryById?id',
            controller: 'cpHistoryController',
            templateUrl: 'views/pre-production/cpHistory.html'
        })

        //VDM
        .state('app.vdm', {
            url: '/vdm',
            template: '<div ui-view></div>'
        })
        
        .state('app.vdm.vdmList', {
            url: '/vdmBySubject?id',
            controller: 'vdmsController',
            templateUrl: 'views/VDM/vdms.html'
        })

        .state('app.vdm.showVdm', {
            url: '/vdm?id',
            controller: 'showVdmController',
            templateUrl: 'views/VDM/showVdm.html'
        })

        .state('app.vdm.vdmsHistory', {
            url: '/vdmsHistorybySubject?id',
            controller: 'vdmsHistoryController',
            templateUrl: 'views/VDM/vdmsHistory.html'
        })

        //SUBJECT

        .state('app.subject',{
            url: '/subject',
            template: '<div ui-view></div>'
        })

        .state('app.subject.createSubject',{
            url: '/createSubject',
            controller: 'createSubjectController',
            templateUrl: "views/pre-production/createSubject.html"
        })

        
  }]);


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
                    }else{
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
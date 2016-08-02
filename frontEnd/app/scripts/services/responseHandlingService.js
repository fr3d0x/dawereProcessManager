/**
 * Created by fr3d0 on 7/23/16.
 */
'use strict';
app.service('responseHandlingService',function(){

    this.evaluate = function(status, msg){
        var title;
        var motive;

        switch (status){
            case "UNAUTHORIZEDLOGIN":
                title = "Usuario o clave invalida";
                motive = "warning";
                break;
            case "FAILED":
                title = "FALLIDO";
                motive = "warning";
                break;
            case "UNAUTHORIZED":
                title = "NO AUTORIZADO";
                motive = "warning";
                break;
            default :
                title = "ERROR";
                motive = "warning";
                msg = "Fallo de conexion";
        }
        swal(title, msg, motive);
    }
});
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
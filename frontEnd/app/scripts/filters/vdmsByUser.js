/**
 * Created by fr3d0 on 8/9/16.
 */
app.filter('vdmsByUser', function() {
    return function(vdms, user) {
        return vdms.filter(function() {

            for (var i in vdms) {
                if (vdms[i].prodAssignment != null) {
                    if(vdms[i].prodAssignment.user_id === user.id){
                        return true;
                    }
                }
            }
            return false;
        });
    };
});
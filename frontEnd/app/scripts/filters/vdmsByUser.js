/**
 * Created by fr3d0 on 8/9/16.
 */
app.filter('vdmsByUser', function() {
    return function(vdms, user, role) {
        filtered = [];
        switch (role){
            case 'editor':
                for(var i = 0; i < vdms.length; i++){
                    var vdm = vdms[i];
                    if (vdm.prodDept.assignment != null) {
                        if(vdm.prodDept.assignment.user_id === user.id && vdm.prodDept.assignment.status != 'no asignado'){
                            filtered.push(vdm)
                        }
                    }
                }
                break;
        }
        return filtered;
    };
});
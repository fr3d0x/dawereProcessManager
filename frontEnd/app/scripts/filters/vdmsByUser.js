/**
 * Created by fr3d0 on 8/9/16.
 */
app.filter('vdmsByUser', function() {
    return function(vdms, user, role) {
        filtered = [];
            for(var i = 0; i < vdms.length; i++){
                var vdm = vdms[i];
                switch (role){
                    case 'editor':
                        if (vdm.prodDept.assignment != null) {
                            if(vdm.prodDept.assignment.user_id === user.id && vdm.prodDept.assignment.status != 'no asignado'){
                                filtered.push(vdm)
                            }
                        }
                        break;
                    case 'designer':
                        if (vdm.designDept.assignment != null) {
                            if(vdm.designDept.assignment.user_id === user.id && vdm.designDept.assignment.status != 'no asignado'){
                                filtered.push(vdm)
                            }
                        }
                        break;
                    case 'post-producer':
                        if (vdm.postProdDept.assignment != null) {
                            if(vdm.postProdDept.assignment.user_id === user.id && vdm.postProdDept.assignment.status != 'no asignado'){
                                filtered.push(vdm)
                            }
                        }
                        break;
                }

            }

        return filtered;
    };
});
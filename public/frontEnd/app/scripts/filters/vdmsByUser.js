/**
 * Created by fr3d0 on 8/9/16.
 */
app.filter('vdmsByUser', function() {
    return function(vdms, user, role) {
        var filtered = [];
            for(var i = 0; i < vdms.length; i++){
                var vdm = vdms[i];
                switch (role){
                    case 'editor':
                        if(vdm.prodDept != null && vdm.prodDept != undefined){
                            if (vdm.prodDept.assignment != null) {
                                if(vdm.prodDept.assignment.user_id === user.id && vdm.prodDept.assignment.status != 'no asignado'){
                                    filtered.push(vdm)
                                }
                            }
                        }
                        break;
                    case 'designer':
                        if(vdm.designDept != null && vdm.designDept != undefined){
                            if (vdm.designDept.assignment != null) {
                                if(vdm.designDept.assignment.user_id === user.id && vdm.designDept.assignment.status != 'no asignado'){
                                    filtered.push(vdm)
                                }
                            }
                        }
                        break;
                    case 'post-producer':
                        if(vdm.postProdDept != null && vdm.postProdDept != undefined){
                            if (vdm.postProdDept.assignment != null) {
                                if(vdm.postProdDept.assignment.user_id === user.id && vdm.postProdDept.assignment.status != 'no asignado'){
                                    filtered.push(vdm)
                                }
                            }
                        }
                        break;
                    case 'qa-analyst':
                        if(vdm.qa != null && vdm.qa != undefined){
                            if (vdm.qa.assignment != null) {
                                if(vdm.qa.assignment.user_id === user.id && vdm.qa.assignment.status != 'no asignado'){
                                    filtered.push(vdm)
                                }
                            }
                        }
                        break;
                }

            }

        return filtered;
    };
});
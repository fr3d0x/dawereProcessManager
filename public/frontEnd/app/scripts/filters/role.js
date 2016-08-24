/**
 * Created by fr3d0 on 09/08/16.
 */
app.filter('roles', function() {
    return function(users, roles) {
        return users.filter(function(user) {

            for (var i in user.roles) {
                if (roles.indexOf(user.roles[i].role) != -1) {
                    return true;
                }
            }
            return false;
        });
    };
});
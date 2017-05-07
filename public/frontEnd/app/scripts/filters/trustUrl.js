/**
 * Created by fr3d0 on 4/28/17.
 */
app.filter("trustUrl", ['$sce', function ($sce) {
    return function (url) {
        return $sce.trustAsResourceUrl(url);
    };
}]);
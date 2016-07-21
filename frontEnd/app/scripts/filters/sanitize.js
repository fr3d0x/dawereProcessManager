/**
 * Created by fr3d0 on 07/12/15.
 */
app.filter("sanitizeHtml", ['$sce', function($sce) {
  return function(htmlCode){
    return $sce.trustAsHtml(htmlCode);
  }}]);

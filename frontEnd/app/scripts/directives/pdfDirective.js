/**
 * Created by fr3d0 on 4/12/16.
 */
app.directive('pdf', function() {
  return {
    restrict: 'E',
    replace: true,
    scope: {
      data: '=',
      height: '='
    },

  link: function(scope, element, attrs) {
      var construction = function(){
        var height = scope.height;
        element.html('<object type="application/pdf" data="data:application/pdf;base64, ' + scope.data + ' " style="width:100%; height: '+scope.height+ 'px ;margin-top:20px;margin-bottom:20px"></object>');
      };
      construction();
      scope.$watch("data", function () {
        construction();
      });
      scope.$watch("height", function () {
          construction();
      });
    }
  };
});

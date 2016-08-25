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
        element.html('<iframe type="application/pdf" src="data:application/pdf;base64, ' + scope.data + ' " style="width:100%; height: '+scope.height+ 'px ;margin-top:20px;margin-bottom:20px"></iframe>');
      };
      scope.$watch("data", function () {
          if(scope.data != undefined && scope.data != null){
              construction();
          }
      });
      scope.$watch("height", function () {
          if(scope.data != undefined && scope.data != null){
              construction();
          }
      });
    }
  };
});

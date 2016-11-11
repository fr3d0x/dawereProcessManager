/**
 * Created by fr3d0 on 8/5/16.
 */

app.directive('pdflink', function() {
    return {
        restrict: 'E',
        replace: true,
        scope: {
            data: '=',
            text: '=',
            class: '='
        },

        link: function(scope, element) {
            var construction = function(){
                element.html('<a href= "data:application/pdf;base64, '+scope.data+'" class="'+scope.class+'" target="_blank">'+scope.text+'</a>');
            };
            scope.$watch("data", function () {
                if(scope.data != undefined && scope.data != null && scope.data != ''){
                    construction();
                }
            });
            scope.$watch("text", function () {
                if(scope.text != undefined && scope.text != null && scope.text != ''){
                    construction();
                }
            });
        }
    };
});
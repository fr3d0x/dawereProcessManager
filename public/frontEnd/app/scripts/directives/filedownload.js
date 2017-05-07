/**
 * Created by fr3d0 on 11/11/16.
 */
/**
 * Created by fr3d0 on 4/12/16.
 */
app.directive('filedownload', function() {
    return {
        restrict: 'E',
        replace: true,
        scope: {
            data: '=',
            text: '=',
            class: '=',
            docname: '=',
            doctype: '=',
            extension: '='
        },

        link: function(scope, element) {
            var construction = function(){
                var dat = "";
                if(scope.doctype != null && scope.doctype != undefined && scope.doctype != ''){
                    switch (scope.doctype){
                        case 'pdf':
                            dat = 'data:application/pdf;base64,';
                            break;
                        case 'ppt':
                            dat = 'data:application/vnd.ms-powerpoint;base64,';
                            break;
                        case 'doc':
                            dat = 'data:application/msword;base64,';
                            break;
                    }

                    element.html('<a href='+ dat + scope.data + ' class="'+scope.class+'" download="'+scope.docname + scope.extension+'">'+scope.text+'</a>');
                }
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
            scope.$watch("doctype", function () {
                if(scope.doctype != undefined && scope.doctype != null && scope.doctype != ''){
                    construction();
                }
            });
        }
    };
});
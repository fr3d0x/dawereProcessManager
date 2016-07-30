/**
 * Created by fr3d0 on 7/28/16.
 */
app.directive('underlining',['$timeout',  function($timeout) {
    return {
        restrict: 'E',
        replace: true,
        scope: false,

        link: function(scope, element) {

            $timeout(function () {
                var total_width = element.parent().width();
                var color_width = total_width/3;

                element.html(' <p style="border-bottom: 5px solid #E6E7E8;"> <span  style="color:rgb(231, 232, 233);"></span> </p> ' +
                    '<div id="fbrdr" style="height: 5px; background-color: #ADDBD8; width:'+ color_width + 'px; position: relative ; top: -15px; left: 0;"></div> ' +
                    '<div id="sbrdr" style="height: 5px; background-color: #369291; width:'+ color_width +'px; position: relative; top: -20px;left:' + color_width+ 'px;"></div> ' +
                    '<div id="tbrdr" style="height: 5px; background-color: #135C60; width:' + color_width + 'px; position: relative; top: -25px; left:' + (2*color_width) + 'px;"></div>');
            }, 100);
        }
    };
}]);

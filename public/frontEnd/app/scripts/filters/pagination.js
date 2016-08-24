/**
 * Created by fr3d0 on 10/05/16.
 */

app.filter('startFrom', function() {
  return function(input, start) {
    if (input != undefined && input != null){
      start = +start; //parse to int
      return input.slice(start);
    }
  }
})

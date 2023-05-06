// helper.js
function randomInt(min, max) {
    min = Math.floor(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }
  
  distance = function(dot_a, dot_b) {
    var x, y;
    x = dot_a[0] - dot_b[0];
    y = dot_a[1] - dot_b[1];
    return Math.sqrt(x * x + y * y);
  };

  getLineLength = function(line) {
    return distance([line[0], line[1]], [line[2], line[3]]);
  };

  magnitude = function(vector) {
    return Math.sqrt(vector.x * vector.x + vector.y * vector.y);
  };

  makeVector = function(dot_a, dot_b) {
    var vector;
    vector = {
      x: dot_b[0] - dot_a[0],
      y: dot_b[1] - dot_a[1]
    };
    return vector;
  };

  makeVectorByLine = function(l) {
    return makeVector([l[0], l[1]], [l[2], l[3]]);
  };

  unitVector = function(vector) {
    var r_vector, vector_magnitude;
    vector_magnitude = magnitude(vector);
    return r_vector = {
      x: vector.x / vector_magnitude,
      y: vector.y / vector_magnitude
    };
  };

  vectorPointProduct = function(v1, v2) {
    return v1.x * v2.x + v1.y * v2.y;
  };


  isOutOfBounds = function(dot, world) {
    if (dot[1] > world.h + 3 || dot[0] < -3 || dot[0] > world.w + 3) {
      return true;
    } else {
      return false;
    }
  };
  

  drawBoundingBox = function(line, ctx, color, line_width) {
    if (color == null) {
      color = 'green';
    }
    if (line_width == null) {
      line_width = 1;
    }
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth = line_width;
    ctx.moveTo(Math.floor(line[0]), Math.floor(line[1]));
    ctx.lineTo(Math.floor(line[0]), Math.floor(line[3]));
    ctx.moveTo(Math.floor(line[0]), Math.floor(line[1]));
    ctx.lineTo(Math.floor(line[2]), Math.floor(line[1]));
    ctx.moveTo(Math.floor(line[2]), Math.floor(line[3]));
    ctx.lineTo(Math.floor(line[2]), Math.floor(line[1]));
    ctx.moveTo(Math.floor(line[2]), Math.floor(line[3]));
    ctx.lineTo(Math.floor(line[0]), Math.floor(line[3]));
    return ctx.stroke();
  };

(function() {
  let BG_COLOR, DOT_RADIUS, DOT_U, GRAVITY_Y, LINE_WIDTH, SQUARE_SIDE, VELOCITY_X, VELOCITY_Y, _ANIMATION_FRAME_ID_, _CTX_, _C_, _DEBUG_, _DOT_CTX_, _DOT_C_, _IF_FIRST_TIME_EVER_, _LINE_UPDATE_, _LOCATION_, _SURRENDER_BUTTON_, _VCTX_, _VC_, _W_, applyGravityToDot, bounceDot, bounceLineNormal, copy, createLine, createRandomLine, d, draw, drawDot, drawDots, drawLine, drawLines, drawSquare, drawTempLine, getInputCoordinates, initWorld, isDotLineCollision, isDotSquareCollision, isSurrenderClicked, isWithinBoundingBox, makeDot, makeLine, makeSquare, moveDot, onDrawOut, placePoint, pointOnLineClosestToDot, ragnaroek, resizeCanvas, setFinalLinePoint, setStartLinePoint, setTempLineEndPoint, stackToLine, surrender, tick, update, updateDots, updateLines, velocityBound, writeStuff;

  _DEBUG_ = false;

  _IF_FIRST_TIME_EVER_ = true;

  _W_ = {};

  _ANIMATION_FRAME_ID_ = 0;

  VELOCITY_Y = 3.5;

  VELOCITY_X = 0;

  DOT_RADIUS = 4;

  DOT_U = 6;

  GRAVITY_Y = 0.0138;

  SQUARE_SIDE = 35;

  BG_COLOR = '#f5f5f5';
  //BG_COLOR = 'rgba(236, 236, 236, 1)';


  LINE_WIDTH = 2;

  _LOCATION_ = window.document.body;

  _LINE_UPDATE_ = true;

  _VC_ = document.createElement('canvas');

  _VC_.id = 'vc';

  _VCTX_ = _VC_.getContext('2d');

  _VC_.style.backgroundColor = BG_COLOR;

  _C_ = document.createElement('canvas');

  _C_.style.backgroundColor = BG_COLOR;

  _CTX_ = _C_.getContext('2d');

  _DOT_C_ = document.createElement('canvas');

  _DOT_CTX_ = _DOT_C_.getContext('2d');

  _DOT_C_.id = 'dot_canvas';

  _DOT_C_.style.zIndex = _VC_.style.zIndex + 1;

  _DOT_C_.style.background = 'transparent';

  _SURRENDER_BUTTON_ = document.createElement('button');

  _SURRENDER_BUTTON_.id = 'surrender_button';

  _SURRENDER_BUTTON_.innerHTML = 'Surrender';


  _VCTX_.imageSmoothingEnabled = false;
  _CTX_.imageSmoothingEnabled = false;
  _DOT_CTX_.imageSmoothingEnabled = false;


  resizeCanvas = function() {
    var bounds;
    _VC_.style.position = _DOT_C_.style.position = 'absolute';
    
    bounds = _LOCATION_ === window.document.body ? {
      top: "0px",
      left: "0px",
      width: _LOCATION_.clientWidth - 1,
      height: _LOCATION_.clientHeight - 1
    } : _LOCATION_.getBoundingClientRect();
    
    _VC_.width = _C_.width = _DOT_C_.width = bounds.width;
    _VC_.height = _C_.height = _DOT_C_.height = bounds.height;
    _VC_.style.top = _DOT_C_.style.top = bounds.top;
    _VC_.style.left = _DOT_C_.style.left = bounds.left;
    
    return null;
  };
  

  initWorld = (wins = 0, average_lines = 0) => {
    resizeCanvas();
    _W_.dots = [];
    _W_.lines = [];
    _W_.line_point_stack = [];
    _W_.h = _C_.height;
    _W_.w = _C_.width;
    _W_.time_since_last_circle = 0;
    _W_.square = makeSquare();
    _W_.dots.push(makeDot());
    _W_.end = false;
    _W_.won = false;
    _W_.pointer_down = false;
    _W_.temp_line_end_point = null;
    _W_.wins = wins;
    _W_.average_lines = Math.round(average_lines * 100) / 100;
  
    if (_W_.wins > 0) {
      const results = [];
      for (let k = 1, ref = _W_.wins; k <= ref; k++) {
        results.push(createRandomLine(_W_));
      }
      return results;
    }
  };
  

  d = (msg) => {
    if (_DEBUG_) {
      console.log(msg);
    }
    return msg;
  };

  copy = ()  =>  {
    return _VCTX_.drawImage(_C_, 0, 0);
  };

  window.startLsd = (wins = 0, average_lines = 0, location = _LOCATION_) => {
    _LOCATION_ = location;
  
    if (_IF_FIRST_TIME_EVER_) {
      _LOCATION_.appendChild(_VC_);
      _LOCATION_.appendChild(_DOT_C_);
      _LOCATION_.appendChild(_SURRENDER_BUTTON_);
      _IF_FIRST_TIME_EVER_ = false;
    }
  
    initWorld(wins, average_lines);
    return tick();
  };
  
  tick = () => {
    if (!_W_.end) {
      _ANIMATION_FRAME_ID_ = requestAnimationFrame(tick);
      update(_W_);
      return draw(_W_, _CTX_);
    } else {
      ragnaroek(_W_);
      copy();
      return window.cancelAnimationFrame(_ANIMATION_FRAME_ID_);
    }
  };
  

  ragnaroek = function(world) {
    var av, wins;
    if (world.won === true) {
      drawSquare(world.square, _CTX_, true);
      wins = _W_.wins + 1;
      if (wins > 1) {
        av = (_W_.average_lines + _W_.lines.length) / 2;
      } else {
        av = _W_.lines.length;
      }
    } else {
      wins = _W_.wins - 1;
      if (wins < 0) {
        wins = 0;
      }
      av = _W_.average_lines;
    }
    drawDots(world.dots, _DOT_CTX_, BG_COLOR);
    if (_W_.end === true) {
      if (_W_.won === false) {
        return setTimeout(startLsd, 200, wins, av);
      } else {
        return setTimeout(startLsd, 1000, wins, av);
      }
    }
  };

  update = function(world) {
    world = updateDots(world);
    stackToLine(world.line_point_stack);
    return world;
  };

  draw = function(world, ctx, line_update = _LINE_UPDATE_) {
    drawDots(world.dots, _DOT_CTX_);
    if (line_update === true) {
      _LINE_UPDATE_ = false;
      ctx.fillStyle = BG_COLOR;
      ctx.fillRect(0, 0, world.w, world.h);
      drawLines(world.lines, ctx);
      drawSquare(world.square, ctx);
      drawTempLine(world, ctx);
      writeStuff(world, ctx);
      return copy();
    }
  };



  writeStuff = function(world, ctx) {
      if (world == null) {
        world = _W_;
      }
    
      const writeText = document.createElement('div');
      writeText.className = 'level-text';
      writeText.textContent = "Level " + world.wins;
    
      if (document.getElementById('level-text')) {
        document.getElementById('level-text').remove();
      }
      writeText.id = 'level-text';
      _LOCATION_.appendChild(writeText);
    };
    
    
    

  makeDot = function(x, y) {
    var a;
    if (x == null) {
      x = Math.floor(_W_.w / 2);
    }
    if (y == null) {
      y = 10;
    }
    a = [x, y];
    a.velocity = {};
    a.velocity.x = VELOCITY_X;
    a.velocity.y = VELOCITY_Y;
    return a;
  };

  makeLine = function(x1, y1, x2, y2, color = LINE_COLOR) {
      _LINE_UPDATE_ = true;
      return [x1, y1, x2, y2, color];
    };
    

createLine = function(x1, y1, x2, y2, color, world) {
if (world == null) {
  world = _W_;
}
if (!color && tempLineColor) {
  color = tempLineColor; // Use the temporary line's color
}
else
{
  color = getRandomColor();
}
return world.lines.push(makeLine(x1, y1, x2, y2, color));
};



drawLine = function(line, ctx, is_temp_line = false, line_width = LINE_WIDTH) {
let color = line[4];

//console.log("Color "+color);
//console.log("temp line color: " + tempLineColor)
//console.log("line color: " + tempLineColor)
ctx.beginPath();
ctx.moveTo(Math.floor(line[0]), Math.floor(line[1]));
ctx.lineTo(Math.floor(line[2]), Math.floor(line[3]));
ctx.lineWidth = line_width;
if(!getBlackAndWhite())
{
  ctx.strokeStyle = is_temp_line ? tempLineColor : (color || getRandomColor());
}
else
{
  ctx.strokeStyle = "black";
}
//ctx.strokeStyle = color;
ctx.setLineDash(is_temp_line ? [4, 2] : []);
ctx.stroke();
ctx.closePath();
};


drawLines = function(lines, ctx) {
for (const line of lines) {
  drawLine(line, ctx);
}
};

drawTempLine = function(world, ctx) {
if (world && world.temp_line_end_point && world.line_point_stack[0] && ctx) {
  if(!tempLineColor)
  {
    tempLineColor = getRandomColor();
  }
  drawLine([world.line_point_stack[0][0], world.line_point_stack[0][1], world.temp_line_end_point[0], world.temp_line_end_point[1]], ctx, true, LINE_WIDTH * 1);
}
else
{
  tempLineColor = null;
}
};




    
    
    createRandomLine = function(world) {
      temprandomcolor = null;
      var x1, x2, y1, y2;
      if (world == null) {
        world = _W_;
      }
      x1 = randomInt(0, _W_.w);
      y1 = randomInt(0 + 10, _W_.h);
      x2 = randomInt(0, _W_.w);
      y2 = randomInt(0 + 10, _W_.h);
      if (y1 < 40 && y2 < 40) {
        if (y1 <= y2) {
          y2 = randomInt(_W_.h / 2, _W_.h);
        } else {
          y1 = randomInt(_W_.h / 2, _W_.h);
        }
      }
      return createLine(x1, y1, x2, y2, getRandomColor(), _W_);
    };
    

  isWithinBoundingBox = function(dot, line) {
    var dx, dy, exf, within_x, within_y, x1, x2, y1, y2;
    dx = dot[0], dy = dot[1];
    x1 = line[0], y1 = line[1], x2 = line[2], y2 = line[3];
    exf = 20;
    within_x = ((x1 <= x2) && (dx >= x1 - exf) && (dx <= x2 + exf)) || ((x1 >= x2) && (dx <= x1 + exf) && (dx >= x2 - exf)) || (dx === x1) || (dx === x2);
    within_y = ((y1 <= y2) && (dy >= y1 - exf) && (dy <= y2 + exf)) || ((y1 >= y2) && (dy <= y1 + exf) && (dy >= y2 - exf)) || (dy === y1) || (dy === y2);
    return within_x && within_y;
  };

  updateDots = function(world) {
    var dot, i, j, k, last_collision_dot, last_collision_line, len, len1, line, m, ref, ref1;
    last_collision_line = null;
    last_collision_dot = null;
    ref = world.dots;
    for (i = k = 0, len = ref.length; k < len; i = ++k) {
      dot = ref[i];
      ref1 = world.lines;
      for (j = m = 0, len1 = ref1.length; m < len1; j = ++m) {
        line = ref1[j];
        if (isWithinBoundingBox(dot, line)) {
          if (isDotLineCollision(dot, line)) {
            bounceDot(dot, line);
            last_collision_line = line;
            last_collision_dot = dot;
          }
        }
      }
      dot = moveDot(dot);
      if (last_collision_line && last_collision_dot && isDotLineCollision(last_collision_dot, last_collision_line)) {
        moveDot(dot, 0.5);
      }
      if (isDotSquareCollision(dot, _W_.square)) {
        world.end = true;
        world.won = true;
      }
      if (isOutOfBounds(dot, world)) {
        world.end = true;
        world.won = false;
      }
    }
    return world;
  };

  updateLines = function(world) {
    return world;
  };

  drawDot = function(dot, dot_ctx, fill_style) {
    if (fill_style == null) {
      fill_style = "black";
    }
    dot_ctx.clearRect(dot[0] - 15, dot[1] - 15, 30, 30);
    dot_ctx.beginPath();
    dot_ctx.arc(dot[0], dot[1], DOT_RADIUS, 0, Math.PI * 2, true);
    dot_ctx.closePath();
    dot_ctx.strokeStyle = "rgba(0, 0, 0, 1)";
    dot_ctx.fillStyle = fill_style;
    dot_ctx.fill();
    return dot_ctx.stroke();
  };

  drawDots = function(dots, dot_ctx, fill_style) {
    var dot, k, len, results;
    if (dot_ctx == null) {
      dot_ctx = _DOT_CTX_;
    }
    if (fill_style == null) {
      fill_style = "black";
    }
    results = [];
    for (k = 0, len = dots.length; k < len; k++) {
      dot = dots[k];
      results.push(drawDot(dot, dot_ctx, fill_style));
    }
    return results;
  };



  function getRandomColor() {
      // Initialize hue to a random value based on the golden ratio
      let hue = Math.random() * (1 + 0.618033988749895 - 0.381966011250105) + 0.381966011250105;
    
      // Use the hue to generate a random color in the HSL color space
      return "hsl(" + (hue * 360) + ", 100%, 50%)";
    }
    
    
    
    let tempLineColor;    


    
  
 


  makeSquare = function(x, y) {
    if (x == null) {
      x = randomInt(SQUARE_SIDE + 2, _W_.w - (SQUARE_SIDE + 2));
    }
    if (y == null) {
      y = randomInt(SQUARE_SIDE + 2, _W_.h - (SQUARE_SIDE + 2));
    }
    _LINE_UPDATE_ = true;
    return [x, y];
  };

  drawSquare = function(p, ctx, fill) {
    var prev_stroke_style, x, y;
    if (ctx == null) {
      ctx = _CTX_;
    }
    if (fill == null) {
      fill = false;
    }
    x = p[0], y = p[1];
    prev_stroke_style = ctx.strokeStyle;
    ctx.lineWidth = LINE_WIDTH;
    ctx.setLineDash([]);
    ctx.beginPath();
    ctx.rect(x, y, SQUARE_SIDE, SQUARE_SIDE);
    ctx.strokeStyle = "rgba(0, 0, 0, 1)";
    ctx.stroke();
    if (fill === true) {
      ctx.fillStyle = "black";
      ctx.fill();
    }
    ctx.strokeStyle = prev_stroke_style;
    return ctx.closePath();
  };



  pointOnLineClosestToDot = (dot, line) => {
    const unitVec = unitVector(makeVectorByLine(line));
    const endVec = makeVector([line[0], line[1]], dot);
    const proj = vectorPointProduct(endVec, unitVec);
  
    if (proj <= 0) {
      return [line[0], line[1]];
    }
    if (proj >= getLineLength(line)) {
      return [line[2], line[3]];
    }
    return [line[0] + unitVec.x * proj, line[1] + unitVec.y * proj];
  };
  

  isDotSquareCollision = function(dot, square) {
    var dx, dy, sx, sy;
    dx = dot[0], dy = dot[1];
    sx = square[0], sy = square[1];
    if (dx > sx && dx < sx + SQUARE_SIDE) {
      if (dy > sy && dy < sy + SQUARE_SIDE) {
        return true;
      }
    }
    return false;
  };



  isDotLineCollision = function(dot, line) {
    var closest, r;
    closest = pointOnLineClosestToDot(dot, line);
    r = distance(dot, closest) < DOT_RADIUS;
    return r;
  };

  moveDot = function(dot, factor) {
    if (factor == null) {
      factor = 1;
    }
    dot[0] = dot[0] + (dot.velocity.x * factor);
    dot[1] = dot[1] + (dot.velocity.y * factor);
    dot = applyGravityToDot(dot);
    return dot;
  };

  applyGravityToDot = function(dot) {
    var pref_y;
    pref_y = dot.velocity.y;
    dot.velocity.y = dot.velocity.y + GRAVITY_Y;
    if (dot.velocity.y === 0 && dot.velocity.x === 0) {
      if (pref_y >= 0) {
        dot.velocity.y - (GRAVITY_Y * 0.01);
      } else {
        dot.velocity.y + (GRAVITY_Y * 0.01);
      }
    }
    dot = velocityBound(dot);
    return dot;
  };

  velocityBound = function(dot) {
    if (dot.velocity.y > VELOCITY_Y) {
      dot.velocity.y = VELOCITY_Y;
    }
    return dot;
  };

  bounceDot = (dot, line) => {
    const lineNormal = bounceLineNormal(dot, line);
    const vecProd = vectorPointProduct(dot.velocity, lineNormal);
    dot.velocity.x -= 2 * vecProd * lineNormal.x;
    dot.velocity.y -= 2 * vecProd * lineNormal.y;
    return velocityBound(dot);
  };
  
  bounceLineNormal = (dot, line) => {
    const dotToClosest = makeVector(pointOnLineClosestToDot(dot, line), dot);
    return unitVector(dotToClosest);
  };
  

  getInputCoordinates = function(e) {
    var ex, ey, rect, ref, ref1, ref2, ref3, ref4, x, y;
    rect = _VC_.getBoundingClientRect();
    ex = e.pageX || (e != null ? (ref = e.touches) != null ? (ref1 = ref[0]) != null ? ref1.clientX : void 0 : void 0 : void 0);
    ey = e.pageY || (e != null ? (ref2 = e.touches) != null ? (ref3 = ref2[0]) != null ? ref3.clientY : void 0 : void 0 : void 0);
    if (e.type === 'touchend' || e.type === 'mouseup' || e.type === "pointerup") {
      if (_W_.temp_line_end_point) { // Check if _W_.temp_line_end_point exists
        ref4 = _W_.temp_line_end_point, ex = ref4[0], ey = ref4[1];
        _W_.temp_line_end_point = null;
      }
    }
    x = ex - _VC_.offsetLeft;
    y = ey - _VC_.offsetTop;
    return [x, y];
  };
  

  placePoint = function(point, world) {
    return world.line_point_stack.push(point);
  };

  isSurrenderClicked = function(point, world) {
    var x, y;
    if (world == null) {
      world = _W_;
    }
    x = point[0], y = point[1];
    if (x > (world.w - 100) && y < 40) {
      world = surrender();
      return true;
    }
    return false;
  };


  let BLACK_AND_WHITE = sessionStorage.getItem('black_and_white') === 'true' || false;

  function setBlackAndWhite(value) {
    BLACK_AND_WHITE = value;
    sessionStorage.setItem('black_and_white', value);
  }
  
  function getBlackAndWhite() {
    return BLACK_AND_WHITE;
  }
  
  function toggleBlackAndWhite() {
    BLACK_AND_WHITE = !BLACK_AND_WHITE;
    sessionStorage.setItem('black_and_white', BLACK_AND_WHITE);
    return BLACK_AND_WHITE;
  }
  

const isLevelTextClicked = (e) => {
const levelText = document.getElementById("level-text");
const rect = levelText.getBoundingClientRect();
const x = e.clientX;
const y = e.clientY;
if (x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom) {
  black_and_white = toggleBlackAndWhite();
  draw(_W_, _CTX_, true);
  return true;
}
return false;
}




  window.surrender = surrender = function(world) {
    if (world == null) {
      world = _W_;
    }
    world.end = true;
    world.won = false;
    return _W_;
  };

  setStartLinePoint = function(e) {
    var point;
    e.preventDefault();
    _W_.line_point_stack = [];
    point = getInputCoordinates(e);
    if (isSurrenderClicked(point) === false && isLevelTextClicked(e) === false) {
      placePoint(point, _W_);
      return _W_.pointer_down = true;
    }
    
  };

  setFinalLinePoint = function(e) {
    var point;
    e.preventDefault();
    point = getInputCoordinates(e);
    placePoint(point, _W_);
    
    //console.log(point);
    //createLine(_W_.line_point_stack[0][0], _W_.line_point_stack[0][1], point[0], point[1], tempLineColor);
    return _W_.pointer_down = false;
  };

  setTempLineEndPoint = function(e) {
    e.preventDefault();
    if (_W_.pointer_down === true) {
      _LINE_UPDATE_ = true;
      return _W_.temp_line_end_point = getInputCoordinates(e);
    }
  };

  onDrawOut = function(e) {
    e.preventDefault();
    return setFinalLinePoint(e);
  };

  stackToLine = function(stack) {
    var end_point, start_point;
    if (stack.length > 1) {
      end_point = stack.pop();
      start_point = stack.pop();
      return createLine(start_point[0], start_point[1], end_point[0], end_point[1]);
    }
  };

  _DOT_C_.addEventListener('mousedown', function(e) {
    return setStartLinePoint(e);
  });

  _DOT_C_.addEventListener('touchstart', function(e) {
    return setStartLinePoint(e);
  });

  _DOT_C_.addEventListener('mouseup', function(e) {
    return setFinalLinePoint(e);
  });

  _DOT_C_.addEventListener('touchend', function(e) {
    return setFinalLinePoint(e);
  });

  _DOT_C_.addEventListener('mousemove', function(e) {
    return setTempLineEndPoint(e);
  });

  _DOT_C_.addEventListener('touchmove', function(e) {
    return setTempLineEndPoint(e);
  });

  _DOT_C_.addEventListener('mouseout', function(e) {
    return onDrawOut(e);
  });

  _DOT_C_.addEventListener('touchleave', function(e) {
    return onDrawOut(e);
  });

  _DOT_C_.addEventListener('touchcancel', function(e) {
    return onDrawOut(e);
  });

  window.document.body.addEventListener('touchmove', function(e) {
    return e.preventDefault();
  });

  window.addEventListener('resize', function() {
    return surrender();
  }, false);



}).call(this);

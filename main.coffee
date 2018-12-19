

_DEBUG_ = false
_IF_FIRST_TIME_EVER_ = true
_W_ = {}
_ANIMATION_FRAME_ID_ = 0

VELOCITY_Y = 3.5
VELOCITY_X = 0
DOT_RADIUS = 3
DOT_U = 6
GRAVITY_Y = 0.0138
SQUARE_SIDE = 35
BG_COLOR = '#ececec'
LINE_WIDTH = 1

_LOCATION_ = window.document.body
_LINE_UPDATE_ = true

#visual canvas 
_VC_ = document.createElement('canvas') #document.getElementById('lsd')
_VC_.id = 'vc'
_VCTX_ = _VC_.getContext('2d')
_VC_.style.backgroundColor = BG_COLOR

#VIRTUAL canvas
_C_ =  document.createElement('canvas')#document.getElementById('lsd')
_C_.style.backgroundColor = BG_COLOR
_CTX_ = _C_.getContext('2d')

#DOT ONLY CANVAS
_DOT_C_ = document.createElement('canvas')
_DOT_CTX_ =_DOT_C_.getContext('2d')
_DOT_C_.id = 'dot_canvas'
_DOT_C_.style.zIndex = _VC_.style.zIndex + 1
_DOT_C_.style.background = 'transparent'


_SURRENDER_BUTTON_ = document.createElement('button')
_SURRENDER_BUTTON_.id = 'surrender_button'
_SURRENDER_BUTTON_.innerHTML = 'Surrender'

_BUTTONSTYLE_ = document.createElement('style')
_BUTTONSTYLE_.innerText = '#surrender_button {
  display: inline-block;
  position: relative;
  color: #888;
  text-shadow: 0 1px 0 rgba(255,255,255, 0.8);
  text-decoration: none;
  text-align: center;
  padding: 8px 12px;
  font-size: 12px;
  font-weight: 700;
  font-family: helvetica, arial, sans-serif;
  border-radius: 4px;
  border: 1px solid #bcbcbc;

  -webkit-box-shadow: 0 1px 3px rgba(0,0,0,0.12);
  box-shadow: 0 1px 3px rgba(0,0,0,0.12);

  background-image: -webkit-linear-gradient(top, rgba(255,255,255,1) 0%,rgba(239,239,239,1) 60%,rgba(225,223,226,1) 100%);
  background-image: -moz-linear-gradient(top, rgba(255,255,255,1) 0%,rgba(239,239,239,1) 60%,rgba(225,223,226,1) 100%);
  background-image: -o-linear-gradient(top, rgba(255,255,255,1) 0%,rgba(239,239,239,1) 60%,rgba(225,223,226,1) 100%);
  background-image: -ms-linear-gradient(top, rgba(255,255,255,1) 0%,rgba(239,239,239,1) 60%,rgba(225,223,226,1) 100%);
  background-image: linear-gradient(top, rgba(255,255,255,1) 0%,rgba(239,239,239,1) 60%,rgba(225,223,226,1) 100%);
}'


resizeCanvas = () ->
  _VC_.style.position = _DOT_C_.style.position = 'absolute'

  if _LOCATION_ is window.document.body
    #d('_LOCATION_ IS document.body')
    bounds = 
      top: "0px"
      left: "0px"
      width: _LOCATION_.clientWidth-1
      height: _LOCATION_.clientHeight-1
  else
    bounds = _LOCATION_.getBoundingClientRect()
  
  _VC_.width = _C_.width = _DOT_C_.width = bounds.width
  _VC_.height = _C_.height = _DOT_C_.height = bounds.height
  _VC_.style.top = _DOT_C_.style.top = bounds.top
  _VC_.style.left = _DOT_C_.style.left = bounds.left

  _SURRENDER_BUTTON_.style.position = 'absolute'
  _SURRENDER_BUTTON_.style.top = 3 + parseInt(_VC_.style.top)
  _SURRENDER_BUTTON_.style.left = parseInt(_VC_.width-86)
  #console.log(_SURRENDER_BUTTON_)

initWorld = (wins = 0, average_lines = 0) ->
  resizeCanvas()
  _W_.dots = []
  _W_.lines = []
  _W_.line_point_stack = []
  _W_.h = _C_.height
  _W_.w = _C_.width
  _W_.time_since_last_circle = 0
  _W_.square = makeSquare()
  _W_.dots.push(makeDot())
  _W_.end = false
  _W_.won = false #won = false means loss or surrender
  _W_.pointer_down = false
  _W_.temp_line_end_point = null
  _W_.wins = wins
  _W_.average_lines = ( Math.round(average_lines * 100) / 100 )

  if _W_.wins > 0
    for [1 .. _W_.wins]
      createRandomLine(_W_)

d = (msg) ->
  console.log(msg) if _DEBUG_ 
  return msg


copy = () ->
  _VCTX_.drawImage(_C_, 0, 0)

window.startLsd = (wins = 0, average_lines = 0, location = _LOCATION_) -> 
  _LOCATION_ = location 
  if _IF_FIRST_TIME_EVER_ is true 
    _LOCATION_.appendChild(_VC_)
    _LOCATION_.appendChild(_DOT_C_)
    _LOCATION_.appendChild(_SURRENDER_BUTTON_)
    _LOCATION_.appendChild(_BUTTONSTYLE_)
    _IF_FIRST_TIME_EVER_ = false
  initWorld(wins, average_lines)
  tick()

tick = () ->
  if not _W_.end 
    _ANIMATION_FRAME_ID_ = requestAnimationFrame(tick)
    update(_W_)
    draw(_W_, _CTX_)
  else
    ragnaroek(_W_)
    copy()
    window.cancelAnimationFrame(_ANIMATION_FRAME_ID_)

ragnaroek = (world) ->
  if world.won is true
    drawSquare(world.square, _CTX_, true)
    wins = _W_.wins+1
    if wins > 1
      av = (_W_.average_lines + _W_.lines.length) / 2
    else
      av = _W_.lines.length
  else
    wins = _W_.wins-1
    if wins < 0 then wins = 0
    av = _W_.average_lines

  drawDots(world.dots, _DOT_CTX_, BG_COLOR)

  if _W_.end is true
    if _W_.won is false #means surrender or lost
      setTimeout(startLsd, 200, wins, av)
    else
      setTimeout(startLsd, 1000, wins, av)

update = (world) ->
  world = updateDots(world)
  stackToLine(world.line_point_stack)
  return world

draw = (world, ctx) ->
  drawDots(world.dots, _DOT_CTX_)
  if _LINE_UPDATE_ is true
    #d('full canvas update')
    _LINE_UPDATE_ = false 
    ctx.fillStyle = BG_COLOR
    ctx.fillRect(0, 0, world.w, world.h)
    drawLines(world.lines, ctx)
    #drawSquare(world.square, ctx)
    drawSquare(world.square, ctx)
    drawTempLine(world, ctx)
    writeStuff(world, ctx)
    copy() #_VCTX_.drawImage(_C_, 0, 0)


randomInt = (min,max) ->
  min = Math.floor(min)
  max = Math.floor(max)
  return Math.floor(Math.random() * (max - min + 1)) + min

writeStuff = (world = _W_, ctx) ->
  ctx.fillStyle = "black";
  ctx.font = "12px Verdana";
  ctx.fillText("Level "+world.wins, 4, 14)
  #if world.wins < 10
  #  ctx.fillText("Level "+world.wins, world.w-48, 12)
  #else
  #  ctx.fillText("Level "+world.wins, world.w-53, 12)
  #ctx.fillText("Surrender", 2, 12)  
  #drawLine([2,14,63,14], ctx, false, 1)

makeDot = (x = Math.floor(_W_.w/2),y = 10) ->
  a = [x,y]
  a.velocity  = {}
  a.velocity.x = VELOCITY_X
  a.velocity.y = VELOCITY_Y
  return a

makeLine = (x1, y1, x2, y2) ->
  _LINE_UPDATE_ = true
  return [x1,y1,x2,y2]

createLine = (x1, y1, x2, y2, world = _W_) ->
  world.lines.push(makeLine(x1, y1, x2, y2))

createRandomLine = (world = _W_) ->
    x1 = randomInt(0, _W_.w)
    y1 = randomInt(0+10, _W_.h)
    x2 = randomInt(0, _W_.w)
    y2 = randomInt(0+10, _W_.h)

    if y1 < 40 and y2 < 40
      if y1 <= y2
        y2 = randomInt(_W_.h/2, _W_.h)
      else
        y1 = randomInt(_W_.h/2, _W_.h)

    createLine(x1, y1, x2, y2,_W_)

isWithinBoundingBox = (dot, line) ->
  [dx,dy] = dot
  [x1,y1,x2,y2] = line
  exf = 20
  #if x1 <= x2
  #  x1 =+10; x2=-10;
  #else
  #  x2 =+10; x1=-10;
  #
  #if y1 <= y2
  #  y1 =+10; y2=-10;
  #else
  #  y2 =+10; y1=-10;
  within_x = ((x1 <= x2) and (dx >= x1-exf) and (dx <= x2+exf)) or ((x1 >= x2) and (dx <=x1+exf) and (dx >= x2-exf)) or (dx is x1) or (dx is x2)
  within_y = ((y1 <= y2) and (dy >= y1-exf) and (dy <= y2+exf)) or ((y1 >= y2) and (dy <=y1+exf) and (dy >= y2-exf)) or (dy is y1) or (dy is y2)
  return (within_x and within_y)
  #if (within_x and within_y)
  #  d("within x y")
  #  drawBoundingBox(line, _DOT_CTX_, 'pink', 1)
  #  return true
  #else if within_x
  #  d('withinx')
  #  #return true
  #else if within_y
  #  d('withiny')
  #return false


updateDots = (world) ->
  last_collision_line = null 
  last_collision_dot = null 
  for dot, i in world.dots
    for line, j in world.lines
      if isWithinBoundingBox(dot, line)
        if isDotLineCollision(dot, line)
          bounceDot(dot, line)
          last_collision_line = line
          last_collision_dot = dot 
    dot = moveDot(dot)
    if last_collision_line and last_collision_dot and isDotLineCollision(last_collision_dot, last_collision_line)
      #d('dot stuck')
      moveDot(dot, 0.5)
    if isDotSquareCollision(dot, _W_.square)
      #endGame(true, true) #only set the variable here
      world.end = true
      world.won = true
    if isOutOfBounds(dot, world)
      #endGame(true) # only set the variable here
      world.end = true
      world.won = false # surrender 
    #if dot[1] > world.h 
    #  VELOCITY = VELOCITY * -1
  #alert(world)
  return world

updateLines = (world) ->
  return world

drawDot = (dot, dot_ctx, fill_style = "black") ->
  dot_ctx.clearRect(dot[0]-15, dot[1]-15, 30, 30)
  dot_ctx.beginPath()
  dot_ctx.arc(dot[0], dot[1], DOT_RADIUS, 0, Math.PI * 2, true)
  dot_ctx.closePath()
  dot_ctx.strokeStyle = "black"
  dot_ctx.fillStyle = fill_style
  dot_ctx.fill()
  dot_ctx.stroke()



drawDots = (dots, dot_ctx = _DOT_CTX_, fill_style = "black") ->
  for dot in dots
    drawDot(dot, dot_ctx, fill_style)

drawBoundingBox = (line, ctx, color = 'green', line_width = 1) ->
  #drawboundingbox
  ctx.beginPath()
  ctx.strokeStyle = color
  ctx.lineWidth = line_width
  ctx.moveTo(Math.floor(line[0]), Math.floor(line[1]))
  ctx.lineTo(Math.floor(line[0]), Math.floor(line[3]))
  
  ctx.moveTo(Math.floor(line[0]), Math.floor(line[1]))
  ctx.lineTo(Math.floor(line[2]), Math.floor(line[1]))

  ctx.moveTo(Math.floor(line[2]), Math.floor(line[3]))
  ctx.lineTo(Math.floor(line[2]), Math.floor(line[1]))

  ctx.moveTo(Math.floor(line[2]), Math.floor(line[3]))
  ctx.lineTo(Math.floor(line[0]), Math.floor(line[3]))

  #ctx.lineTo(Math.floor(line[1]), Math.floor(line[1]))
  #ctx.lineTo(Math.floor(line[3]), Math.floor(line[0]))
  ctx.stroke()


drawLine = (line, ctx, is_temp_line = false, line_width = LINE_WIDTH) ->
  #drawBoundingBox(line, ctx)


  ctx.beginPath()
  ctx.moveTo(Math.floor(line[0]), Math.floor(line[1]))
  ctx.lineTo(Math.floor(line[2]), Math.floor(line[3]))
  ctx.lineWidth = line_width
  ctx.strokeStyle = "black"
  if is_temp_line then ctx.strokeStyle = "red"
  ctx.stroke()
  ctx.closePath()
  

drawLines = (lines, ctx) ->
  for line in lines
    drawLine(line, ctx)
#(x = randomInt(SQUARE_SIDE*2, _W_.w-SQUARE_SIDE*2),y = randomInt(SQUARE_SIDE*2, _W_.h-SQUARE_SIDE*2)) ->
  
drawTempLine = (world, ctx) ->
  if world.pointer_down is true and world.line_point_stack[0] and world.temp_line_end_point
    #_LINE_UPDATE_ = true
    [sx, sy] = world.line_point_stack[0]
    [tx, ty] = world.temp_line_end_point
    drawLine([sx,sy,tx,ty], ctx, true)




makeSquare = (x = randomInt(SQUARE_SIDE+2, _W_.w-(SQUARE_SIDE+2)), y = randomInt((SQUARE_SIDE+2), _W_.h-(SQUARE_SIDE+2))) -> 
  _LINE_UPDATE_ = true
  return [x,y]

drawSquare = (p, ctx = _CTX_, fill = false) ->
  [x,y] = p
  #ctx.restore()
  #ctx.setLineDash([0,0])
  prev_stroke_style = ctx.strokeStyle
  ctx.beginPath()
  ctx.rect(x,y,SQUARE_SIDE,SQUARE_SIDE)
  ctx.strokeStyle = "black"
  ctx.stroke()
  if fill is true
    ctx.fillStyle = "black"
    ctx.fill()
  ctx.strokeStyle = prev_stroke_style
  ctx.closePath()


distance = (dot_a, dot_b) ->
  x = dot_a[0] - dot_b[0]
  y = dot_a[1] - dot_b[1]
  return Math.sqrt(x*x+y*y)

getLineLength = (line) ->
  return distance([line[0],line[1]], [line[2],line[3]])

magnitude = (vector) ->
  return Math.sqrt(vector.x * vector.x + vector.y * vector.y)

makeVector = (dot_a, dot_b) ->
  vector = 
    x: dot_b[0] - dot_a[0]
    y: dot_b[1] - dot_a[1]
  return vector

makeVectorByLine = (l) ->
  return makeVector(
    [l[0],l[1]],
    [l[2],l[3]]
    )

unitVector = (vector) ->
  vector_magnitude = magnitude(vector)
  r_vector = 
    x: vector.x / vector_magnitude
    y: vector.y / vector_magnitude

vectorPointProduct = (v1, v2) ->
  return v1.x * v2.x + v1.y * v2.y  

pointOnLineClosestToDot = (dot, line) ->
  line_unit_vector = unitVector(makeVectorByLine(line))
  end_of_line_to_dot_vector = makeVector([line[0], line[1]], dot)
  projection = vectorPointProduct(end_of_line_to_dot_vector, line_unit_vector)

  if projection <= 0
    return [line[0], line[1]]
  if projection >= getLineLength(line)
    return [line[2], line[3]]
  r_point = 
    [
      line[0]+line_unit_vector.x*projection,
      line[1]+line_unit_vector.y*projection
    ]

isDotSquareCollision = (dot, square) ->
  [dx, dy] = dot
  #drawSquare(dot)
  [sx, sy] = square #note square is always to upper left corner
  #drawSquare(square)
  if dx > sx and dx < sx + SQUARE_SIDE
    if dy > sy and dy < sy + SQUARE_SIDE
      return true
      
  return false

isOutOfBounds = (dot, world) ->
  if dot[1] > world.h+3 or dot[0] < -3 or dot[0] > world.w + 3
    return true
  else
    return false


isDotLineCollision = (dot, line) ->
  
  closest = pointOnLineClosestToDot(dot, line)
  r = distance(dot, closest) < DOT_RADIUS
  #if r is true
  #  d(dot)
  return r

moveDot = (dot, factor = 1) ->
  dot[0] = dot[0] + (dot.velocity.x * factor)
  dot[1] = dot[1] + (dot.velocity.y * factor)
  dot = applyGravityToDot(dot)
  return dot

applyGravityToDot = (dot) ->
  pref_y = dot.velocity.y
  dot.velocity.y = dot.velocity.y + GRAVITY_Y
  if dot.velocity.y is 0 and dot.velocity.x is 0 
   if pref_y >= 0
     dot.velocity.y - (GRAVITY_Y*0.01)
    else 
      dot.velocity.y + (GRAVITY_Y*0.01)
  dot = velocityBound(dot)
  return dot

velocityBound = (dot) ->
  if dot.velocity.y > VELOCITY_Y then dot.velocity.y = VELOCITY_Y
  return dot

bounceDot = (dot, line) ->

  bounce_line_normal = bounceLineNormal(dot, line)

  dot_to_line_vector_product  = vectorPointProduct(dot.velocity, bounce_line_normal)

  dot.velocity.x = dot.velocity.x - (2 * dot_to_line_vector_product * bounce_line_normal.x)
  dot.velocity.y = dot.velocity.y - (2 * dot_to_line_vector_product * bounce_line_normal.y)
  #method to make sure dot does not get stuck



  #check if y velcity still ok
  dot = velocityBound(dot)
  return dot
  

bounceLineNormal = (dot, line) ->
  dot_to_closest_point_on_line_vector = 
    makeVector(pointOnLineClosestToDot(dot,line),dot)
  #TODO: if line is exact on point Object {x: NaN, y: NaN} is returned
  return unitVector(dot_to_closest_point_on_line_vector)

getInputCoordinates = (e) ->
  rect = _VC_.getBoundingClientRect()
  ex = e.pageX or e?.touches?[0]?.clientX
  ey = e.pageY or e?.touches?[0]?.clientY
  if e.type is 'touchend'  #if ex is 0 and ex is 0 #and e?.touches?.length is 0
    [ex, ey] = _W_.temp_line_end_point
    _W_.temp_line_end_point = null
    #alert(ex+' '+ey)
  x = ex - _VC_.offsetLeft #e.pageX - rect.left #- r/2
  y = ey - _VC_.offsetTop #rect.top #- r/2
  #d(x)
  #d(y)
  return [x,y]

placePoint = (point, world) ->
  world.line_point_stack.push(point)

isSurrenderClicked = (point, world = _W_) ->
  [x,y] = point
  if x > (world.w-80) and y < 38
    world = surrender()
    return true
  return false

window.surrender = surrender = (world = _W_) ->
  world.end = true
  world.won = false # surrender clicked, so lost
  return _W_



setStartLinePoint = (e) ->
  e.preventDefault()
  _W_.line_point_stack = []
  point = getInputCoordinates(e)
  #check if click on surrender
  #d(point)
  if isSurrenderClicked(point) is false
    placePoint(point, _W_)
    _W_.pointer_down = true

setFinalLinePoint = (e) ->
  e.preventDefault()
  point = getInputCoordinates(e)
  placePoint(point, _W_)
  _W_.pointer_down = false


setTempLineEndPoint = (e) ->
  #_LINE_UPDATE_ = true
  e.preventDefault()
  if _W_.pointer_down is true
    _LINE_UPDATE_ = true
    _W_.temp_line_end_point = getInputCoordinates(e)

onDrawOut = (e) ->
  e.preventDefault() 
  setFinalLinePoint(e)


stackToLine = (stack) ->
  if stack.length > 1
    end_point = stack.pop()
    start_point = stack.pop()
    createLine(start_point[0], start_point[1], end_point[0], end_point[1] )


#_DOT_C_
_DOT_C_.addEventListener('mousedown', (e) -> setStartLinePoint(e))
_DOT_C_.addEventListener('touchstart', (e) -> setStartLinePoint(e))
_DOT_C_.addEventListener('mouseup', (e) -> setFinalLinePoint(e))
_DOT_C_.addEventListener('touchend', (e) -> setFinalLinePoint(e))
_DOT_C_.addEventListener('mousemove', (e) -> setTempLineEndPoint(e))
_DOT_C_.addEventListener('touchmove', (e) -> setTempLineEndPoint(e))
_DOT_C_.addEventListener('mouseout', (e) -> onDrawOut(e))
_DOT_C_.addEventListener('touchleave', (e) -> onDrawOut(e))
_DOT_C_.addEventListener('touchcancel', (e) -> onDrawOut(e))

window.document.body.addEventListener('touchmove', (e) -> e.preventDefault())

window.addEventListener('resize', () -> 
  surrender()
, false)













_DEBUG_ = false
_W_ = {}
_ANIMATION_FRAME_ID_ = 0

VELOCITY_Y = 4
VELOCITY_X = 0
DOT_RADIUS = 3
DOT_U = 6
GRAVITY_Y = 0.015
SQUARE_SIDE = 35
BG_COLOR = '#eee'

_VC_ = document.getElementById('lsd')
_VCTX_ = _VC_.getContext('2d')
_VC_.style.backgroundColor = BG_COLOR

_C_ =  document.createElement('canvas')#document.getElementById('lsd')
_C_.style.backgroundColor = BG_COLOR
_CTX_ = _C_.getContext('2d')




resizeCanvas = () ->
  _VC_.width = _C_.width = window.innerWidth
  _VC_.height = _C_.height = window.innerHeight

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
  _W_.won = false
  _W_.lost = false 
  _W_.pointer_down = false
  _W_.temp_line_end_point = null
  _W_.wins = wins
  _W_.average_lines = ( Math.round(average_lines * 100) / 100 )

  if _W_.wins > 0
    for [1 .. _W_.wins]
      createLine(randomInt(0, _W_.w),randomInt(0, _W_.h),randomInt(0, _W_.w),randomInt(0, _W_.h),_W_)




d = (msg) ->
  console.log(msg) if _DEBUG_ 
  return msg




window.addEventListener('resize', window.startLsd, false)

copy = () ->
  #_VCTX_.clearRect(0,0,_VC_.width, _VC_.height)
  _VCTX_.drawImage(_C_, 0, 0)

window.startLsd = (wins = 0, average_lines = 0) -> 
  initWorld(wins, average_lines)
  #_W_.lines.push(makeLine(10,0,290,350))
  #_W_.lines.push(makeLine(390,0,190,350))
  #_W_.lines.push(makeLine(10,350,90,350))
  tick()

tick = () ->
  if not _W_.end 
    _ANIMATION_FRAME_ID_ = requestAnimationFrame(tick)
    update(_W_)
    draw(_W_, _CTX_)
  else
    #debugger
    #d('hiho')
    #d('_W_.end = true')
    ragnaroek(_W_)
    copy()
    window.cancelAnimationFrame(_ANIMATION_FRAME_ID_)
  
  
  #check here if an end event did happen????
  #debugger

ragnaroek = (world) ->
  #alert('end')
  #_END_ = true

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

  drawDots(world.dots, _CTX_, true)
  #d('end of game')
  #alert('end of game')
  #d('animate frame ID NOW')
  #d(_ANIMATION_FRAME_ID_)
  #d('animate frame ID NOW END')
  if _W_.end is true
    setTimeout(startLsd, 1000, wins, av)


update = (world) ->
  world = updateDots(world)
  stackToLine(world.line_point_stack)

  return world
  #world = updateLines(world)
  #world = createNewDot(world)

draw = (world, ctx) ->
  #d('in draw')
  #ctx.clearRect(0, 0, world.w, world.h)
  _CTX_.fillStyle = BG_COLOR
  _CTX_.fillRect(0, 0, world.w, world.h)
  drawDots(world.dots, ctx)
  drawLines(world.lines, ctx)
  drawSquare(world.square, ctx)
  drawTempLine(world, ctx)
  writeStuff(world, ctx)
  copy() #_VCTX_.drawImage(_C_, 0, 0)

randomInt = (min,max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

writeStuff = (world, ctx) ->
  ctx.fillStyle = "black";
  ctx.font = "12px Verdana";
  ctx.fillText("Level "+world.wins, 2, 12)
  ctx.fillText("Surrender", 2, 26)  
  drawLine([2,28,64,28], ctx)
  #ctx.fillText(world.wins+" (Ø "+world.average_lines+")", 2, 12);
  #ctx.fillText(world.wins, 2, 12);

#class Dot extends Array
#  @vx = VELOCITY_X
#  @vy = 
#x=Math.floor(_W_.h/2)Ø "+world.aver  +"
makeDot = (x = Math.floor(_W_.w/2),y = 10) ->
  a = [x,y]
  a.velocity  = {}
  a.velocity.x = VELOCITY_X
  a.velocity.y = VELOCITY_Y
  return a

makeLine = (x1, y1, x2, y2) ->
  return [x1,y1,x2,y2]

createLine = (x1, y1, x2, y2, world = _W_) ->
  world.lines.push(makeLine(x1, y1, x2, y2))



updateDots = (world) ->
  for dot, i in world.dots
    for line, j in world.lines
      if isDotLineCollison(dot, line)
        bounceDot(dot, line)
    dot = moveDot(dot)
    if isDotSquareCollision(dot, _W_.square)
      #endGame(true, true) #only set the variable here
      world.end = true
      world.won = true
    if isOutOfBounds(dot, world)
      #endGame(true) # only set the variable here
      world.end = true
      world.lost = true
    #if dot[1] > world.h 
    #  VELOCITY = VELOCITY * -1
  #alert(world)
  return world

updateLines = (world) ->
  return world

drawDot = (dot, ctx, inverse = false) ->
  #ctx.clearRect(dot[0]-50, dot[1]-50, 100, 100)

  #ctx.fillStyle = BG_COLOR
  #ctx.fillRect(dot[0]-50, dot[1]-50, 100, 100)
  ctx.beginPath()
  #ctx.arc(Math.floor(dot[0]), Math.floor(dot[1]), DOT_RADIUS, 0, Math.PI * 2, true)
  ctx.arc(dot[0], dot[1], DOT_RADIUS, 0, Math.PI * 2, true)

  ctx.closePath()
  if not inverse
    ctx.fillStyle = "black"
    ctx.fill()
  else
    ctx.strokeStyle = "black"
    ctx.fillStyle = BG_COLOR
    ctx.fill()
    ctx.stroke()


drawDots = (dots, ctx, inverse = false) ->
  for dot in dots
    drawDot(dot, ctx, inverse)

drawLine = (line, ctx, is_temp_line = false) ->
  ctx.beginPath()
  ctx.moveTo(Math.floor(line[0]), Math.floor(line[1]))
  ctx.lineTo(Math.floor(line[2]), Math.floor(line[3]))
  if not is_temp_line
    #ctx.restore()
    #ctx.setLineDash([0,0])
    ctx.strokeStyle = "black"
  else
    ctx.strokeStyle = "red"
    #ctx.setLineDash([7])
  ctx.stroke()

drawLines = (lines, ctx) ->
  for line in lines
    drawLine(line, ctx)
#(x = randomInt(SQUARE_SIDE*2, _W_.w-SQUARE_SIDE*2),y = randomInt(SQUARE_SIDE*2, _W_.h-SQUARE_SIDE*2)) ->
  
drawTempLine = (world, ctx) ->
  if world.pointer_down is true and world.line_point_stack[0] and world.temp_line_end_point
    [sx, sy] = world.line_point_stack[0]
    [tx, ty] = world.temp_line_end_point
    drawLine([sx,sy,tx,ty], ctx, true)




makeSquare = (x = randomInt(SQUARE_SIDE+2, _W_.w-(SQUARE_SIDE+2)), y = randomInt((SQUARE_SIDE+2), _W_.h-(SQUARE_SIDE+2))) -> 
  #d(x)
  #d(y)
  return [x,y]

drawSquare = (p, ctx = _CTX_, fill = false) ->
  [x,y] = p
  #ctx.restore()
  #ctx.setLineDash([0,0])
  ctx.rect(x,y,SQUARE_SIDE,SQUARE_SIDE)
  ctx.strokeStyle = "black"
  ctx.stroke()
  if fill is true
    ctx.fillStyle = "black"
    ctx.fill()


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
  drawSquare(dot)
  [sx, sy] = square #note square is always to upper left corner
  drawSquare(square)
  if dx > sx and dx < sx + SQUARE_SIDE
    if dy > sy and dy < sy + SQUARE_SIDE
      return true
      
  return false

isOutOfBounds = (dot, world) ->
  if dot[1] > world.h+3 or dot[0] < -3 or dot[0] > world.w + 3
    return true
  else
    return false


isDotLineCollison = (dot, line) ->
  closest = pointOnLineClosestToDot(dot, line)
  r = distance(dot, closest) < DOT_RADIUS
  return r

moveDot = (dot) ->
  dot[0] = dot[0] + dot.velocity.x
  dot[1] = dot[1] + dot.velocity.y
  dot = applyGravityToDot(dot)
  return dot

applyGravityToDot = (dot) ->
  dot.velocity.y = dot.velocity.y + GRAVITY_Y if dot.velocity.y < VELOCITY_Y
  return dot

bounceDot = (dot, line) ->
  #alert('hit')
  #d('hit')
  bounce_line_normal = bounceLineNormal(dot, line)
  #d('bounce line normal')
  #d(bounce_line_normal)
  #d('dot.velocity')
  #d(dot.velocity)
  dot_to_line_vector_product  = vectorPointProduct(dot.velocity, bounce_line_normal)

  #d('dot.velocity');d(dot.velocity)
  #d('dot_to_line_vector_product');d(dot_to_line_vector_product)
  #d('bounce_line_normal');d(bounce_line_normal)
  dot.velocity.x = dot.velocity.x - (2 * dot_to_line_vector_product * bounce_line_normal.x)
  dot.velocity.y = dot.velocity.y - (2 * dot_to_line_vector_product * bounce_line_normal.y)
  #method to make sure dot does not get stuck

bounceLineNormal = (dot, line) ->
  dot_to_closest_point_on_line_vector = 
    makeVector(pointOnLineClosestToDot(dot,line),dot)
  #TODO: if line is exact on point Object {x: NaN, y: NaN} is returned
  return unitVector(dot_to_closest_point_on_line_vector)

getInputCoordinates = (e) ->
  rect = _VC_.getBoundingClientRect()
  ex = e.pageX or e?.touches[0]?.clientX
  ey = e.pageY or e?.touches[0]?.clientY
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

setStartLinePoint = (e) ->
  e.preventDefault()
  _W_.line_point_stack = []
  point = getInputCoordinates(e)
  #check if click on surrender
  #d(point)
  [x,y] = point
  if x < 64  and x > 2 and y > 16 and y < 28
      _W_.end = true
      _W_.lost = true
  else
    placePoint(point, _W_)
    _W_.pointer_down = true

setFinalLinePoint = (e) ->
  e.preventDefault()
  point = getInputCoordinates(e)
  placePoint(point, _W_)
  _W_.pointer_down = false

setTempLineEndPoint = (e) ->
  e.preventDefault()
  _W_.temp_line_end_point = getInputCoordinates(e)

onDrawOut = (e) ->
  e.preventDefault() 
  setFinalLinePoint(e)




stackToLine = (stack) ->
  if stack.length > 1
    end_point = stack.pop()
    start_point = stack.pop()
    createLine(start_point[0], start_point[1], end_point[0], end_point[1] )






_VC_.addEventListener('mousedown', (e) -> setStartLinePoint(e))
_VC_.addEventListener('touchstart', (e) -> d('touchstart');setStartLinePoint(e))
_VC_.addEventListener('mouseup', (e) -> setFinalLinePoint(e))
_VC_.addEventListener('touchend', (e) -> d('touchend');d(e);setFinalLinePoint(e))
_VC_.addEventListener('mousemove', (e) -> setTempLineEndPoint(e))
_VC_.addEventListener('touchmove', (e) -> setTempLineEndPoint(e))
_VC_.addEventListener('mouseout', (e) -> onDrawOut(e))
_VC_.addEventListener('touchleave', (e) -> onDrawOut(e))
_VC_.addEventListener('touchcancel', (e) -> onDrawOut(e))

window.document.body.addEventListener('touchmove', (e) -> e.preventDefault())











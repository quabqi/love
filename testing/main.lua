-- & 'c:\Program Files\LOVE\love.exe' ./ --console 
-- /Applications/love.app/Contents/MacOS/love ./

-- load test objs
require('classes.TestSuite')
require('classes.TestModule')
require('classes.TestMethod')

-- create testsuite obj
love.test = TestSuite:new()

-- load test scripts if module is active
if love.audio ~= nil then require('tests.audio') end
if love.data ~= nil then require('tests.data') end
if love.event ~= nil then require('tests.event') end
if love.filesystem ~= nil then require('tests.filesystem') end
if love.font ~= nil then require('tests.font') end
if love.graphics ~= nil then require('tests.graphics') end
if love.image ~= nil then require('tests.image') end
if love.math ~= nil then require('tests.math') end
if love.physics ~= nil then require('tests.physics') end
if love.sound ~= nil then require('tests.sound') end
if love.system ~= nil then require('tests.system') end
if love.thread ~= nil then require('tests.thread') end
if love.timer ~= nil then require('tests.timer') end
if love.video ~= nil then require('tests.video') end
if love.window ~= nil then require('tests.window') end
require('tests.objects')

-- love.load
-- load given arguments and run the test suite
love.load = function(args)

  -- setup basic img to display
  if love.window ~= nil then
    love.window.setMode(256, 256, {
      fullscreen = false,
      resizable = true,
      centered = true
    })
    if love.graphics ~= nil then
      love.graphics.setDefaultFilter("nearest", "nearest")
      love.graphics.setLineStyle('rough')
      love.graphics.setLineWidth(1)
      Logo = {
        texture = love.graphics.newImage('resources/love.png'),
        img = nil
      }
      Logo.img = love.graphics.newQuad(0, 0, 64, 64, Logo.texture)
    end
  end

  -- get all args with any comma lists split out as seperate
  local arglist = {}
  for a=1,#args do
    local splits = UtilStringSplit(args[a], '([^,]+)')
    for s=1,#splits do
      table.insert(arglist, splits[s])
    end
  end

  -- convert args to the cmd to run, modules, method (if any) and disabled
  local testcmd = '--runAllTests'
  local module = ''
  local method = ''
  local modules = {
    'audio', 'data', 'event', 'filesystem', 'font', 'graphics',
    'image', 'math', 'objects', 'physics', 'sound', 'system',
    'thread', 'timer', 'video', 'window'
  }
  for a=1,#arglist do
    if testcmd == '--runSpecificMethod' then
      if module == '' and love[ arglist[a] ] ~= nil then 
        module = arglist[a] 
        table.insert(modules, module)
      end
      if module ~= '' and love[module][ arglist[a] ] ~= nil and method == '' then 
        method = arglist[a] 
      end
    end
    if testcmd == '--runSpecificModules' then
      if love[ arglist[a] ] ~= nil or arglist[a] == 'objects' then 
        table.insert(modules, arglist[a]) 
      end
    end
    if arglist[a] == '--runSpecificMethod' then
      testcmd = arglist[a]
      modules = {}
    end
    if arglist[a] == '--runSpecificModules' then
      testcmd = arglist[a]
      modules = {}
    end
  end

  -- runSpecificMethod uses the module + method given
  if testcmd == '--runSpecificMethod' then
    local testmodule = TestModule:new(module, method)
    table.insert(love.test.modules, testmodule)
    love.test.module = testmodule
    love.test.module:log('grey', '--runSpecificMethod "' .. module .. '" "' .. method .. '"')
    love.test.output = 'lovetest_runSpecificMethod_' .. module .. '_' .. method
  end

  -- runSpecificModules runs all methods for all the modules given
  if testcmd == '--runSpecificModules' then
    local modulelist = {}
    for m=1,#modules do
      local testmodule = TestModule:new(modules[m])
      table.insert(love.test.modules, testmodule)
      table.insert(modulelist, modules[m])
    end
    
    love.test.module = love.test.modules[1]
    love.test.module:log('grey', '--runSpecificModules "' .. table.concat(modulelist, '" "') .. '"')
    love.test.output = 'lovetest_runSpecificModules_' .. table.concat(modulelist, '_')
  end

  -- otherwise default runs all methods for all modules
  if arglist[1] == nil or arglist[1] == '' or arglist[1] == '--runAllTests' then
    for m=1,#modules do
      local testmodule = TestModule:new(modules[m])
      table.insert(love.test.modules, testmodule)
    end
    love.test.module = love.test.modules[1]
    love.test.module:log('grey', '--runAllTests')
    love.test.output = 'lovetest_runAllTests'
  end

  -- invalid command
  if love.test.module == nil then
    print("Wrong flags used")
  end

  -- start first module
  love.test.module:runTests()

end

-- love.update
-- run test suite logic 
love.update = function(delta)
  love.test:runSuite(delta)
end


-- love.draw
-- draw a little logo to the screen
love.draw = function()
  love.graphics.draw(Logo.texture, Logo.img, 64, 64, 0, 2, 2)
end


-- love.quit
-- add a hook to allow test modules to fake quit
love.quit = function()
  if love.test.module ~= nil and love.test.module.fakequit == true then
    return true
  else
    return false
  end
end


-- string split helper
function UtilStringSplit(str, splitter)
  local splits = {}
  for word in string.gmatch(str, splitter) do
    table.insert(splits, word)
  end
  return splits
end
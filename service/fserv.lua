local minitel = require "minitel"
local serial = require "serialization"

local cfg = {["path"]="/boot/srv/frequest",["port"]=70}

f=io.open("/boot/cfg/fserv.cfg","rb")
if f then
 local ncfg = serial.unserialize(f:read("*a"))
 f:close()
 for k,v in pairs(ncfg) do
 cfg[k] = v
 end
end

local function fileHandler(socket,rtype,path)
 syslog(string.format("[%s:%d] %s %s",socket.addr,socket.port,rtype,path),syslog.info,"fserv")
 if rtype == "t" then
  if fs.exists(path) and fs.isDirectory(path) then
   socket:write("d")
   for _,file in ipairs(fs.list(path)) do
    socket:write(file.."\n")
   end
  elseif fs.exists(path) and not fs.isDirectory(path) then
   local f,err = io.open(path,"rb")
   if f then
    socket:write("y")
    while true do
     local c = f:read(4096)
     if not c or c == "" then break end
     socket:write(c)
    end
   else
    socket:write("fFailed to open file: "..err)
   end
  else
   socket:write("nFile not found")
  end
 elseif rtype == "s" then
  if fs.exists(path) then
   local ftype = "f"
   if fs.isDirectory(path) then
    ftype = "d"
   end
   socket:write(string.format("y%s\n%d",ftype,fs.size(path)))
  else
   socket:write("nFile not found.")
  end
 else
  socket:write("fUnknown request type")
 end
 socket:close()
end
local function httpHandler(socket,rtype,path)
 socket:write("fHTTP requests are not yet implemented.")
 socket:close()
end

local function socketHandler(socket)
 return function() 
  local line = nil
  repeat
   coroutine.yield()
   line = socket:read()
  until line
  local rtype, path = line:match("(.)(.+)")
  if path:sub(1,6) == "/http/" or path:sub(1,5) == "http/" then
   httpHandler(socket,rtype,path)
  else
   path = (cfg.path .. "/" .. path:gsub("../","")):gsub("/+","/")
   fileHandler(socket,rtype,path)
  end
  socket:close()
 end
end

while true do
 os.spawn(socketHandler(minitel.listen(70)))
end

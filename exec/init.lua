if os.taskInfo(1) and os.pid() ~= 1 then
 return false, "init already started"
end
os.setenv("PWD","/boot")
io.input("/dev/null")
io.output("/dev/syslog")
local pids = {}
local function loadlist()
 local f = io.open("/boot/cfg/init.txt","rb")
 if not f then return false end
 for line in f:read("*a"):gmatch("[^\r\n]+") do
  dprint(line)
  pids[line] = -1
 end
 f:close()
end
loadlist()
while true do
 for k,v in pairs(pids) do
  if not os.taskInfo(v) then
   dprint("Starting service "..k)
   pids[k] = os.spawnfile("/boot/service/"..k)
  end
 end
 coroutine.yield()
end

do
tTasks,nPid,nTimeout,cPid = {},1,0,0 -- table of tasks, next process ID, event timeout, current PID
function os.spawn(f,n) -- creates a process from function *f* with name *n*
 tTasks[nPid] = {["c"]=coroutine.create(f),["n"]=n,["p"]=nPid,e={}}
 if tTasks[cPid] then
  for k,v in pairs(tTasks[cPid].e) do
   tTasks[nPid].e[k] = tTasks[nPid].e[k] or v
  end
 end
 nPid = nPid + 1
 return nPid - 1
end
function os.kill(pid) -- removes process *pid* from the task list
 tTasks[pid] = nil
end
function sched() -- the actual scheduler function
 while #tTasks > 0 do
  local tEv = {computer.pullSignal(nTimeout)}
  for k,v in pairs(tTasks) do
   if coroutine.status(v.c) ~= "dead" then
    cPid = k
    coroutine.resume(v.c,table.unpack(tEv))
   else
    tTasks[k] = nil
   end
  end
 end
end
function os.setenv(k,v) -- set's the current process' environment variable *k* to *v*, which is passed to children
 if tTasks[cPid] then
  tTasks[cPid].e[k] = v
 end
end
function os.getenv(k) -- gets a process' *k* environment variable
 if tTasks[cPid] then
  return tTasks[cPid].e[k]
 end
end
end

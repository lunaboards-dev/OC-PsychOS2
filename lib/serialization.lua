local serial = {}
local local_pairs=function(tbl)
 local mt=getmetatable(tbl)
 return (mt and mt.__pairs or pairs)(tbl)
end
function serial.serialize(value)
 local kw={["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,["end"]=true,["false"]=true,["for"]=true,["function"]=true,["goto"]=true,["if"]=true,["in"]=true,["local"]=true,["nil"]=true,["not"]=true,["or"]=true,["repeat"]=true,["return"]=true,["then"]=true,["true"]=true,["until"]=true,["while"]=true}
 local id="^[%a_][%w_]*$"
 local ts={}
 local function s(v,l)
  local t=type(v)
  if t=="nil" then return "nil"
  elseif t=="boolean" then return v and "true" or "false"
  elseif t=="number" then
   if v~=v then return "0/0"
   elseif v==math.huge then return "math.huge"
   elseif v==-math.huge then return "-math.huge"
   else return tostring(v) end
  elseif t=="string" then return string.format("%q",v):gsub("\\\n","\\n")
  elseif t=="table" then
   if ts[v] then error("tcyc") end
   ts[v]=true
   local i,r=1, nil
   local f=table.pack(local_pairs(v))
   for k,v in table.unpack(f) do
    if r then r=r..","..(("\n"..string.rep(" ",l)) or "")
    else r="{" end
    local tk=type(k)
    if tk=="number" and k==i then
     i=i+1
     r=r..s(v,l+1)
    else
     if tk == "string" and not kw[k] and string.match(k,id) then r=r..k
     else r=r.."["..s(k,l+1).."]" end
     r=r.."="..s(v,l+1) end end
   ts[v]=nil
   return (r or "{").."}"
  else error("ut "..t) end end
 return s(value, 1)
end
function serial.unserialize(data)
 checkArg(1, data, "string")
 local result, reason = load("return " .. data, "=data", _, {math={huge=math.huge}})
 if not result then return nil, reason end
 local ok, output = pcall(result)
 if not ok then return nil, output end
 return output
end
return serial

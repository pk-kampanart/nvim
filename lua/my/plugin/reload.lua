local M = {}

-- TODO: understand this code
local function _assign(old, new, k)
  local otype = type(old[k])
  local ntype = type(new[k])
  -- print("hi")
  if (otype == "thread" or otype == "userdata") or (ntype == "thread" or ntype == "userdata") then
    vim.notify(string.format("warning: old or new attr %s type be thread or userdata", k))
  end
  old[k] = new[k]
end

local function _replace(old, new, repeat_tbl)
  if repeat_tbl[old] then
    return
  end
  repeat_tbl[old] = true

  local dellist = {}
  for k, _ in pairs(old) do
    if not new[k] then
      table.insert(dellist, k)
    end
  end
  for _, v in ipairs(dellist) do
    old[v] = nil
  end

  for k, _ in pairs(new) do
    if not old[k] then
      old[k] = new[k]
    else
      if type(old[k]) ~= type(new[k]) then
        vim.notify(string.format("warning: attr %s old type no equal new type!!!", k))
        _assign(old, new, k)
      else
        if type(old[k]) == "table" then
          _replace(old[k], new[k], repeat_tbl)
        else
          _assign(old, new, k)
        end
      end
    end
  end
end

function M.reload(mod)
  if not package.loaded[mod] then
    local m = require(mod)
    return m
  end
  -- vim.notify "begin reload!!!"

  local old = package.loaded[mod]
  package.loaded[mod] = nil
  local new = require(mod)

  if type(old) == "table" and type(new) == "table" then
    vim.notify("reload: " .. mod)
    local repeat_tbl = {}
    _replace(old, new, repeat_tbl)
  end

  package.loaded[mod] = old
  -- vim.notify "finish reload!!!"
  return old
end

function M.reload_all()
  for _, pack in ipairs(vim.fn.glob("./lua/*/**.lua", false, true)) do
    pack = string.gsub(pack, "..lua/", "")
    pack = string.gsub(pack, ".lua$", "")
    pack = string.gsub(pack, "/", ".")
    M.reload(pack)
  end
end

return M

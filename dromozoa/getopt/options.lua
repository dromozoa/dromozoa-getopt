-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-getopt.
--
-- dromozoa-getopt is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-getopt is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-getopt.  If not, see <http://www.gnu.org/licenses/>.

local function identity(v)
  return v
end

return function ()
  local self = {
    _missing = "?";
    _options = {};
    _option_by_char = {};
    _option_by_name = {};
  }

  function self:add_option(char, name, arg)
    if arg == true then
      arg = identity
    end
    local option = {
      char = char;
      name = name;
      arg = arg;
    }
    local options = self._options
    options[#options + 1] = option
    if char ~= nil then
      self._option_by_char[char] = option
    end
    if name ~= nil then
      self._option_by_name[name] = option
    end
  end

  function self:add_optstring(optstring)
    local i = 1
    local _1

    local function scan(pattern)
      local a, b, c = optstring:find("^" .. pattern, i)
      if b == nil then
        return false
      else
        i = b + 1
        _1 = c
        return true
      end
    end

    local options = self._options
    if scan ":" then
      self._missing = ":"
    end
    while i <= #optstring do
      if scan "(.):" then
        self:add_option(_1, nil, true)
      elseif scan "(.)" then
        self:add_option(_1, nil, false)
      end
    end
  end

  function self:add_options(options)
    for i = 1, #options do
      local v = options[i]
      self:add_option(v.char, v.name, v.arg)
    end
  end

  function self:parse_name(u, v, result)
    local a, b = u:match("^%-%-([^=]+)=(.*)$")
    if a ~= nil then
      local option = self._option_by_name[a]
      if option == nil then
        return nil
      else
        if option.arg then
          local b = option.arg(b)
          if b == nil then
            return nil
          end
          result[#result + 1] = { option = option; arg = b }
          return 1
        else
          return nil
        end
      end
    else
      local a = u:match("^%-%-([^=]+)$")
      if a ~= nil then
        local option = self._option_by_name[a]
        if option == nil then
          return nil
        end
        if option.arg then
          local b = option.arg(v)
          if b == nil then
            return nil
          end
          result[#result + 1] = { option = option; arg = b }
          return 2
        else
          result[#result + 1] = { option = option }
          return 1
        end
      end
    end
    return 0
  end

  function self:parse_char(u, v, result)
    if u:sub(1, 1) == "-" then
      local i = 2
      while i <= #u do
        local a = u:sub(i, i)
        local option = self._option_by_char[a]
        if option == nil then
          return nil
        else
          if option.arg then
            if i < #u then
              local b = option.arg(u:sub(i + 1))
              if b == nil then
                return nil
              end
              result[#result + 1] = { option = option; arg = b }
              return 1
            else
              local b = option.arg(v)
              if b == nil then
                return nil
              end
              result[#result + 1] = { option = option; arg = b }
              return 2
            end
          else
            result[#result + 1] = { option = option }
            i = i + 1
          end
        end
      end
      return 1
    else
      return 0
    end
  end

  function self:parse(arg, i, j)
    if i == nil then
      i = 1
    end
    if j == nil then
      j = #arg
    end
    local result = {}
    while i <= j do
      local u, v = arg[i], arg[i + 1]
      if u == "--" then
        i = i + 1
        break
      end
      local a = self:parse_name(u, v, result)
      if a == nil then
        return nil, "bad argument #" .. i
      elseif a > 0 then
        i = i + a
      else
        local a = self:parse_char(u, v, result)
        if a == nil then
          return nil, "bad argument #" .. i
        elseif a > 0 then
          i = i + a
        else
          break
        end
      end
    end
    return result, i
  end

  return self
end

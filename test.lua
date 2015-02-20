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

local json = require "dromozoa.json.pure"
local options = require "dromozoa.getopt.options"

local data = {
  { "-ao", "arg", "path", "path" };
  { "-a", "-o", "arg", "path", "path" };
  { "-o", "arg", "-a", "path", "path" };
  { "-a", "-o", "arg", "--", "path", "path" };
  { "-a", "-oarg", "path", "path" };
  { "-aoarg", "path", "path" };
}

for i = 1, #data do
  local opts = options()
  local arg = data[i]
  opts:add_optstring(":abf:o:")
  local a, b = opts:parse(arg)
  assert(type(a) == "table")
  assert(#a == 2)
  table.sort(a, function (a, b) return a.option.char < b.option.char end)
  assert(a[1].option.char == "a")
  assert(a[2].option.char == "o")
  assert(a[2].arg == "arg")
  assert(b + 1 == #arg)
  assert(arg[b] == "path")
  assert(arg[b + 1] == "path")
end

local data = {
  {
    { "-h" };
    { { char = "h" } };
    2;
  };
  {
    { "--help" };
    { { char = "h" } };
    2;
  };
  {
    { "-o", "-h" };
    { { char = "o"; arg = "-h" } };
    3;
  };
  {
    { "--output", "-h" };
    { { char = "o"; arg = "-h" } };
    3;
  };
  {
    { "--output=-h" };
    { { char = "o"; arg = "-h" } };
    2;
  };
  {
    { "-vV", "--", "-V" };
    { { char = "v" }, { char = "V" } };
    3;
  };
  { { "-x" } };
  { { "-o" } };
  { { "--output" } };
  {
    { "-O0" };
    { { char = "O", arg = 0 } };
    2;
  };
  {
    { "-O", "1" };
    { { char = "O", arg = 1 } };
    3;
  };
  { { "-Os" } };
}

for i = 1, #data do
  local opts = options()
  opts:add_options {
    { char = "h"; name = "help" };
    { char = "o"; name = "output"; arg = true };
    { char = "O"; arg = tonumber };
    { char = "v"; name = "verbose" };
    { char = "V"; name = "version" };
  }
  local a, b = opts:parse(data[i][1])
  if data[i][2] ~= nil then
    assert(type(a) == "table")
    assert(#a == #data[i][2])
    for j = 1, #a do
      local u = a[j]
      local v = data[i][2][j]
      assert(u.option.char == v.char)
      assert(u.arg == v.arg)
    end
    assert(b == data[i][3])
  else
    assert(a == nil)
  end
end

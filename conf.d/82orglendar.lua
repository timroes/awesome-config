-- Calendar with Emacs org-mode agenda for Awesome WM
-- Inspired by and contributed from the org-awesome module, copyright of Damien Leone
-- Licensed under GPLv2
-- Version 1.1-awesome-git
-- @author Alexander Yakushev <yakushev.alex@gmail.com>
-- Modified by Tim Roes for personal use

local awful = require("awful")
local util = awful.util
local theme = require("beautiful")
local naughty = require("naughty")
local setmetatable = setmetatable
local tostring = tostring
local tonumber = tonumber
local mouse = mouse
local os = os
local string = string
local math = math
local lunaconf = require('lunaconf')

module("widgets.orglendar")

local orglendar = { files = {},
                    char_width = nil,
                    text_color = theme.cal_fg or theme.fg_normal or "#FFFFFF",
                    today_color = theme.cal_today or theme.bg_urgent or "#00FF00",
                    font = 'Source Code Pro ' .. tostring(math.floor(lunaconf.dpi.toScale(11))),
                    calendar_width = 19 }

local freq_table =
{ d = { lapse = 86400,
        occur = 5,
        next = function(t, i)
                  local date = os.date("*t", t)
                  return os.time{ day = date.day + i, month = date.month,
                                  year = date.year }
               end },
  w = { lapse = 604800,
        occur = 3,
        next = function(t, i)
                  return t + 604800 * i
               end },
  y = { lapse = 220752000,
        occur = 1,
        next = function(t, i)
                  local date = os.date("*t", t)
                  return os.time{ day = date.day, month = date.month,
                                  year = date.year + i }
               end },
  m = { lapse = 2592000,
        occur = 1,
        next = function(t, i)
                  local date = os.date("*t", t)
                  return os.time{ day = date.day, month = date.month + i,
                                  year = date.year }
               end }
 }

local calendar = nil
local todo = nil
local offset = 0

local data = nil

local function pop_spaces(s1, s2, maxsize)
   local sps = ""
   for i = 1, maxsize - string.len(s1) - string.len(s2) do
      sps = sps .. " "
   end
   return s1 .. sps .. s2
end

local function strip_time(time_obj)
   local tbl = os.date("*t", time_obj)
   return os.time{day = tbl.day, month = tbl.month, year = tbl.year}
end

local function create_calendar()
   offset = offset or 0

   local now = os.date("*t")
   local cal_month = now.month + offset
   local cal_year = now.year
   if cal_month > 12 then
      cal_month = (cal_month % 12)
      cal_year = cal_year + 1
   elseif cal_month < 1 then
      cal_month = (cal_month + 12)
      cal_year = cal_year - 1
   end

   local last_day = os.date("%d", os.time({ day = 1, year = cal_year,
                                            month = cal_month + 1}) - 86400)
   local first_day = os.time({ day = 1, month = cal_month, year = cal_year})
   local first_day_in_week = (os.date("%w", first_day) - 1) % 7
   local result = "Mo Di Mi Do Fr Sa So\n"
   for i = 1, first_day_in_week do
      result = result .. "   "
   end

   local this_month = false
   for day = 1, last_day do
      local last_in_week = (day + first_day_in_week) % 7 == 0
      local day_str = pop_spaces("", day, 2) .. (last_in_week and "" or " ")
      if cal_month == now.month and cal_year == now.year and day == now.day then
         this_month = true
         result = result ..
            string.format('<span weight="bold" foreground="%s">%s</span>',
                          orglendar.today_color, day_str)
      else
         result = result .. day_str
      end
      if last_in_week and day ~= tonumber(last_day) then
         result = result .. "\n"
      end
   end

   local header = os.date("%B %Y", first_day)
   return header, string.format('<span font="%s" foreground="%s">%s</span>',
                                orglendar.font, orglendar.text_color, result)
end

function orglendar.get_calendar_and_todo_text(_offset)
   if not data or parse_on_show then
      orglendar.parse_agenda()
   end

   offset = _offset
   local header, cal = create_calendar()
   return string.format('<span font="%s" foreground="%s">%s</span>\n%s',
                        orglendar.font, orglendar.text_color, header, cal)
end

local function calculate_char_width()
   return theme.get_font_height(orglendar.font) * 0.555
end

function orglendar.hide()
   if calendar ~= nil then
      naughty.destroy(calendar)
      calendar = nil
      offset = 0
   end
end

function orglendar.show(inc_offset)
   inc_offset = inc_offset or 0

   local save_offset = offset
   orglendar.hide()
   offset = save_offset + inc_offset

   local char_width = char_width or calculate_char_width()
   local header, cal_text = create_calendar()
   calendar = naughty.notify({ title = header,
                               text = cal_text,
                               timeout = 0, hover_timeout = 0.5,
                               width = orglendar.calendar_width * char_width,
                               screen = mouse.screen,
							   position = "top_right"
                            })
end

function orglendar.register(_, widget)
   widget:connect_signal("mouse::enter", function() orglendar.show(0) end)
   widget:connect_signal("mouse::leave", orglendar.hide)
   widget:buttons(util.table.join( awful.button({ }, 4, function()
                                                           orglendar.show(-1)
                                                        end),
                                   awful.button({ }, 5, function()
                                                           orglendar.show(1)
                                                        end)))
end

setmetatable(_M, { __call = orglendar.register })

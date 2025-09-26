return {
  {
    "rebelot/heirline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local heirline = require("heirline")
      local utils = require("heirline.utils")
      local conditions = require("heirline.conditions")

      -- Color setup
      local function setup_colors()
        return {
          bright_bg = utils.get_highlight("Folded").bg,
          bright_fg = utils.get_highlight("Folded").fg,
          red = utils.get_highlight("DiagnosticError").fg,
          dark_red = utils.get_highlight("DiffDelete").bg,
          green = utils.get_highlight("String").fg,
          blue = utils.get_highlight("Function").fg,
          gray = utils.get_highlight("NonText").fg,
          orange = utils.get_highlight("Constant").fg,
          purple = utils.get_highlight("Statement").fg,
          cyan = utils.get_highlight("Special").fg,
          diag_warn = utils.get_highlight("DiagnosticWarn").fg,
          diag_error = utils.get_highlight("DiagnosticError").fg,
          diag_hint = utils.get_highlight("DiagnosticHint").fg,
          diag_info = utils.get_highlight("DiagnosticInfo").fg,
          git_del = utils.get_highlight("diffRemoved").fg,
          git_add = utils.get_highlight("diffAdded").fg,
          git_change = utils.get_highlight("diffChanged").fg,
        }
      end

      -- Mode colors and names
      local mode_colors = {
        n = "red",
        i = "green",
        v = "cyan",
        V = "cyan",
        ["\22"] = "cyan",
        c = "orange",
        s = "purple",
        S = "purple",
        ["\19"] = "purple",
        R = "orange",
        r = "orange",
        ["!"] = "red",
        t = "green",
      }

      local mode_names = {
        n = "NORMAL",
        no = "NORMAL",
        nov = "NORMAL",
        noV = "NORMAL",
        ["no\22"] = "NORMAL",
        niI = "NORMAL",
        niR = "NORMAL",
        niV = "NORMAL",
        nt = "NTERMINAL",
        v = "VISUAL",
        vs = "VISUAL",
        V = "VISUAL",
        Vs = "VISUAL",
        ["\22"] = "VISUAL",
        ["\22s"] = "VISUAL",
        s = "SELECT",
        S = "SELECT",
        ["\19"] = "SELECT",
        i = "INSERT",
        ic = "INSERT",
        ix = "INSERT",
        R = "REPLACE",
        Rc = "REPLACE",
        Rx = "REPLACE",
        Rv = "REPLACE",
        Rvc = "REPLACE",
        Rvx = "REPLACE",
        c = "COMMAND",
        cv = "Ex",
        r = "...",
        rm = "M",
        ["r?"] = "?",
        ["!"] = "!",
        t = "TERMINAL",
      }

      -- Vi Mode
      local ViMode = {
        init = function(self)
          self.mode = vim.fn.mode(1)
        end,
        static = {
          mode_names = mode_names,
        },
        provider = function(self)
          return " %2(" .. self.mode_names[self.mode] .. "%) "
        end,
        hl = function(self)
          local mode = self.mode:sub(1, 1)
          return { fg = "black", bg = mode_colors[mode], bold = true }
        end,
        update = {
          "ModeChanged",
          pattern = "*:*",
          callback = vim.schedule_wrap(function()
            vim.cmd("redrawstatus")
          end),
        },
      }

      -- File info
      local FileNameBlock = {
        init = function(self)
          self.filename = vim.api.nvim_buf_get_name(0)
        end,
      }

      local FileIcon = {
        init = function(self)
          local filename = self.filename
          local extension = vim.fn.fnamemodify(filename, ":e")
          self.icon, self.icon_color =
            require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
        end,
        provider = function(self)
          return self.icon and (self.icon .. " ")
        end,
        hl = function(self)
          return { fg = self.icon_color }
        end,
      }

      local FileName = {
        provider = function(self)
          local filename = vim.fn.fnamemodify(self.filename, ":.")
          if filename == "" then
            return "[No Name]"
          end
          if not conditions.width_percent_below(#filename, 0.25) then
            filename = vim.fn.pathshorten(filename)
          end
          return filename
        end,
        hl = { fg = utils.get_highlight("Directory").fg },
      }

      local FileFlags = {
        {
          condition = function()
            return vim.bo.modified
          end,
          provider = "[+]",
          hl = { fg = "green" },
        },
        {
          condition = function()
            return not vim.bo.modifiable or vim.bo.readonly
          end,
          provider = "",
          hl = { fg = "orange" },
        },
      }

      local FileNameModifer = {
        hl = function()
          if vim.bo.modified then
            return { fg = "cyan", bold = true, force = true }
          end
        end,
      }

      FileNameBlock = utils.insert(
        FileNameBlock,
        FileIcon,
        utils.insert(FileNameModifer, FileName),
        FileFlags,
        { provider = "%<" } -- this means that the statusline is cut here when there's not enough space
      )

      -- Git
      local Git = {
        condition = conditions.is_git_repo,

        init = function(self)
          self.status_dict = vim.b.gitsigns_status_dict
          self.has_changes = self.status_dict.added ~= 0
            or self.status_dict.removed ~= 0
            or self.status_dict.changed ~= 0
        end,

        hl = { fg = "orange" },

        { -- git branch name
          provider = function(self)
            return " " .. self.status_dict.head
          end,
          hl = { bold = true },
        },
        -- You could handle delimiters, icons and counts similar to Diagnostics
        {
          condition = function(self)
            return self.has_changes
          end,
          provider = "(",
        },
        {
          provider = function(self)
            local count = self.status_dict.added or 0
            return count > 0 and ("+" .. count)
          end,
          hl = { fg = "git_add" },
        },
        {
          provider = function(self)
            local count = self.status_dict.removed or 0
            return count > 0 and ("-" .. count)
          end,
          hl = { fg = "git_del" },
        },
        {
          provider = function(self)
            local count = self.status_dict.changed or 0
            return count > 0 and ("~" .. count)
          end,
          hl = { fg = "git_change" },
        },
        {
          condition = function(self)
            return self.has_changes
          end,
          provider = ")",
        },
      }

      -- Diagnostics
      local Diagnostics = {
        condition = conditions.has_diagnostics,

        static = {
          error_icon = (function()
            local signs = vim.fn.sign_getdefined("DiagnosticSignError")
            return (signs and signs[1] and signs[1].text) or "E"
          end)(),
          warn_icon = (function()
            local signs = vim.fn.sign_getdefined("DiagnosticSignWarn")
            return (signs and signs[1] and signs[1].text) or "W"
          end)(),
          info_icon = (function()
            local signs = vim.fn.sign_getdefined("DiagnosticSignInfo")
            return (signs and signs[1] and signs[1].text) or "I"
          end)(),
          hint_icon = (function()
            local signs = vim.fn.sign_getdefined("DiagnosticSignHint")
            return (signs and signs[1] and signs[1].text) or "H"
          end)(),
        },
        init = function(self)
          self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
          self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
          self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
          self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,

        update = { "DiagnosticChanged", "BufEnter" },

        {
          provider = "![",
        },
        {
          provider = function(self)
            return self.errors > 0 and (self.error_icon .. self.errors .. " ")
          end,
          hl = { fg = "diag_error" },
        },
        {
          provider = function(self)
            return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
          end,
          hl = { fg = "diag_warn" },
        },
        {
          provider = function(self)
            return self.info > 0 and (self.info_icon .. self.info .. " ")
          end,
          hl = { fg = "diag_info" },
        },
        {
          provider = function(self)
            return self.hints > 0 and (self.hint_icon .. self.hints)
          end,
          hl = { fg = "diag_hint" },
        },
        {
          provider = "]",
        },
      }

      -- LSP
      local LSPActive = {
        condition = conditions.lsp_attached,
        update = { "LspAttach", "LspDetach" },

        provider = function()
          local names = {}
          for i, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
            table.insert(names, server.name)
          end
          return " [" .. table.concat(names, " ") .. "]"
        end,
        hl = { fg = "green", bold = true },
      }

      -- File type
      local FileType = {
        provider = function()
          return string.upper(vim.bo.filetype)
        end,
        hl = { fg = utils.get_highlight("Type").fg, bold = true },
      }

      -- File encoding
      local FileEncoding = {
        provider = function()
          local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
          return enc ~= "utf-8" and enc:upper()
        end,
      }

      local FileFormat = {
        provider = function()
          local fmt = vim.bo.fileformat
          return fmt ~= "unix" and fmt:upper()
        end,
      }

      -- Ruler
      local Ruler = {
        -- %l = current line number
        -- %L = number of lines in the buffer
        -- %c = column number
        -- %P = percentage through file of displayed window
        provider = "%7(%l/%3L%):%2c %P",
      }

      -- Scrollbar
      local ScrollBar = {
        static = {
          sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
        },
        provider = function(self)
          local curr_line = vim.api.nvim_win_get_cursor(0)[1]
          local lines = vim.api.nvim_buf_line_count(0)
          local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
          return string.rep(self.sbar[i], 2)
        end,
        hl = { fg = "blue", bg = "bright_bg" },
      }

      -- Search count
      local SearchCount = {
        condition = function()
          return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0
        end,
        init = function(self)
          local ok, search = pcall(vim.fn.searchcount)
          if ok and search.total then
            self.search = search
          end
        end,
        provider = function(self)
          local search = self.search
          return string.format("[%d/%d]", search.current, math.min(search.total, search.maxcount))
        end,
      }

      -- Spacers
      local Align = { provider = "%=" }
      local Space = { provider = " " }

      -- Put it all together
      local StatusLine = {
        ViMode,
        Space,
        FileNameBlock,
        Space,
        Git,
        Space,
        Diagnostics,
        Align,
        SearchCount,
        Space,
        LSPActive,
        Space,
        FileType,
        Space,
        FileEncoding,
        Space,
        FileFormat,
        Space,
        Ruler,
        Space,
        ScrollBar,
      }

      -- Winbar for breadcrumbs
      local WinBar = {
        fallthrough = false,
        {
          condition = function()
            return conditions.buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix" },
              filetype = { "^git.*", "fugitive", "Trouble", "dashboard" },
            })
          end,
          init = function()
            vim.opt_local.winbar = nil
          end,
        },
        utils.make_buflist(utils.insert({
          init = function(self)
            self.filename = vim.api.nvim_buf_get_name(self.bufnr)
          end,
          hl = function(self)
            if self.is_active then
              return "TabLineSel"
            else
              return "TabLine"
            end
          end,
          {
            init = function(self)
              local filename = self.filename
              local extension = vim.fn.fnamemodify(filename, ":e")
              self.icon, self.icon_color =
                require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
            end,
            provider = function(self)
              return self.icon
            end,
            hl = function(self)
              return { fg = self.icon_color }
            end,
          },
          {
            provider = function(self)
              local filename = vim.fn.fnamemodify(self.filename, ":t")
              if filename == "" then
                return "[No Name]"
              end
              return " " .. filename
            end,
          },
          {
            condition = function(self)
              return not vim.api.nvim_buf_get_option(self.bufnr, "modified")
            end,
            provider = " 󰅖",
            hl = { fg = "gray" },
            on_click = {
              callback = function(_, minwid)
                vim.schedule(function()
                  vim.api.nvim_buf_delete(minwid, { force = false })
                  vim.cmd.redrawtabline()
                end)
              end,
              minwid = function(self)
                return self.bufnr
              end,
              name = "heirline_tabline_close_buffer_callback",
            },
          },
        }, { provider = "%T" }, Space)),
      }

      heirline.setup({
        statusline = StatusLine,
        winbar = WinBar,
        opts = {
          disable_winbar_cb = function(args)
            return conditions.buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
              filetype = { "gitcommit", "fugitive", "Trouble", "dashboard" },
            }, args.buf)
          end,
          colors = setup_colors,
        },
      })

      -- Update colors on colorscheme change
      local augroup = vim.api.nvim_create_augroup("Heirline", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          utils.on_colorscheme(setup_colors())
        end,
        group = augroup,
      })
    end,
  },
}

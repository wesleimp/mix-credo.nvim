local Job = require("plenary.job")
local Utils = require("utils")

local M = { _opts = {} }

local DEFAULTS = {
  args = { "credo", "--format", "json", "--strict" },
  mappings = {
    consistency = vim.diagnostic.severity.INFO,
    warning = vim.diagnostic.severity.ERROR,
    refactor = vim.diagnostic.severity.WARN,
    readability = vim.diagnostic.severity.INFO,
    desingn = vim.diagnostic.severity.INFO,
  },
}

function M.setup(opts)
  M._opts = vim.tbl_deep_extend("force", DEFAULTS, opts or {})
end

function M.run(file)
  file = file or ""
  local args = M._opts.args
  table.insert(args, file)

  Job:new({
    command = "mix",
    args = args,
    on_exit = function(j, status)
      if status == 0 then
        print("[mix credo] no issues")
        return
      end
      if status >= 128 then
        local error = table.concat(j:stderr_result(), "\n")
        Utils.error("[mix credo] failed with code " .. status .. "\n" .. error)
        return
      end
    end,
  }):start()
end

return M

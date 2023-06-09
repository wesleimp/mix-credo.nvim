local Job = require("plenary.job")
local Utils = require("mix-credo.utils")

local M = {}

local namespace = vim.api.nvim_create_namespace("mix-credo")
local augroup = vim.api.nvim_create_augroup("mix-credo", { clear = true })

local options = {
  patterns = { "*.ex", "*.exs" },
  mappings = {
    warning = vim.diagnostic.severity.ERROR,
    consistency = vim.diagnostic.severity.WARN,
    readability = vim.diagnostic.severity.HINT,
    refactor = vim.diagnostic.severity.HINT,
    desingn = vim.diagnostic.severity.HINT,
  },
}

function M.setup(opts)
  options = vim.tbl_deep_extend("force", options, opts or {})

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    group = augroup,
    pattern = options.patterns,
    callback = function()
      M.attach_to_buf(vim.api.nvim_get_current_buf())
    end,
  })
end

function M.attach_to_buf(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local args = { "credo", "--format", "json", "--strict", bufname }

  Job
    :new({
      command = "mix",
      args = args,
      on_exit = vim.schedule_wrap(function(j, status)
        local error = table.concat(j:stderr_result(), "\n")
        if status == 1 and error ~= '"credo" could not be found' then
          return
        end

        if status >= 128 then
          Utils.error(
            "[mix credo] failed with code " .. status .. "\n" .. error
          )
          return
        end

        local content = table.concat(j:result(), "\n")
        local response = vim.json.decode(content)

        local issues = {}
        for _, issue in pairs(response.issues) do
          local column = tonumber(issue.column) or 0
          if column > 0 then
            column = column - 1
          end

          local column_end = tonumber(issue.column_end) or 0
          if column_end > 0 then
            column_end = column_end - 1
          end

          table.insert(issues, {
            bufnr = bufnr,
            lnum = tonumber(issue.line_no) - 1,
            col = column,
            end_col = column_end,
            message = issue.message,
            severity = options.mappings[issue.category],
            source = "MixCredo",
            user_data = {},
          })
        end

        vim.diagnostic.set(namespace, bufnr, issues, {})
      end),
    })
    :start()
end

vim.api.nvim_create_user_command("MixCredo", function()
  M.attach_to_buf(vim.api.nvim_get_current_buf())
end, {})

return M

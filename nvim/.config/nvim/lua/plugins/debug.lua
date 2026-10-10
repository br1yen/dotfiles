vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/mfussenegger/nvim-jdtls",
})

local dap = require("dap")

-- keymaps
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Conditional Breakpoint" })

-- built-in widgets replace dap-ui
local widgets = require("dap.ui.widgets")
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: REPL" })
vim.keymap.set({ "n", "v" }, "<leader>dh", widgets.hover, { desc = "Debug: Hover value" })
vim.keymap.set("n", "<leader>ds", function()
  widgets.centered_float(widgets.scopes)
end, { desc = "Debug: Scopes" })
vim.keymap.set("n", "<leader>df", function()
  widgets.centered_float(widgets.frames)
end, { desc = "Debug: Stack frames" })

-- java
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local debug_jar = vim.fn.glob(
      vim.fn.stdpath("data")
        .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
      true
    )

    require("jdtls").start_or_attach({
      cmd = { "jdtls" },
      root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }) or vim.fn.getcwd(),
      init_options = {
        bundles = debug_jar ~= "" and { debug_jar } or {},
      },
      on_attach = function()
        require("jdtls").setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
      end,
    })
  end,
})

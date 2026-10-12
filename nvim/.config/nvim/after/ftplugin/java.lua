local jdtls = require("jdtls")

-- Use the directory Neovim was launched from.
local project_root = vim.fn.getcwd()

-- Keep separate JDT LS data for each working directory.
local workspace_name = project_root:gsub("[/\\:]", "_")
local workspace_dir = vim.fn.stdpath("data")
    .. "/jdtls-workspace/"
    .. workspace_name

-- Find the Java debugger bundle if it has been installed.
local debug_jars = vim.fn.glob(
  vim.fn.stdpath("data")
  .. "/mason/packages/java-debug-adapter/extension/server/"
  .. "com.microsoft.java.debug.plugin-*.jar",
  false,
  true
)

local config = {
  cmd = {
    "jdtls",
    "-data",
    workspace_dir,
  },

  root_dir = project_root,

  settings = {
    java = {
      project = {
        sourcePaths = { "." },
      },
      configuration = {
        updateBuildConfiguration = "interactive",
      },
    },
  },

  init_options = {
    bundles = debug_jars,
  },
}

jdtls.start_or_attach(config)

-- Register Java debugging with nvim-dap.
jdtls.setup_dap({
  hotcodereplace = "auto",
})

require("jdtls.setup").add_commands()

local jdtls = require("jdtls")

-- Use the directory Neovim was launched from.
local project_root = vim.fn.getcwd()

-- Keep separate JDT LS data for each working directory.
local workspace_name = project_root:gsub("[/\\:]", "_")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. workspace_name

if project_root == vim.env.HOME then
    vim.notify("jdtls: not starting in $HOME; cd into a project first", vim.log.levels.WARN)
    return
end

-- Find the Java debugger bundle if it has been installed.
local debug_jars = vim.fn.glob(
    vim.fn.stdpath("data")
        .. "/mason/packages/java-debug-adapter/extension/server/"
        .. "com.microsoft.java.debug.plugin-*.jar",
    false,
    true
)

local config = {
    cmd = { "jdtls", "-data", workspace_dir },
    cmd_env = { JAVA_HOME = "/usr/lib/jvm/java-25-openjdk" },
    root_dir = project_root,
    settings = {
        java = {
            project = { sourcePaths = { "." } },
            configuration = { updateBuildConfiguration = "interactive" },
        },
    },
    init_options = { bundles = debug_jars },
    on_attach = function()
        jdtls.setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
    end,
}

jdtls.start_or_attach(config)

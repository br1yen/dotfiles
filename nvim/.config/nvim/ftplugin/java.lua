local jdtls = require("jdtls")

-- unique workspace per project so eclipse.jdt.ls doesn't mix up indexes
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

local config = {
  cmd = { "jdtls", "-data", workspace_dir },

  root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw", "pom.xml" }),

  -- merge blink.cmp's LSP capabilities so completions work here too
  capabilities = require("blink.cmp").get_lsp_capabilities(),

  settings = {
    java = {
      -- only needed if your project's JDK differs from the one running jdtls
      -- configuration = {
      --   runtimes = {
      --     { name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk/" },
      --   },
      -- },
    },
  },

  init_options = {
    bundles = {}, -- add java-debug / vscode-java-test jars here later if you want debugging
  },
}

vim.keymap.set("n", "<leader>co", jdtls.organize_imports, { buffer = 0, desc = "Organize imports" })
vim.keymap.set("n", "crv", jdtls.extract_variable, { buffer = 0, desc = "Extract variable" })
vim.keymap.set("v", "crv", function() jdtls.extract_variable(true) end, { buffer = 0 })
vim.keymap.set("n", "crm", jdtls.extract_method, { buffer = 0, desc = "Extract method" })

vim.keymap.set("n", "<leader>jr", function()
  vim.cmd("write")
  local dir = vim.fn.expand("%:p:h")
  local file = vim.fn.expand("%:t")
  local class = vim.fn.expand("%:t:r")
  vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(dir)
    .. " && javac " .. vim.fn.shellescape(file)
    .. " && java " .. class)
end, { desc = "Compile and run current Java file" })

jdtls.start_or_attach(config)

require("jdtls").start_or_attach({
    cmd = { "jdtls" },
    root_dir = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", ".git" }) or vim.fn.getcwd(),
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    settings = {
        java = { symbols = { includeSourceMethodDeclarations = true } },
    },
})

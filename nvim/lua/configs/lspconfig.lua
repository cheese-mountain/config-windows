require("nvchad.configs.lspconfig").defaults()

local capabilities = require("nvchad.configs.lspconfig").capabilities

require("mason-lspconfig").setup {
  automatic_enable = {
        exclude = {
            "jdtls",
            "intelephense"
        }
    },
  ensure_installed = { "omnisharp", "lua_ls", "cssls", "html", "jsonls", "ts_ls", "intelephense", "tailwindcss", "eslint", "jdtls", "kotlin_language_server" }
}

-- local servers = {
--   jsonls = {},
--   cssls = {},
--   ts_ls = {
--     init_options = {
--       maxTsServerMemory = 8192
--     }
--   },
--   dartls = {},
--   -- tailwindcss = {},
--   eslint = {},
--   omnisharp = {},
-- }
--
-- for name, opts in pairs(servers) do
--   vim.lsp.config(name, opts)
--   vim.lsp.enable(name)
-- end

vim.lsp.config("intelephense", {
  capabilities = capabilities,
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_dir = vim.fs.root(0, { "composer.json", ".git" }),
  settings = {
    intelephense = {
      stubs = {
        "apache", "bcmath", "bz2", "calendar", "com_dotnet", "Core", "ctype",
        "curl", "date", "dba", "dom", "enchant", "exif", "FFI", "fileinfo",
        "filter", "fpm", "ftp", "gd", "gettext", "gmp", "hash", "iconv",
        "imap", "intl", "json", "ldap", "libxml", "mbstring", "meta",
        "mysqli", "oci8", "odbc", "openssl", "pcntl", "pcre", "PDO",
        "pdo_ibm", "pdo_mysql", "pdo_pgsql", "pdo_sqlite", "pgsql", "Phar",
        "posix", "pspell", "readline", "Reflection", "session", "shmop",
        "SimpleXML", "snmp", "soap", "sockets", "sodium", "SPL", "sqlite3",
        "standard", "superglobals", "sysvmsg", "sysvsem", "sysvshm", "tidy",
        "tokenizer", "xml", "xmlreader", "xmlrpc", "xmlwriter", "xsl",
        "Zend OPcache", "zip", "zlib", "wordpress", "woocommerce", "acf-pro",
        "wordpress-globals", "wp-cli", "genesis", "polylang"
      },
      environment = {
        includePaths = {'/home/kasper/.config/composer/vendor/php-stubs/'}
      },
      files = {
        maxSize = 5000000,
      },
    },
  }
})
vim.lsp.enable("intelephense")

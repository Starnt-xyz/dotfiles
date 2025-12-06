vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.termguicolors = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

	-- Core Improvements
	{
		"shawnohare/hadalized.nvim",
		opts = {},
		priority = 1000,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = 'master',
		lazy = false,
		build = ":TSUpdate"
	},
	{
		'nvim-telescope/telescope.nvim',
		tag = 'v0.1.9',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			dashboard = { enabled = false },
			explorer = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			picker = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
	},

	-- LSP & Completion
	{
		"williamboman/mason.nvim",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		lazy = false,
	},
	{ "williamboman/mason-lspconfig.nvim", lazy = false },
	{ "neovim/nvim-lspconfig", lazy = false },
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		lazy = false,
	},
	{ "onsails/lspkind.nvim", dependencies = { "nvim-cmp" }, lazy = false },
	{
		'dgagn/diagflow.nvim',
		event = 'LspAttach',
		opts = {}
	},

	-- UI
	{ "nvim-lualine/lualine.nvim", dependencies = { 'nvim-tree/nvim-web-devicons' } },
	{ "windwp/nvim-autopairs" },
	{ "lewis6991/gitsigns.nvim" },
})

require 'nvim-treesitter.configs'.setup {
	ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go", "c", "cpp", "odin" },
	sync_install = false,
	auto_install = true,
	highlight = true,
	additional_vim_regex_highlighting = true,
}

vim.cmd("colorscheme hadalized-dark")
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "clangd", "gopls", "rust_analyzer" },
	automatic_installation = true,
})

local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	sources = cmp.config.sources(
		{
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
		},
		{
			{ name = "buffer" },
			{ name = "path" },
		}
	),
	formatting = {
		format = lspkind.cmp_format({}),
	},
})

require("lspkind").init({})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local clangd_defaults = vim.lsp.config.clangd or {}
vim.lsp.config.clangd = vim.tbl_deep_extend("force", clangd_defaults, { capabilities = capabilities })

local gopls_defaults = vim.lsp.config.gopls or {}
vim.lsp.config.gopls = vim.tbl_deep_extend("force", gopls_defaults, { capabilities = capabilities })

local rust_defaults = vim.lsp.config.rust_analyzer or {}
vim.lsp.config.rust_analyzer = vim.tbl_deep_extend("force", rust_defaults, { capabilities = capabilities })

require("nvim-autopairs").setup()
vim.lsp.enable("clangd")
vim.lsp.enable("gopls")
vim.lsp.enable("rust_analyzer")
require("lualine").setup({})
require('diagflow').setup()

-- Keymaps
vim.keymap.set('n', '<leader>q', ':q!<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>s', ':wq<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>nf', ':enew<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ff', ':Telescope find_files <CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gg', ':Telescope live_grep <CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, bufopts)
vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, bufopts)

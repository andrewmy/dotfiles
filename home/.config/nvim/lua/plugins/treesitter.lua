local function has_c_compiler()
  return vim.fn.executable("cc") == 1
    or vim.fn.executable("gcc") == 1
    or vim.fn.executable("clang") == 1
end

return {
  {
    "windwp/nvim-ts-autotag",
    enabled = has_c_compiler(),
  },
}

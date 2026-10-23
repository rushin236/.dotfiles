vim.filetype.add({
  extension = {
    mdx = "mdx",
    scad = "openscad",
  },

  pattern = {
    [".*%.tmpl"] = "gotmpl",
    [".*%.tpl"] = "gotmpl",

    [".*docker%-compose%.yml"] = "yaml.docker-compose",
    [".*docker%-compose%.yaml"] = "yaml.docker-compose",

    [".*gitlab%-ci%.yml"] = "yaml.gitlab",

    [".*values%.ya?ml"] = "yaml.helm-values",
  },
})

"第二步：配置 ~/.vim/coc-settings.json
"如果该文件不存在，请创建它。 作用： 告诉 Coc 你的代码片段存在哪，并配置 Clangd（C/C++"智能补全和格式化）。
"创建文件，复制下面的即可
"JSON

{
  "snippets.ultisnips.enable": true,
  "snippets.userSnippetsDirectory": "~/.vim/snippets",
  "snippets.priority": 100,
  "suggest.noselect": false,
  "clangd.enabled": true,
  "clangd.arguments": [
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm"
  ],
  "explorer.width": 30,
  "explorer.icon.enableNerdfont": true,
  "explorer.file.showHiddenFiles": true,
  "diagnostic.displayByAle": false
}

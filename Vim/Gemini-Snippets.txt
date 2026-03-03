"第三步：配置 Snippets (代码片段)
"关键修正： 之前你在 vimrc 里写代码片段是错误的。 必须新建文件。 新建目录和文件： 然后 "    mkdir -p ~/.vim/snippets
"    vim ~/.vim/snippets/c.snippets
"将你之前的自定义代码片段粘贴进去：

# ----------------------------
# 1. Structures
# ----------------------------
snippet struct "Struct definition"
struct ${1:name} {
    ${0}
};
endsnippet

snippet tstruct "Typedef struct"
typedef struct ${1:name} {
    ${0}
} ${1:name}_t;
endsnippet

snippet enum "Enum definition"
enum ${1:name} {
    ${0}
};
endsnippet

# ----------------------------
# 2. Functions
# ----------------------------
snippet main "Main function"
int main(int argc, char *argv[]) {
    ${0}
    return 0;
}
endsnippet

snippet fun "Function definition"
${1:void} ${2:name}(${3:args}) {
    ${0}
}
endsnippet

# ----------------------------
# 3. Loops & Control
# ----------------------------
snippet for "For loop"
for (${1:int i = 0}; ${2:i < N}; ${3:i++}) {
    ${0}
}
endsnippet

snippet while "While loop"
while (${1:condition}) {
    ${0}
}
endsnippet

snippet if "If statement"
if (${1:condition}) {
    ${0}
}
endsnippet

snippet ife "If-Else statement"
if (${1:condition}) {
    ${2}
} else {
    ${0}
}
endsnippet

snippet switch "Switch statement"
switch (${1:expression}) {
    case ${2:value}:
        ${3}
        break;
    default:
        ${0}
}
endsnippet

# ----------------------------
# 4. Memory
# ----------------------------
snippet malloc "Malloc"
${1:type} *${2:ptr} = malloc(sizeof(${1:type}) * ${3:size});
assert(${2:ptr} != NULL);
${0}
endsnippet

snippet free "Free"
if (${1:ptr} != NULL) {
    free(${1:ptr});
    ${1:ptr} = NULL;
}
endsnippet

# ----------------------------
# 5. IO
# ----------------------------
snippet printf "Printf"
printf("${1:format}\n", ${2:args});
endsnippet

snippet scanf "Scanf"
scanf("${1:format}", &${2:var});
endsnippet

snippet fprintf "Fprintf"
fprintf(${1:stderr}, "${2:format}\n", ${3:args});
endsnippet

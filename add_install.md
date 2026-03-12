## 📁 词库文件说明（写给未来的自己）

### 1️⃣ 固定短语文件 `custom_phrase.txt`

- **作用**：存放需要**死死顶在首位**的固定短语，比如缩写（`gpio` → `GPIO`）、你的名字、常用代码片段等。
- **特点**：输入编码直接出词，权重设为 `100` 则优先级最高，不会被其他词挤掉。但**不能**参与组词联想（比如输入“单”不会联想出“单片机开发板”）。
- **路径**：`~/.local/share/fcitx5/rime/custom_phrase.txt`
- **格式**：`词<Tab>编码<Tab>权重`  
  例如：`gpio    GPIO    100`

### 2️⃣ 专业词库文件 `embedded.dict.yaml`

- **作用**：存放嵌入式、物联网、智能家居领域的**大量术语**，支持组词联想（比如输入“单”时，“单片机”“单板计算机”都会出现）。
- **特点**：采用完整拼音，可以灵活组合。通过修改 `rime_ice.dict.yaml` 中的加载顺序，让这个词库**优先于其他词库**，相关词汇自然靠前。
- **路径**：`~/.local/share/fcitx5/rime/cn_dicts/embedded.dict.yaml`  
  （如果 `cn_dicts` 文件夹不存在，自己新建一个）
- **格式**：  
  头部元数据（固定写法）：
  
  ```yaml
  # embedded.dict.yaml
  ---
  name: embedded
  version: "1.0"
  sort: by_weight
  use_preset_vocabulary: true
  ...
  ```
  
  之后每行：`词<Tab>完整拼音（空格分隔）<Tab>权重`  
  例如：`单片机    dan pian ji    100`

### 3️⃣ 如何让专业词库优先加载

编辑主配置文件 `~/.local/share/fcitx5/rime/rime_ice.dict.yaml`，找到 `import_tables:` 列表，把你的词库名（不带后缀）加到**最前面**：

```yaml
import_tables:
  - cn_dicts/embedded      # ← 你的词库，现在排第一
  - cn_dicts/base
  - cn_dicts/ext
  - cn_dicts/tencent
  - cn_dicts/others
```

### 4️⃣ 每次修改后必须重新部署

Rime 输入法不会直接读源文件，而是读 `build` 文件夹里的编译结果。修改源文件后，必须**删除旧的 build 缓存**并触发重新编译，新词才会生效。

**方法一（命令行）：**

```bash
rm -rf ~/.local/share/fcitx5/rime/build
fcitx5-remote -r
```

**方法二（图形界面）：**  
在屏幕右上角输入法托盘图标上**右键点击** → 选择 **重新部署 (Redeploy)**。

### 5️⃣ 权重数字说明

- 数字越大，候选词位置越靠前。
- `100` 表示最高优先级（通常够用），如果想更靠前可以设得更高（比如 `200`），但一般没必要。
- 固定短语的权重一定要高，否则可能被其他词库的同编码词覆盖。

### 6️⃣ 两个文件互不冲突

- `custom_phrase.txt` 管“死词”（固定短语）
- `embedded.dict.yaml` 管“活词”（专业词库，支持组词）
- 两者可以同时存在，输入法会合并处理。同一个拼音下，两个文件里的词都会出现，按权重排序。

---

## 🔁 日常维护指南

- **添加新词**：
  - 缩写/固定短语 → 加进 `custom_phrase.txt`
  - 专业术语（尤其是长词） → 加进 `embedded.dict.yaml`
- **修改后**：记得重新部署（删 `build` + `fcitx5-remote -r`）
- **备份/同步**：整个 `~/.local/share/fcitx5/rime/` 文件夹都可以用 Git 管理，换设备时直接拉取并重新部署即可。

---

有任何疑问，随时看这个说明，或者问我 😄

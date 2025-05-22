# C-Minus 编译器实验项目

## 项目简介

本项目为 C-Minus 语言的编译器前端实现，包含词法分析、语法分析、抽象语法树（AST）构建等功能。项目基于 Flex 和 Bison 实现，支持基本的 C-Minus 语法，并能检测常见的词法和语法错误。

## 目录结构

```
.
├── CMakeLists.txt         # CMake 构建脚本
├── cminus.l               # 词法分析器（Flex）
├── cminus.y               # 语法分析器（Bison）
├── globals.h              # 全局类型与变量定义
├── main.c                 # 主程序入口
├── util.c                 # 工具函数
├── test/                  # 测试用例
│   ├── test1.cm
│   ├── test2.cm
│   ├── test3.cm
│   ├── test4.cm
│   └── test5.cm
└── README.md             # 项目说明文档
```

## 环境依赖

- GCC 或兼容的 C 编译器
- [Flex](https://github.com/westes/flex)
- [Bison](https://www.gnu.org/software/bison/)
- [CMake](https://cmake.org/) 3.10 及以上

## 构建与运行

1. **克隆项目**

   ```sh
   git clone https://github.com/tbuliHe/compiler
   cd compiler
   ```

2. **构建项目**

   使用 CMake 构建：

   ```sh
   mkdir -p build
   cd build
   cmake ..
   make
   ```

   构建完成后，`build/` 目录下会生成可执行文件 `cminus_parser`。

3. **运行测试用例**

   在 `build/` 目录下运行：

   ```sh
   ./cminus_parser ../test/test1.cm
   ```

   你可以将 `test/` 目录下的任意 `.cm` 文件作为输入，程序会输出抽象语法树或错误信息。

## 主要文件说明

- [`cminus.l`](cminus.l)：定义 C-Minus 语言的词法规则。
- [`cminus.y`](cminus.y)：定义 C-Minus 语言的语法规则及语法树构建逻辑。
- [`globals.h`](globals.h)：定义语法树节点类型、全局变量等。
- [`main.c`](main.c)：程序入口，负责文件读取、调用解析器、输出结果。
- [`util.c`](util.c)：实现字符串复制、语法树节点创建、语法树打印等工具函数。
- [`test/`](test/)：包含多个测试用例，覆盖不同的语法和错误场景。

## 常见问题

- **找不到 Flex/Bison 命令**  
  请确保 `flex` 和 `bison` 已正确安装，并加入了环境变量。

- **编译错误**  
  检查 CMake 输出，确认依赖已安装，或尝试清理 `build/` 目录后重新构建。

## 联系方式

如有问题，请联系我的qq：2080208310

---
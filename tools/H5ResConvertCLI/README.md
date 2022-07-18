### 介绍
这是一个对h5引擎资源做转换的CLI工具,输入来自unity插件导出的h5引擎资源，输出 转换并压缩的h5资源格式。
源码目录 ：enginetools/h5ResCoverTool/

### 使用
环境依赖 net core 3.1 （没有需先安装好）

命令行运行：
* 打印帮助
> $ H5ResConvertCLI.exe -v

* 执行资源转换 
> $ H5ResConvertCLI.exe -c -r ./xxx/资源目录 ./xxx/转换后的目录 

### 错误处理
如果提示 .lock 卡住， 请删除 ./.lock 文件
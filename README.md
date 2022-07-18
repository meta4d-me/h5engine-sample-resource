### 说明
这是引擎样例项目的资源目录，存放各种引擎样例所有使用到的资源。

### 目录描述
./atlas/				    图集资源。
./audio/				    音频资源。
./effect/				    特效资源。
./font/                     字体资源。
./navmesh/				    导航寻路网格资源。
./particleSystem/           粒子系统资源。
./pbrRes/				    PBR相关(gltf、hdr)资源。
./prefab/				    unity导出预制体资源。
./shader/				    着色器资源。
./spine/				    spine资源。
./texture/				    纹理资源。
./tools/				    工具。

### unity资源转换
引擎当前无法直接加载，unity导出的原始资源格式，需要调用一下转换工具。
流程：
1. unity 导出资源，放置到当前相应目录，例如 "./prefab/"
2. 双击执行 "转换资源.bat" (依赖安装 .net core 3.1)
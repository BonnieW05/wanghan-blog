---
title: dino-wm新开服务器配环境步骤
date: 2025-07-14T00:06:00+08:00
draft: false
tags:
  - 技术笔记
  - 世界模型
categories:
  - 技术笔记
description: 技术笔记描述
cover:
  image: ""
  alt: ""
  caption: ""
  relative: false
---
- 租借的是autodl的服务器，配置是RTX 4090 / 24G （一开始租的是5090，结果一阵配环境后发现项目指定的pytorch版本不支持，所以只好换一下）
	- 服务器租赁教程参考：https://www.bilibili.com/video/BV16PVDzfEvk?vd_source=0e63ac2dd754b64db4ecb7f2de6ea971

- 需要上传的文件(可以先无卡模式开机做上传文件和配环境的工作)
	- dino_wm.zip（我上传的包含源码和dinov2模型修改后的代码）
	- mujoco210-linux-x86_64.tar.gz
	- train/plan任务对应的数据集的压缩包

- 特殊的环境设置
```python
sudo apt update
sudo apt install -y \
libosmesa6-dev \
libgl1-mesa-dev \
libglfw3 \
libglfw3-dev \
patchelf \
gcc \
g++
```

### 数据集/checkpoints下载
https://osf.io/bmw48/files/osfstorage?view_only=a56a296ce3b24cceaf408383a175ce28
下载建议是一个一个zip在浏览器上下载（我尝试整包wget, curl和浏览器下载，均功亏一篑…）
下载在本机后上传到服务器，以及接下来修改路径

### 主流程
大部分内容和github仓库readme指示的一样，但是有一些地方有调整
1. 创建conda环境：在dino_wm目录下conda env create -f environment.yaml, 然后conda activate dino_wm
2. 安装Mujoco: 服务器大概是连不上的，所以要使用上传的文件，放到root/.mujoco并tar -xzvf mujoco210-linux-x86_64.tar.gz
3. 环境变量设置：vi ~/.bashrc i编辑 esc退出编辑 :wq保存并退出
```python
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.mujoco/mujoco210/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/nvidia
export DATASET_DIR=/path/to/data # 比如我把数据集直接扔到了数据盘，所以是"/root/autodl-tmp/dataset"
```
然后source ~/.bashrc
4. 训练模型指令：
```python
python train.py --config-name train.yaml env=point_maze frameskip=5 num_hist=3
```
（如果和我配置一样 会出现跑不动的情况，可在train.yaml里把batch_size改为8）
5. plan指令：
```python
python plan.py model_name=point_maze n_evals=5 planner=cem goal_H=5 goal_source='random_state' planner.opt_steps=30
```
where the model is saved at folder `<ckpt_base_path>/outputs/<model_name>`, and `<ckpt_base_path>` can be specified in `conf/plan.yaml`
- 也就是下载的checkpoints/训练出来的权重存放的位置

### 我做出的修改
可以在走主流程遇到问题后来这里看（？）
1. 直接命令行export HYDRA_FULL_ERROR=1, 可以查看traceback
2. wandb相关
由于现在wandb似乎一直连不上，故使用swanlab替代。首先需要pip install swanlab. 然后使用apikey在命令行进行swanlab login. 在每个有wandb.init的文件里：
```python
import swanlab
import os
swanlab.sync_wandb()
os.environ["WANDB_MODE"] = "offline"
...
wandb.init...
```
3. 关于DinoV2Encoder的报错：由于dino-wm的环境要求是python3.9, 而使用`self.base_model = torch.hub.load("facebookresearch/dinov2", name)`下载下来的代码包含其不允许的语法，故要做出修改。我的方案是：在缓存里找到一开始拉取的代码并把它保存到dino_wm/dinov2_local, 并修改：
```python
// dinov2_local/dinov2/layers/attention.py
from typing import Union
def __init__(self, dim: int, num_heads: int = 8, qkv_bias: bool = False, proj_bias: bool = True, attn_drop: float = 0.0, proj_drop: float = 0.0, init_attn_std: Union[float, None] = None, init_proj_std: Union[float, None] = None, factor: float = 1.0) -> None:

// dinov2_local/dinov2/layers/block.py
from typing import Union

def init_weights(self, init_attn_std: Union[float, None] = None, init_proj_std: Union[float, None] = None, init_fc_std: Union[float, None] = None, factor: float = 1.0) -> None:
```
同时将dino.py中的`self.base_model = torch.hub.load("facebookresearch/dinov2", name)`改为
```python
import os
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
dinov2_path = os.path.join(project_root, "dinov2_local")
self.base_model = torch.hub.load(dinov2_path, name, source='local', pretrained=False)
```


4. 其他：运行时遇到了一些工作目录和运行目录混乱的问题（报错大概是file not found），做了一些修改：
```python
// plan.py
project_root = os.path.dirname(os.path.dirname(os.getcwd()))
model_path = os.path.join(project_root, "outputs", cfg_dict['model_name'])
# ckpt_base_path = cfg_dict["ckpt_base_path"]
# model_path = f"{ckpt_base_path}/outputs/{cfg_dict['model_name']}/"
```

然后就可以快乐炼丹啦！目前我跑了point_maze的plan和train都没有问题。如果还有解决不了的报错可以联系我讨论～

---

**标签**: #技术笔记 #世界模型
**分类**: 技术笔记  
**创建时间**: 2025-07-14 00:06  
**更新时间**: 2025-07-14 00:06

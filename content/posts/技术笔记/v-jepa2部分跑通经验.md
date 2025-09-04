---
title: v-jepa2部分跑通经验
date: 2025-07-15T22:47:00+08:00
draft: false
tags:
  - 技术笔记
  - 世界模型
categories:
  - 技术笔记
description:
cover:
  image: ""
  alt: ""
  caption: ""
  relative: false
---
# vjepa代码部分跑通经验

租的依然是autodl上RTX4090/24G, 服务器租赁相关见上篇


## 环境配置

在clone下来的主目录下运行

```

conda create -n vjepa2-312 python=3.12

conda activate vjepa2-312

pip install .

```

  

## 跑通demo

### notebooks/vjepa2_demo.ipynb —— for mac

一开始是在mac上做的尝试，所以这里提供一下在mac上成功运行vjepa2_demo.ipynb所需的改动（把cuda相关的改掉，然后把没办法连接到的资源换个源）。以及出于对配置的考虑将giant相关的代码改成了large相关代码

  

1. 将decord换成opencv

将from decord import VideoReader换成import cv2

在第一个块中

```python

if os.getcwd().endswith('notebooks'):

os.chdir('..') # 切换到项目根目录

```

将原先的get_video()用以下函数替代

```python

def get_video():

cap = cv2.VideoCapture("sample_video.mp4")

total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

frames = []

frame_idx = np.arange(0, min(128, total_frames), 2)

current_frame = 0

while True:

ret, frame = cap.read()

if not ret:

break

if current_frame in frame_idx:

frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

frame_tensor = torch.tensor(frame_rgb, dtype=torch.uint8) # 使用 torch.tensor() 代替 torch.from_numpy()

frames.append(frame_tensor)

current_frame += 1

if len(frames) >= len(frame_idx):

break

cap.release()

video = torch.stack(frames, dim=0)

return video

```

  

2. giant转large

将from src.models.vision_transformer import vit_giant_xformers_rope换成from src.models.vision_transformer import vit_large_rope

以及在load模型的时候变成hf_model_name = "facebook/vjepa2-vitl-fpc64-256"

  

3. 关于换源

因为在本机上一直连不上hugging face, 所以做了以下替换。但如果是在autodl服务器上跑的话，可以采用科研相关加速来解决。详情见其文档。

在命令行运行export HF_ENDPOINT=https://hf-mirror.com

将forward_vjepa_video()用以下函数替代

```python

def forward_vjepa_video(model_hf, model_pt, hf_transform, pt_transform):

with torch.inference_mode():

video = get_video()

if video.dtype == torch.uint8:

video = video.float() / 255.0

video = video.permute(0, 3, 1, 2)

x_pt = pt_transform(video).unsqueeze(0)

x_hf = x_pt

out_patch_features_pt = model_pt(x_pt)

out_patch_features_hf = model_pt(x_hf)

return out_patch_features_hf, out_patch_features_pt

```

模型加载模块变成

```python

# HuggingFace model repo name

hf_model_name = "facebook/vjepa2-vitl-fpc64-256"

# Path to local PyTorch weights

pt_model_path = "./models/vitl.pt"

  

try:

model_hf = AutoModel.from_pretrained(hf_model_name, trust_remote_code=True)

hf_transform = AutoVideoProcessor.from_pretrained(hf_model_name, trust_remote_code=True)

img_size = hf_transform.crop_size["height"]

model_hf.eval()

print("✅ HuggingFace 加载成功")

except:

print("⚠️ HuggingFace 失败，使用 PyTorch 版本")

img_size = 256 # 从模型名推断

model_pt = vit_large_rope(img_size=(img_size, img_size), num_frames=64)

model_pt.eval()

load_pretrained_vjepa_pt_weights(model_pt, pt_model_path)

model_hf = model_pt

class SimpleTransform:

crop_size = {"height": img_size}

hf_transform = SimpleTransform()

  

if 'model_pt' not in locals():

model_pt = model_hf

  

# Build PyTorch preprocessing transform

pt_video_transform = build_pt_video_transform(img_size=img_size)

```

  

最后运行起来效果belike:

![alt text](0bd94464f353ac52f9384167e8686a1.png)

:)

  

### vjepa2_demo.py —— for networkless(

由于一开始我实在本机wsl上跑的，这个部分的很多东西一直连不上，所以直接采用了暴力下载 + 上传 + 直接在本地load的方法 X 所以如果能连上的话大概不用这么麻烦

具体来说：

1. 资源获取

直接在浏览器输入 https://dl.fbaipublicfiles.com/vjepa2/vitg-384.pt和https://dl.fbaipublicfiles.com/vjepa2/evals/ssv2-vitg-384-64x2x3.pt 下载了文件然后上传到了服务器，并移到了/root/autodl-tmp/vjepa2_models

ssv2_classes.json直接点击 https://huggingface.co/datasets/huggingface/label-files/resolve/d79675f2d50a7b1ecf98923d42c30526a51818e2/ 然后把内容复制到了本地/root/autodl-tmp/ssv2_classes.json文件中

然后视频也是直接从 https://huggingface.co/datasets/nateraw/kinetics-mini/resolve/main/val/bowling/-WH-lxmGJVY_000005_000015.mp4 上搞的并改名sample_video.mp4

  

2. 修改路径

pt_model_path = "./vitg-384.pt"

classifier_model_path = "./ssv2-vitg-384-64x2x3.pt"

sample_video_path = "./sample_video.mp4"

ssv2_classes_path = "./ssv2_classes.json"

  

3. 修改代码

```python

# hf_model_name = (

# "facebook/vjepa2-vitg-fpc64-384" # Replace with your favored model, e.g. facebook/vjepa2-vitg-fpc64-384

# )

  

# # Initialize the HuggingFace model, load pretrained weights

# model_hf = AutoModel.from_pretrained(hf_model_name)

# model_hf.cuda().eval()

  

# # Build HuggingFace preprocessing transform

# hf_transform = AutoVideoProcessor.from_pretrained(hf_model_name)

# img_size = hf_transform.crop_size["height"] # E.g. 384, 256, etc.

  

# Inference on video

# out_patch_features_hf, out_patch_features_pt = forward_vjepa_video(

# model_hf, model_pt, hf_transform, pt_video_transform

# )

  

# print(

# f"""

# Inference results on video:

# HuggingFace output shape: {out_patch_features_hf.shape}

# PyTorch output shape: {out_patch_features_pt.shape}

# Absolute difference sum: {torch.abs(out_patch_features_pt - out_patch_features_hf).sum():.6f}

# Close: {torch.allclose(out_patch_features_pt, out_patch_features_hf, atol=1e-3, rtol=1e-3)}

# """

# )

  

with torch.inference_mode():

video = get_video() # T x H x W x C

video = torch.from_numpy(video).permute(0, 3, 1, 2) # T x C x H x W

x_pt = pt_video_transform(video).cuda().unsqueeze(0)

out_patch_features_pt = model_pt(x_pt)

  

print(f"PyTorch output shape: {out_patch_features_pt.shape}")

```

然后应该就能跑通啦

  

## 跑通evaluation

我跑的是ssv2的评估，主要解决了几个难题：数据集下载与处理，配置修改与模型转换。下面将分点描述

  

### 数据集相关

something something v2数据集可以在 https://www.qualcomm.com/developer/software/something-something-v-2-dataset/downloads 下载到

其中两个zip文件都下载后，进入存放它们的目录，使用 cat 20bn-something-something-v2-?? | tar zx 指令进行解压，会得到一个巨大的20bn-something-something-v2目录，里面就是视频文件。

（两点注意：首先，这两个文件必须一起解压，只有第一个，会提示奇怪的EOF; 只有第二个会无法开始。 其次，如果是使用autodl云服务器的话，这时候就应该考虑先扩容一下数据盘，然后弄完之后删掉解压前文件再缩容即可。我是中间扩容了20G，够用）

  

#### 使用脚本创建csv文件

注意到配置文件里data相关要求的是csv文件，而我们下载和解压后得到的只是视频文件和label, 因此还需要再做一个处理。

```python

#!/usr/bin/env python3

import os

import json

from pathlib import Path

  

# 配置文件路径

data_root = "/root/autodl-tmp/dataset/20bn-something-something-v2"

config_dir = "/root/autodl-tmp/dataset/labels"

output_dir = "/root/autodl-tmp/dataset/csv"

os.makedirs(output_dir, exist_ok=True)

  

def normalize_template(template):

import re

return re.sub(r'\[([^\]]+)\]', r'\1', template)

  

def load_labels_mapping(config_dir):

labels_path = os.path.join(config_dir, "labels.json")

if os.path.exists(labels_path):

with open(labels_path, 'r', encoding='utf-8') as f:

labels_data = json.load(f)

if isinstance(labels_data, dict):

return labels_data

elif isinstance(labels_data, list):

return {label: i for i, label in enumerate(labels_data)}

return {}

  

def create_vjepa_csv(split_name, json_filename, data_root, config_dir, output_dir, label_mapping=None):

json_path = os.path.join(config_dir, json_filename)

if not os.path.exists(json_path):

return None

with open(json_path, 'r', encoding='utf-8') as f:

data = json.load(f)

  

csv_lines = []

for item in data:

video_id = item['id']

video_path = os.path.join(data_root, f"{video_id}.webm")

if not os.path.exists(video_path):

continue

if 'template' in item:

template = item['template']

normalized_template = normalize_template(template)

if label_mapping and normalized_template in label_mapping:

label_num = int(label_mapping[normalized_template])

csv_lines.append(f"{video_path} {label_num}") # 这个格式是查看了模型中相关处理代码得出的。实际上，它是按列识别。

else:

csv_lines.append(f"{video_path} 0")

  

if not csv_lines:

return None

  

csv_path = os.path.join(output_dir, f"ssv2_{split_name}_vjepa_format.csv")

with open(csv_path, 'w', encoding='utf-8') as f:

f.write('\n'.join(csv_lines))

return csv_path

  

def main():

if not os.path.exists(data_root) or not os.path.exists(config_dir):

return

  

label_mapping = load_labels_mapping(config_dir)

create_vjepa_csv("train", "train.json", data_root, config_dir, output_dir, label_mapping)

create_vjepa_csv("val", "validation.json", data_root, config_dir, output_dir, label_mapping)

create_vjepa_csv("test", "test.json", data_root, config_dir, output_dir, label_mapping)

  

if __name__ == "__main__":

main()

```

这样，我们就得到了所需的csv文件

  

### 配置修改

找到/root/autodl-tmp/configs/eval文件，修改所选模型对应的ssv2.yaml文件。此处以/root/autodl-tmp/configs/eval/vitl/ssv2.yaml在我选择租赁的服务器上的修改为例

```yaml

folder: /root/autodl-tmp/vjepa2_experiments/ssv2_eval # 输出目录

mem_per_gpu: 20G

nodes: 1

  

data:

dataset_train: /root/autodl-tmp/dataset/csv/ssv2_train_vjepa_format.csv

dataset_val: /root/autodl-tmp/dataset/csv/ssv2_val_vjepa_format.csv

  

optimization:

batch_size: 1

  

checkpoint: /root/autodl-tmp/vjepa2_models/vjepa_official.pt

```

如果是giant模型其实也差不多。主要就是要根据配置信息调整一些参数。

  

### 模型转换

由于giant-368模型对显存要求太高，我将配置一降再降都没有能成功跑起来，所以我开始思考转向更小规模的模型。但是通过 https://dl.fbaipublicfiles.com/vjepa2/vitl.pt 是获取不到large模型的pt文件的，而只能通过 https://huggingface.co/collections/facebook/v-jepa-2-6841bad8413014e185b497a6 在hugging face上的文件，所以就在思考怎么样得到一个vitl.pt填进配置文件里（否则的话要把模型调用的地方全部改掉，可能会比较麻烦）

碎碎念：一开始我只是觉得也许可以试试把hugging face的代码转成pt文件，然后就去找ai问了一版代码（其实这两个能转倒是比较自然，毕竟都是模型记录相关的，只是不同的形式） 但是当我试图直接用第一版弄出来的pt文件跑，却出现了各种各样的报错。我看了一下报错，大概是因为有一些字段缺失，就想到可能是pt这种格式其实也不是完全相同的，大概还得符合一定的规范。正好其实是有一个能下载下来但是没用上的vitg-384.pt，我就想：也许可以写脚本分析一下它有什么，然后反过来构建自己的文件。于是就把需求告诉了ai（并和它进行了极限拉扯。。。它有时候真的是听不懂人话🤬） 不过经历几番拉扯，我又自己小改了一下之后，就得到了正确的“翻译脚本”，最后成功把评估跑起来了。代码如下：

  

```python

#!/usr/bin/env python3

"""

V-JEPA 模型从 Hugging Face 下载、转换和保存脚本（改进版）

支持多种转换模式以满足不同需求

"""

  

import os

import torch

import requests

from pathlib import Path

from huggingface_hub import hf_hub_download, snapshot_download

from transformers import AutoModel, AutoConfig

import json

from collections import OrderedDict

  

def setup_directories():

"""创建必要的目录"""

dirs = ['models', 'converted_models', 'checkpoints']

for d in dirs:

Path(d).mkdir(exist_ok=True)

return dirs

  

def download_vjepa_from_hf(model_name="facebook/vjepa2-vitl-fpc64-256", local_dir="./models"):

"""

从 Hugging Face 下载 V-JEPA 模型

"""

print(f"开始从 Hugging Face 下载 {model_name}...")

try:

# 方法1: 下载整个仓库

local_path = snapshot_download(

repo_id=model_name,

local_dir=local_dir,

local_dir_use_symlinks=False

)

print(f"模型已下载到: {local_path}")

return local_path

except Exception as e:

print(f"下载失败: {e}")

  

def remove_module_prefix(state_dict):

"""

移除键名中的 'module.' 前缀

"""

new_state_dict = OrderedDict()

for key, value in state_dict.items():

if key.startswith('module.'):

new_key = key[7:] # 移除 'module.'

else:

new_key = key

new_state_dict[new_key] = value

return new_state_dict

  

def extract_encoder_only(checkpoint):

"""

只提取encoder部分

"""

if 'encoder' in checkpoint:

encoder_state = checkpoint['encoder']

return remove_module_prefix(encoder_state)

else:

# 如果直接是state_dict格式

return remove_module_prefix(checkpoint)

  

def extract_full_model(checkpoint):

"""

提取完整模型（encoder + predictor）

"""

full_state = OrderedDict()

if 'encoder' in checkpoint:

# 添加encoder

encoder_state = remove_module_prefix(checkpoint['encoder'])

for key, value in encoder_state.items():

full_state[f"encoder.{key}"] = value

# 添加predictor

if 'predictor' in checkpoint:

predictor_state = remove_module_prefix(checkpoint['predictor'])

for key, value in predictor_state.items():

full_state[f"predictor.{key}"] = value

else:

# 如果直接是state_dict格式

full_state = remove_module_prefix(checkpoint)

return full_state

  

def extract_backbone_only(checkpoint):

"""

只提取backbone部分（不包含预测头）

"""

backbone_state = OrderedDict()

if 'encoder' in checkpoint:

encoder_state = remove_module_prefix(checkpoint['encoder'])

for key, value in encoder_state.items():

if key.startswith('backbone.') and not key.startswith('backbone.predictor'):

new_key = key[9:] # 移除 'backbone.'

backbone_state[new_key] = value

else:

# 如果直接是state_dict格式

state_dict = remove_module_prefix(checkpoint)

for key, value in state_dict.items():

if not key.startswith('predictor') and not key.startswith('head'):

backbone_state[key] = value

return backbone_state

  

def convert_to_standard_vit(checkpoint):

"""

转换为标准ViT格式

"""

standard_state = OrderedDict()

if 'encoder' in checkpoint:

encoder_state = remove_module_prefix(checkpoint['encoder'])

else:

encoder_state = remove_module_prefix(checkpoint)

# 映射键名到标准ViT格式

key_mapping = {

'backbone.patch_embed.proj.weight': 'patch_embed.projection.weight',

'backbone.patch_embed.proj.bias': 'patch_embed.projection.bias',

'backbone.pos_embed': 'embeddings.position_embeddings',

'backbone.cls_token': 'embeddings.cls_token',

}

for old_key, value in encoder_state.items():

# 处理特殊映射

if old_key in key_mapping:

new_key = key_mapping[old_key]

elif old_key.startswith('backbone.blocks.'):

# 转换注意力和MLP层

new_key = old_key.replace('backbone.blocks.', 'encoder.layer.')

new_key = new_key.replace('.attn.', '.attention.attention.')

new_key = new_key.replace('.mlp.', '.intermediate.')

elif old_key.startswith('backbone.norm.'):

new_key = old_key.replace('backbone.norm.', 'layernorm.')

else:

new_key = old_key

standard_state[new_key] = value

return standard_state

  

def convert_to_official_format(checkpoint):

"""

转换为官方checkpoint格式，保持完整结构

"""

official_checkpoint = {}

# 如果已经是官方格式，直接返回

if 'encoder' in checkpoint and 'predictor' in checkpoint:

print("检测到已是官方checkpoint格式")

return checkpoint

# 如果是单一state_dict，需要重构为官方格式

if isinstance(checkpoint, dict) and 'encoder' not in checkpoint:

print("转换单一state_dict为官方格式")

# 初始化结构

encoder_state = OrderedDict()

predictor_state = OrderedDict()

for key, value in checkpoint.items():

if 'predictor' in key or 'mask_token' in key:

# 确保有module.backbone前缀

if not key.startswith('module.backbone.'):

new_key = f'module.backbone.{key}'

else:

new_key = key

predictor_state[new_key] = value

else:

# 其他都归类为encoder

if not key.startswith('module.backbone.'):

new_key = f'module.backbone.{key}'

else:

new_key = key

encoder_state[new_key] = value

# 构建官方格式

official_checkpoint['encoder'] = encoder_state

official_checkpoint['predictor'] = predictor_state

official_checkpoint['target_encoder'] = encoder_state.copy() # target_encoder通常是encoder的副本

# 添加训练相关的默认值

official_checkpoint['epoch'] = 0

official_checkpoint['loss'] = 0.0

official_checkpoint['batch_size'] = 1

official_checkpoint['world_size'] = 1

official_checkpoint['lr'] = 0.0001

# 添加空的优化器和scaler状态

official_checkpoint['opt'] = {'state': {}, 'param_groups': []}

official_checkpoint['scaler'] = {

'scale': 1.0,

'growth_factor': 2.0,

'backoff_factor': 0.5,

'growth_interval': 2000,

'_growth_tracker': 0

}

return official_checkpoint

  

def convert_model_format(input_path, output_path, conversion_mode="official_format"):

"""

转换模型格式

conversion_mode 选项:

- "official_format": 转换为官方checkpoint格式（推荐）

- "encoder_only": 只提取encoder

- "full_model": 提取encoder+predictor

- "backbone_only": 只提取backbone（无预测头）

- "standard_vit": 转换为标准ViT格式

- "raw": 保持原始格式，只去除module前缀

"""

print(f"开始转换模型格式，模式: {conversion_mode}")

try:

# 检查输入路径

if os.path.isdir(input_path):

# 如果是目录，寻找模型文件

possible_files = [

"pytorch_model.bin",

"model.safetensors",

"vitl.pt",

"checkpoint.pth"

]

model_file = None

for f in possible_files:

full_path = os.path.join(input_path, f)

if os.path.exists(full_path):

model_file = full_path

break

if not model_file:

raise FileNotFoundError("在目录中未找到模型文件")

else:

model_file = input_path

print(f"加载模型文件: {model_file}")

# 加载模型

if model_file.endswith('.safetensors'):

from safetensors.torch import load_file

checkpoint = load_file(model_file)

else:

checkpoint = torch.load(model_file, map_location='cpu')

print(f"原始检查点包含 {len(checkpoint)} 个顶层键")

if isinstance(checkpoint, dict):

print(f"顶层键: {list(checkpoint.keys())}")

# 根据转换模式处理

if conversion_mode == "official_format":

# 转换为官方格式

final_checkpoint = convert_to_official_format(checkpoint)

elif conversion_mode == "encoder_only":

final_checkpoint = extract_encoder_only(checkpoint)

elif conversion_mode == "full_model":

final_checkpoint = extract_full_model(checkpoint)

elif conversion_mode == "backbone_only":

final_checkpoint = extract_backbone_only(checkpoint)

elif conversion_mode == "standard_vit":

final_checkpoint = convert_to_standard_vit(checkpoint)

elif conversion_mode == "raw":

if 'encoder' in checkpoint:

final_checkpoint = remove_module_prefix(checkpoint['encoder'])

else:

final_checkpoint = remove_module_prefix(checkpoint)

else:

raise ValueError(f"不支持的转换模式: {conversion_mode}")

# 创建输出目录

Path(output_path).mkdir(exist_ok=True)

# 保存转换后的模型

if conversion_mode == "official_format":

output_file = os.path.join(output_path, 'vjepa_official.pt')

else:

output_file = os.path.join(output_path, f'vjepa_{conversion_mode}.pt')

torch.save(final_checkpoint, output_file)

print(f"模型已保存到: {output_file}")

# 保存模型信息

if conversion_mode == "official_format":

# 对于官方格式，显示详细结构信息

info = {

'original_file': model_file,

'converted_file': output_file,

'conversion_mode': conversion_mode,

'checkpoint_structure': {

'top_level_keys': list(final_checkpoint.keys()),

'encoder_tensors': len(final_checkpoint['encoder']) if 'encoder' in final_checkpoint else 0,

'predictor_tensors': len(final_checkpoint['predictor']) if 'predictor' in final_checkpoint else 0,

'target_encoder_tensors': len(final_checkpoint['target_encoder']) if 'target_encoder' in final_checkpoint else 0

},

'encoder_keys_sample': list(final_checkpoint['encoder'].keys())[:5] if 'encoder' in final_checkpoint else [],

'predictor_keys_sample': list(final_checkpoint['predictor'].keys())[:5] if 'predictor' in final_checkpoint else []

}

else:

# 其他格式的标准信息

if isinstance(final_checkpoint, dict):

num_params = sum(p.numel() for p in final_checkpoint.values() if torch.is_tensor(p))

num_tensors = len([v for v in final_checkpoint.values() if torch.is_tensor(v)])

sample_keys = [k for k, v in final_checkpoint.items() if torch.is_tensor(v)][:10]

else:

num_params = 0

num_tensors = 0

sample_keys = []

info = {

'original_file': model_file,

'converted_file': output_file,

'conversion_mode': conversion_mode,

'num_parameters': num_params,

'num_tensors': num_tensors,

'model_keys_sample': sample_keys

}

info_file = os.path.join(output_path, f'model_info_{conversion_mode}.json')

with open(info_file, 'w', encoding='utf-8') as f:

json.dump(info, f, indent=2, ensure_ascii=False)

print(f"模型信息已保存到: {info_file}")

# 显示转换结果摘要

if conversion_mode == "official_format":

print(f"\n✅ 转换为官方格式成功!")

print(f" 顶层键: {list(final_checkpoint.keys())}")

if 'encoder' in final_checkpoint:

print(f" encoder: {len(final_checkpoint['encoder'])} 个张量")

if 'predictor' in final_checkpoint:

print(f" predictor: {len(final_checkpoint['predictor'])} 个张量")

else:

print(f"转换后包含 {len(final_checkpoint)} 个张量" if isinstance(final_checkpoint, dict) else "转换完成")

return output_file

except Exception as e:

print(f"转换失败: {e}")

import traceback

traceback.print_exc()

return None

  

def verify_model(model_path):

"""

验证转换后的模型

"""

print(f"\n验证模型: {model_path}")

try:

# 加载模型并检查

checkpoint = torch.load(model_path, map_location='cpu')

# 检查是否为官方checkpoint格式

if isinstance(checkpoint, dict) and 'encoder' in checkpoint:

print("✓ 检测到官方checkpoint格式")

print(f" 顶层键: {list(checkpoint.keys())}")

if 'encoder' in checkpoint:

encoder_keys = len(checkpoint['encoder'])

print(f" encoder: {encoder_keys} 个张量")

# 显示encoder的示例键名

sample_keys = list(checkpoint['encoder'].keys())[:3]

for key in sample_keys:

tensor = checkpoint['encoder'][key]

print(f" {key}: {tensor.shape}")

if 'predictor' in checkpoint:

predictor_keys = len(checkpoint['predictor'])

print(f" predictor: {predictor_keys} 个张量")

if 'target_encoder' in checkpoint:

target_encoder_keys = len(checkpoint['target_encoder'])

print(f" target_encoder: {target_encoder_keys} 个张量")

# 计算总参数量

total_params = 0

for key in ['encoder', 'predictor', 'target_encoder']:

if key in checkpoint:

total_params += sum(p.numel() for p in checkpoint[key].values())

print(f" 总参数量: {total_params:,}")

else:

# 单一state_dict格式

print("✓ 检测到单一state_dict格式")

if isinstance(checkpoint, dict):

state_dict = checkpoint

print(f"模型包含 {len(state_dict)} 个参数张量")

print(f"总参数量: {sum(p.numel() for p in state_dict.values()):,}")

# 显示一些关键信息

print("\n模型结构概览:")

for i, (name, tensor) in enumerate(state_dict.items()):

if i < 10: # 显示前10个

print(f" {name}: {tensor.shape}")

elif i == 10:

print(f" ... 还有 {len(state_dict) - 10} 个张量")

break

# 检查常见的层

key_patterns = ['patch_embed', 'pos_embed', 'blocks', 'norm', 'head']

print("\n层类型分析:")

for pattern in key_patterns:

matching_keys = [k for k in state_dict.keys() if pattern in k.lower()]

if matching_keys:

print(f" {pattern}: {len(matching_keys)} 个相关键")

return True

except Exception as e:

print(f"验证失败: {e}")

return False

  

def download_via_transformers(model_name="facebook/vjepa2-vitl-fpc64-256", output_dir="./models"):

"""

通过 transformers 库下载 V-JEPA 2 模型

"""

print(f"通过 transformers 下载 {model_name}...")

try:

from transformers import AutoModel, AutoConfig

import torch

# 下载配置和模型

config = AutoConfig.from_pretrained(model_name)

model = AutoModel.from_pretrained(model_name)

# 保存模型

Path(output_dir).mkdir(exist_ok=True)

output_path = os.path.join(output_dir, "vjepa2_model.pt")

torch.save(model.state_dict(), output_path)

# 保存配置

config_path = os.path.join(output_dir, "config.json")

config.save_pretrained(output_dir)

print(f"模型已保存到: {output_path}")

print(f"配置已保存到: {config_path}")

return output_path

except Exception as e:

print(f"transformers 下载失败: {e}")

return None

  

def download_via_torch_hub(model_name='vjepa2_vit_large', output_dir="./models"):

"""

通过 torch.hub 下载 V-JEPA 2 模型

"""

print(f"通过 torch.hub 下载 {model_name}...")

try:

import torch

# 下载模型

model = torch.hub.load('facebookresearch/vjepa2', model_name, pretrained=True)

# 保存模型状态字典

Path(output_dir).mkdir(exist_ok=True)

output_path = os.path.join(output_dir, f"{model_name}.pt")

torch.save(model.state_dict(), output_path)

print(f"模型已保存到: {output_path}")

return output_path

except Exception as e:

print(f"torch.hub 下载失败: {e}")

return None

  

def main():

"""

主函数

"""

print("V-JEPA 2 模型下载转换工具（改进版）")

print("=" * 60)

# 创建目录

setup_directories()

# 方法1: 尝试通过 transformers 下载

print("方法1: 通过 transformers 下载...")

model_path = download_via_transformers()

if not model_path:

# 方法2: 尝试从 Hugging Face Hub 下载

print("\n方法2: 从 Hugging Face Hub 下载...")

model_path = download_vjepa_from_hf()

if not model_path:

# 方法3: 尝试通过 torch.hub 下载

print("\n方法3: 通过 torch.hub 下载...")

model_path = download_via_torch_hub()

if model_path:

print(f"\n成功下载模型到: {model_path}")

# 首先转换为官方格式（主要目标）

print("\n--- 转换为官方checkpoint格式 ---")

converted_path = convert_model_format(model_path, "./converted_models", "official_format")

if converted_path:

if verify_model(converted_path):

print(f"🎉 官方格式转换成功: {converted_path}")

print("✅ 模型已转换为和官方vitg-384.pt相同的格式!")

else:

print("❌ 官方格式验证失败")

else:

print("❌ 官方格式转换失败")

else:

print("\n❌ 所有下载方法都失败")

print("\n备选方案:")

print("1. 手动下载模型文件")

print("2. 使用 convert_local_model() 函数转换本地文件")

  

def convert_local_model(local_file_path, conversion_mode="official_format"):

"""

转换本地模型文件（支持多种转换模式）

"""

if not os.path.exists(local_file_path):

print(f"文件不存在: {local_file_path}")

return None

setup_directories()

return convert_model_format(local_file_path, "./converted_models", conversion_mode)

  

def batch_convert_local_model(local_file_path):

"""

批量转换本地模型文件为所有支持的格式

"""

conversion_modes = ["official_format", "encoder_only", "full_model", "backbone_only", "standard_vit", "raw"]

results = {}

for mode in conversion_modes:

print(f"\n--- 转换模式: {mode} ---")

result = convert_local_model(local_file_path, mode)

results[mode] = result

if result and verify_model(result):

print(f"✅ {mode} 模式转换成功")

else:

print(f"❌ {mode} 模式转换失败")

return results

  

if __name__ == "__main__":

# 可以直接运行主程序

# main()

# 或者转换本地文件（取消注释并修改路径）

# convert_local_model("path/to/your/model.pt", "official_format")

# 或者批量转换所有格式

# batch_convert_local_model("path/to/your/model.pt")

# 显示使用说明

print("🎯 V-JEPA模型下载转换工具")

print("="*50)

print("主要功能: 下载并转换为官方checkpoint格式")

print("\n📖 使用说明:")

print("1. main() - 下载并转换为官方格式")

print("2. convert_local_model(file_path) - 转换本地文件为官方格式")

print("3. convert_local_model(file_path, mode) - 转换为指定格式")

print("4. batch_convert_local_model(file_path) - 批量转换所有格式")

print("\n🔧 转换模式:")

print("- official_format: 转换为官方checkpoint格式 (🎯推荐)")

print("- encoder_only: 只提取encoder部分")

print("- full_model: 提取encoder+predictor")

print("- backbone_only: 只提取backbone（无预测头）")

print("- standard_vit: 转换为标准ViT格式")

print("- raw: 保持原始格式，只去除module前缀")

print("\n💡 快速开始:")

print('# 下载并转换为官方格式')

print('main()')

print('\n# 转换本地文件')

print('convert_local_model("your_model.pt")')

# 自动运行主程序

main()

```

得到vitl.pt并修改配置文件中的路径后，使用 `python -m evals.main --fname /root/autodl-tmp/configs/eval/vitl/ssv2.yaml \ --devices cuda:0` 指令就可以跑起来啦

（但是有一说一，我这个配置跑得相当的慢。最后跑了四五个小时还没跑完，我就手动停下了，因为我租服务器的预算还是有限的。。）

  

接下来主要会看一下实现的代码，暂时不打算继续做训练的跑通啦。如果有什么问题欢迎联系我讨论~

---

**标签**: #技术笔记 #世界模型
**分类**: 技术笔记  
**创建时间**: 2025-07-15 22:47  
**更新时间**: 2025-07-15 22:47

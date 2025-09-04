---
title: 数学公式测试
date: 2025-09-04T21:00:00+08:00
draft: false
math: true
tags:
  - 测试
categories:
  - 测试
description: 测试数学公式渲染
---

# 数学公式测试

## 行内公式测试

这是一个行内公式：$T_{\text{old}} = 100$

另一个行内公式：$a + b = c$

## 块级公式测试

$$T_{\text{new}} = T_{\text{old}} \left[ (1 - a) + \frac{a}{k} \right]$$

$$S = \frac{T_{\text{old}}}{T_{\text{new}}} = \frac{1}{(1 - a) + \frac{a}{k}}$$

## 复杂公式测试

$$TAdd_w(u,v)=\left\{\begin{matrix}
u+v+2^w&u+v<TMin_w&NegOver/向下溢出\\
u+v&TMin_w\leq u+v\leq TMax_w&\\
u+v-2^w&Tmax_w<u+v&PosOver/向上溢出
\end{matrix}\right.$$

如果这些公式都能正确显示，说明MathJax配置成功！

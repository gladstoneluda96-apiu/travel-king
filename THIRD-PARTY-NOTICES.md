# 第三方组件与许可说明

本文件列出旅游大王（Travel King）直接依赖的第三方组件、字体与其许可证。
各组件版权归其作者所有，本项目仅按各自许可证的要求使用。

> ⚠️ **请先阅读第 3 节「与 GPL-2.0 的许可冲突提示」**：本项目依赖的 HelloAgents 采用
> CC-BY-NC-SA-4.0（含非商业限制），会影响本项目的整体使用范围。

## 1. 后端依赖

| 组件 | 版本 | 许可证 |
| --- | --- | --- |
| fastapi | 0.141.1 | MIT |
| uvicorn | 0.54.0 | BSD-3-Clause |
| pydantic / pydantic-settings | 2.13.5 / 2.15.0 | MIT |
| httpx | 0.28.1 | BSD-3-Clause |
| aiohttp | 3.14.3 | Apache-2.0 AND MIT |
| python-dotenv | 1.2.3 | BSD-3-Clause |
| loguru | 0.7.3 | MIT |
| PyExecJS | 1.5.1 | MIT |
| requests | 2.34.2 | Apache-2.0 |
| aiosqlite | 0.22.1 | MIT |
| pypinyin | 0.55.0 | MIT |
| python-dateutil | 2.9.0 | Dual License（PSF / BSD） |
| huggingface_hub | 2.0.0 | Apache-2.0 |
| openai | 1.109.1 | Apache-2.0 |
| fastmcp | 2.14.7 | Apache-2.0 |
| uv | 0.12.19 | MIT OR Apache-2.0 |
| **hello-agents** | **0.2.9** | **CC-BY-NC-SA-4.0（非商业 + 相同方式共享）** |

## 2. 前端依赖

| 组件 | 版本 | 许可证 |
| --- | --- | --- |
| vue | 3.5.22 | MIT |
| vue-router | 4.5.1 | MIT |
| vue-i18n | 9.14.4 | MIT |
| ant-design-vue | 4.2.6 | MIT |
| @ant-design/icons-vue | 7.0.1 | MIT |
| axios | 1.12.2 | MIT |
| dayjs | 1.11.18 | MIT |
| echarts | 5.6.0 | Apache-2.0 |
| html2canvas | 1.4.1 | MIT |
| @amap/amap-jsapi-loader | 1.0.1 | MIT |
| @googlemaps/js-api-loader | 1.16.10 | Apache-2.0 |
| @phosphor-icons/vue | 2.2.1 | MIT |

### 字体（自托管）

| 字体 | 版本 | 许可证 |
| --- | --- | --- |
| Outfit Variable（@fontsource-variable/outfit） | 5.3.0 | SIL Open Font License 1.1 |
| JetBrains Mono Variable（@fontsource-variable/jetbrains-mono） | 5.3.0 | SIL Open Font License 1.1 |

> SIL OFL 1.1 允许自由使用与再分发（含商用），但要求：保留版权与许可证声明；
> 若对字体本身做修改并以"保留字体名"的方式再分发则不被允许。本项目仅按原样再分发字体文件。

## 3. 与 GPL-2.0 的许可冲突提示

本项目继承上游 GPL-2.0，同时依赖 **HelloAgents**
（<https://github.com/jjyaoao/HelloAgents>，许可证 **CC-BY-NC-SA-4.0**）。

这两种许可证的要求无法同时满足：

- GPL-2.0 允许任何目的的使用（含商业使用），且不允许对下游追加额外限制；
- CC-BY-NC-SA-4.0 **禁止商业使用**，并要求衍生作品以相同方式共享。

因此对于包含 HelloAgents 的整体分发：

1. **使用范围受限**：整体应视为**仅供个人学习与非商业用途**，不应据此开展商业使用；
2. **必须署名**：需保留 HelloAgents 的名称、来源链接与许可证声明（见下）；
3. **相同方式共享**：涉及 HelloAgents 的部分及其衍生，需继续以 CC-BY-NC-SA-4.0 提供。

如需商业使用或希望整体仅按 GPL-2.0 发布，需要先替换 HelloAgents 依赖
（本项目对它的使用面较小：MCP 工具封装与智能体编排），或向 HelloAgents 作者取得额外授权。

## 4. 上游项目署名

本项目复刻自 **1sdv/TripStar**（<https://github.com/1sdv/TripStar>），
沿用其 GPL-2.0 许可证。上游项目及其贡献者的版权与署名完整保留，详见 [NOTICE](NOTICE)。

## 5. 第三方服务条款

本项目通过接口访问以下第三方服务，使用者需自行遵守其用户协议与使用条款：

| 服务 | 用途 | 条款入口 |
| --- | --- | --- |
| 小红书 | 景点素材与实拍图检索（需自备登录 Cookie） | <https://www.xiaohongshu.com/> |
| 高德开放平台 | 地理编码、POI、天气、静态地图、地图渲染 | <https://lbs.amap.com/> |
| Google Maps Platform（可选） | 国外地图引擎 | <https://developers.google.com/maps> |
| 大语言模型服务商（示例为 DeepSeek） | 行程生成与问答 | <https://platform.deepseek.com/> |

本项目不内置、不分发任何第三方账号凭据；地图与图片的展示遵循对应平台的要求。

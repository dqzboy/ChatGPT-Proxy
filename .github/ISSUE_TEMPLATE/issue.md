---
name: issue
about: Please describe the issue you encountered during the deployment process.
title: ''
labels: issue
assignees: dqzboy

---

name: Issue 🐛
description: 项目运行中遇到的Bug或问题。
labels: ['status: needs check']
body:
  - type: markdown
    attributes:
      value: |
        ### ⚠️ 前置确认
        1. 网络能够访问openai接口
        2. `docker images` 是否最新镜像
        3. 服务器规格是否> 1C1G
  - type: checkboxes
    attributes:
      label: 前置确认
      options:
        - label: 我确认我的网络可以访问openai，运行的是最新镜像，并且服务器规格 > 1C1G
          required: true
  - type: checkboxes
    attributes:
      label: ⚠️ 搜索issues中是否已存在类似问题
      description: >
        请在 [历史issue](https://github.com/dqzboy/ChatGPT-Porxy/issues) 中清空输入框，搜索你的问题
        或相关日志的关键词来查找是否存在类似问题。
      options:
        - label: 我已经搜索过issues和disscussions，没有跟我遇到的问题相关的issue
          required: true
  - type: markdown
    attributes:
      value: |
        请在上方的`title`中填写你对你所遇到问题的简略总结，这将帮助其他人更好的找到相似问题，谢谢❤️。
  - type: dropdown
    attributes:
      label: 操作系统类型?
      description: >
        请选择你运行程序的操作系统类型。
      options:
        - Windows
        - Linux
        - MacOS
        - Docker
        - Railway
        - Windows Subsystem for Linux (WSL)
        - Other (请在问题中说明)
    validations:
      required: true

  - type: textarea
    attributes:
      label: 复现步骤 🕹
      description: |
        **⚠️ 不能复现将会关闭issue.**
  - type: textarea
    attributes:
      label: 问题描述 😯
      description: 详细描述出现的问题，或提供有关截图。
  - type: textarea
    attributes:
      label: 终端日志 📒
      description: |
        在此处粘贴终端日志，可在主目录下`run.log`文件中找到，这会帮助我们更好的分析问题，注意隐去你的API key。
        如果在配置文件中加入`"debug": true`，打印出的日志会更有帮助。

        <details>
        <summary><i>示例</i></summary>
        ```log
        [DEBUG][2023-04-16 00:23:22][plugin_manager.py:157] - Plugin SUMMARY triggered by event Event.ON_HANDLE_CONTEXT
        [DEBUG][2023-04-16 00:23:22][main.py:221] - [Summary] on_handle_context. content: $总结前100条消息
        [DEBUG][2023-04-16 00:23:24][main.py:240] - [Summary] limit: 100, duration: -1 seconds
        [ERROR][2023-04-16 00:23:24][chat_channel.py:244] - Worker return exception: name 'start_date' is not defined
        Traceback (most recent call last):
          File "C:\ProgramData\Anaconda3\lib\concurrent\futures\thread.py", line 57, in run
            result = self.fn(*self.args, **self.kwargs)
          File "D:\project\chatgpt-on-wechat\channel\chat_channel.py", line 132, in _handle
            reply = self._generate_reply(context)
          File "D:\project\chatgpt-on-wechat\channel\chat_channel.py", line 142, in _generate_reply
            e_context = PluginManager().emit_event(EventContext(Event.ON_HANDLE_CONTEXT, {
          File "D:\project\chatgpt-on-wechat\plugins\plugin_manager.py", line 159, in emit_event
            instance.handlers[e_context.event](e_context, *args, **kwargs)
          File "D:\project\chatgpt-on-wechat\plugins\summary\main.py", line 255, in on_handle_context
            records = self._get_records(session_id, start_time, limit)
          File "D:\project\chatgpt-on-wechat\plugins\summary\main.py", line 96, in _get_records
            c.execute("SELECT * FROM chat_records WHERE sessionid=? and timestamp>? ORDER BY timestamp DESC LIMIT ?", (session_id, start_date, limit))
        NameError: name 'start_date' is not defined
        [INFO][2023-04-16 00:23:36][app.py:14] - signal 2 received, exiting...
        ```
        </details>
      value: |
        ```log
        <此处粘贴终端日志>
        ```

# scunetd

用于自动登录scu校园网

## 用法

### 一次使用

```bash
bash scunetd.sh --userid <学号> --password <密码> [--ip <认证服务器IP>]
```

### 使用systemd定时登录

设置执行脚本的用户[User](./scunetd.service#L8)和重试时间[OnCalendar](./scunetd.timer#L5)，默认每10min尝试一次

使用
```bash
systemctl enable scunetd.timer
systemctl start scunetd.timer
```
启用/当前会话启动定时器
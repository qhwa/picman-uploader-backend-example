picman-uploader-backend-example
===============================

picman-uploader 的后端处理范例（ruby）

简单的Ruby服务器，能处理picman-uploader的上传文件请求，并可以按规则输出成功或失败的返回。

## urls

* POST /

  结果成功

* POST /fail

  结果失败

* POST /fail/:msg

  结果失败，并且使用指定的错误消息

* POST /random

  随机失败或成功

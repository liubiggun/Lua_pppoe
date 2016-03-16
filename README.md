# Lua_pppoe

本人博客：http://blog.csdn.net/liubiggun

        用于广西师范大学校内pppoe拨号，检测上网状态，断网则自动发送获取权限UDP包并拨号联网，用在openwrt平台上
    需要在wan之上建立一个pppoe连接，文件的路径对应系统的根路径，如root目录下有pppoe目录，即/root/pppoe，将
    pppoe目录置于/root目录下即可，其他同理。/etc目录中，rc.local用来开机启动我们的服务脚本，crontabs/root则
    是定期清理我们的服务脚本产生的日志文件。此应用需要有Lua和Lua的nixio库的支持。

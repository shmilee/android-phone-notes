# adb 基础命令

```bash
$ adb version
Android Debug Bridge version 1.0.41
Version 35.0.2-android-tools
Installed as /usr/bin/adb

$ adb shell [-e ESCAPE] [-n] [-Tt] [-x] [COMMAND...]
$ adb push [--sync] LOCAL... REMOTE
$ adb reboot [bootloader|recovery|sideload|sideload-auto-reboot]
```

```bash
# 查看
$ adb shell pm list packages [-f] [-d] [-e] [-s] [-q] [-3] [-i] [-l] [-u] [-U] 
      [--show-versioncode] [--apex-only] [--factory-only]
      [--uid UID] [--user USER_ID] [FILTER]
    Prints all packages; optionally only those whose name contains
    the text in FILTER.  Options are:
      -f: see their associated file
      -a: all known packages (but excluding APEXes)
      -d: filter to only show disabled packages
      -e: filter to only show enabled packages
      -s: filter to only show system packages
      -3: filter to only show third party packages
      -i: see the installer for the packages
      -l: ignored (used for compatibility with older releases)
      -U: also show the package UID
      -u: also include uninstalled packages
      --show-versioncode: also show the version code
      --apex-only: only show APEX packages
      --factory-only: only show system packages excluding updates
      --uid UID: filter to only show packages with the given UID
      --user USER_ID: only list packages belonging to the given user
      --match-libraries: include packages that declare static shared and SDK libraries

# 卸载
$ adb uninstall  [-k] [--user <USER_ID>] PACKAGE
$ adb shell pm uninstall [-k] [--user <USER_ID>] PACKAGE

# 冻结：启用(enable)/禁用(disable-user)，非暂停(unsuspend)/暂停(suspend)，非隐藏(unhide)/隐藏(hide)
$ adb shell pm disable/disable-user/enable [--user USER_ID] PACKAGE_OR_COMPONENT
$ adb shell pm suspend/unsuspend [--user USER_ID] PACKAGE

# 安装
$ adb install [-lrtsdg] [--user USER_ID|all|current] [--instant] PACKAGE
$ adb install-multiple [-lrtsdpg] [--instant] PACKAGE...
$ adb install-existing [--user USER_ID|all|current] [--instant] PACKAGE
    Installs an existing application for a new user.
```

# ColorOS【开发者选项】

* 开启: 点击【设置】>【关于本机】>【版本信息】, 点 **7** 次【版本号】`15.0.0.850`
* 【系统与更新】>【开发者选项】
  + 系统自动更新 off
  + USB调试 on
  + 通过USB验证应用 on

# ColorOS 应用管理

## 系统应用

```bash
USER_ID=0  # 机主

adb shell pm list packages --user $USER_ID -s  # 查看系统应用

APPS=(
    #com.heytap.browser #自带浏览器
    #com.heytap.market #软件商店
    #com.coloros.video #视频
    com.oplus.statistics.rom #用户体验改进计划
    com.oppo.store #OPPO商城
    com.redteamobile.roaming #逍遥游，国际上网
    com.oplus.logkit #反馈工具箱
    #com.coloros.operationManual #帮助与反馈
    com.oplus.crashbox #crashbox
    com.oneplus.bbs #一加社区
    com.oneplus.brickmode #禅定模式
    com.coloros.childrenspace #儿童模式
    com.heytap.mcs #商业服务，广告推送组件
    com.oplus.appdetail #安全应用安装
)
for app in ${APPS[@]}; do
    echo "Uninstall $app for user $USER_ID ..."
    adb shell pm uninstall --user $USER_ID $app
    # 恢复
    #adb shell pm install-existing --user $USER_ID $app
done
```

* 卸载失败 -> 冻结

```bash
APPS=(
    com.heytap.pictorial #乐滑锁屏
    com.opos.ads #oppo后台广告
)
for app in ${APPS[@]}; do
    echo "Suspend $app for user $USER_ID ..."
    adb shell pm suspend --user $USER_ID $app
    # 恢复
    #adb shell pm unsuspend --user $USER_ID $app
done
```

## 冻结系统更新升级应用

* 【设置】>【移动网络】>【流量管理】>【应用联网管理】：软件更新，禁用网络
* 【设置】>【应用】>【应用管理】> 右上：显示系统应用
    - 搜“软件更新”
        + 静默通知：off
        + 存储：清除数据和缓存
        + 流量消耗：禁用网络
        + 特殊应用权限：不允许修改系统设置
    - 分别搜 “配置更新”、“更新服务”、“升级指南”、“系统升级服务”
        + 关通知；清存储；禁网络；流量-后台不使用数据
* 【设置】>【系统与更新】>【软件更新】> 自动更新设置，关闭所有

* 先尝试 suspend

```bash
suspend_APPS=(
    com.oplus.upgradeguide #升级指南
    com.oplus.cota #配置更新
    com.oplus.romupdate #更新服务（通知推送更新）
    com.oplus.ota #系统更新
    com.oplus.sau #系统应用升级服务, 和系统版本升级无关。如安全漏洞推送更新。
    com.oplus.sauhelper #系统应用升级帮助
)
for app in ${suspend_APPS[@]}; do
    echo "Suspend $app for user $USER_ID ..."
    adb shell pm suspend --user $USER_ID $app
    # 恢复
    #adb shell pm unsuspend --user $USER_ID $app
done
```

* suspend 失败(state: false), 则继续尝试 disable-user

```bash
disable_user_APPS=(
    com.oplus.ota #系统更新
    com.oplus.sau #系统应用升级服务
    com.oplus.sauhelper #系统应用升级帮助
)
for app in ${disable_user_APPS[@]}; do
    echo "Disable-user $app for user $USER_ID ..."
    adb shell pm disable-user --user $USER_ID $app
    # 恢复
    #adb shell pm enable --user $USER_ID $app
done

# 输出
Package com.oplus.ota new state: enabled
Package com.oplus.sau new state: default
Package com.oplus.sauhelper new state: disabled-user
```

* 重启。除【设置】中的“软件更新(安装ColorOS新版本)”提示外，再无更新提醒。

## 删除第三方应用

```bash
# 查看第三方应用列表
adb shell pm list packages -3

# 仅部分示例
APPS=(
    com.ss.android.article.news #今日头条
    com.sankuai.meituan #美团
    com.dianping.v1 #大众点评
    com.taobao.taobao #淘宝
    com.jingdong.app.mall #京东
    com.ximalaya.ting.android #喜马拉雅FM
    com.zhihu.android #知乎
    com.smile.gifmaker #快手
    com.sina.weibo #新浪微博
    com.baidu.searchbox #手机百度
)

for app in ${APPS[@]}; do
    echo "Uninstall $app ..."
    adb uninstall $app
done
```

# 安装常用应用

* [微信](https://weixin.qq.com/)
* [QQ](https://im.qq.com/download/)
* [支付宝](https://mobile.alipay.com/index.htm)
* [deepseek](https://chat.deepseek.com)
* [WPS Office](http://mo.wps.cn/pc-app/office-android.html)
* [腾讯会议](https://meeting.tencent.com/download/)

* [百度地图](https://map.baidu.com/)
* [铁路12306](https://www.12306.cn/)
* [携程旅行](http://app.ctrip.com/)

* [哔哩哔哩](https://www.bilibili.com/)
* [网易云音乐](https://music.163.com/#/download)

* [RealCalc-Plus-v2.3.1-Patched.apk](https://apkhome.net/realcalc-plus-2-3-1/)
* [smart-tools-v2.0.8-paid.apk](https://www.apkhere.com/app/kr.aboy.tools)
* [BubbleUPnP-v2.6.1.apk](http://bbs.zhiyoo.com/thread-12442204-1-1.html) DLNA server and client.
* [selene-1.6.6-armv8.apk](https://github.com/MoonTechLab/Selene)


* [v2rayNG](https://github.com/2dust/v2rayNG/releases) + [apkpure](https://apkpure.com)
    - 安装 Google Play 商店
    - apk 文件路径：`adb shell pm list packages -f | grep com.android.vending`
*  Google Play 商店
    - [Firefox](https://wiki.mozilla.org/Mobile/Platforms/Android)
        + addons: Adblock Plus, Proxy SwitchyOmega
    - [github](https://github.com/settings/security)
        + app for github 2FA
    - [Zotero](https://www.zotero.org/blog/zotero-for-android/)
        + https://zotero-chinese.com/user-guide/install
    - [KDE-connect](https://kdeconnect.kde.org/download.html)
    - [mpv-android](https://github.com/mpv-android/mpv-android)
    - Chrome, YouTube, Duolingo, ResearchGate 等
* [Termux](https://github.com/termux/termux-app)：统一通过 **F-Droid** 安装。
    - Version 0.118.3 (1002) suggested
    - [Termux:Styling Version 0.32.1 (1000) suggested](https://github.com/termux/termux-styling)
* [tailscale](https://github.com/tailscale/tailscale-android#using)
    - menu icon (three dots) on the top right must be
      repeatedly opened and closed until the "Change server" option appears
    - 老版本 `ipn_135` 登陆成功
* [GoldenDict](https://github.com/goldendict/goldendict/issues/1700#issuecomment-2442743656)
    - 下载 http://goldendict.mobi/downloads/android/paid/
    - 获取 [goldendict-key.txt](http://goldendict.mobi/free.php)
* [阅读](https://github.com/gedoor/legado)

```bash
USER_ID=0
UAPPDIR='常用应用'
find $UAPPDIR -type f -name '*.apk' -print -exec adb install -r --user $USER_ID {} \;
```

# 添加 audio

```bash
adb shell mkdir -pv /storage/emulated/0/{Alarms,Notifications,Ringtones}
adb shell ls /storage/emulated/0/{Alarms,Notifications,Ringtones}
adb push --sync ./audio/Notifications /storage/emulated/0/
adb push --sync ./audio/Ringtones /storage/emulated/0/
adb shell ls /storage/emulated/0/{Alarms,Notifications,Ringtones}
```

# ColorOS 配置记录

* 设置
    + 云备份
    + WLAN 助理 > 智能切换 off
    + 流量管理 > 限额
    + NFC > 默认付款应用
    + 电池健康
    + 来电铃声、通知铃声
* 负一屏 推荐 off
* 桌面
    + 天气、闹钟
    + 桌面布局
* other 通知 off

# 配置 termux

* 长按，More，Style：选择配色、字体

* `termux-change-repo`
    - 选择 TUNA 镜像 https://mirrors.tuna.tsinghua.edu.cn/help/termux/

* 查看已安装软件包
  ```bash
  $pkg list-installed
  ...
  bash
  ...
  ```

* ~~修改 motd `$PREFIX/etc/motd`~~
* 更新、安装、配置常用软件（命令从 github app 内复制粘贴）
  - 安装 `htop proot neofetch git gnupg openssh python-pip vim zsh` 等
  - 配置 git, ssh, python, vim
  - 配置 zsh, `Cabbagec/termux-ohmyzsh`
  - 一键脚本 `termux/termux-setup.sh`, 复制到内部存储
    ```bash
    $ termux-setup-storage #启用外置存储
    $ mv ~/storage/shared/termux ~/
    $ cd ~/termux/
    $ chmod +x ./termux-setup.sh
    $ ./termux-setup.sh
    $ rm -r ~/termux/
    ```

* ~~安装 linux 发行版, [PRoot Distro](https://github.com/termux/proot-distro)~~
  - `Arch Linux 	archlinux 	rolling 	supported`
  - `Debian 	debian 	trixie 	supported`

```bash
pkg install proot-distro
proot-distro <command> <arguments>
proot-distro list
proot-distro install archlinux
proot-distro login archlinux
proot-distro remove archlinux
  ```

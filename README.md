# NeteasePotPlayer

适用于 PotPlayer 的网易云音乐插件

## 安装插件

将项目 `Media/PlayParse` 路径下的 `MediaPlayParse - Netease.as` 和 `MediaPlayParse - Netease.ico` 两个文件复制到 `{PotPlayer 安装路径}\Extension\MediaPlayParse` 文件夹下。比如，如果 PotPlayer 安装路径为 `D:\DAUM\PotPlayer`，则将两个文件复制到 `D:\DAUM\PotPlayer\Extension\Media\PlayParse` 文件夹下。

然后打开 `MediaPlayParse - Netease.as` 文件进行设置

```AngelScript
// 填写 Cookie，如 MUSIC_U=xxxxxxxxxxxxx
string cookie = "";
// 比特率: 128000 | 192000 | 320000 | 999000
string br = "128000";
// 清晰度
string r = "1080";
```

填写 cookie，可以只填写 MUSIC_U 部分，如 `MUSIC_U=xxxxxxxxxxxxx`

填写 cookie 后，则可以播放云盘歌曲，如果是黑胶账号，还能播放 VIP 歌曲。如果不填写 cookie，则只能播放免费歌曲。



## 使用

使用 PotPlayer 打开网易云链接，即可播放。

### 播放 MV

![MV](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/mv.png)

### 播放歌曲

![Song](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/song.png)

### 播放歌单

![MV](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/playlist.png)

### 播放歌手 MV

![MV](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/artist_mv.png)

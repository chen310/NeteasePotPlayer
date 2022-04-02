# NeteasePotPlayer

适用于 PotPlayer 的网易云音乐插件

## 安装插件

将项目 `Media/PlayParse` 路径下的 `MediaPlayParse - Netease.as` 和 `MediaPlayParse - Netease.ico` 两个文件复制到 `{PotPlayer 安装路径}\Extension\Media\PlayParse` 文件夹下。

将项目 `Media/UrlList` 路径下的 `MediaUrlList - Netease.as` 和 `MediaUrlList - Netease.ico` 两个文件复制到 `{PotPlayer 安装路径}\Extension\Media\UrlList` 文件夹下。

比如，如果 PotPlayer 安装路径为 `D:\DAUM\PotPlayer`，则将 `MediaPlayParse - Netease.as` 和 `MediaPlayParse - Netease.ico` 两个文件复制到 `D:\DAUM\PotPlayer\Extension\Media\PlayParse` 文件夹下，将 `MediaUrlList - Netease.as` 和 `MediaUrlList - Netease.ico` 两个文件复制到 `D:\DAUM\PotPlayer\Extension\Media\UrlList` 文件夹下。

然后打开 `MediaPlayParse - Netease.as` 文件进行设置。

```AngelScript
// 填写 Cookie
string cookie = "";
// 比特率: 128000 | 192000 | 320000 | 999000
string br = "128000";
// 清晰度
string r = "1080";
```

填写 cookie 后，则可以播放云盘歌曲，如果是黑胶账号，还能播放 VIP 歌曲。如果不填写 cookie，则只能播放免费歌曲。

然后打开 `MediaUrlList - Netease.as` 文件进行设置。

```AngelScript
// 填写 Cookie
string cookie = "";
// 填写用户 id
string uid = "";
```

需要填写自己的用户 id。如果不填写 cookie，则无法查看隐私歌单。

## 使用

使用 PotPlayer 打开网易云链接（快捷键为 <kbd>ctrl</kbd> + <kbd>U</kbd>），即可播放。

### 播放 MV

![MV](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/mv.png)

### 播放歌曲

![Song](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/song.png)

### 播放歌单

![MV](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/playlist.png)

### 播放歌手 MV

![MV](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/artist_mv.png)

### 播放歌手歌曲

![ArtistSong](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/artist_song.png)

### 我的歌单

按 <kbd>ctrl</kbd> + <kbd>U</kbd>，选择 `NeteaseCloudMusic 我的歌单`，即可得到歌单列表，选择想要播放的歌单，双击即可播放。

![MyPlaylist](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/my_playlist.png)
# NeteasePotPlayer

适用于 PotPlayer 的网易云音乐插件。如果配合[油猴脚本](https://greasyfork.org/zh-CN/scripts/443047-neteasepotplayer)，可以直接在网页打开 PotPlayer 进行播放

## 安装插件

将项目 `Media/PlayParse` 路径下的 `MediaPlayParse - Netease.as`、 `MediaPlayParse - Netease.ico` 和 `Netease_Config.json` 三个文件复制到 `{PotPlayer 安装路径}\Extension\Media\PlayParse` 文件夹下。

将项目 `Media/UrlList` 路径下的 `MediaUrlList - Netease.as` 和 `MediaUrlList - Netease.ico` 两个文件复制到 `{PotPlayer 安装路径}\Extension\Media\UrlList` 文件夹下。

比如，如果 PotPlayer 安装路径为 `D:\DAUM\PotPlayer`，则将 `MediaPlayParse - Netease.as`、 `MediaPlayParse - Netease.ico` 和 `Netease_Config.json` 三个文件复制到 `D:\DAUM\PotPlayer\Extension\Media\PlayParse` 文件夹下，将 `MediaUrlList - Netease.as` 和 `MediaUrlList - Netease.ico` 两个文件复制到 `D:\DAUM\PotPlayer\Extension\Media\UrlList` 文件夹下。

然后打开 `Netease_Config.json` 文件进行设置。

```json
{
    // 填写账号 Cookie
    "cookie": "",
    // 有多个账号可填写，用来获取歌曲播放链接。可不填
    "VIPCookie": "",
    "X-Real-IP": "",
    // 歌曲音质，可用 standard | higher | exhigh | lossless | hires | jyeffect | sky | jymaster | dolby
    "musicQuality": "hires",
    // 视频画质
    "videoQesolution": "1080",
    // 是否跳过不能播放的歌曲
    "skipUnavailable": true,
    // 是否使用第三方 API 地址，如为 true，则需在下方填写 API 地址，否则使用官方 API
    "useNeteaseApi": false,
    // 第三方 API 地址，详见 https://github.com/Binary/NeteaseCloudMusicApi
    "NeteaseApi": "",
    // 歌词 API
    "lyricApi": "",
    "debug": false
}
```

填写 cookie 后，则可以播放云盘歌曲，如果是黑胶账号，还能播放 VIP 歌曲。如果不填写 cookie，则只能播放免费歌曲。

如果无法访问 vercel，可以自己搭建歌词 API 并填写服务器地址: [NeteaseLyric](https://github.com/chen310/NeteaseLyric)

插件默认使用的是官方 API，如果要使用自己搭建的 API，请将 `useNeteaseApi` 变量的值设置为 true，并在 `NeteaseApi` 中填写服务器地址。服务器搭建方法详见 [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi)

按 <kbd>F5</kbd> 打开选项，点击扩展功能下的媒体播放列表/项目，再点击 `NeteaseCloudMusic`，然后打开 `账号设置`，在 `配置文件路径` 中填写配置文件 `Netease_Config.json` 的路径，如 `D:\DAUM\PotPlayer\Extension\Media\PlayParse\Netease_Config.json`，之后可以点击测试按钮进行测试。

如果不使用 <kbd>ctrl</kbd> + <kbd>U</kbd> 的列表功能，后面的设置可不填写：打开 `MediaUrlList - Netease.as` 文件进行设置。

```AngelScript
// 填写 Cookie
string cookie = "";
// 填写用户 id
string uid = "";
// 是否使用第三方 API 地址，如为 true，则需在下方填写 API 地址，否则使用官方 API
bool useNeteaseApi = false;
// 第三方 API 地址，详见 https://github.com/Binary/NeteaseCloudMusicApi
string NeteaseApi = "";
```

需要填写自己的用户 id。如果不填写 cookie，则无法查看隐私歌单。

## 在列表中显示缩略图

按 <kbd>F6</kbd> 打开播放列表，点击鼠标右键，点击`样式`，选择显示缩略图，即可显示缩略图。

## 使用

使用 PotPlayer 打开网易云链接（快捷键为 <kbd>ctrl</kbd> + <kbd>U</kbd>），即可播放。

### 播放 MV

示例链接

```
https://music.163.com/mv?id=482078
```

![MV](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/mv.png)

### 播放歌曲

示例链接

```
https://music.163.com/song?id=186331
```

![Song](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/song.png)

### 播放歌单

示例链接

```
https://music.163.com/playlist?id=492068610
```

![Playlist](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/playlist.png)

### 播放视频歌单

示例链接

```
https://music.163.com/playlist?id=6642773122
```

![VideoPlaylist](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/video_playlist.png)

### 播放专辑

示例链接

```
https://music.163.com/#/album?id=6491
```

![Album](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/album.png)

### 播放歌手 MV

示例链接

```
https://music.163.com/#/artist/mv?id=7763
```

![ArtistMV](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/artist_mv.png)

### 播放歌手歌曲

示例链接

```
https://music.163.com/#/artist?id=2116
```

![ArtistSong](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/artist_song.png)

### 播放电台

示例链接

```
https://music.163.com/#/djradio?id=966559685
```

![Radio](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/radio.png)

### 已购单曲

示例链接

```
https://music.163.com/#/member/purchasedsong
```

### 每日歌曲推荐

示例链接

```
https://music.163.com/#/discover/recommend/taste
```

### 排行榜

示例链接

```
https://music.163.com/#/discover/toplist
https://music.163.com/#/discover/toplist?id=3779629
```

### 收藏的视频

示例链接

```
https://music.163.com/#/my/m/music/mv
```

### 我的歌单

按 <kbd>ctrl</kbd> + <kbd>U</kbd>，选择 `NeteaseCloudMusic 我的歌单`，即可得到歌单列表，选择想要播放的歌单，双击即可播放。

![MyPlaylist](https://cdn.jsdelivr.net/gh/chen310/NeteasePotPlayer/public/img/my_playlist.png)

/*
	Netease media parse
	author: chen310
	link: https://github.com/chen310/NeteasePotPlayer
*/

// void OnInitialize()
// void OnFinalize()
// string GetTitle() 									-> get title for UI
// string GetVersion									-> get version for manage
// string GetDesc()										-> get detail information
// string GetLoginTitle()								-> get title for login dialog
// string GetLoginDesc()								-> get desc for login dialog
// string GetUserText()									-> get user text for login dialog
// string GetPasswordText()								-> get password text for login dialog
// string ServerCheck(string User, string Pass) 		-> server check
// string ServerLogin(string User, string Pass) 		-> login
// void ServerLogout() 									-> logout
//------------------------------------------------------------------------------------------------
// bool PlayitemCheck(const string &in)					-> check playitem
// array<dictionary> PlayitemParse(const string &in)	-> parse playitem
// bool PlaylistCheck(const string &in)					-> check playlist
// array<dictionary> PlaylistParse(const string &in)	-> parse playlist

Config ConfigData;
string host = "https://music.163.com";

string GetTitle() {

	return "NeteaseCloudMusic";
}

string GetVersion() {

	return "1.3";
}

string GetDesc() {

	return "https://music.163.com";
}

string GetLoginTitle()
{
	return "请输入配置文件所在位置";
}

string GetLoginDesc()
{
	return "请输入配置文件所在位置";
}

string GetUserText()
{
	return "配置文件路径";
}

string GetPasswordText()
{
	return "";
}

string ServerCheck(string User, string Pass) {
	if (User.empty()) {
		return "未填写配置文件路径";
	}
	if (!isFileExists(User)) {
		return "配置文件不存在";
	}
	if (ConfigData.cookie.empty()) {
		return "未填写cookie";
	}
	string info = "";
	JsonReader reader;
	JsonValue root;
	string res = post("/api/user/level");
	if (reader.parse(res, root) && root.isObject()) {
		if (root["code"].asInt() != 200) {
			return "无法获取用户信息";
		}
		JsonValue data = root["data"];
		if (data.isObject()) {
			info += "登录成功\n";
			info += "用户ID: " + data["userId"].asString() + "\n";
		}
	}
	return info;
}

string ServerLogin(string User, string Pass)
{
	if (User.empty()) return "路径不可为空";
	if (!isFileExists(User)) {
		return "配置文件不存在";
	}
	ConfigData = ReadConfigFile(User);
	if (!ConfigData.cookie.empty() && ConfigData.cookie.find("os=") < 0) {
		ConfigData.cookie += "; os=pc; appver=3.1.6.203622";
	}
	if (!ConfigData.VIPCookie.empty() && ConfigData.VIPCookie.find("os=") < 0) {
		ConfigData.VIPCookie += "; os=pc; appver=3.1.6.203622";
	}
	if (ConfigData.debug) {
		HostOpenConsole();
	}

	return "配置文件读取成功，填写完配置后需要重启 PotPlayer 才能生效";
}

bool isFileExists(string path) {
	return HostFileOpen(path) > 0;
}

class Config {
	string fullConfig;
	string cookie;
	string VIPCookie;
	string ip;
	string musicQuality = "hires";
	string videoQesolution = "1080";
	bool skipUnavailable = true;
	bool useNeteaseApi = false;
	string NeteaseApi;
	string lyricApi = "https://neteaselyric.chen310.repl.co";
	bool debug = false;
};

Config ReadConfigFile(string file) {
	Config config;
	config.fullConfig = HostFileRead(HostFileOpen(file), 10000);
	JsonReader reader;
	JsonValue root;
	if (reader.parse(config.fullConfig, root) && root.isObject()) {
		if (root["cookie"].isString() && !root["cookie"].asString().empty()) {
			config.cookie = root["cookie"].asString();
		}
		if (root["VIPCookie"].isString() && !root["VIPCookie"].asString().empty()) {
			config.VIPCookie = root["VIPCookie"].asString();
		}
		if (root["X-Real-IP"].isString() && !root["X-Real-IP"].asString().empty()) {
			config.ip = root["X-Real-IP"].asString();
		}
		if (root["musicQuality"].isString() && !root["musicQuality"].asString().empty()) {
			config.musicQuality = root["musicQuality"].asString();
		}
		if (root["videoQesolution"].isString() && !root["videoQesolution"].asString().empty()) {
			config.videoQesolution = root["videoQesolution"].asString();
		}
		if (root["skipUnavailable"].isBool()) {
			config.skipUnavailable = root["skipUnavailable"].asBool();
		}
		if (root["useNeteaseApi"].isBool()) {
			config.useNeteaseApi = root["useNeteaseApi"].asBool();
		}
		if (root["NeteaseApi"].isString() && !root["NeteaseApi"].asString().empty()) {
			config.NeteaseApi = root["NeteaseApi"].asString();
		}
		if (root["lyricApi"].isString() && !root["lyricApi"].asString().empty()) {
			config.lyricApi = root["lyricApi"].asString();
		}
		if (root["debug"].isBool()) {
			config.debug = root["debug"].asBool();
		}
	}
	return config;
}

void log(string item) {
	if (!ConfigData.debug) {
		return;
	}
	HostPrintUTF8(item);
}

void log(string item, string info) {
	log(item + ": " + info);
}

void log(string item, int info) {
	log(item + ": " + info);
}

string post(string api, string data="", bool isInCloudDrive=false) {
	string UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36";
	string url;
	string Headers;
	if (ConfigData.useNeteaseApi) {
		Headers = "Accept: */*\r\nConnection: keep-alive\r\n";
		url = ConfigData.NeteaseApi + api;
	} else {
		Headers = "Accept: */*\r\nConnection: keep-alive\r\nHost: music.163.com\r\nReferer: https://music.163.com\r\n";
		url = host + api;
	}
	if (!ConfigData.ip.empty()) {
		Headers += "X-Real-IP: " + ConfigData.ip + "\r\n";
	}
	if (!isInCloudDrive && !ConfigData.VIPCookie.empty() && (api.find("/api/song/enhance/player/url/v1") >= 0 || api.find("/song/url") >= 0)) {
		Headers += "Cookie: " + ConfigData.VIPCookie + "\r\n";
	} else if (!ConfigData.cookie.empty()) {
		Headers += "Cookie: " + ConfigData.cookie + "\r\n";
	}
	log("request", url);
	return HostUrlGetStringWithAPI(url, UserAgent, Headers, data, true);
}

array<dictionary> Album(string id) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/album?id=" + id);
	} else {
		res = post("/api/v1/album/" + id);
	}
	array<dictionary> songs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["songs"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							// 填写了 VIPCookie 后不会跳过 VIP 歌曲
							if ((ConfigData.skipUnavailable && item["privilege"]["pl"].asInt() == 0 && (ConfigData.VIPCookie.empty() || item["privilege"]["fee"].asInt() != 1))) {
								continue;
							}
							dictionary song;
							song["title"] = item["name"].asString();
							song["duration"] = item["dt"].asInt();
							song["url"] = host + "/song?id=" + item["id"].asString();
							song["thumbnail"] = item["al"]["picUrl"].asString();
							song["author"] = item["ar"][0]["name"].asString();
							songs.insertLast(song);
						}
					}
				}
			}
		}
	}
	return songs;
}

array<dictionary> Playlist(string id) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/playlist/detail?id=" + id);
	} else {
		res = post("/api/v6/playlist/detail?id=" + id + "&n=100000&s=8");
	}
	array<dictionary> songs;
	bool isVideoPlaylist;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				isVideoPlaylist = Root["playlist"]["specialType"].asInt() == 200;
				// 视频歌单
				if (isVideoPlaylist) {
					JsonValue data = Root["playlist"]["videos"];
					if (data.isArray()) {
						for (int i = 0; i < data.size(); i++) {
							JsonValue item = data[i];
							if (item.isObject()) {
								dictionary song;
								song["title"] = item["mlogBaseData"]["text"].asString();
								song["duration"] = item["mlogBaseData"]["duration"].asInt();
								string vid = item["mlogBaseData"]["id"].asString();
								int videoType = item["mlogBaseData"]["type"].asInt();
								// videoType: 1: video, 2: mlog, 3: mv
								if (videoType == 1) {
									song["url"] = host + "/#/video?id=" + vid;
								} else if (videoType == 2) {
									song["url"] = "https://st.music.163.com/mlog/mlog.html?id=" + vid;
								} else {
									song["url"] = host + "/mv?id=" + vid;
								}
								song["thumbnail"] = item["mlogBaseData"]["coverUrl"].asString();
								if (item["mlogExtVO"].isObject() && item["mlogExtVO"]["artistName"].isString()) {
									song["author"] = item["mlogExtVO"]["artistName"].asString();
								}
								songs.insertLast(song);
							}
						}
					}
				} else {
					JsonValue data = Root["playlist"]["tracks"];
					JsonValue privileges = Root["privileges"];
					if (data.isArray()) {
						for (int i = 0; i < data.size(); i++) {
							JsonValue item = data[i];
							JsonValue privilege = privileges[i];
							if (item.isObject()) {
								if ((ConfigData.skipUnavailable && privilege["pl"].asInt() == 0 && (ConfigData.VIPCookie.empty() || privilege["fee"].asInt() != 1))) {
									continue;
								}
								dictionary song;
								song["title"] = item["name"].asString();
								song["duration"] = item["dt"].asInt();
								song["url"] = host + "/song?id=" + item["id"].asString();
								song["thumbnail"] = item["al"]["picUrl"].asString();
								song["author"] = item["ar"][0]["name"].asString();
								songs.insertLast(song);
							}

						}
					}
				}
			}
		}
	}
	return songs;
}

array<dictionary> RecommendSongs() {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/recommend/songs");
	} else {
		res = post("/api/v2/discovery/recommend/songs");
	}
	array<dictionary> songs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["recommend"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							if ((ConfigData.skipUnavailable && item["privilege"]["pl"].asInt() == 0 && (ConfigData.VIPCookie.empty() || item["privilege"]["fee"].asInt() != 1))) {
								continue;
							}
							dictionary song;
							song["title"] = item["name"].asString();
							song["duration"] = item["duration"].asInt();
							song["url"] = host + "/song?id=" + item["id"].asString();
							song["thumbnail"] = item["album"]["picUrl"].asString();
							song["author"] = item["artists"][0]["name"].asString();
							songs.insertLast(song);
						}
					}
				}
			}
		}
	}
	return songs;
}

array<dictionary> ArtistSong(string id) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/artist/songs?id=" + id + "&limit=1000");
	} else {
		res = post("/api/v1/artist/songs?id=" + id + "&offset=0&limit=1000&private_cloud=true&work_type=1&order=hot");
	}
	array<dictionary> songs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["songs"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							if ((ConfigData.skipUnavailable && item["privilege"]["pl"].asInt() == 0 && (ConfigData.VIPCookie.empty() || item["privilege"]["fee"].asInt() != 1))) {
								continue;
							}
							dictionary song;
							song["title"] = item["name"].asString();
							song["duration"] = item["dt"].asInt();
							song["url"] = host + "/song?id=" + item["id"].asString();
							song["thumbnail"] = item["al"]["picUrl"].asString();
							song["author"] = item["ar"][0]["name"].asString();
							songs.insertLast(song);
						}
					}
				}
			}
		}
	}
	return songs;
}

array<dictionary> ArtistMV(string id) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/artist/mv?id=" + id + "&offset=0&limit=1000");
	} else {
		res = post("/api/artist/mvs?artistId=" + id + "&offset=0&limit=1000");
	}
	array<dictionary> mvs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["mvs"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary mv;
							mv["title"] = item["name"].asString();
							mv["duration"] = item["duration"].asInt();
							mv["url"] = host + "/mv?id=" + item["id"].asString();
							mv["thumbnail"] = item["imgurl"].asString();
							mv["author"] = item["artist"]["name"].asString();
							mvs.insertLast(mv);
						}

					}
				}
			}
		}
	}
	return mvs;
}

array<dictionary> MVSublist() {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/mv/sublist");
	} else {
		res = post("/api/cloudvideo/allvideo/sublist");
	}
	array<dictionary> mvs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["data"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary mv;
							int videoType = item["type"].asInt();
							mv["title"] = item["title"].asString();
							mv["duration"] = item["durationms"].asInt();
							if (videoType == 1) {
								mv["url"] = host + "/#/video?id=" + item["vid"].asString();
							} else if (videoType == 0) {
								mv["url"] = host + "/mv?id=" + item["vid"].asString();
							}
							mv["thumbnail"] = item["coverUrl"].asString();
							mv["author"] = item["creator"][0]["userName"].asString();
							mvs.insertLast(mv);
						}
					}
				}
			}
		}
	}
	return mvs;
}

string MlogUrl(string id, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/mlog/url?id=" + id + "&res=" + ConfigData.videoQesolution);
	} else {
		res = post("/api/mlog/detail/v1?type=1&id=" + id + "&resolution=" + ConfigData.videoQesolution);
	}
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue item = Root["data"]["resource"]["content"];
				MetaData["title"] = item["title"].asString();
				MetaData["webUrl"] = path;
				MetaData["content"] = item["title"].asString();
				return item["video"]["urlInfo"]["url"].asString();
			} else {
				return "";
			}
		}
	}
	return "";
}

string VideoUrl(string id, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/video/detail?id=" + id);
	} else {
		res = post("/api/cloudvideo/v1/video/detail?id=" + id);
	}
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue item = Root["data"];
				MetaData["title"] = item["title"].asString();
				MetaData["author"] = item["creator"]["nickname"].asString();
				MetaData["content"] = item["description"].asString();
				MetaData["webUrl"] = path;
			} else {
				return "";
			}
		}
	}
	if (ConfigData.useNeteaseApi) {
		res = post("/video/url?id" + id + "&res=" + ConfigData.videoQesolution);
	} else {
		res = post("/api/cloudvideo/playurl?ids=%5B%22" + id + "%22%5D&resolution=" + ConfigData.videoQesolution);
	}
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["urls"];
				if (data.size() == 0) {
					return "";
				}
				JsonValue item = data[0];
				if (item.isObject()) {
					JsonValue url = item["url"];
					if (url.isString() && !url.asString().empty()) {
						return url.asString();
					}
				}
			} else {
				return "";
			}
		}
	}
	return "";
}


string MVUrl(string id, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/mv/detail?mvid=" + id);
	} else {
		res = post("/api/v1/mv/detail?id=" + id);
	}
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue item = Root["data"];
				MetaData["title"] = item["name"].asString();
				MetaData["author"] = item["artistName"].asString();
				MetaData["content"] = item["name"].asString();
				MetaData["webUrl"] = path;
			} else {
				return "";
			}
		}
	}
	if (ConfigData.useNeteaseApi) {
		res = post("/mv/url?id=" + id + "&r=" + ConfigData.videoQesolution);
	} else {
		res = post("/api/song/enhance/play/mv/url?id=" + id + "&r=" + ConfigData.videoQesolution);
	}
	if (!res.empty())
	{
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject())
		{
			if (Root["code"].asInt() == 200)
			{
				JsonValue item = Root["data"];
				if (item.isObject())
				{
					JsonValue url = item["url"];
					if (url.isString() && !url.asString().empty())
					{
						return url.asString();
					}
				}
			} else {
				return "";
			}
		}
	}
	return "";
}

array<dictionary> Djradio(string id) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/dj/program?rid=" + id + "&limit=1000");
	} else {
		res = post("/api/dj/program/byradio?radioId=" + id + "&offset=0&limit=1000");
	}
	array<dictionary> songs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["programs"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary song;
							song["title"] = item["name"].asString();
							song["duration"] = item["duration"].asInt();
							song["url"] = host + "#/program?id=" + item["id"].asString();
							song["thumbnail"] = item["album"]["picUrl"].asString();
							song["author"] = item["artists"][0]["name"].asString();
							songs.insertLast(song);
						}
					}
				}
			}
		}
	}
	return songs;
}

array<string> GetSongUrl(string id, bool isInCloudDrive) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/song/url/v1?id=" + id + "&level=" + ConfigData.musicQuality, "", isInCloudDrive);
	} else {
		if (ConfigData.musicQuality == "dolby") {
			res = post("/api/song/enhance/player/url/v1?ids=%5B" + id + "%5D&level=hires&effects=%5B%22dolby%22%5D&encodeType=mp4", "", isInCloudDrive);
		}
		res = post("/api/song/enhance/player/url/v1?ids=%5B" + id + "%5D&level=" + ConfigData.musicQuality + "&encodeType=mp4", "", isInCloudDrive);
	}
	array<string> output;
	if (!res.empty())
	{
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["data"];
				if (data.isArray()) {
					JsonValue item = data[0];
					if (item.isObject()) {
						JsonValue url = item["url"];
						if (url.isString() && !url.asString().empty()) {
							output.insertLast(url.asString());
							if (item["level"].isString() && !item["level"].asString().empty()) {
								output.insertLast(item["level"].asString());
							}
							return output;
						}
					}
				}
			} else {
				output.insertLast("");
				return output;
			}
		}
	}
	output.insertLast("");
	return output;
}

string getQuality(string level) {
	array<string> levelList = { "standard", "higher", "exhigh", "lossless", "hires", "jyeffect", "sky", "jymaster", "dolby" };
	array<string> qualityList = { "标准", "较高", "极高", "无损", "Hi-Res", "高清环绕声", "沉浸环绕声", "超清母带", "杜比全景声"};
	int idx = levelList.find(level);
	if (idx >= 0) {
		return qualityList[idx];
	}
	return level;
}

string SongUrl(string id, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/song/detail?ids=" + id);
	} else {
		res = post("/api/v3/song/detail?c=[{\"id\":" + id +"}]");
	}
	bool isInCloudDrive = false;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["songs"];
				if (data.isArray()) {
					JsonValue item = data[0];
					if (item.isObject()) {
						if (!item["name"].asString().empty()) {
							MetaData["title"] = item["name"].asString();
							MetaData["content"] = item["name"].asString();
							MetaData["author"] = item["ar"][0]["name"].asString();
						}
						MetaData["webUrl"] = path;
						if (!ConfigData.lyricApi.empty()){
							array<dictionary> subtitle;
							dictionary dic;
							dic["name"] = item["name"].asString();
							dic["url"] = ConfigData.lyricApi + "/lyric?id=" + id;
							subtitle.insertLast(dic);
							MetaData["subtitle"] = subtitle;
						}
						if (item["pc"].isObject()) {
							isInCloudDrive = true;
						}
					}
				}
			} else {
				return "";
			}
		}
	}
	array<string> output = GetSongUrl(id, isInCloudDrive);
	if (output[0].empty()) {
		return "";
	}
	if (@QualityList !is null) {
		dictionary qualityitem1;
		string quality = getQuality(output[1]);
		if (isInCloudDrive) {
			qualityitem1["quality"] = quality + " (云盘)";
		} else {
			qualityitem1["quality"] = quality;
		}
		qualityitem1["qualityDetail"] = qualityitem1["quality"];
		qualityitem1["url"] = output[0];
		qualityitem1["itag"] = 0;
		QualityList.insertLast(qualityitem1);

		dictionary qualityitem2;
		qualityitem2["quality"] = "-";
		qualityitem2["qualityDetail"] = qualityitem2["quality"];
		qualityitem2["url"] = output[0];
		qualityitem2["itag"] = 1;
		QualityList.insertLast(qualityitem2);
	}
	return output[0];
}

array<dictionary> BoughtSongs() {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/song/purchased?offset=0&limit=1000");
	} else {
		res = post("/api/single/mybought/song/list?offset=0&limit=1000");
	}
	array<dictionary> songs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["data"]["list"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary song;
							song["title"] = item["name"].asString();
							song["url"] = host + "/song?id=" + item["songId"].asString();
							song["thumbnail"] = item["picUrl"].asString();
							song["author"] = item["artistName"].asString();
							songs.insertLast(song);
						}
					}
				}
			}
		}
	}
	return songs;
}

string parseArtists(JsonValue list, string sep) {
	if (!list.isArray() || list.size() == 0) {
		return "";
	}
	string res = list[0]["name"].asString();
	for (int i = 1; i < list.size(); i++) {
		res += sep;
		res += list[i]["name"].asString();
	}
	return res;
}

array<dictionary> Search(string path) {
	string res;
	string kw;
	if (path.find("?WithCaption") >= 0) {
		path.replace("?WithCaption", "");
		kw = HostUrlEncode(parse(path, "s"));
	} else {
		kw = parse(path, "s");
	}
	string type = parse(path, "type");
	if (type != "1" and type != "1004" and type != "1006" and type != "1014") {
		type = "1";
	}
	if (ConfigData.useNeteaseApi) {
		res = post("/cloudsearch?keywords=" + kw + "&type=" + type + "&offsest=0&limit=100&total=true");
	} else {
		res = post("/api/cloudsearch/pc?s=" + kw + "&type=" + type + "&offsest=0&limit=100&total=true");
	}
	array<dictionary> songs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["result"]["songs"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							JsonValue privilege = item["privilege"];
							if (privilege.isObject()) {
								if ((ConfigData.skipUnavailable && privilege["pl"].asInt() == 0 && (ConfigData.VIPCookie.empty() || privilege["fee"].asInt() != 1))) {
									continue;
								}
							}
							dictionary song;
							song["title"] = item["name"].asString();
							song["duration"] = item["dt"].asInt();
							song["url"] = host + "/song?id=" + item["id"].asString();
							song["thumbnail"] = item["al"]["picUrl"].asString();
							song["author"] = parseArtists(item["ar"], "/");
							songs.insertLast(song);
						}
					}
				}
				data = Root["result"]["videos"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary video;
							video["title"] = item["title"].asString();
							if (item["vid"].asString().length() >= 32) {
								video["url"] = host + "/#/video?id=" + item["vid"].asString();
							} else {
								video["url"] = host + "/mv?id=" + item["vid"].asString();
							}
							video["thumbnail"] = item["coverUrl"].asString();
							video["author"] = item["creator"][0]["userName"].asString();
							songs.insertLast(video);
						}
					}
				}
				data = Root["result"]["mvs"];
				if (data.isArray()) {
					for (int i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary mv;
							mv["title"] = item["name"].asString();
							mv["url"] = host + "/mv?id=" + item["id"].asString();
							mv["thumbnail"] = item["cover"].asString();
							mv["author"] = item["artists"][0]["name"].asString();
							songs.insertLast(mv);
						}
					}
				}
			}
		}
	}
	return songs;
}

string Program(string id, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string res;
	if (ConfigData.useNeteaseApi) {
		res = post("/dj/program/detail?id=" + id);
	} else {
		res = post("/api/dj/program/detail?id=" + id);
	}
	string songId = "0";
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue item = Root["program"]["mainSong"];
				if (item.isObject()) {
					songId = item["id"].asString();
					MetaData["title"] = item["name"].asString();
					MetaData["url"] = path;
					if (!ConfigData.lyricApi.empty()){
						array<dictionary> subtitle;
						dictionary dic;
						dic["name"] = item["name"].asString();
						dic["url"] = ConfigData.lyricApi + "/lyric?id=" + id;
						subtitle.insertLast(dic);
						MetaData["subtitle"] = subtitle;
					}
				}
			} else {
				return "";
			}
		}
	}
	return GetSongUrl(songId, false)[0];
}

string parse(string url, string key, string defaultValue="") {
	string value = HostRegExpParse(url, "\\?" + key + "=([^&]+)");
	if (!value.empty()) {
		return value;
	}
	value = HostRegExpParse(url, "&" + key + "=([^&]+)");
	if (!value.empty()) {
		return value;
	}

	value = defaultValue;
	return value;
}

bool PlayitemCheck(const string &in path) {
	if (path.find("music.163.com") < 0) {
		return false;
	}

	if (path.find("/song") >= 0) {
		return true;
	}

	if (path.find("/video") >= 0) {
		return true;
	}

	if (path.find("/mlog") >= 0) {
		return true;
	}

	if (path.find("#/mv") >= 0 || path.find("music.163.com/mv") >= 0) {
		return true;
	}

	if (path.find("/program") >= 0) {
		return true;
	}

	return false;
}

bool PlaylistCheck(const string &in path) {
	if (path.find("music.163.com") < 0) {
		return false;
	}

	if (path.find("/playlist") >= 0) {
		return true;
	}

	if (path.find("/artist?") >= 0) {
		return true;
	}

	if (path.find("/artist/mv") >= 0) {
		return true;
	}

	if (path.find("/album") >= 0) {
		return true;
	}

	if (path.find("/djradio") >= 0 or path.find("/radio") >= 0) {
		return true;
	}

	if (path.find("/discover/toplist") >= 0) {
		return true;
	}

	if (path.find("/recommend/taste") >= 0) {
		return true;
	}

	if (path.find("/purchasedsong") >= 0) {
		return true;
	}

	if (path.find("/music/mv") >= 0) {
		return true;
	}

	if (path.find("/search") >= 0) {
		return true;
	}

	return false;
}

string parseId(string url) {
	string id = HostRegExpParse(url, "\\?id=([a-zA-Z0-9]+)");
	if (!id.empty()) {
		return id;
	}
	id = HostRegExpParse(url, "&id=([a-zA-Z0-9]+)");
	if (!id.empty()) {
		return id;
	}
	return "";
}

array<dictionary> PlaylistParse(const string &in path) {
	array<dictionary> result;

	if (path.find("/recommend/taste") >= 0) {
		return RecommendSongs();
	}

	if (path.find("/purchasedsong") >= 0) {
		return BoughtSongs();
	}

	if (path.find("/music/mv") >= 0) {
		return MVSublist();
	}

	string id = parseId(path);
	if (id.empty()) {
		// 飙升榜
		if (path.find("/discover/toplist") >= 0) {
			id = "19723756";
		} else if (path.find("/search") >= 0) {
			return Search(path);
		} else {
			return result;
		}
	}

	if (path.find("/artist/mv") >= 0) {
		return ArtistMV(id);
	}

	if (path.find("/playlist") >= 0) {
		return Playlist(id);
	}

	if (path.find("/album") >= 0) {
		return Album(id);
	}

	if (path.find("/artist?") >= 0) {
		return ArtistSong(id);
	}

	if (path.find("/djradio") >= 0 or path.find("/radio") >= 0) {
		return Djradio(id);
	}

	if (path.find("/discover/toplist") >= 0) {
		return Playlist(id);
	}

	return result;
}

string PlayitemParse(const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string id = parseId(path);
	if (id.empty()) {
		return "";
	}

	if (path.find("/song") >= 0) {
		return SongUrl(id, path, MetaData, QualityList);
	}

	if (path.find("/mv") >= 0) {
		return MVUrl(id, path, MetaData, QualityList);
	}

	if (path.find("/mlog") >= 0) {
		return MlogUrl(id, path, MetaData, QualityList);
	}

	if (path.find("/video") >= 0) {
		return VideoUrl(id, path, MetaData, QualityList);
	}

	if (path.find("/program") >= 0) {
		return Program(id, path, MetaData, QualityList);
	}

	return path;
}

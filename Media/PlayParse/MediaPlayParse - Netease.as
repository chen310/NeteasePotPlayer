/*
	Netease media parse
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

// ******************** 设置开始 ********************

// 填写 Cookie，如 MUSIC_U=xxxxxxxxxxxxx
string cookie = "";
// 比特率: 128000 | 192000 | 320000 | 999000
string br = "999000";
// 清晰度
string r = "1080";

// ******************** 设置结束 ********************

string host = "https://music.163.com";

string GetTitle() {

	return "NeteaseCloudMusic";
}

string GetVersion() {

	return "1.0";
}

string GetDesc() {

	return "https://music.163.com/";
}

string post(string api, string data="") {
	string Headers = "Accept: */*\r\nConnection: keep-alive\r\nHost: music.163.com\r\nReferer: https://music.163.com\r\n";
	string UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36";
	if (!cookie.empty()) {
		Headers += "Cookie: " + cookie + "\r\n";
	}
	return HostUrlGetStringWithAPI(host + api, UserAgent, Headers, data, true);
}

array<dictionary> Album(string id) {
	string res = post("/api/v1/album/" + id);
	array<dictionary> songs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["songs"];
				if (data.isArray()) {
					for (uint i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary song;
							song["title"] = item["name"].asString();
							song["url"] = host + "/song/?id=" + item["id"].asString();
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
	string res = post("/api/v6/playlist/detail?id=" + id + "&n=100000&s=8");
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
						for (uint i = 0; i < data.size(); i++) {
							JsonValue item = data[i];
							if (item.isObject()) {
								dictionary song;
								song["title"] = item["mlogBaseData"]["text"].asString();
								string id = item["mlogBaseData"]["id"].asString();
								int videoType = item["mlogBaseData"]["type"].asInt();
								// videoType: 1: video, 2: mlog, 3: mv
								if (videoType == 1) {
									song["url"] = host + "/#/video?id=" + id;
								} else if (videoType == 2) {
									song["url"] = "https://st.music.163.com/mlog/mlog.html?id=" + id;
								} else {
									song["url"] = host + "/mv/?id=" + id;
								}
								songs.insertLast(song);
							}
						}
					}
				} else {
					JsonValue data = Root["playlist"]["tracks"];
					if (data.isArray()) {
						for (uint i = 0; i < data.size(); i++) {
							JsonValue item = data[i];
							if (item.isObject()) {
								dictionary song;
								song["title"] = item["name"].asString();
								song["duration"] = item["dt"].asInt();
								song["url"] = host + "/song/?id=" + item["id"].asString();
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

array<dictionary> ArtistMV(string id) {
	string res = post("/api/artist/mvs?artistId=" + id + "&offset=0&limit=1000");
	array<dictionary> mvs;
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["mvs"];
				if (data.isArray()) {
					for (uint i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary mv;
							mv["title"] = item["name"].asString();
							mv["url"] = host + "/mv/?id=" + item["id"].asString();
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
	string res = post("/api/mlog/detail/v1?type=1&id=" + id + "&resolution=" + r);
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue item = Root["data"]["resource"]["content"];
				MetaData["title"] = item["title"].asString();
				MetaData["SourceUrl"] = path;
				return item["video"]["urlInfo"]["url"].asString();
			} else {
				return "";
			}
		}
	}
	return "";
}

string VideoUrl(string id, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string res = post("/api/cloudvideo/v1/video/detail?id=" + id);
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue item = Root["data"];
				MetaData["title"] = item["title"].asString();
				MetaData["SourceUrl"] = path;
			} else {
				return "";
			}
		}
	}
	res = post("/api/cloudvideo/playurl?ids=%5B%22" + id + "%22%5D&resolution=" + r);
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
	string res = post("/api/v1/mv/detail?id=" + id);
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue item = Root["data"];
				MetaData["title"] = item["artistName"].asString() + ' - ' + item["name"].asString();
				MetaData["SourceUrl"] = path;
			} else {
				return "";
			}
		}
	}
	res = post("/api/song/enhance/play/mv/url?id=" + id + "&r=1080");
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

string SongUrl(string id, const string &in path, dictionary &MetaData, array<dictionary> &QualityList) {
	string res = post("/api/v3/song/detail?c=[{\"id\":" + id +"}]");
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["songs"];
				if (data.isArray()) {
					JsonValue item = data[0];
					if (item.isObject()) {
						MetaData["title"] = item["ar"][0]["name"].asString() + ' - ' + item["name"].asString();
						MetaData["SourceUrl"] = path;
					}
				}
			} else {
				return "";
			}
		}
	}
	res = post("/api/song/enhance/player/url?ids=%5B" + id + "%5D&br=" + br);
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
							return url.asString();
						}
					}
				}
			} else {
				return "";
			}
		}
	}
	return "";
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

	return false;
}

string parseId(string url) {
	string id = HostRegExpParse(url, "\?id=([a-zA-Z0-9]+)");
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
	string id = parseId(path);

	if (id.empty()) {
		return result;
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

	return path;
}

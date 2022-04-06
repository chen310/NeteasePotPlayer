/*
	media url search by netease
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
// array<dictionary> GetCategorys()						-> get category list
// string GetSorts(string Category, string Extra, string PathToken, string Query)									-> get sort option
// array<dictionary> GetUrlList(string Category, string Extra, string PathToken, string Query, string PageToken)	-> get url list for Category

// ******************** 设置开始 ********************

// 填写 Cookie
string cookie = "";
// 填写用户 id
string uid = "";
// 是否使用第三方 API 地址，如为 true，则需在下方填写 API 地址，否则使用官方 API
bool useNeteaseApi = false;
// 第三方 API 地址，详见 https://github.com/Binary/NeteaseCloudMusicApi
string NeteaseApi = "";

// ******************** 设置结束 ********************

string host = "https://music.163.com";

string GetTitle()
{
	return "NeteaseCloudMusic";
}

string GetVersion()
{
	return "1.1";
}

string GetDesc()
{
	return "https://music.163.com";
}

string post(string api, string data="") {
	string UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36";
	string url;
	string Headers;
	if (useNeteaseApi) {
		Headers = "Accept: */*\r\nConnection: keep-alive\r\n";
		url = NeteaseApi + api;
	} else {
		Headers = "Accept: */*\r\nConnection: keep-alive\r\nHost: music.163.com\r\nReferer: https://music.163.com\r\n";
		url = host + api;
	}
	if (!cookie.empty()) {
		Headers += "Cookie: " + cookie + "\r\n";
	}
	return HostUrlGetStringWithAPI(url, UserAgent, Headers, data, true);
}

array<dictionary> MyPlaylist() {
	array<dictionary> ret;
	if (uid.empty()) {
		return ret;
	}
	string res;
	if (useNeteaseApi) {
		res = post("/user/playlist?uid=" + uid + "&limit=1000");
	} else {
		res = post("/api/user/playlist?uid=" + uid + "&offse=0&limit=1000&includeVideo=true");
	}
	if (!res.empty()) {
		JsonReader Reader;
		JsonValue Root;
		if (Reader.parse(res, Root) && Root.isObject()) {
			if (Root["code"].asInt() == 200) {
				JsonValue data = Root["playlist"];
				if (data.isArray()) {
					for (uint i = 0; i < data.size(); i++) {
						JsonValue item = data[i];
						if (item.isObject()) {
							dictionary playlist;
							playlist["title"] = item["name"].asString();
							playlist["url"] = host + "/#/playlist?id=" + item["id"].asString();
							ret.insertLast(playlist);
						}
					}
				}
			}
		}
	}
	return ret;
}

array<dictionary> GetCategorys()
{
	array<dictionary> ret;

	dictionary item1;
	item1["title"] = "我的歌单";
	item1["Category"] = "most";
	ret.insertLast(item1);

	return ret;
}

array<dictionary> GetUrlList(string Category, string Extra, string PathToken, string Query, string PageToken)
{
	return MyPlaylist();
}

//
//  JSONColorFormatter.m
//  Alphabetical List Utility
//
//  Created by HAI on 7/22/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "JSONColorFormatter.h"

#import "NKFColor.h"

@implementation JSONColorFormatter





+ (NSString *)sportsTeamsColorsJSON {
	NSString *sportsTeamJSON = @"{\
	\"epl\": [{\
	\"team\": \"Arsenal\",\
	\"colors\": {\
	\"hex\": [\"EF0107\", \"023474\", \"9C824A\"],\
	\"rgb\": [\"239 1 7\", \"2 52 116\", \"156 130 74\"]\
	}\
	}, {\
	\"team\": \"Aston Villa\",\
	\"colors\": {\
	\"hex\": [\"94BEE5\", \"7A003C\", \"FFE600\"],\
	\"rgb\": [\"148 190 229\", \"122 0 60\", \"255 230 0\"]\
	}\
	}, {\
	\"team\": \"Burnley\",\
	\"colors\": {\
	\"hex\": [\"8CCCE5\", \"53162F\", \"F9EC34\"],\
	\"rgb\": [\"140 204 229\", \"83 22 47\", \"249 236 52\"]\
	}\
	}, {\
	\"team\": \"Chelsea\",\
	\"colors\": {\
	\"hex\": [\"034694\", \"DBA111\", \"ED1C24\"],\
	\"rgb\": [\"3 70 148\", \"219 161 17\", \"237 28 36\"]\
	}\
	}, {\
	\"team\": \"Crystal Palace\",\
	\"colors\": {\
	\"hex\": [\"1B458F\", \"C4122E\", \"A7A5A6\"],\
	\"rgb\": [\"27 69 143\", \"196 18 46\", \"167 165 166\"]\
	}\
	}, {\
	\"team\": \"Everton\",\
	\"colors\": {\
	\"hex\": [\"274488\"],\
	\"rgb\": [\"39 68 136\"]\
	}\
	}, {\
	\"team\": \"Hull City\",\
	\"colors\": {\
	\"hex\": [\"F5A12D\", \"000000\"],\
	\"rgb\": [\"245 161 45\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"Leicester City\",\
	\"colors\": {\
	\"hex\": [\"FDBE11\", \"0053A0\"],\
	\"rgb\": [\"253 190 17\", \"0 83 160\"]\
	}\
	}, {\
	\"team\": \"Liverpool\",\
	\"colors\": {\
	\"hex\": [\"00A398\", \"D00027\", \"FEF667\"],\
	\"rgb\": [\"0 163 152\", \"208 0 39\", \"254 246 103\"]\
	}\
	}, {\
	\"team\": \"Manchester City\",\
	\"colors\": {\
	\"hex\": [\"5CBFEB\", \"FFCE65\"],\
	\"rgb\": [\"92 191 235\", \"255 206 101\"]\
	}\
	}, {\
	\"team\": \"Manchester United\",\
	\"colors\": {\
	\"hex\": [\"DA020E\", \"FFE500\", \"000000\"],\
	\"rgb\": [\"218 2 14\", \"255 229 0\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"Newcastle United\",\
	\"colors\": {\
	\"hex\": [\"00B6F1\", \"BBBDBF\", \"231F20\", \"F0B83D\"],\
	\"rgb\": [\"0 182 241\", \"187 189 191\", \"35 31 32\", \"240 184 61\"]\
	}\
	}, {\
	\"team\": \"Queens Park Rangers\",\
	\"colors\": {\
	\"hex\": [\"005CAB\"],\
	\"rgb\": [\"0 92 171\"]\
	}\
	}, {\
	\"team\": \"Southampton\",\
	\"colors\": {\
	\"hex\": [\"ED1A3B\", \"211E1F\", \"FFC20E\"],\
	\"rgb\": [\"237 26 59\", \"33 30 31\", \"255 194 14\"]\
	}\
	}, {\
	\"team\": \"Stoke City\",\
	\"colors\": {\
	\"hex\": [\"E03A3E\", \"1B449C\"],\
	\"rgb\": [\"224 58 62\", \"27 68 156\"]\
	}\
	}, {\
	\"team\": \"Sunderland\",\
	\"colors\": {\
	\"hex\": [\"EB172B\", \"A68A26\", \"211E1E\"],\
	\"rgb\": [\"235 23 43\", \"166 138 38\", \"33 30 30\"]\
	}\
	}, {\
	\"team\": \"Swansea City\",\
	\"colors\": {\
	\"hex\": [\"000000\"],\
	\"rgb\": [\"0 0 0\"]\
	}\
	}, {\
	\"team\": \"Tottenham Hotspur\",\
	\"colors\": {\
	\"hex\": [\"001C58\"],\
	\"rgb\": [\"0 28 88\"]\
	}\
	}, {\
	\"team\": \"West Bromwich Albion\",\
	\"colors\": {\
	\"hex\": [\"091453\"],\
	\"rgb\": [\"9 20 83\"]\
	}\
	}, {\
	\"team\": \"West Ham United\",\
	\"colors\": {\
	\"hex\": [\"60223B\", \"F7C240\", \"5299C6\"],\
	\"rgb\": [\"96 34 59\", \"247 194 64\", \"82 153 198\"]\
	}\
	}],\
	\"mlb\": [{\
	\"team\": \"Arizona Diamondbacks\",\
	\"colors\": {\
	\"hex\": [\"A71930\", \"000000\", \"DBCEAC\"],\
	\"rgb\": [\"167 25 48\", \"0 0 0\", \"219 206 172\"]\
	}\
	}, {\
	\"team\": \"Atlanta Braves\",\
	\"colors\": {\
	\"hex\": [\"002F5F\", \"B71234\"],\
	\"rgb\": [\"0 47 95\", \"183 18 52\"]\
	}\
	}, {\
	\"team\": \"Baltimore Orioles\",\
	\"colors\": {\
	\"hex\": [\"ed4c09\", \"000000\"],\
	\"rgb\": [\"237 76 9\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"Boston Red Sox\",\
	\"colors\": {\
	\"hex\": [\"C60C30\", \"002244\"],\
	\"rgb\": [\"198 12 48\", \"0 34 68\"]\
	}\
	}, {\
	\"team\": \"Chicago Cubs\",\
	\"colors\": {\
	\"hex\": [\"003279\", \"CC0033\"],\
	\"rgb\": [\"0 50 121\", \"204 0 51\"]\
	}\
	}, {\
	\"team\": \"Chicago White Sox\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"C0C0C0\"],\
	\"rgb\": [\"0 0 0\", \"192 192 192\"]\
	}\
	}, {\
	\"team\": \"Cincinnati Reds\",\
	\"colors\": {\
	\"hex\": [\"C6011F\", \"000000\"],\
	\"rgb\": [\"198 1 31\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"Colorado Rockies\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"333366\", \"C0C0C0\"],\
	\"rgb\": [\"0 0 0\", \"51 51 102\", \"192 192 192\"]\
	}\
	}, {\
	\"team\": \"Cleveland Indians\",\
	\"colors\": {\
	\"hex\": [\"003366\", \"d30335\"],\
	\"rgb\": [\"0 51 102\", \"211 3 53\"]\
	}\
	}, {\
	\"team\": \"Detroit Tigers\",\
	\"colors\": {\
	\"hex\": [\"001742\", \"DE4406\"],\
	\"rgb\": [\"0 23 66\", \"222 68 6\"]\
	}\
	}, {\
	\"team\": \"Houston Astros\",\
	\"colors\": {\
	\"hex\": [\"072854\", \"FF7F00\"],\
	\"rgb\": [\"7 40 84\", \"255 127 0\"]\
	}\
	}, {\
	\"team\": \"Kansas City Royals\",\
	\"colors\": {\
	\"hex\": [\"15317E\", \"74B4FA\"],\
	\"rgb\": [\"21 49 126\", \"116 180 250\"]\
	}\
	}, {\
	\"team\": \"Los Angeles Angels of Anaheim\",\
	\"colors\": {\
	\"hex\": [\"B71234\", \"002244\"],\
	\"rgb\": [\"183 18 52\", \"0 34 68\"]\
	}\
	}, {\
	\"team\": \"Los Angeles Dodgers\",\
	\"colors\": {\
	\"hex\": [\"083C6B\"],\
	\"rgb\": [\"8 60 107\"]\
	}\
	}, {\
	\"team\": \"Miami Marlins\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"F9423A\", \"8A8D8F\", \"0077C8\", \"FFD100\"],\
	\"rgb\": [\"0 0 0\", \"249 66 58\", \"138 141 143\", \"0 119 200\", \"255 209 0\"]\
	}\
	}, {\
	\"team\": \"Milwaukee Brewers\",\
	\"colors\": {\
	\"hex\": [\"182B49\", \"92754C\"],\
	\"rgb\": [\"24 43 73\", \"146 117 76\"]\
	}\
	}, {\
	\"team\": \"Minnesota Twins\",\
	\"colors\": {\
	\"hex\": [\"072754\", \"C6011F\"],\
	\"rgb\": [\"7 39 84\", \"198 1 31\"]\
	}\
	}, {\
	\"team\": \"New York Mets\",\
	\"colors\": {\
	\"hex\": [\"002C77\", \"FB4F14\"],\
	\"rgb\": [\"0 44 119\", \"251 79 20\"]\
	}\
	}, {\
	\"team\": \"New York Yankees\",\
	\"colors\": {\
	\"hex\": [\"1C2841\", \"808080\"],\
	\"rgb\": [\"28 40 65\", \"128 128 128\"]\
	}\
	}, {\
	\"team\": \"Oakland Athletics\",\
	\"colors\": {\
	\"hex\": [\"003831\", \"FFD800\"],\
	\"rgb\": [\"0 56 49\", \"255 216 0\"]\
	}\
	}, {\
	\"team\": \"Philadelphia Phillies\",\
	\"colors\": {\
	\"hex\": [\"BA0C2F\", \"003087\"],\
	\"rgb\": [\"186 12 47\", \"0 48 135\"]\
	}\
	}, {\
	\"team\": \"Pittsburgh Pirates\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"fdb829\"],\
	\"rgb\": [\"0 0 0\", \"253 184 41\"]\
	}\
	}, {\
	\"team\": \"San Diego Padres\",\
	\"colors\": {\
	\"hex\": [\"002147\", \"B4A76C\"],\
	\"rgb\": [\"0 33 71\", \"180 167 108\"]\
	}\
	}, {\
	\"team\": \"San Francisco Giants\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"F2552C\", \"FFFDD0\"],\
	\"rgb\": [\"0 0 0\", \"242 85 44\", \"255 253 208\"]\
	}\
	}, {\
	\"team\": \"Seattle Mariners\",\
	\"colors\": {\
	\"hex\": [\"0C2C56\", \"005C5C\", \"C0C0C0\"],\
	\"rgb\": [\"12 44 86\", \"0 92 92\", \"192 192 192\"]\
	}\
	}, {\
	\"team\": \"St Louis Cardinals\",\
	\"colors\": {\
	\"hex\": [\"c41e3a\", \"0A2252\"],\
	\"rgb\": [\"196 30 58\", \"10 34 82\"]\
	}\
	}, {\
	\"team\": \"Tampa Bay Rays\",\
	\"colors\": {\
	\"hex\": [\"00285D\", \"9ECEEE\", \"ffd700\"],\
	\"rgb\": [\"0 40 93\", \"158 206 238\", \"255 215 0\"]\
	}\
	}, {\
	\"team\": \"Texas Rangers\",\
	\"colors\": {\
	\"hex\": [\"BD1021\", \"003279\"],\
	\"rgb\": [\"189 16 33\", \"0 50 121\"]\
	}\
	}, {\
	\"team\": \"Toronto Blue Jays\",\
	\"colors\": {\
	\"hex\": [\"003DA5\", \"041E42\", \"DA291C\"],\
	\"rgb\": [\"0 61 165\", \"4 30 66\", \"218 41 28\"]\
	}\
	}, {\
	\"team\": \"Washington Nationals\",\
	\"colors\": {\
	\"hex\": [\"BA122B\", \"11225B\"],\
	\"rgb\": [\"186 18 43\", \"17 34 91\"]\
	}\
	}],\
	\"mls\": [{\
	\"team\": \"Chicago Fire\",\
	\"colors\": {\
	\"hex\": [\"AF2626\", \"0A174A\", \"8A8D8F\"],\
	\"rgb\": [\"175 38 38\", \"10 23 74\", \"138 141 143\"]\
	}\
	}, {\
	\"team\": \"Chivas USA\",\
	\"colors\": {\
	\"hex\": [\"AA002C\", \"031A43\", \"FFC800\"],\
	\"rgb\": [\"170 0 44\", \"3 26 67\", \"255 200 0\"]\
	}\
	}, {\
	\"team\": \"Colorado Rapids\",\
	\"colors\": {\
	\"hex\": [\"91022D\", \"85B7EA\", \"8A8D8F\", \"313F49\"],\
	\"rgb\": [\"145 2 45\", \"133 183 234\", \"138 141 143\", \"49 63 73\"]\
	}\
	}, {\
	\"team\": \"Columbus Crew\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"FFDB00\", \"8A8D8F\"],\
	\"rgb\": [\"0 0 0\", \"255 219 0\", \"138 141 143\"]\
	}\
	}, {\
	\"team\": \"DC United\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"DD0000\"],\
	\"rgb\": [\"0 0 0\", \"221 0 0\"]\
	}\
	}, {\
	\"team\": \"FC Dallas\",\
	\"colors\": {\
	\"hex\": [\"CF0032\", \"07175C\", \"8A8D8F\"],\
	\"rgb\": [\"207 0 50\", \"7 23 92\", \"138 141 143\"]\
	}\
	}, {\
	\"team\": \"Houston Dynamo\",\
	\"colors\": {\
	\"hex\": [\"F36600\", \"2E2926\", \"85B7EA\"],\
	\"rgb\": [\"243 102 0\", \"46 41 38\", \"133 183 234\"]\
	}\
	}, {\
	\"team\": \"Los Angeles Galaxy\",\
	\"colors\": {\
	\"hex\": [\"00245D\", \"004689\", \"F1AA00\", \"FFD200\"],\
	\"rgb\": [\"0 36 93\", \"0 70 137\", \"241 170 0\", \"255 210 0\"]\
	}\
	}, {\
	\"team\": \"Montreal Impact\",\
	\"colors\": {\
	\"hex\": [\"122089\", \"000000\", \"7A878F\"],\
	\"rgb\": [\"18 32 137\", \"0 0 0\", \"122 135 143\"]\
	}\
	}, {\
	\"team\": \"New England Revolution\",\
	\"colors\": {\
	\"hex\": [\"0A2141\", \"D80016\", \"8A8D8F\"],\
	\"rgb\": [\"10 33 65\", \"216 0 22\", \"138 141 143\"]\
	}\
	}, {\
	\"team\": \"New York Red Bulls\",\
	\"colors\": {\
	\"hex\": [\"D50031\", \"012055\", \"FFC800\", \"8A8D8F\"],\
	\"rgb\": [\"213 0 49\", \"1 32 85\", \"255 200 0\", \"138 141 143\"]\
	}\
	}, {\
	\"team\": \"New York City FC\",\
	\"colors\": {\
	\"hex\": [\"6CADDF\", \"00285E\", \"FD4F00\"],\
	\"rgb\": [\"108 173 223\", \"0 40 94\", \"253 79 0\"]\
	}\
	}, {\
	\"team\": \"Orlando City SC\",\
	\"colors\": {\
	\"hex\": [\"633492\", \"FDE192\"],\
	\"rgb\": [\"99 52 146\", \"253 225 146\"]\
	}\
	}, {\
	\"team\": \"Philadelphia Union\",\
	\"colors\": {\
	\"hex\": [\"001B2D\", \"B18500\", \"348AE1\"],\
	\"rgb\": [\"0 27 45\", \"177 133 0\", \"52 138 225\"]\
	}\
	}, {\
	\"team\": \"Portland Timbers\",\
	\"colors\": {\
	\"hex\": [\"004812\", \"EBE72B\"],\
	\"rgb\": [\"0 72 18\", \"235 231 43\"]\
	}\
	}, {\
	\"team\": \"Real Salt Lake\",\
	\"colors\": {\
	\"hex\": [\"A50531\", \"013474\", \"F2D11A\"],\
	\"rgb\": [\"165 5 49\", \"1 52 116\", \"242 209 26\"]\
	}\
	}, {\
	\"team\": \"San Jose Earthquakes\",\
	\"colors\": {\
	\"hex\": [\"0051BA\", \"000000\", \"B1B4B2\"],\
	\"rgb\": [\"0 81 186\", \"0 0 0\", \"177 180 178\"]\
	}\
	}, {\
	\"team\": \"Seattle Sounders FC\",\
	\"colors\": {\
	\"hex\": [\"4F8A10\", \"11568C\", \"212930\"],\
	\"rgb\": [\"79 138 16\", \"17 86 140\", \"33 41 48\"]\
	}\
	}, {\
	\"team\": \"Sporting Kansas City\",\
	\"colors\": {\
	\"hex\": [\"A4BBD7\", \"0A2141\", \"787775\"],\
	\"rgb\": [\"164 187 215\", \"10 33 65\", \"120 119 117\"]\
	}\
	}, {\
	\"team\": \"Toronto FC\",\
	\"colors\": {\
	\"hex\": [\"D80016\", \"313F49\", \"A1AAAD\"],\
	\"rgb\": [\"216 0 22\", \"49 63 73\", \"161 170 173\"]\
	}\
	}, {\
	\"team\": \"Vancouver Whitecaps FC\",\
	\"colors\": {\
	\"hex\": [\"12264C\", \"85B7EA\", \"838383\"],\
	\"rgb\": [\"18 38 76\", \"133 183 234\", \"131 131 131\"]\
	}\
	}],\
	\"nba\": [{\
	\"team\": \"Atlanta Hawks\",\
	\"colors\": {\
	\"rgb\": [\"225 58 62\", \"196 214 0\", \"6 25 34\"],\
	\"cmyk\": [\"0 91 76 6\", \"29 2 100 0\", \"30 0 0 100\"],\
	\"pms\": [\"186\", \"382\", \"Black\"],\
	\"hex\": [\"e13a3e\", \"c4d600\", \"061922\"]\
	}\
	}, {\
	\"team\": \"Boston Celtics\",\
	\"colors\": {\
	\"rgb\": [\"0 131 72\", \"187 151 83\", \"167 56 50\", \"250 179 131\", \"6 25 34\"],\
	\"cmyk\": [\"100 0 91 27\", \"30 40 80 0\", \"40 95 100 0\", \"0 35 50 0\", \"30 0 0 100\"],\
	\"pms\": [\"356\", \"874\", \"174\", \"472\", \"Black\"],\
	\"hex\": [\"008348\", \"bb9753\", \"a73832\", \"fab383\", \"061922\"]\
	}\
	}, {\
	\"team\": \"Brooklyn Nets\",\
	\"colors\": {\
	\"rgb\": [\"6 25 34\"],\
	\"cmyk\": [\"30 0 0 100\"],\
	\"pms\": [\"Black\"],\
	\"hex\": [\"061922\"]\
	}\
	}, {\
	\"team\": \"Charlotte Hornets\",\
	\"colors\": {\
	\"rgb\": [\"29 17 96\", \"0 140 168\", \"161 161 164\"],\
	\"cmyk\": [\"98 100 0 43\", \"100 0 19 23\", \"0 1 0 43\"],\
	\"pms\": [\"275\", \"3145\", \"Cool Gray 8\"],\
	\"hex\": [\"1d1160\", \"008ca8\", \"a1a1a4\"]\
	}\
	}, {\
	\"team\": \"Chicago Bulls\",\
	\"colors\": {\
	\"rgb\": [\"206 17 65\", \"6 25 34\"],\
	\"cmyk\": [\"0 100 65 15\", \"30 0 0 100\"],\
	\"pms\": [\"200\", \"Black\"],\
	\"hex\": [\"ce1141\", \"061922\"]\
	}\
	}, {\
	\"team\": \"Cleveland Cavaliers\",\
	\"colors\": {\
	\"rgb\": [\"134 0 56\", \"253 187 48\", \"0 45 98\"],\
	\"cmyk\": [\"0 100 34 53\", \"0 29 91 0\", \"100 68 54 0\"],\
	\"pms\": [\"209\", \"1235\", \"282\"],\
	\"hex\": [\"860038\", \"fdbb30\", \"002d62\"]\
	}\
	}, {\
	\"team\": \"Dallas Mavericks\",\
	\"colors\": {\
	\"rgb\": [\"0 125 197\", \"196 206 211\", \"6 25 34\", \"32 56 91\"],\
	\"cmyk\": [\"100 40 0 0\", \"5 0 0 20\", \"30 0 0 100\", \"94 79 36 32\"],\
	\"pms\": [\"2935\", \"877\", \"Black\", \"289\"],\
	\"hex\": [\"007dc5\", \"c4ced3\", \"061922\", \"20385b\"]\
	}\
	}, {\
	\"team\": \"Denver Nuggets\",\
	\"colors\": {\
	\"rgb\": [\"77 144 205\", \"253 185 39\", \"15 88 108\"],\
	\"cmyk\": [\"69 34 0 0\", \"0 30 94 0\", \"100 72 56 0\"],\
	\"pms\": [\"279\", \"123\", \"282\"],\
	\"hex\": [\"4d90cd\", \"fdb927\", \"0f586c\"]\
	}\
	}, {\
	\"team\": \"Detroit Pistons\",\
	\"colors\": {\
	\"rgb\": [\"237 23 76\", \"0 107 182\", \"15 88 108\"],\
	\"cmyk\": [\"0 100 65 0\", \"100 56 0 0\", \"100 72 0 56\"],\
	\"pms\": [\"199\", \"293\", \"282\"],\
	\"hex\": [\"ed174c\", \"006bb6\", \"0f586c\"]\
	}\
	}, {\
	\"team\": \"Golden State Warriors\",\
	\"colors\": {\
	\"rgb\": [\"253 185 39\", \"0 107 182\", \"38 40 42\"],\
	\"cmyk\": [\"0 30 94 0\", \"100 56 0 0\", \"73 65 62 67\"],\
	\"pms\": [\"123\", \"293\", \"426\"],\
	\"hex\": [\"fdb927\", \"006bb6\", \"26282a\"]\
	}\
	}, {\
	\"team\": \"Houston Rockets\",\
	\"colors\": {\
	\"rgb\": [\"206 17 65\", \"196 206 211\", \"6 25 34\", \"253 185 39\"],\
	\"cmyk\": [\"100 65 15\", \"5 0 0 20\", \"30 0 0 100\", \"0 30 94 0\"],\
	\"pms\": [\"200\", \"877\", \"Black\", \"123\"],\
	\"hex\": [\"ce1141\", \"c4ced3\", \"061922\", \"fdb927\"]\
	}\
	}, {\
	\"team\": \"Indiana Pacers\",\
	\"colors\": {\
	\"rgb\": [\"255 198 51\", \"0 39 93\", \"190 192 194\"],\
	\"cmyk\": [\"0 23 90 0\", \"100 72 0 56\", \"0 0 0 29\"],\
	\"pms\": [\"1235\", \"282\", \"Cool Gray 5\"],\
	\"hex\": [\"ffc633\", \"00275d\", \"bec0c2\"]\
	}\
	}, {\
	\"team\": \"Los Angeles Clippers\",\
	\"colors\": {\
	\"rgb\": [\"237 23 76\", \"0 107 182\", \"6 25 34\", \"190 192 194\"],\
	\"cmyk\": [\"0 100 65 0\", \"100 56 0 0\", \"30 0 0 100\", \"0 0 0 29\"],\
	\"pms\": [\"199\", \"293\", \"Black\", \"Cool Gray 5\"],\
	\"hex\": [\"ed174c\", \"006bb6\", \"061922\", \"bec0c2\"]\
	}\
	}, {\
	\"team\": \"Los Angeles Lakers\",\
	\"colors\": {\
	\"rgb\": [\"253 185 39\", \"85 37 130\", \"6 25 34\", \"129 119 183\"],\
	\"cmyk\": [\"0 30 94 0\", \"79 100 0 12\", \"30 100 0 0\", \"54 56 0 0\"],\
	\"pms\": [\"123\", \"526\", \"Black\", \"265\"],\
	\"hex\": [\"fdb927\", \"552582\", \"061922\", \"8177b7\"]\
	}\
	}, {\
	\"team\": \"Memphis Grizzlies\",\
	\"colors\": {\
	\"rgb\": [\"15 88 108\", \"115 153 198\", \"190 212 233\", \"253 185 39\"],\
	\"cmyk\": [\"100 72 0 56\", \"50 25 0 10\", \"24 9 2 0\", \"0 30 94 0\"],\
	\"pms\": [\"289\", \"652\", \"650\", \"123\"],\
	\"hex\": [\"0f586c\", \"7399c6\", \"bed4e9\", \"fdb927\"]\
	}\
	}, {\
	\"team\": \"Miami Heat\",\
	\"colors\": {\
	\"rgb\": [\"152 0 46\", \"249 160 27\", \"6 25 34\", \"188 190 192\"],\
	\"cmyk\": [\"0 100 61 43\", \"0 43 100 0\", \"30 0 0 100\", \"40 0 0 0\"],\
	\"pms\": [\"202\", \"137\", \"Black\", \"877\"],\
	\"hex\": [\"98002e\", \"f9a01b\", \"061922\", \"bcbec0\"]\
	}\
	}, {\
	\"team\": \"Milwaukee Bucks\",\
	\"colors\": {\
	\"rgb\": [\"0 71 27\", \"240 235 210\", \"6 25 34\", \"0 125 197\"],\
	\"cmyk\": [\"80 0 90 75\", \"6 9 23 0\", \"20 20 20 100\", \"100 45 0 0\"],\
	\"pms\": [\"350\", \"468\", \"Black\", \"2935\"],\
	\"hex\": [\"00471b\", \"f0ebd2\", \"061922\", \"007dc5\"]\
	}\
	}, {\
	\"team\": \"Minnesota Timberwolves\",\
	\"colors\": {\
	\"rgb\": [\"0 80 131\", \"0 169 79\", \"196 206 211\", \"255 230 0\", \"224 58 63\", \"6 25 34\"],\
	\"cmyk\": [\"95 45 0 40\", \"94 0 100 0\", \"5 0 0 20\", \"0 5 100 0\", \"0 91 75 6\", \"30 0 0 100\"],\
	\"pms\": [\"647\", \"355\", \"877\", \"012\", \"186\", \"Black\"],\
	\"hex\": [\"005083\", \"00a94f\", \"c4ced3\", \"ffe600\", \"e03a3f\", \"061922\"]\
	}\
	}, {\
	\"team\": \"New Orleans Pelicans\",\
	\"colors\": {\
	\"rgb\": [\"0 43 92\", \"227 24 55\", \"180 151 90\"],\
	\"cmyk\": [\"100 64 0 60\", \"0 100 81 4\", \"20 30 70 15\"],\
	\"pms\": [\"289\", \"186\", \"872\"],\
	\"hex\": [\"002b5c\", \"e31837\", \"b4975a\"]\
	}\
	}, {\
	\"team\": \"New York Knicks\",\
	\"colors\": {\
	\"rgb\": [\"0 107 182\", \"245 132 38\", \"190 192 194\", \"35 31 32\"],\
	\"cmyk\": [\"100 56 0 0\", \"0 59 96 0\", \"0 0 0 29\", \"30 0 0 100\"],\
	\"pms\": [\"293\", \"165\", \"Cool Gray 5\", \"Black\"],\
	\"hex\": [\"006bb6\", \"f58426\", \"bec0c2\", \"231f20\"]\
	}\
	}, {\
	\"team\": \"Oklahoma City Thunder\",\
	\"colors\": {\
	\"rgb\": [\"0 125 195\", \"240 81 51\", \"253 187 48\", \"0 45 98\"],\
	\"cmyk\": [\"89 43 0 0\", \"0 84 88 0\", \"0 29 91 0\", \"100 68 0 54\"],\
	\"pms\": [\"285C\", \"1788C\", \"1235C\", \"282C\"],\
	\"hex\": [\"007dc3\", \"f05133\", \"fdbb30\", \"002d62\"]\
	}\
	}, {\
	\"team\": \"Orlando Magic\",\
	\"colors\": {\
	\"rgb\": [\"0 125 197\", \"196 206 211\", \"6 25 34\"],\
	\"cmyk\": [\"100 40 0 0\", \"5 0 0 20\", \"30 0 0 100\"],\
	\"pms\": [\"2935\", \"877\", \"Black\"],\
	\"hex\": [\"007dc5\", \"c4ced3\", \"061922\"]\
	}\
	}, {\
	\"team\": \"Philadelphia 76ers\",\
	\"colors\": {\
	\"rgb\": [\"237 23 76\", \"0 107 182\", \"0 43 92\", \"196 206 211\"],\
	\"cmyk\": [\"0 100 65 0\", \"100 56 0 0\", \"100 64 0 60\", \"5 0 0 20\"],\
	\"pms\": [\"199\", \"293\", \"289\", \"877\"],\
	\"hex\": [\"ed174c\", \"006bb6\", \"002b5c\", \"c4ced3\"]\
	}\
	}, {\
	\"team\": \"Phoenix Suns\",\
	\"colors\": {\
	\"rgb\": [\"229 96 32\", \"29 17 96\", \"99 113 122\", \"249 160 27\", \"185 89 21\", \"190 192 194\", \"6 25 34\"],\
	\"cmyk\": [\"0 75 100 5\", \"98 100 0 43\", \"15 0 0 65\", \"0 43 100 0\", \"0 67 100 28\", \"0 0 0 29\", \"30 0 0 100\"],\
	\"pms\": [\"159\", \"275\", \"431\", \"137\", \"1675\", \"Cool Gray 5\", \"Black\"],\
	\"hex\": [\"e56020\", \"1d1160\", \"63717a\", \"f9a01b\", \"b95915\", \"bec0c2\", \"061922\"]\
	}\
	}, {\
	\"team\": \"Portland Trail Blazers\",\
	\"colors\": {\
	\"rgb\": [\"224 58 62\", \"186 195 201\", \"6 25 34\"],\
	\"cmyk\": [\"0 91 76 6\", \"5 0 0 25\", \"30 0 0 100\"],\
	\"pms\": [\"186\", \"877\", \"Black\"],\
	\"hex\": [\"e03a3e\", \"bac3c9\", \"061922\"]\
	}\
	}, {\
	\"team\": \"Sacramento Kings\",\
	\"colors\": {\
	\"rgb\": [\"114 76 159\", \"142 144 144\", \"6 25 34\"],\
	\"cmyk\": [\"65 82 0 0\", \"46 37 38 2\", \"30 0 0 100\"],\
	\"pms\": [\"266\", \"877\", \"Black\"],\
	\"hex\": [\"724c9f\", \"8e9090\", \"061922\"]\
	}\
	}, {\
	\"team\": \"San Antonio Spurs\",\
	\"colors\": {\
	\"rgb\": [\"186 195 201\", \"6 25 34\"],\
	\"cmyk\": [\"5 0 0 25\", \"30 0 0 100\"],\
	\"pms\": [\"877\", \"Black\"],\
	\"hex\": [\"bac3c9\", \"061922\"]\
	}\
	}, {\
	\"team\": \"Toronto Raptors\",\
	\"colors\": {\
	\"rgb\": [\"206 17 65\", \"6 25 34\", \"161 161 164\", \"180 151 90\"],\
	\"cmyk\": [\"0 100 65 15\", \"30 0 0 100\", \"0 1 0 43\", \"20 30 70 15\"],\
	\"pms\": [\"200\", \"Black\", \"Cool Gray 8\", \"872\"],\
	\"hex\": [\"ce1141\", \"061922\", \"a1a1a4\", \"b4975a\"]\
	}\
	}, {\
	\"team\": \"Utah Jazz\",\
	\"colors\": {\
	\"rgb\": [\"0 43 92\", \"249 160 27\", \"0 71 27\", \"190 192 194\"],\
	\"cmyk\": [\"100 64 0 60\", \"0 43 100 0\", \"80 0 90 75\", \"0 0 0 29\"],\
	\"pms\": [\"289\", \"137\", \"350\", \"Cool Gray 5\"],\
	\"hex\": [\"002b5c\", \"f9a01b\", \"00471b\", \"bec0c2\"]\
	}\
	}, {\
	\"team\": \"Washington Wizards\",\
	\"colors\": {\
	\"rgb\": [\"0 43 92\", \"227 24 55\", \"196 206 212\"],\
	\"cmyk\": [\"100 64 0 60\", \"0 100 81 4\", \"5 0 0 20\"],\
	\"pms\": [\"289\", \"186\", \"877\"],\
	\"hex\": [\"002b5c\", \"e31837\", \"c4ced4\"]\
	}\
	}],\
	\"nfl\": [{\
	\"team\": \"Arizona Cardinals\",\
	\"colors\": {\
	\"hex\": [\"97233F\", \"000000\", \"FFB612\", \"A5ACAF\"],\
	\"rgb\": [\"135 0 39\", \"0 0 0\", \"238 173 30\", \"155 161 162\"],\
	\"cmyk\": [\"0 100 60 30\", \"70 50 50 100\", \"0 25 100 0\", \"5 0 0 30\"],\
	\"pms\": [\"194 C\", \"Process Black C\", \"1235 C\", \"429 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_west.zip\"\
	}, {\
	\"team\": \"Atlanta Falcons\",\
	\"colors\": {\
	\"hex\": [\"A71930\", \"000000\", \"A5ACAF\"],\
	\"rgb\": [\"163 13 45\", \"0 0 0\", \"166 174 176\"],\
	\"cmyk\": [\"20 100 80 0\", \"70 50 50 100\", \"5 0 0 25\"],\
	\"pms\": [\"187 C\", \"Process Black C\", \"877 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_south.zip\"\
	}, {\
	\"team\": \"Baltimore Ravens\",\
	\"colors\": {\
	\"hex\": [\"241773\", \"000000\", \"9E7C0C\", \"C60C30\"],\
	\"rgb\": [\"26 25 95\", \"0 0 0\", \"187 147 52\", \"213 10 10\"],\
	\"cmyk\": [\"100 100 0 5\", \"70 50 50 100\", \"0 20 80 20\", \"10 100 100 0\"],\
	\"pms\": [\"273 C\", \"Process Black C\", \"8660 C Metallic\", \"186 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_north.zip\"\
	}, {\
	\"team\": \"Buffalo Bills\",\
	\"colors\": {\
	\"hex\": [\"00338D\", \"C60C30\"],\
	\"rgb\": [\"12 46 130\", \"213 10 10\"],\
	\"cmyk\": [\"100 60 0 20\", \"10 100 100 0\"],\
	\"pms\": [\"287 C\", \"186 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_east.zip\"\
	}, {\
	\"team\": \"Carolina Panthers\",\
	\"colors\": {\
	\"hex\": [\"0085CA\", \"000000\", \"BFC0BF\"],\
	\"rgb\": [\"0 133 202\", \"0 0 0\", \"191 192 191\"],\
	\"cmyk\": [\"100 10 0 5\", \"100 40 0 100\", \"0 0 0 20\"],\
	\"pms\": [\"Process Blue C\", \"Black 6 C\", \"421 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_south.zip\"\
	}, {\
	\"team\": \"Cincinnati Bengals\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"FB4F14\"],\
	\"rgb\": [\"0 0 0\", \"211 47 30\"],\
	\"cmyk\": [\"70 50 50 100\", \"0 85 100 0\"],\
	\"pms\": [\"Process Black C\", \"1655 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_north.zip\"\
	}, {\
	\"team\": \"Cleveland Browns\",\
	\"colors\": {\
	\"hex\": [\"FB4F14\", \"22150C\", \"A5ACAF\"],\
	\"rgb\": [\"211 47 30\", \"34 21 12\", \"155 161 162\"],\
	\"cmyk\": [\"0 75 100 0\", \"1 33 85 94\", \"5 0 0 30\"],\
	\"pms\": [\"1655 C\", \"NFL Cleveland Browns\", \"429 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_north.zip\"\
	}, {\
	\"team\": \"Dallas Cowboys\",\
	\"colors\": {\
	\"hex\": [\"002244\", \"B0B7BC\", \"ACC0C6\", \"A5ACAF\", \"00338D\", \"000000\"],\
	\"rgb\": [\"0 21 50\", \"176 183 188\", \"186 202 211\", \"155 161 162\", \"12 46 130\", \"0 0 0\"],\
	\"cmyk\": [\"100 65 0 60\", \"3 0 0 32\", \"10 0 0 20\", \"0 0 0 20\", \"100 60 0 20\", \"70 50 50 100\"],\
	\"pms\": [\"289 C\", \"8180 C Metallic\", \"8240 C\", \"429 C\", \"287 C\", \"Process Black\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_east.zip\"\
	}, {\
	\"team\": \"Chicago Bears\",\
	\"colors\": {\
	\"hex\": [\"0B162A\", \"C83803\"],\
	\"rgb\": [\"11 22 42\", \"200 56 3\"],\
	\"cmyk\": [\"100 60 0 80\", \"0 75 100 0\"],\
	\"pms\": [\"5395 C\", \"1665 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_north.zip\"\
	}, {\
	\"team\": \"Denver Broncos\",\
	\"colors\": {\
	\"hex\": [\"002244\", \"FB4F14\"],\
	\"rgb\": [\"0 35 76\", \"255 82 0\"],\
	\"cmyk\": [\"100 72 0 64\", \"0 82 100 0\"],\
	\"pms\": [\"289 C\", \"1655 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_west.zip\"\
	}, {\
	\"team\": \"Detroit Lions\",\
	\"colors\": {\
	\"hex\": [\"005A8B\", \"B0B7BC\", \"000000\"],\
	\"rgb\": [\"0 78 137\", \"176 183 188\", \"0 0 0\"],\
	\"cmyk\": [\"100 45 0 10\", \"3 0 0 32\", \"70 50 50 100\"],\
	\"pms\": [\"7462 C\", \"429\", \"Process Black C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_north.zip\"\
	}, {\
	\"team\": \"Green Bay Packers\",\
	\"colors\": {\
	\"hex\": [\"203731\", \"FFB612\"],\
	\"rgb\": [\"28 45 37\", \"238 173 30\"],\
	\"cmyk\": [\"70 40 60 60\", \"0 25 100 0\"],\
	\"pms\": [\"5535 C\", \"1235 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_north.zip\"\
	}, {\
	\"team\": \"Houston Texans\",\
	\"colors\": {\
	\"hex\": [\"03202F\", \"A71930\"],\
	\"rgb\": [\"0 7 28\", \"163 13 45\"],\
	\"cmyk\": [\"100 60 0 80\", \"0 100 79 20\"],\
	\"pms\": [\"5395 C\", \"187 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_south.zip\"\
	}, {\
	\"team\": \"Indianapolis Colts\",\
	\"colors\": {\
	\"hex\": [\"002C5F\", \"A5ACAF\"],\
	\"rgb\": [\"1 51 105\", \"155 161 162\"],\
	\"cmyk\": [\"100 65 0 35\", \"5 0 0 30\"],\
	\"pms\": [\"654 C\", \"429 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_south.zip\"\
	}, {\
	\"team\": \"Jacksonville Jaguars\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"006778\", \"9F792C\", \"D7A22A\"],\
	\"rgb\": [\"0 0 0\", \"0 101 118\", \"159 121 44\", \"215 162 42\"],\
	\"cmyk\": [\"70 50 50 100\", \"100 0 20 30\", \"34 48 100 13\", \"17 37 100 0\"],\
	\"pms\": [\"Process Black C\", \"3155 C\", \"126 C\", \"7555 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_south.zip\"\
	}, {\
	\"team\": \"Kansas City Chiefs\",\
	\"colors\": {\
	\"hex\": [\"E31837\", \"FFB612\", \"000000\"],\
	\"rgb\": [\"227 24 55\", \"238 173 30\", \"0 0 0\"],\
	\"cmyk\": [\"0 100 81 4\", \"0 25 100 0\", \"70 50 50 100\"],\
	\"pms\": [\"186 C\", \"1235 C\", \"Process Black C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_west.zip\"\
	}, {\
	\"team\": \"Miami Dolphins\",\
	\"colors\": {\
	\"hex\": [\"008E97\", \"F58220\", \"005778\"],\
	\"rgb\": [\"0 142 151\", \"245 130 32\", \"0 87 120\"],\
	\"cmyk\": [\"100 21 42 2\", \"0 60 100 0\", \"100 61 35 15\"],\
	\"pms\": [\"321 C\", \"151 C\", \"7701 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_east.zip\"\
	}, {\
	\"team\": \"Minnesota Vikings\",\
	\"colors\": {\
	\"hex\": [\"4F2683\", \"FFC62F\", \"E9BF9B\", \"000000\"],\
	\"rgb\": [\"79 38 131\", \"255 198 47\", \"233 191 155\", \"0 0 0\"],\
	\"cmyk\": [\"82 100 0 12\", \"0 23 91 0\", \"0 30 30 5\", \"70 50 50 100\"],\
	\"pms\": [\"268 C\", \"123 C\", \"720 C\", \"Process Black C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_north.zip\"\
	}, {\
	\"team\": \"New England Patriots\",\
	\"colors\": {\
	\"hex\": [\"002244\", \"C60C30\", \"B0B7BC\"],\
	\"rgb\": [\"0 21 50\", \"213 10 10\", \"176 183 188\"],\
	\"cmyk\": [\"100 65 0 60\", \"10 100 100 0\", \"3 0 0 32\"],\
	\"pms\": [\"289 C\", \"186 C\", \"429 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_east.zip\"\
	}, {\
	\"team\": \"New Orleans Saints\",\
	\"colors\": {\
	\"hex\": [\"9F8958\", \"000000\"],\
	\"rgb\": [\"159 137 88\", \"0 0 0\"],\
	\"cmyk\": [\"37 40 74 8\", \"70 50 50 100\"],\
	\"pms\": [\"8383 C Metallic\", \"Process Black C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_south.zip\"\
	}, {\
	\"team\": \"New York Giants\",\
	\"colors\": {\
	\"hex\": [\"0B2265\", \"A71930\", \"A5ACAF\"],\
	\"rgb\": [\"1 35 82\", \"163 13 45\", \"155 161 162\"],\
	\"cmyk\": [\"100 75 0 30\", \"20 100 80 0\", \"5 0 0 30\"],\
	\"pms\": [\"2758 C\", \"187 C\", \"429 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_east.zip\"\
	}, {\
	\"team\": \"New York Jets\",\
	\"colors\": {\
	\"hex\": [\"203731\"],\
	\"rgb\": [\"28 45 37\"],\
	\"cmyk\": [\"70 40 60 60\"],\
	\"pms\": [\"5535 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_east.zip\"\
	}, {\
	\"team\": \"Oakland Raiders\",\
	\"colors\": {\
	\"hex\": [\"A5ACAF\", \"000000\"],\
	\"rgb\": [\"166 174 176\", \"0 0 0\"],\
	\"cmyk\": [\"5 0 0 25\", \"70 50 50 100\"],\
	\"pms\": [\"429 C\", \"Process Black C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_west.zip\"\
	}, {\
	\"team\": \"Philadelphia Eagles\",\
	\"colors\": {\
	\"hex\": [\"004953\", \"A5ACAF\", \"ACC0C6\", \"000000\", \"565A5C\"],\
	\"rgb\": [\"0 49 53\", \"191 192 191\", \"186 202 211\", \"0 0 0\", \"95 96 98\"],\
	\"cmyk\": [\"100 0 30 70\", \"5 0 0 25\", \"10 0 0 20\", \"70 50 50 100\", \"0 0 0 80\"],\
	\"pms\": [\"316 C\", \"429 C\", \"8240 C Metallic\", \"Process Black C\", \"425 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_east.zip\"\
	}, {\
	\"team\": \"Pittsburgh Steelers\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"FFB612\", \"C60C30\", \"00539B\", \"A5ACAF\"],\
	\"rgb\": [\"0 0 0\", \"238 173 30\", \"213 10 10\", \"0 83 155\", \"155 161 162\"],\
	\"cmyk\": [\"70 50 50 100\", \"0 25 100 0\", \"10 100 100 0\", \"100 68 0 12\", \"5 0 0 30\"],\
	\"pms\": [\"Process Black C\", \"1235 C\", \"186 C\", \"287 C\", \"429 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_north.zip\"\
	}, {\
	\"team\": \"San Diego Chargers\",\
	\"colors\": {\
	\"hex\": [\"002244\", \"0073CF\", \"FFB612\"],\
	\"rgb\": [\"0 21 50\", \"0 128 197\", \"238 173 30\"],\
	\"cmyk\": [\"100 65 0 60\", \"90 40 0 0\", \"0 25 100 0\"],\
	\"pms\": [\"289 C\", \"285 C\", \"1235 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_west.zip\"\
	}, {\
	\"team\": \"San Francisco 49ers\",\
	\"colors\": {\
	\"hex\": [\"AA0000\", \"B3995D\", \"000000\", \"A5ACAF\"],\
	\"rgb\": [\"170 0 0\", \"175 146 93\", \"0 0 0\", \"155 161 162\"],\
	\"cmyk\": [\"0 100 59 26\", \"5 20 50 20\", \"70 50 50 100\", \"5 0 0 30\"],\
	\"pms\": [\"187C\", \"465 C\", \"Process Black C\", \"429 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_west.zip\"\
	}, {\
	\"team\": \"Seattle Seahawks\",\
	\"colors\": {\
	\"hex\": [\"002244\", \"69BE28\", \"A5ACAF\"],\
	\"rgb\": [\"0 21 50\", \"105 190 40\", \"155 161 162\"],\
	\"cmyk\": [\"100 65 0 60\", \"57 0 84 0\", \"5 0 0 30\"],\
	\"pms\": [\"289 C\", \"368 C\", \"429 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_west.zip\"\
	}, {\
	\"team\": \"St Louis Rams\",\
	\"colors\": {\
	\"hex\": [\"002244\", \"B3995D\"],\
	\"rgb\": [\"0 21 50\", \"175 146 93\"],\
	\"cmyk\": [\"100 65 0 60\", \"5 20 50 20\"],\
	\"pms\": [\"289 C\", \"465 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_west.zip\"\
	}, {\
	\"team\": \"Tampa Bay Buccaneers\",\
	\"colors\": {\
	\"hex\": [\"D50A0A\", \"34302B\", \"000000\", \"FF7900\", \"B1BABF\"],\
	\"rgb\": [\"213 10 10\", \"52 48 43\", \"0 0 0\", \"255 121 0\", \"177 186 191\"],\
	\"cmyk\": [\"10 100 100 0\", \"64 61 65 64\", \"70 50 50 100\", \"0 50 100 0\", \"5 0 0 30\"],\
	\"pms\": [\"186 C\", \"Black 7 C\", \"Process Black C\", \"151 C\", \"421 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_south.zip\"\
	}, {\
	\"team\": \"Tennessee Titans\",\
	\"colors\": {\
	\"hex\": [\"002244\", \"4B92DB\", \"C60C30\", \"A5ACAF\"],\
	\"rgb\": [\"0 21 50\", \"68 149 210\", \"213 10 10\", \"191 192 191\"],\
	\"cmyk\": [\"100 65 0 60\", \"70 30 0 0\", \"10 100 100 0\", \"5 0 0 25\"],\
	\"pms\": [\"289 C\", \"279 C\", \"186 C\", \"421 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/afc_south.zip\"\
	}, {\
	\"team\": \"Washington Redskins\",\
	\"colors\": {\
	\"hex\": [\"773141\", \"FFB612\", \"000000\", \"5B2B2F\"],\
	\"rgb\": [\"63 16 16\", \"238 173 30\", \"0 0 0\", \"91 43 47\"],\
	\"cmyk\": [\"20 100 60 30\", \"0 25 100 0\", \"70 50 50 100\", \"0 80 70 70\"],\
	\"pms\": [\"195 C\", \"1235 C\", \"Process Black C\", \"490 C\"]\
	},\
	\"src\": \"http://www.nflmedia.com/nfc_east.zip\"\
	}],\
	\"nhl\": [{\
	\"team\": \"Anaheim Ducks\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"91764B\", \"EF5225\"],\
	\"rgb\": [\"0 0 0\", \"145 118 75\", \"239 82 37\"]\
	}\
	}, {\
	\"team\": \"Arizona Coyotes\",\
	\"colors\": {\
	\"hex\": [\"841F27\", \"000000\", \"EFE1C6\"],\
	\"rgb\": [\"132 31 39\", \"0 0 0\", \"239 225 198\"]\
	}\
	}, {\
	\"team\": \"Boston Bruins\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"FFC422\"],\
	\"rgb\": [\"0 0 0\", \"255 196 34\"]\
	}\
	}, {\
	\"team\": \"Buffalo Sabres\",\
	\"colors\": {\
	\"hex\": [\"002E62\", \"FDBB2F\", \"AEB6B9\"],\
	\"rgb\": [\"0 46 98\", \"253 187 47\", \"174 182 185\"]\
	}\
	}, {\
	\"team\": \"Calgary Flames\",\
	\"colors\": {\
	\"hex\": [\"E03A3E\", \"FFC758\", \"000000\"],\
	\"rgb\": [\"224 58 62\", \"255 199 88\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"Carolina Hurricanes\",\
	\"colors\": {\
	\"hex\": [\"E03A3E\", \"000000\", \"8E8E90\"],\
	\"rgb\": [\"224 58 62\", \"0 0 0\", \"142 142 144\"]\
	}\
	}, {\
	\"team\": \"Chicago Blackhawks\",\
	\"colors\": {\
	\"hex\": [\"E3263A\", \"000000\"],\
	\"rgb\": [\"227 38 58\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"Colorado Avalanche\",\
	\"colors\": {\
	\"hex\": [\"8B2942\", \"01548A\", \"000000\", \"A9B0B8\"],\
	\"rgb\": [\"139 41 66\", \"1 84 138\", \"0 0 0\", \"169 176 184\"]\
	}\
	}, {\
	\"team\": \"Columbus Blue Jackets\",\
	\"colors\": {\
	\"hex\": [\"00285C\", \"E03A3E\", \"A9B0B8\"],\
	\"rgb\": [\"0 40 92\", \"224 58 62\", \"169 176 184\"]\
	}\
	}, {\
	\"team\": \"Dallas Stars\",\
	\"colors\": {\
	\"hex\": [\"006A4E\", \"000000\", \"C0C0C0\"],\
	\"rgb\": [\"0 106 78\", \"0 0 0\", \"192 192 192\"]\
	}\
	}, {\
	\"team\": \"Detroit Red Wings\",\
	\"colors\": {\
	\"hex\": [\"EC1F26\"],\
	\"rgb\": [\"236 31 38\"]\
	}\
	}, {\
	\"team\": \"Edmonton Oilers\",\
	\"colors\": {\
	\"hex\": [\"003777\", \"E66A20\"],\
	\"rgb\": [\"0 55 119\", \"230 106 32\"]\
	}\
	}, {\
	\"team\": \"Florida Panthers\",\
	\"colors\": {\
	\"hex\": [\"C8213F\", \"002E5F\", \"D59C05\"],\
	\"rgb\": [\"200 33 63\", \"0 46 95\", \"213 156 5\"]\
	}\
	}, {\
	\"team\": \"Los Angeles Kings\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"AFB7BA\"],\
	\"rgb\": [\"0 0 0\", \"175 183 186\"]\
	}\
	}, {\
	\"team\": \"Minnesota Wild\",\
	\"colors\": {\
	\"hex\": [\"025736\", \"BF2B37\", \"EFB410\", \"EEE3C7\"],\
	\"rgb\": [\"2 87 54\", \"191 43 55\", \"239 180 16\", \"238 227 199\"]\
	}\
	}, {\
	\"team\": \"Montreal Canadiens\",\
	\"colors\": {\
	\"hex\": [\"BF2F38\", \"213770\"],\
	\"rgb\": [\"191 47 56\", \"33 55 112\"]\
	}\
	}, {\
	\"team\": \"Nashville Predators\",\
	\"colors\": {\
	\"hex\": [\"FDBB2F\", \"002E62\"],\
	\"rgb\": [\"253 187 47\", \"0 46 98\"]\
	}\
	}, {\
	\"team\": \"New Jersey Devils\",\
	\"colors\": {\
	\"hex\": [\"E03A3E\", \"000000\"],\
	\"rgb\": [\"224 58 62\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"New York Islanders\",\
	\"colors\": {\
	\"hex\": [\"00529B\", \"F57D31\"],\
	\"rgb\": [\"0 82 155\", \"245 125 49\"]\
	}\
	}, {\
	\"team\": \"New York Rangers\",\
	\"colors\": {\
	\"hex\": [\"0161AB\", \"E6393F\"],\
	\"rgb\": [\"1 97 171\", \"230 57 63\"]\
	}\
	}, {\
	\"team\": \"Ottawa Senators\",\
	\"colors\": {\
	\"hex\": [\"E4173E\", \"000000\", \"D69F0F\"],\
	\"rgb\": [\"228 23 62\", \"0 0 0\", \"214 159 15\"]\
	}\
	}, {\
	\"team\": \"Philadelphia Flyers\",\
	\"colors\": {\
	\"hex\": [\"F47940\", \"000000\"],\
	\"rgb\": [\"244 121 64\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"Pittsburgh Penguins\",\
	\"colors\": {\
	\"hex\": [\"000000\", \"D1BD80\"],\
	\"rgb\": [\"0 0 0\", \"209 189 128\"]\
	}\
	}, {\
	\"team\": \"San Jose Sharks\",\
	\"colors\": {\
	\"hex\": [\"05535D\", \"F38F20\", \"000000\"],\
	\"rgb\": [\"5 83 93\", \"243 143 32\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"St Louis Blues\",\
	\"colors\": {\
	\"hex\": [\"0546A0\", \"FFC325\", \"101F48\"],\
	\"rgb\": [\"5 70 160\", \"255 195 37\", \"16 31 72\"]\
	}\
	}, {\
	\"team\": \"Tampa Bay Lightning\",\
	\"colors\": {\
	\"hex\": [\"013E7D\", \"000000\", \"C0C0C0\"],\
	\"rgb\": [\"1 62 125\", \"0 0 0\", \"192 192 192\"]\
	}\
	}, {\
	\"team\": \"Toronto Maple Leafs\",\
	\"colors\": {\
	\"hex\": [\"003777\"],\
	\"rgb\": [\"0 55 119\"]\
	}\
	}, {\
	\"team\": \"Vancouver Canucks\",\
	\"colors\": {\
	\"hex\": [\"07346F\", \"047A4A\", \"A8A9AD\"],\
	\"rgb\": [\"7 52 111\", \"4 122 74\", \"168 169 173\"]\
	}\
	}, {\
	\"team\": \"Washington Capitals\",\
	\"colors\": {\
	\"hex\": [\"CF132B\", \"00214E\", \"000000\"],\
	\"rgb\": [\"207 19 43\", \"0 33 78\", \"0 0 0\"]\
	}\
	}, {\
	\"team\": \"Winnipeg Jets\",\
	\"colors\": {\
	\"hex\": [\"002E62\", \"0168AB\", \"A8A9AD\"],\
	\"rgb\": [\"0 46 98\", \"1 104 171\", \"168 169 173\"]\
	}\
	}]\
	}";
	
	return sportsTeamJSON;
}

+ (void)logSportsTeamJSON {
	NSString *sportsJSON = [self sportsTeamsColorsJSON];
	NSError *error;
	NSDictionary *sportsDictionary = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[sportsJSON dataUsingEncoding:NSStringEncodingConversionAllowLossy] options:NSJSONReadingAllowFragments error:&error]];
	
	NSMutableString *finalOutputString = [[NSMutableString alloc] init];
	
	for (NSString *key in sportsDictionary.allKeys) {
		NSArray *leagueJSONArray = [sportsDictionary objectForKey:key];
		NSArray *leagueArray = [NSArray arrayWithArray:leagueJSONArray];
		
		[finalOutputString appendFormat:@"#pragma mark - %@\n\n", [key uppercaseString]];
		
		for (NSDictionary *teamObject in leagueArray) {
			NSDictionary *teamDictionary = [NSDictionary dictionaryWithDictionary:teamObject];
			
			NSString *teamName;
			NSString *shortenedTeamName;
			
			for (NSString *colorKey in teamDictionary.allKeys) {
				NSObject *colorObject = [teamDictionary objectForKey:colorKey];
				
				if ([[[colorObject class] description] isEqualToString:@"__NSCFString"]) {
					NSString *potentialTeamName = (NSString *)colorObject;
					
					if ([potentialTeamName rangeOfString:@".com"].location == NSNotFound) {
						teamName = (NSString *)colorObject;
						
						NSLog(@"Team Name: %@", colorObject);
						
						NSArray *words = [teamName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
						
						if (words.count > 0) {
							if ([[words lastObject] length] > 3) {
								shortenedTeamName = [words lastObject];
								
								if ([finalOutputString rangeOfString:shortenedTeamName].location != NSNotFound) {
									if (words.count > 1) {
										for (NSInteger i = words.count - 2; i >= 0; i--) {
											NSString *word = [words objectAtIndex:i];
											shortenedTeamName = [NSString stringWithFormat:@"%@%@", [word substringToIndex:1], shortenedTeamName];
										}
									}
								}
							}
							
							shortenedTeamName = [shortenedTeamName lowercaseString];
							
							if ([shortenedTeamName isEqualToString:teamName]) {
								shortenedTeamName = nil;
							}
						}
					}
					
					
				} else if ([[[colorObject class] description] isEqualToString:@"__NSCFDictionary"]) {
					NSDictionary *colorDictionary = [NSDictionary dictionaryWithDictionary:(NSDictionary *)colorObject];
					
					if ([colorDictionary objectForKey:@"hex"]) {
						NSArray *hexArray = [NSArray arrayWithArray:[colorDictionary objectForKey:@"hex"]];
						
						if (teamName) {
							
							NSInteger colorCount = 1;
							for (NSString *hexString in hexArray) {
								[finalOutputString appendFormat:@"\n+ (NKFColor *)%@%@ {\n\treturn [NKFColor colorWithHexString:@\"#%@\"];\n}\n", [[[teamName lowercaseString] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""], (colorCount > 1) ? [NSString stringWithFormat:@"%zd", colorCount] : @"", hexString];
								colorCount++;
							}
							
							if (shortenedTeamName) {
								colorCount = 1;
								for (int j = 0; j < hexArray.count; j++) {
									[finalOutputString appendFormat:@"\n+ (NKFColor *)%@%@ {\n\treturn [NKFColor %@%@];\n}\n", [[[shortenedTeamName lowercaseString] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""], (colorCount > 1) ? [NSString stringWithFormat:@"%zd", colorCount] : @"", [[[teamName lowercaseString] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""], (colorCount > 1) ? [NSString stringWithFormat:@"%zd", colorCount] : @""];
									colorCount++;
								}
							}
							
						} else {
							NSLog(@"No team name yet!");
						}
					} else {
						NSLog(@"No key for hex: %@", colorDictionary.allKeys);
					}
				}
			}
			
			[finalOutputString appendString:@"\n"];
		}
	}
	
	NSLog(@"+ (void)logSportsTeamJSON: %@", finalOutputString);
}

@end

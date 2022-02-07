local _, T = ...

T.RewardPrio = {
	-- Veiled Runes
	{"itemID", 181468},
	-- Gold
	{"title", "Money Reward"},
	-- XP Items, Epic, Rare, Uncommon
	{"itemID", 188657,},
	{"itemID", 188656,},
	{"itemID", 188655,},
	-- Pet Charms
	{"itemID", 163036,},
	-- Rare Korthia Anima Quest
	{"itemID", 187517},
	-- Rare Venthyr Anima (35)
	{"itemID", 181545}, {"itemID", 181546}, {"itemID", 181547}, {"itemID", 181548},
	{"itemID", 181550}, {"itemID", 184147}, {"itemID", 184150}, {"itemID", 184777},
	-- Rare Necrolord Anima (35)
	{"itemID", 181645}, {"itemID", 181647}, {"itemID", 181649},
	{"itemID", 184305}, {"itemID", 184772}, {"itemID", 184773},
	{"itemID", 184774}, {"itemID", 184775}, {"itemID", 184776},
	-- Rare Night Fae Anima (35)
	{"itemID", 181477}, {"itemID", 181479}, {"itemID", 181541},
	{"itemID", 184378}, {"itemID", 184381}, {"itemID", 184382},
	{"itemID", 184383}, {"itemID", 184384}, {"itemID", 184519},
	-- Rare Kyrian Anima (35)
	{"itemID", 181368}, {"itemID", 181377}, {"itemID", 181745}, {"itemID", 184294},
	{"itemID", 184362}, {"itemID", 184363}, {"itemID", 184765}, {"itemID", 184766},
	{"itemID", 184767}, {"itemID", 184768},
	-- Uncommon Venthyr Anima (5)
	{"itemID", 181544}, {"itemID", 181551}, {"itemID", 184146},
	{"itemID", 184148}, {"itemID", 184151}, {"itemID", 184152},
	-- Uncommon Necrolord Anima (5)
	{"itemID", 181642}, {"itemID", 181643}, {"itemID", 181644},
	{"itemID", 184306}, {"itemID", 184307},
	-- Uncommon Night Fae Anima (5)
	{"itemID", 181540}, {"itemID", 184385}, {"itemID", 184386},
	{"itemID", 184387}, {"itemID", 184388}, {"itemID", 184389},
	-- Uncommon Kyrian Anima (5)
	{"itemID", 181744}, {"itemID", 184293}, {"itemID", 184360},
	{"itemID", 184769}, {"itemID", 184770}, {"itemID", 184771},
}

T.Covs = {
	[1] = { -- Kyrian
		FollowerPrio = {
			{1269, "Ispiron"},
			{1268, "Molako"},
			{1274, "Disciple Kosmas"},
			{1267, "Hala"},
			{1273, "Clora"},
			{1272, "Sika"},
			{1223, "Telethakas"},
			{1222, "Kythekios"},
			{1325, "Croman"},
			{1221, "Teliah"},
			{1341, "Hermestes"},
			{1329, "Kiaranyka"},
			{1276, "Apolon"},
			{1270, "Nemea"},
			{1271, "Pelodis"},
			{1275, "Bron"},
			{1257, "Meatball"},
			{1342, "Cromas the Mystic"},
			{1259, "Pelagos"},
			{1328, "ELGU-007"},
			{1260, "Kleia"},
			{1343, "Auric Spiritguide"},
			{1258, "Mikanikos"},
			{1342, "Cromas the Mystic"},
		},
		TroopIDs = {
			1320, -- Kyrian Phalanx
			1319, -- Kyrian Halberdier
		}
	},
	[2] = { -- Necrolord
		FollowerPrio = {
			{1305, "Rathan"},
			{1308, "Velkein"},
			{1311, "Ashraka"},
			{1325, "Croman"},
			{1303, "Khaliiq"},
			{1300, "Secutor Mevix"},
			{1309, "Assembler Xertora"},
			{1301, "Gunn Gorgebone"},
			{1302, "Rencissa the Dynamo"},
			{1307, "Talethi"},
			{1306, "Gorgelimb"},
			{1331, "Kinessa the Absorbent"},
			{1257, "Meatball"},
			{1310, "Rattlebag"},
			{1335, "Enceladus"},
			{1330, "Ryuja Shockfist"},
			{1261, "Plague Deviser Marileth"},
			{1262, "Bonesmith Heirmir"},
			{1334, "Lyra Hailstorm"},
			{1263, "Emeni"},
			{1336, "Deathfang"},
			{1304, "Plaguey"},
		},
		TroopIDs = {
			0, -- Maldraxxus Plaguesinger
			0, -- Maldraxxus Shock Trooper
		}
	},
	[3] = { -- Night Fae
		FollowerPrio = {
			-- {garrFollowerID, name}
			{1287, "Watcher Vesperbloom"},
			{1282, "Yira'lya"},
			{1284, "Master Sha'lor"},
			{1286, "Qadarin"},
			{1288, "Groonoomcrooek"},
			{1279, "Karynmwylyann"},
			{1277, "Blisswing"},
			{1278, "Duskleaf"},
			{1326, "Spore of Marasmius"},
			{1280, "Chalkyth"},
			{1266, "Hunt-Captain Korayn"},
			{1283, "Guardian Kota"},
			{1265, "Niya"},
			{1325, "Croman"},
			{1257, "Meatball"},
			{1281, "Lloth'wellyn"},
			{1338, "Elwyn"},
			{1327, "Ella"},
			{1264, "Dreamweaver"},
			{1339, "Yanlar"},
			{1285, "Te'zan"},
			{1337, "Sulanoom"},
		},
		TroopIDs = {
			1316, -- Ardenweald Grovetender
			1318, -- Ardenweald Trapper
		}
	},
	[4] = { -- Venthyr
		FollowerPrio = {
			-- {garrFollowerID, name}
			{1255, "Vulca"},
			{1213, "Thela Soulsipper"},
			{1253, "Bogdan"},
			{1325, "Croman"},
			{1333, "Lassik Spinebender"},
			{1214, "Dug Gravewell"},
			{1252, "Simone"},
			{1251, "Stonehead"},
			{1217, "Kaletar"},
			{1332, "Steadyhands"},
			{1347, "Lucia"},
			{1208, "Nadjia the Mistblade"},
			{1215, "Nerith Darkwing"},
			{1254, "Lost Sybille"},
			{1250, "Rahel"},
			{1257, "Meatball"},
			{1346, "Madame Iza"},
			{1209, "General Draven"},
			{1220, "Ayeleth"},
			{1210, "Theotar"},
			{1216, "Stonehuck"},
			{1345, "Chachi the Artiste"},
		},
		TroopIDs = {
			0, -- Venthyr Soulcaster
			0, -- Venthyr Nightblade
		}
	}
}

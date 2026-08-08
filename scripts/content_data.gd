class_name ContentData
extends RefCounted


const LANGUAGES := {
	"ar": {
		"name": "العربية", "english_name": "Arabic", "locale": "ar-SA",
		"font": "res://assets/fonts/NotoSansArabic-Variable.ttf",
		"accent": "#ff5994", "sample": "ا ب ت ث", "rtl": true
	},
	"ru": {
		"name": "Русский", "english_name": "Russian", "locale": "ru-RU",
		"font": "res://assets/fonts/NotoSans-Variable.ttf",
		"accent": "#82b6ff", "sample": "А Б В Г", "rtl": false
	},
	"sa": {
		"name": "संस्कृतम्", "english_name": "Sanskrit", "locale": "hi-IN",
		"font": "res://assets/fonts/NotoSansDevanagari-Variable.ttf",
		"accent": "#ff9668", "sample": "अ आ इ ई", "rtl": false
	},
	"la": {
		"name": "Latina", "english_name": "Latin", "locale": "it-IT",
		"font": "res://assets/fonts/NotoSans-Variable.ttf",
		"accent": "#84ff9f", "sample": "A B C D", "rtl": false
	}
}

const ARABIC := [
	["ا", "أَسَد", "a-sad", "lion", "🦁"],
	["ب", "بَيْت", "bayt", "house", "🏠"],
	["ت", "تُفّاح", "toof-faah", "apple", "🍎"],
	["ث", "ثَلْج", "thalj", "snow", "❄️"],
	["ج", "جَمَل", "ja-mal", "camel", "🐪"],
	["ح", "حَليب", "ha-leeb", "milk", "🥛"],
	["خ", "خُبْز", "khoobz", "bread", "🍞"],
	["د", "دُبّ", "doobb", "bear", "🐻"],
	["ذ", "ذَهَب", "dha-hab", "gold", "🪙"],
	["ر", "رَجُل", "ra-jool", "man", "👨"],
	["ز", "زَهْرَة", "zah-ra", "flower", "🌸"],
	["س", "سَمَك", "sa-mak", "fish", "🐟"],
	["ش", "شَمْس", "shams", "sun", "☀️"],
	["ص", "صابُون", "saa-boon", "soap", "🧼"],
	["ض", "ضِفْدَع", "dif-da", "frog", "🐸"],
	["ط", "طائِرَة", "taa-i-ra", "airplane", "✈️"],
	["ظ", "ظِلّ", "dhill", "shadow", "👤"],
	["ع", "عَيْن", "ayn", "eye", "👁️"],
	["غ", "غُرْفَة", "ghoor-fa", "room", "🛏️"],
	["ف", "فيل", "feel", "elephant", "🐘"],
	["ق", "قَلَم", "qa-lam", "pen", "🖊️"],
	["ك", "كِتاب", "ki-taab", "book", "📘"],
	["ل", "لَيْمون", "lay-moon", "lemon", "🍋"],
	["م", "ماء", "maa", "water", "💧"],
	["ن", "نار", "naar", "fire", "🔥"],
	["ه", "هِلال", "hi-laal", "crescent moon", "🌙"],
	["و", "وَرْد", "ward", "rose", "🌹"],
	["ي", "يَد", "yad", "hand", "✋"]
]

const RUSSIAN := [
	["А а", "арбуз", "ar-BOOZ", "watermelon", "🍉"],
	["Б б", "банан", "ba-NAN", "banana", "🍌"],
	["В в", "вода", "va-DA", "water", "💧"],
	["Г г", "глаз", "glahs", "eye", "👁️"],
	["Д д", "дом", "dom", "house", "🏠"],
	["Е е", "еда", "yi-DA", "food", "🍲"],
	["Ё ё", "ёлка", "YOL-ka", "fir tree", "🎄"],
	["Ж ж", "жук", "zhook", "beetle", "🪲"],
	["З з", "зуб", "zoop", "tooth", "🦷"],
	["И и", "игра", "ee-GRA", "game", "🎲"],
	["Й й", "йод", "yot", "iodine", "🧴"],
	["К к", "кот", "kot", "cat", "🐈"],
	["Л л", "лимон", "lee-MON", "lemon", "🍋"],
	["М м", "мама", "MA-ma", "mum", "👩"],
	["Н н", "нос", "nohs", "nose", "👃"],
	["О о", "окно", "ak-NO", "window", "🪟"],
	["П п", "папа", "PA-pa", "dad", "👨"],
	["Р р", "рыба", "RY-ba", "fish", "🐟"],
	["С с", "сок", "sok", "juice", "🧃"],
	["Т т", "торт", "tort", "cake", "🎂"],
	["У у", "утка", "OOT-ka", "duck", "🦆"],
	["Ф ф", "фото", "FO-ta", "photo", "📷"],
	["Х х", "хлеб", "khlyeb", "bread", "🍞"],
	["Ц ц", "цирк", "tseerk", "circus", "🎪"],
	["Ч ч", "чай", "chai", "tea", "🍵"],
	["Ш ш", "шар", "shar", "ball", "⚽"],
	["Щ щ", "щётка", "SHCHYOT-ka", "brush", "🪥"],
	["Ъ ъ", "объект", "ab-YEKT", "object", "📦"],
	["Ы ы", "сыр", "syr", "cheese", "🧀"],
	["Ь ь", "соль", "sol'", "salt", "🧂"],
	["Э э", "это", "EH-ta", "this", "👉"],
	["Ю ю", "юбка", "YOOB-ka", "skirt", "👗"],
	["Я я", "яблоко", "YA-bla-ka", "apple", "🍎"]
]

const SANSKRIT := [
	["अ", "अग्नि", "ag-nee", "fire", "🔥"],
	["आ", "आनन्द", "aa-nand", "joy", "😊"],
	["इ", "इति", "i-ti", "thus / so", "➡️"],
	["ई", "ईश्वर", "ee-shva-ra", "lord / God", "🪷"],
	["उ", "उदक", "oo-da-ka", "water", "💧"],
	["ऊ", "ऊर्णा", "oor-naa", "wool", "🧶"],
	["ऋ", "ऋषि", "ri-shi", "sage", "🧘"],
	["ॠ", "", "long ri", "rare; learn sound first", "🎵"],
	["ऌ", "", "li", "very rare; learn sound first", "🎵"],
	["ॡ", "", "long li", "extremely rare", "🎵"],
	["ए", "एक", "ay-ka", "one", "1️⃣"],
	["ऐ", "ऐक्य", "ai-kya", "unity", "🤝"],
	["ओ", "ओषधि", "oh-sha-dhi", "herb", "🌿"],
	["औ", "औषध", "au-sha-dha", "medicine", "💊"],
	["क", "कमल", "ka-ma-la", "lotus", "🪷"],
	["ख", "खग", "kha-ga", "bird", "🐦"],
	["ग", "गज", "ga-ja", "elephant", "🐘"],
	["घ", "घट", "gha-ta", "pot", "🏺"],
	["ङ", "अङ्ग", "ang-ga", "limb / body part", "💪"],
	["च", "चन्द्र", "chan-dra", "moon", "🌙"],
	["छ", "छत्र", "chha-tra", "umbrella / parasol", "☂️"],
	["ज", "जल", "ja-la", "water", "💧"],
	["झ", "झष", "jha-sha", "fish", "🐟"],
	["ञ", "पञ्च", "pan-cha", "five", "5️⃣"],
	["ट", "टङ्क", "tung-ka", "chisel", "🛠️"],
	["ठ", "पठति", "pa-tha-ti", "reads", "📖"],
	["ड", "डमरु", "da-ma-roo", "small drum", "🥁"],
	["ढ", "ढक्का", "dhak-kaa", "large drum", "🪘"],
	["ण", "गुण", "goo-na", "quality", "⭐"],
	["त", "तरु", "ta-roo", "tree", "🌳"],
	["थ", "रथ", "ra-tha", "chariot", "🛺"],
	["द", "दन्त", "dan-ta", "tooth", "🦷"],
	["ध", "धन", "dha-na", "wealth", "🪙"],
	["न", "नदी", "na-dee", "river", "🏞️"],
	["प", "पद", "pa-da", "foot / word", "🦶"],
	["फ", "फल", "pha-la", "fruit", "🍎"],
	["ब", "बाल", "baa-la", "child", "🧒"],
	["भ", "भूमि", "bhoo-mi", "earth / land", "🌍"],
	["म", "माता", "maa-taa", "mother", "👩"],
	["य", "योग", "yo-ga", "yoga / union", "🧘"],
	["र", "रथ", "ra-tha", "chariot", "🛺"],
	["ल", "लता", "la-taa", "vine", "🌿"],
	["व", "वन", "va-na", "forest", "🌲"],
	["श", "शश", "sha-sha", "rabbit", "🐇"],
	["ष", "षट्", "shat", "six", "6️⃣"],
	["स", "सूर्य", "soor-ya", "sun", "☀️"],
	["ह", "हस्त", "has-ta", "hand", "✋"]
]

const LATIN := [
	["A", "aqua", "AH-kwa", "water", "💧"],
	["B", "bonus", "BOH-noos", "good", "👍"],
	["C", "canis", "KA-nis", "dog", "🐕"],
	["D", "domus", "DOH-moos", "house", "🏠"],
	["E", "ego", "EH-go", "I / me", "🙋"],
	["F", "filius", "FEE-lee-oos", "son", "👦"],
	["G", "gallina", "gal-LEE-na", "hen", "🐔"],
	["H", "homo", "HOH-mo", "person / human", "🧑"],
	["I", "insula", "IN-soo-la", "island", "🏝️"],
	["K", "Kalendae", "ka-LEN-dai", "first day of the month", "📅"],
	["L", "luna", "LOO-na", "moon", "🌙"],
	["M", "mater", "MAH-ter", "mother", "👩"],
	["N", "nomen", "NOH-men", "name", "🏷️"],
	["O", "oculus", "OH-koo-loos", "eye", "👁️"],
	["P", "pater", "PAH-ter", "father", "👨"],
	["Q", "quattuor", "KWAT-too-or", "four", "4️⃣"],
	["R", "rosa", "ROH-sa", "rose", "🌹"],
	["S", "sol", "sohl", "sun", "☀️"],
	["T", "terra", "TER-ra", "earth / land", "🌍"],
	["V", "vita", "WEE-ta", "life", "🌱"],
	["X", "xystus", "KSOOS-toos", "garden walk", "🌳"],
	["Y", "ypsilon", "OOP-see-lon", "the letter upsilon", "🔤"],
	["Z", "zona", "ZOH-na", "belt / zone", "⭕"]
]

const CONTENT := {
	"ar": ARABIC,
	"ru": RUSSIAN,
	"sa": SANSKRIT,
	"la": LATIN
}


static func language(code: String) -> Dictionary:
	return LANGUAGES.get(code, {})


static func entries(code: String, include_sound_only := true) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var rows: Array = CONTENT.get(code, [])
	for index in range(rows.size()):
		var row: Array = rows[index]
		if not include_sound_only and str(row[1]).is_empty():
			continue
		result.append({
			"index": index,
			"letter": str(row[0]),
			"word": str(row[1]),
			"say": str(row[2]),
			"english": str(row[3]),
			"emoji": str(row[4]),
			"language": code,
			"letter_audio": "res://assets/audio/alphabets/%s/%02d.mp3" % [code, index + 1],
			"word_audio": "res://assets/audio/words/%s/%02d.mp3" % [code, index + 1]
		})
	return result


static func font_for(code: String) -> Font:
	var path := str(language(code).get("font", LANGUAGES["la"]["font"]))
	return load(path) as Font


static func base_letter(text: String) -> String:
	if text.is_empty():
		return ""
	return text.substr(0, 1)


static func letter_audio_for_piece(language_code: String, piece: String) -> String:
	if language_code == "sa" and is_sanskrit_vowel_sign(piece):
		return "res://assets/audio/pieces/sa/matra_%s.mp3" % _codepoint_key(piece)
	var wanted := _normalized_letter(base_letter(piece))
	for entry in entries(language_code, true):
		var candidate := _normalized_letter(base_letter(str(entry["letter"])))
		if candidate == wanted:
			return str(entry["letter_audio"])
	return ""


static func _normalized_letter(letter: String) -> String:
	var normalized := letter.to_lower()
	if normalized in ["أ", "إ", "آ", "ٱ"]:
		return "ا"
	return normalized


static func build_pieces(word: String, language_code := "") -> Array[String]:
	if language_code == "sa":
		return _sanskrit_spelling_pieces(word)
	var clusters: Array[String] = _unicode_clusters(word)
	# Russian and Arabic spelling practice is deliberately letter-by-letter.
	# Arabic harakat remain attached to their base letter, but adjacent Arabic
	# letters must never be bundled into one draggable tile.
	if language_code in ["ru", "ar"]:
		return clusters
	if clusters.size() <= 4:
		return clusters
	var piece_count := 3 if clusters.size() <= 9 else 4
	var result: Array[String] = []
	for piece_index in range(piece_count):
		var start := int(floor(float(piece_index * clusters.size()) / float(piece_count)))
		var finish := int(floor(float((piece_index + 1) * clusters.size()) / float(piece_count)))
		var piece := ""
		for cluster_index in range(start, finish):
			piece += clusters[cluster_index]
		result.append(piece)
	return result


static func _sanskrit_spelling_pieces(word: String) -> Array[String]:
	var result: Array[String] = []
	for character in word:
		var codepoint := character.unicode_at(0)
		# A virama belongs to its consonant (क्), while a vowel sign is a
		# separate learning piece (क + ा). Other combining signs stay attached
		# so they are not rendered as unsupported stand-alone marks.
		if codepoint == 0x094d and not result.is_empty():
			result[result.size() - 1] += character
		elif _is_sanskrit_vowel_sign_codepoint(codepoint):
			result.append(character)
		elif (
			(codepoint >= 0x093a and codepoint <= 0x0957)
			or (codepoint >= 0x0962 and codepoint <= 0x0963)
		) and not result.is_empty():
			result[result.size() - 1] += character
		else:
			result.append(character)
	return result


static func is_sanskrit_vowel_sign(piece: String) -> bool:
	return piece.length() == 1 and _is_sanskrit_vowel_sign_codepoint(piece.unicode_at(0))


static func _is_sanskrit_vowel_sign_codepoint(codepoint: int) -> bool:
	return (codepoint >= 0x093e and codepoint <= 0x094c) or codepoint in [0x0962, 0x0963]


static func sanskrit_vowel_sign_name(piece: String) -> String:
	var names := {
		0x093e: "आकार", 0x093f: "इकार", 0x0940: "ईकार",
		0x0941: "उकार", 0x0942: "ऊकार", 0x0943: "ऋकार",
		0x0944: "ॠकार", 0x0947: "एकार", 0x0948: "ऐकार",
		0x094b: "ओकार", 0x094c: "औकार", 0x0962: "ऌकार",
		0x0963: "ॡकार",
	}
	return str(names.get(piece.unicode_at(0), piece)) if not piece.is_empty() else piece


static func sanskrit_combined_syllable(base_piece: String, vowel_sign: String) -> String:
	if base_piece.is_empty() or not is_sanskrit_vowel_sign(vowel_sign):
		return ""
	if base_piece.unicode_at(base_piece.length() - 1) == 0x094d:
		return ""
	return base_piece + vowel_sign


static func sanskrit_combination_audio(syllable: String) -> String:
	if syllable.is_empty():
		return ""
	return "res://assets/audio/pieces/sa/combo_%s.mp3" % _codepoint_key(syllable)


static func _codepoint_key(text: String) -> String:
	var parts: Array[String] = []
	for character in text:
		parts.append("%04x" % character.unicode_at(0))
	return "_".join(parts)


static func _unicode_clusters(text: String) -> Array[String]:
	var result: Array[String] = []
	var join_next := false
	for character in text:
		var codepoint := character.unicode_at(0)
		var combining := (
			(codepoint >= 0x0300 and codepoint <= 0x036f)
			or (codepoint >= 0x064b and codepoint <= 0x0670)
			or (codepoint >= 0x093a and codepoint <= 0x094d)
			or (codepoint >= 0x0951 and codepoint <= 0x0957)
			or (codepoint >= 0x0962 and codepoint <= 0x0963)
			or codepoint == 0x200c or codepoint == 0x200d
		)
		if result.is_empty() or (not combining and not join_next):
			result.append(character)
		else:
			result[result.size() - 1] += character
		join_next = codepoint == 0x094d or codepoint == 0x200d
	return result

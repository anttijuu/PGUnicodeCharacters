//
//  String+Extensions.swift
//  PGUnicodeCharacters
//
//  Created by Antti Juustila on 27.5.2025.
//

extension String {
	func escape() -> String {
		let characters = [
			"&amp;": "&",
			"&lt;": "<",
			"&gt;": ">",
			"&#34;": "\"", // &quot;
			"&apos;": "'" // &#39;
		]
		var str = self
		for (escaped, unescaped) in characters {
			str = str.replacingOccurrences(of: unescaped, with: escaped)
		}
		return str
	}
	
	// Modified from https://stackoverflow.com/a/52016010/10557366
	func rightJustified(width: Int, fillChar: String = " ", truncate: Bool = false) -> String {
		guard width > count else {
			return truncate ? String(suffix(width)) : self
		}
		return String(repeating: fillChar, count: width - count) + self
	}
	
	func leftJustified(width: Int, fillChar: String = " ", truncate: Bool = false) -> String {
		guard width > count else {
			return truncate ? String(prefix(width)) : self
		}
		return self + String(repeating: fillChar, count: width - count)
	}
	
}


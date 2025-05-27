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
				"&quot;": "\"",
				"&apos;": "'"
		  ]
		  var str = self
		  for (escaped, unescaped) in characters {
				str = str.replacingOccurrences(of: unescaped, with: escaped)
		  }
		  return str
	 }
}


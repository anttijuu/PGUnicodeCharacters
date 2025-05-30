// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

@available(macOS 15.0, *)
@main
struct PGUnicodeCharacters: AsyncParsableCommand {
	
	@Argument(help: "Directory where the PG books are.")
	private var books: String
	
	@Argument(help: "Output file with path and file extension.")
	private var output: String
	
	enum Format: String, ExpressibleByArgument {
		case html
		case text
	}
	
	@Option(help: "Output file format, either html or text.")
	var format: Format = .text
	
	enum Order: String, ExpressibleByArgument {
		case charsAscending
		case countDescending
	}
	
	@Option(help: "Either charsAscending or countDescending; prints results by chars ascending or count descending")
	var order: Order = .countDescending
	
	enum Normalization: String, ExpressibleByArgument {
		case none
		case formC
		case formD
		case formKC
		case formKD
	}
	
	@Option(help: "String normalization options (none, formC, formD, formKC, formKD)")
	var normalize: Normalization = .none
	
	mutating func run() async throws {
		do {
			try await process()
		} catch {
			print("Failed, due to: \(error.localizedDescription)")
		}
	}
	
	mutating func process() async throws {
		
		let fileManager = FileManager.default
		if !books.hasSuffix("/") {
			books.append("/")
		}
		switch format {
		case .html:
			if !output.hasSuffix(".html") {
				output.append(".html")
			}
		case .text:
			if !output.hasSuffix(".txt") {
				output.append(".txt")
			}
		}
		print(Date.now.formatted(date: .abbreviated, time: .complete))
		print("Starting to process files in \(books)...")
		
		var codePointsUsage: [Character: Int] = [:]
		let start = Date.now
		var fileCount = 0
		do {
			
			let booksDirectory = books
			let selectedNormalization = normalize
			
			try await withThrowingTaskGroup(of: [Character: Int].self) { group in
				
				if let enumerator = fileManager.enumerator(atPath: books) {
					while let file = enumerator.nextObject() as? String {
						if file.hasSuffix(".txt") {
							// print(".", terminator: "")
							fileCount += 1
							group.addTask { () -> [Character: Int] in
								var taskCodePoints: [Character: Int] = [:]
								let fullPath = booksDirectory + file
								let fileContents =
								switch selectedNormalization {
								case .none:
									try String(contentsOf: URL(fileURLWithPath: fullPath), encoding: .utf8)
								case .formC:
									try String(contentsOf: URL(fileURLWithPath: fullPath), encoding: .utf8).precomposedStringWithCanonicalMapping
								case .formD:
									try String(contentsOf: URL(fileURLWithPath: fullPath), encoding: .utf8).decomposedStringWithCanonicalMapping
								case .formKC:
									try String(contentsOf: URL(fileURLWithPath: fullPath), encoding: .utf8).precomposedStringWithCompatibilityMapping
								case .formKD:
									try String(contentsOf: URL(fileURLWithPath: fullPath), encoding: .utf8).decomposedStringWithCompatibilityMapping
								}
								for character in fileContents {
									taskCodePoints[character, default: 0] += 1
								}
								return taskCodePoints
							}
						}
					}
					
					for try await partial in group {
						for (key, value) in partial {
							codePointsUsage[key, default: 0] += value
						}
					}
				}
			}
		} catch {
			print("\nError reading files: \(error), cancelling.")
			return
		}
		print("")
		print("Handled \(fileCount) files.") // Print empty line after not printing line ends in progress.
		switch order {
		case .charsAscending:
			print("Sorting chars in ascending order")
		case .countDescending:
			print("Sorting chars in descending order by count of usage")
		}
		let sortedByCount = if order == .charsAscending {
			codePointsUsage.sorted{ $0.key < $1.key }
		} else {
			codePointsUsage.sorted{ $0.value > $1.value }
		}
		print("Collected \(codePointsUsage.count) unique codepoints")
		let secsTaken = Int(Date.now.timeIntervalSince(start))
		print("Time taken: \(secsTaken) seconds")
		print("Opening the file \(output) for writing results...")
		let fileURL = URL(fileURLWithPath: output)
		try "".data(using: .utf8)!.write(to: fileURL)
		let fileHandle = try FileHandle(forWritingTo: fileURL)
		defer {
			try! fileHandle.close()
		}
		try fileHandle.truncate(atOffset: 0)
		try writeHeader(to: fileHandle, statsFrom: codePointsUsage, secsTaken: secsTaken, fileCount: fileCount)
		for (char, count) in sortedByCount {
			switch format {
			case .html:
				try fileHandle.write(contentsOf: "<tr><td>\(asString(char))</td><td>\(uniCodeScalars(char))</td><td>\(count.formatted())</td></tr>\n".data(using: .utf8)!)
			case .text:
				let str = String(format: "%@ %@ %@\n", asString(char), String(count).rightJustified(width: 14), uniCodeScalars(char))
				try fileHandle.write(contentsOf: str.data(using: .utf8)!)
			}
		}
		try writeFooter(to: fileHandle, with: format)
		print("See results from \(output)")
	}
	
	func writeHeader(
		to file: FileHandle,
		statsFrom: [Character: Int],
		secsTaken: Int,
		fileCount: Int
	) throws {
		let charsInTotal = statsFrom.reduce(into: 0) { $0 += $1.value }
		switch format {
		case .html:
			try file.write(contentsOf: "<!DOCTYPE html>\n".data(using: .utf8)!)
			try file.write(contentsOf: "<head><meta charset=\"utf-8\">\n".data(using: .utf8)!)
			try file.write(contentsOf: "<title>Unicode characters in files</title></head>\n".data(using: .utf8)!)
			try file.write(contentsOf: "<body><p>Generated \(Date.now.formatted(.iso8601)) in \(secsTaken) seconds.<br/>\n".data(using: .utf8)!)
			try file.write(contentsOf: "\(statsFrom.count.formatted()) unique characters in dataset.<br/>\n".data(using: .utf8)!)
			try file.write(contentsOf: "\(charsInTotal.formatted()) characters in total.<br/>\n".data(using: .utf8)!)
			try file.write(contentsOf: "From \(fileCount.formatted()) files.<br/>\n".data(using: .utf8)!)
			try file.write(contentsOf: "Unicode normalization used: \(normalize)<br/></p>\n".data(using: .utf8)!)
			try file.write(contentsOf: "<table><tr><th>Character</th><th>Unicode scalars</th><th>Count</th></tr>\n".data(using: .utf8)!)
		case .text:
			try file.write(contentsOf: "Generated \(Date.now.formatted(.iso8601)) in \(secsTaken) seconds.\n".data(using: .utf8)!)
			try file.write(contentsOf: "\(statsFrom.count.formatted()) unique characters in dataset.\n".data(using: .utf8)!)
			try file.write(contentsOf: "\(charsInTotal.formatted()) characters in total.\n".data(using: .utf8)!)
			try file.write(contentsOf: "From \(fileCount.formatted()) files.\n".data(using: .utf8)!)
			try file.write(contentsOf: "Unicode normalization used: \(normalize)\n\n".data(using: .utf8)!)
			try file.write(contentsOf: "Char            Count Unicode scalars\n".data(using: .utf8)!)
		}
	}
	
	func writeFooter(to file: FileHandle, with format: Format) throws {
		switch format {
		case .html:
			try file.write(contentsOf: "</table></body></html>\n".data(using: .utf8)!)
		case .text:
			try file.write(contentsOf: "\n".data(using: .utf8)!)
		}
	}
	
	fileprivate
	func asString(_ character: Character) -> String {
		let length = 6
		if !character.isWhitespace &&
				character.isLetter ||
				character.isNumber ||
				character.isCurrencySymbol ||
				character.isPunctuation ||
				character.isSymbol ||
				character.isMathSymbol {
			return String(character).padding(toLength: length, withPad: " ", startingAt: 0)
		} else if character.isWhitespace {
			if character == "\t" {
				return "TAB".padding(toLength: length, withPad: " ", startingAt: 0)
			} else if character == " " {
				return "SPACE".padding(toLength: length, withPad: " ", startingAt: 0)
			} else if character == "\r\n" {
				return "CRLF".padding(toLength: length, withPad: " ", startingAt: 0)
			} else if character == "\r" {
				return "CR".padding(toLength: length, withPad: " ", startingAt: 0)
			} else if character == "\n" {
				return "LF".padding(toLength: length, withPad: " ", startingAt: 0)
			} else {
				return "WS ".padding(toLength: length, withPad: " ", startingAt: 0)
			}
		} else {
			switch character.unicodeScalars.first?.properties.generalCategory {
			case .none:
				return "???".padding(toLength: length, withPad: " ", startingAt: 0)
			case .some( let caseValue ):
				switch caseValue {
				case .control:
					return "CTRL".padding(toLength: length, withPad: " ", startingAt: 0)
				case .format:
					return "FRMT".padding(toLength: length, withPad: " ", startingAt: 0)
				case .nonspacingMark:
					return "NSMK".padding(toLength: length, withPad: " ", startingAt: 0)
				default:
					return "???".padding(toLength: length, withPad: " ", startingAt: 0)
				}
			}
		}
	}
	
	fileprivate
	func uniCodeScalars(_ character: Character) -> String {
		var string = ""
		for (index, scalar) in character.unicodeScalars.enumerated() {
			string += asString(scalar)
			if index < character.unicodeScalars.count - 1 {
				string += " "
			}
		}
		return string
	}
	
	
	
	fileprivate
	func asString(_ scalar: UnicodeScalar) -> String {
		let value = String(scalar.value, radix: 16).uppercased().rightJustified(width: 4, fillChar: "0", truncate: false)
		return "U+\(value) \(scalar.properties.generalCategory)"
	}
	
}

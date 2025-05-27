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
		case tsv
	}
	
	@Option(help: "Output file format, either html or tsv.")
	var format: Format = .tsv
	
	enum Order: String, ExpressibleByArgument {
		case charsAscending
		case countDescending
	}
	
	@Option(help: "Either charsAscending or countDescending; prints results by chars ascending or count descending")
	var order: Order = .charsAscending
	
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
		
		print("Starting to process files in \(books)...")
		
		var codePointsUsage: [Character: Int] = [:]
		let start = Date.now
		var fileCounter = 0
		do {
			
			let booksDirectory = books
			
			try await withThrowingTaskGroup(of: [Character: Int].self) { group in
				
				if let enumerator = fileManager.enumerator(atPath: books) {
					while let file = enumerator.nextObject() as? String {
						if file.hasSuffix(".txt") {
							// print(".", terminator: "")
							fileCounter += 1
							group.addTask { () -> [Character: Int] in
								var taskCodePoints: [Character: Int] = [:]
								let fullPath = booksDirectory + file
								let fileContents = try String(contentsOf: URL(fileURLWithPath: fullPath), encoding: .utf8)
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
		print(Date.now.formatted(date: .complete, time: .complete))
		print("\nHandled \(fileCounter) files.") // Print empty line after not printing line ends in progress.
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
		print("Collected \(sortedByCount.count) unique codepoints")
		print("Time taken: \(Date.now.timeIntervalSince(start)) seconds")
		print("Opening the file \(output) for writing results...")
		let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: output))
		defer {
			try! fileHandle.close()
		}
		try fileHandle.truncate(atOffset: 0)
		try writeHeader(to: fileHandle, with: format)
		for (key, value) in sortedByCount {
			switch format {
			case .html:
				try fileHandle.write(contentsOf: "<tr><td>\(String(key).escape())</td><td>\(uniCodeScalars(key))</td><td>\(value.formatted())</td></tr>\n".data(using: .utf8)!)
			case .tsv:
				if key == "\t" {
					try fileHandle.write(contentsOf: ":tab:\t\(uniCodeScalars(key))\t\(value)\n".data(using: .utf8)!)
				} else {
					try fileHandle.write(contentsOf: "\(key)\t\(uniCodeScalars(key))\t\(value)\n".data(using: .utf8)!)
				}
			}
		}
		try writeFooter(to: fileHandle, with: format)
		print("See results from \(output)")
	}
	
	fileprivate
	func uniCodeScalars(_ character: Character) -> String {
		var string = ""
		for (index, scalar) in character.unicodeScalars.enumerated() {
			string += String(scalar.value)
			if index < character.unicodeScalars.count - 1 {
				string += " "
			}
		}
		return string
	}
	
	func writeHeader(to file: FileHandle, with format: Format) throws {
		switch format {
		case .html:
			try file.write(contentsOf: "<!DOCTYPE html>\n".data(using: .utf8)!)
			try file.write(contentsOf: "<head><meta charset=\"utf-8\">\n".data(using: .utf8)!)
			try file.write(contentsOf: "<title>Unicode characters in files</title></head>\n".data(using: .utf8)!)
			try file.write(contentsOf: "<body><table><tr><th>Character</th><th>Unicode scalars</th><th>Count</th></tr>\n".data(using: .utf8)!)
		case .tsv:
			try file.write(contentsOf: "Character\tUnicode scalars\tCount\n".data(using: .utf8)!)
		}
	}
	
	func writeFooter(to file: FileHandle, with format: Format) throws {
		switch format {
		case .html:
			try file.write(contentsOf: "</table></body></html>\n".data(using: .utf8)!)
		case .tsv:
			try file.write(contentsOf: "\n".data(using: .utf8)!)
		}
	}
	
}

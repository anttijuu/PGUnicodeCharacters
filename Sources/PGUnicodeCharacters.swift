// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SystemPackage

@available(macOS 13.0, *)
@main
struct PGUnicodeCharacters: ParsableCommand {
	
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
	
	mutating func run() throws {
		do {
			try process()
		} catch {
			print("Failed, due to: \(error.localizedDescription)")
		}
	}
	
	mutating func process() throws {
		print("Opening the file \(output) for writing results...")
				
		let fileManager = FileManager.default
		if !books.hasSuffix("/") {
			books.append("/")
		}
		
		print("Starting to process files in \(books)...")
		
		let path: FilePath = FilePath(output)
		let fd = try FileDescriptor.open(
			path,
			.writeOnly,
			options: [.create, .truncate],
			permissions: .ownerReadWrite
		)
		defer {
			try! fd.close()
		}
		try writeHeader(to: fd, with: format)
		var codePointsUsage: [Character: Int] = [:]
		let start = Date.now
		var fileCounter = 1
		do {
			if let enumerator = fileManager.enumerator(atPath: books) {
				while let file = enumerator.nextObject() as? String {
					if file.hasSuffix(".txt") {
						print(".", terminator: "")
						let fullPath = books + file
						let fileContents = try String(contentsOf: URL(fileURLWithPath: fullPath), encoding: .utf8)
						for character in fileContents {
							codePointsUsage[character, default: 0] += 1
						}
						fileCounter += 1
					}
				}
			}
		} catch {
			print("\nError reading files: \(error)")
			return
		}
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
		for (key, value) in sortedByCount {
			switch format {
			case .html:
				try fd.writeAll("<tr><td>\(String(key).escape())</td><td>\(uniCodeScalars(key))</td><td>\(value.formatted())</td></tr>\n".data(using: .utf8)!)
			case .tsv:
				if key == "\t" {
					try fd.writeAll(":tab:\t\(uniCodeScalars(key))\t\(value)\n".data(using: .utf8)!)
				} else {
					try fd.writeAll("\(key)\t\(uniCodeScalars(key))\t\(value)\n".data(using: .utf8)!)
				}
			}
		}
		try writeFooter(to: fd, with: format)
		print("See results from \(output)")
	}
	
	fileprivate
	func uniCodeScalars(_ character: Character) -> String {
		var string = ""
		for scalar in character.unicodeScalars {
			string += String(scalar.value) + " "
		}
		return string
	}
	
	func writeHeader(to file: FileDescriptor, with format: Format) throws {
		switch format {
		case .html:
			try file.writeAll("<!DOCTYPE html>\n".data(using: .utf8)!)
			try file.writeAll("<!DOCTYPE html>\n".data(using: .utf8)!)
			try file.writeAll("<head><meta charset=\"utf-8\">\n".data(using: .utf8)!)
			try file.writeAll("<title>Unicode characters in files</title></head>\n".data(using: .utf8)!)
			try file.writeAll("<body><table><tr><th>Character</th><th>Unicode scalars</th><th>Count</th></tr>\n".data(using: .utf8)!)
		case .tsv:
			try file.writeAll("Character\tUnicode scalars\tCount\n".data(using: .utf8)!)
		}
	}
	
	func writeFooter(to file: FileDescriptor, with format: Format) throws {
		switch format {
		case .html:
			try file.writeAll("</table></body></html>\n".data(using: .utf8)!)
		case .tsv:
			try file.writeAll("\n".data(using: .utf8)!)
		}
	}
	
}

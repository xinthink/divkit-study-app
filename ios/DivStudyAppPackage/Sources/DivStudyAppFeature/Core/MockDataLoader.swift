import Foundation

public enum MockDataLoader {

    public enum JSONFile: String {
        case baseline = "baseline-hello-world"
        case moduleA = "module-a-dynamic-form"
    }

    public static func loadJSON(for file: JSONFile) throws -> Data {
        // Try with subdirectory first
        if let url = Bundle.main.url(
            forResource: file.rawValue,
            withExtension: "json",
            subdirectory: "MockData"
        ) {
            return try Data(contentsOf: url)
        }

        // Try without subdirectory as fallback
        guard let url = Bundle.main.url(
            forResource: file.rawValue,
            withExtension: "json"
        ) else {
            throw LoaderError.fileNotFound(file.rawValue)
        }

        return try Data(contentsOf: url)
    }

    enum LoaderError: Error {
        case fileNotFound(String)
    }
}

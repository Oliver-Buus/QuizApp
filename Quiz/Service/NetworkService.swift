import Foundation

class NetworkService {
    static func getData(from url: URL) async -> Data? {
        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResonse = response as? HTTPURLResponse else {return nil}
            if httpResonse.statusCode != 200 {
                print("\(httpResonse.statusCode)")
            }
            return data
        } catch {
            print("getData error: ", error)
        }
        return nil
    }
}

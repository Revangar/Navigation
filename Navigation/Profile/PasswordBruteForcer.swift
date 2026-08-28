import Foundation

final class PasswordBruteForcer {

    private let alphabet: [UInt8] = Array("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".utf8)
    private lazy var indexByByte: [UInt8: Int] = Dictionary(
        uniqueKeysWithValues: alphabet.enumerated().map { ($0.element, $0.offset) }
    )

    func makeRandomPassword(length: Int) -> String {
        precondition(length > 0)

        let bytes = (0..<length).compactMap { _ in alphabet.randomElement() }
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }

    func bruteForce(password: String) -> String? {
        let passwordBytes = Array(password.utf8)
        guard !passwordBytes.isEmpty else { return nil }

        var targetIndices: [Int] = []
        targetIndices.reserveCapacity(passwordBytes.count)

        for byte in passwordBytes {
            guard let index = indexByByte[byte] else { return nil }
            targetIndices.append(index)
        }

        var candidateIndices = Array(repeating: 0, count: targetIndices.count)

        while true {
            if candidateIndices == targetIndices {
                let bytes = candidateIndices.map { alphabet[$0] }
                return String(bytes: bytes, encoding: .utf8)
            }

            var position = candidateIndices.count - 1

            while true {
                candidateIndices[position] += 1

                if candidateIndices[position] < alphabet.count {
                    break
                }

                candidateIndices[position] = 0

                if position == 0 {
                    return nil
                }

                position -= 1
            }
        }
    }
}

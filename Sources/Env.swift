#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public class Env {
    public static func getVar(name: String) -> String? {
        if let out = getenv(name) {
            return String(validatingUTF8: out)
        } else {
            return nil
        }
    }
}

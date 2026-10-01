import Foundation
import Supabase

/// Supabase connection. Values come from Config/Local.xcconfig via Info.plist.
/// Returns nil until the project is configured, so the app still runs with demo data.
enum Backend {
    static let client: SupabaseClient? = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SupabaseURL") as? String,
              let key = Bundle.main.object(forInfoDictionaryKey: "SupabaseAnonKey") as? String,
              !urlString.isEmpty, !key.isEmpty,
              let url = URL(string: urlString) else {
            return nil
        }
        return SupabaseClient(supabaseURL: url, supabaseKey: key)
    }()
}

//
//  SSLMode.swift
//  PostgreSQL
//

public enum SSLMode {
	case Disable
	case Allow
	case Prefer
	case Require
	case VerifyCA
	case VerifyFull
}

extension SSLMode: CustomStringConvertible {
	public var description: String {
		switch self {
			case .Disable:    return "disable"
			case .Allow:      return "allow"
			case .Prefer:     return "prefer"
			case .Require:    return "require"
			case .VerifyCA:   return "verify-ca"
			case .VerifyFull: return "verify-full"
		}
	}
}

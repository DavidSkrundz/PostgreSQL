//
//  DatabaseError.swift
//  PostgreSQL
//

public enum DatabaseError: Error {
	case FailedToConnect(message: String)
}

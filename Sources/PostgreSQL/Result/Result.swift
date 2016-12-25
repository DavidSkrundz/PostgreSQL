//
//  Result.swift
//  PostgreSQL
//

import Util

public typealias ResultEntry = (name: String, type: ObjectID, value: ResultValue)
public typealias ResultRow = Array<ResultEntry>
public typealias ResultList = Array<ResultRow>

public struct Result {
	public let commandStatus: String
	public let errorMessage: String
	
	public let results: ResultList
	
	public var success: Bool {
		return self.errorMessage.length == 0
	}
}

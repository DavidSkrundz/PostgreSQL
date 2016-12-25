//
//  Connection.swift
//  PostgreSQL
//

import CLibPQ

public final class Connection {
	fileprivate let connection: OpaquePointer!
	
	/// - Parameter keywords: A list of keywords for which a non-default value
	///                        should be used
	/// - Parameter values: A list of values corresponding to the `keywords`
	///
	/// - Throws: DatabaseError.FailedToConnect
	public init(keywords: [String], values: [String]) throws {
		self.connection = Connection.createConnection(k: keywords, v: values)
		if !self.connected {
			throw DatabaseError.FailedToConnect(message: self.errorMessage)
		}
	}
	
	deinit {
		PQfinish(self.connection)
	}
	
	/// Reset the connection if it disconnected or an error occured.
	///
	/// - Throws: DatabaseError.FailedToConnect
	public func reset() throws {
		PQreset(self.connection)
		if !self.connected {
			throw DatabaseError.FailedToConnect(message: self.errorMessage)
		}
	}
	
	public func execute(_ query: StaticString) -> Result? {
		return self.unsafeExecute(query.description)
	}
	
	public func unsafeExecute(_ query: String) -> Result? {
		if query.description.isEmpty { return nil }
		
		guard let result = PQexec(self.connection, query) else {
			return nil
		}
		defer { PQclear(result) }
		
		return self.parseResult(result)
	}
	
	private func parseResult(_ result: OpaquePointer) -> Result {
		var resultList: ResultList = []
		
		let rowCount = PQntuples(result)
		let fieldsPerRow = PQnfields(result)
		
		for rowIndex in 0..<rowCount {
			var row: ResultRow = []
			for fieldIndex in 0..<fieldsPerRow {
				row.append(self.parseField(result: result,
				                           rowIndex: rowIndex,
				                           fieldIndex: fieldIndex))
			}
			resultList.append(row)
		}
		
		return Result(commandStatus: String(cString: PQcmdStatus(result)),
		              errorMessage: self.errorMessage,
		              results: resultList)
	}
	
	private func parseField(result: OpaquePointer,
	                        rowIndex: Int32,
	                        fieldIndex: Int32) -> ResultEntry {
		let fieldName = String(cString: PQfname(result, fieldIndex))
		let value = PQgetvalue(result, rowIndex, fieldIndex)!
		let valueLength = PQgetlength(result, rowIndex, fieldIndex)
		let oid = PQftype(result, fieldIndex)
		guard let valueType = ObjectID(rawValue: oid) else {
			fatalError("BAD OID: \(PQftype(result, fieldIndex))")
		}
		
		if PQgetisnull(result, rowIndex, fieldIndex) == 1 {
			return (fieldName, valueType, .Null)
		}
		return (
			fieldName,
			valueType,
			ResultValue(connection: self,
			            oid: valueType,
			            value: value,
			            length: valueLength)
		)
	}
}

extension Connection {
	public var connected: Bool {
		return self.status == .OK
	}
	
	public var databaseName: String {
		return String(cString: PQdb(self.connection))
	}
	
	public var userName: String {
		return String(cString: PQuser(self.connection))
	}
	
	public var password: String {
		return String(cString: PQpass(self.connection))
	}
	
	public var hostName: String {
		return String(cString: PQhost(self.connection))
	}
	
	public var port: Int {
		return Int(String(cString: PQport(self.connection))) ?? -1
	}
	
	public var options: String {
		return String(cString: PQoptions(self.connection))
	}
	
	public var status: ConnectionStatus {
		return ConnectionStatus(status: PQstatus(self.connection))
	}
	
	public var transactionStatus: TransactionStatus {
		return TransactionStatus(status: PQtransactionStatus(self.connection))
	}
	
	public var serverVersion: String {
		return self.parameterStatus("server_version") ?? ""
	}
	
	public var serverEncoding: String {
		return self.parameterStatus("server_encoding") ?? ""
	}
	
	public var clientEncoding: String {
		return self.parameterStatus("client_encoding") ?? ""
	}
	
	public var applicationName: String {
		return self.parameterStatus("application_name") ?? ""
	}
	
	public var isSuperuser: Bool {
		return self.parameterStatus("is_superuser") == "on"
	}
	
	public var authorization: String {
		return self.parameterStatus("session_authorization") ?? ""
	}
	
	public var dateStyle: String {
		return self.parameterStatus("DateStyle") ?? ""
	}
	
	public var intervalStyle: String {
		return self.parameterStatus("IntervalStyle") ?? ""
	}
	
	public var timeZone: String {
		return self.parameterStatus("TimeZone") ?? ""
	}
	
	public var integerDatetimes: Bool {
		return self.parameterStatus("integer_datetimes") == "on"
	}
	
	public var standardConformingStrings: Bool {
		return self.parameterStatus("standard_conforming_strings") == "on"
	}
	
	private func parameterStatus(_ parameter: String) -> String? {
		if let status = PQparameterStatus(self.connection, parameter) {
			return String(cString: status)
		}
		return nil
	}
	
	public var protocolVersion: Int32 {
		return PQprotocolVersion(self.connection)
	}
	
	public var serverVersionInt: Int32 {
		return PQserverVersion(self.connection)
	}
	
	public var errorMessage: String {
		return String(cString: PQerrorMessage(self.connection))
	}
	
	public var socketFileDescriptor: Int32 {
		return PQsocket(self.connection)
	}
	
	public var serverPID: Int32 {
		return PQbackendPID(self.connection)
	}
	
	public var connectionNeedsPassword: Bool {
		return PQconnectionNeedsPassword(self.connection) == 1
	}
	
	public var connectionUsedPassword: Bool {
		return PQconnectionUsedPassword(self.connection) == 1
	}
	
	public var usingSSL: Bool {
		return PQsslInUse(self.connection) == 1
	}
	
	public var sslLibrary: String {
		return self.sslAttribute("library") ?? ""
	}
	
	public var sslProtocol: String {
		return self.sslAttribute("protocol") ?? ""
	}
	
	public var sslKeyBits: Int32 {
		if let sslKeyBitsString = self.sslAttribute("key_bits") {
			return Int32(sslKeyBitsString)!
		}
		return -1
	}
	
	public var sslCipher: String {
		return self.sslAttribute("cipher") ?? ""
	}
	
	public var sslCompression: String {
		return self.sslAttribute("compression") ?? ""
	}

	private func sslAttribute(_ name: String) -> String? {
		if let attribute = PQsslAttribute(self.connection, name) {
			return String(cString: attribute)
		}
		return nil
	}
}

extension Connection {
	fileprivate static func createConnection(k: [String],
	                                         v: [String]) -> OpaquePointer? {
		var keywordsArgs = k.map { UnsafePointer<Int8>(strdup($0)) }
		var valuesArgs   = v.map { UnsafePointer<Int8>(strdup($0)) }
		
		keywordsArgs.append(nil)
		valuesArgs.append(nil)
		
		defer {
			keywordsArgs
				.dropLast()
				.forEach { free(UnsafeMutablePointer(mutating: $0)) }
			valuesArgs
				.dropLast()
				.forEach { free(UnsafeMutablePointer(mutating: $0)) }
		}
		
		return PQconnectdbParams(&keywordsArgs, &valuesArgs, 0)
	}
}

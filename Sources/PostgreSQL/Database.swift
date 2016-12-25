//
//  Database.swift
//  PostgreSQL
//

public struct Database {
	fileprivate var parameters: [String : String]
	
	public init() {
		self.parameters = [
			"client_encoding" : "UTF8",
			"fallback_application_name" : "Swift PostgreSQL (David Skrundz)",
		]
	}
	
	fileprivate init(parameters: [String : String]) {
		self.parameters = parameters
	}
	
	public func connect() throws -> Connection {
		var keywords: [String] = []
		var values: [String] = []
		
		for (key, value) in self.parameters {
			keywords.append(key)
			values.append(value)
		}
		
		return try Connection(keywords: keywords, values: values)
	}
}

extension Database {
	/// - Parameter host: Name of host to connect to.
	public mutating func setHost(_ host: String) {
		self.parameters["host"] = host
	}
	
	/// - Parameter address: Numeric IP address of host to connect to.
	public mutating func setHostAddress(_ address: String) {
		self.parameters["hostaddr"] = address
	}
	
	/// - Parameter port: Port number to connect to at the server host.
	public mutating func setPort(_ port: Int) {
		self.parameters["port"] = "\(port)"
	}
	
	/// - Parameter name: The database name.
	public mutating func setDatabaseName(_ name: String) {
		self.parameters["dbname"] = name
	}
	
	/// - Parameter user: PostgreSQL user name to connect as.
	public mutating func setUser(_ user: String) {
		self.parameters["user"] = user
	}
	
	/// - Parameter password: Password to be used if the server demands password
	///                       authentication.
	public mutating func setPassword(_ password: String) {
		self.parameters["password"] = password
	}
	
	/// - Parameter seconds: Maximum wait for connection, in seconds.
	public mutating func setConnectTimeout(_ seconds: Int) {
		self.parameters["connect_timeout"] = "\(seconds)"
	}
	
	/// - Parameter options: Specifies command-line options to send to the
	///                      server at connection start.
	public mutating func setOptions(_ options: String) {
		self.parameters["options"] = options
	}
	
	/// - Parameter name: Specifies a value for the application_name
	///                   configuration parameter.
	public mutating func setApplicationName(_ name: String) {
		self.parameters["application_name"] = name
	}
	
	/// - Parameter use: Controls whether client-side TCP keepalives are used.
	public mutating func setUseKeepalives(_ use: Bool) {
		self.parameters["keepalives"] = use ? "1" : "0"
	}
	
	/// - Parameter seconds: Controls the number of seconds of inactivity after
	///                      which TCP should send a keepalive message to the
	///                      server.
	public mutating func setKeepalivesIdle(_ seconds: Int) {
		self.parameters["keepalives_idle"] = "\(seconds)"
	}
	
	/// - Parameter seconds: Controls the number of seconds after which a TCP
	///                      keepalive message that is not acknowledged by the
	///                      server should be retransmitted.
	public mutating func setKeepalivesInterval(_ seconds: Int) {
		self.parameters["keepalives_interval"] = "\(seconds)"
	}
	
	/// - Parameter count: Controls the number of TCP keepalives that can be
	///                    lost before the client's connection to the server is
	///                    considered dead.
	public mutating func setKeepalivesMaxLossCount(_ count: Int) {
		self.parameters["keepalives_count"] = "\(count)"
	}
	
	/// - Parameter mode: This option determines whether or with what priority a
	///                   secure SSL TCP/IP connection will be negotiated with
	///                   the server.
	public mutating func setSSLMode(_ mode: SSLMode) {
		self.parameters["sslmode"] = mode.description
	}
	
	/// - Parameter compress: Will data sent over SSL connections be compressed.
	public mutating func setSSLCompression(_ compress: Bool) {
		self.parameters["sslcompression"] = compress ? "1" : "0"
	}
	
	/// - Parameter filePath: This parameter specifies the file name of the
	///                       client SSL certificate, replacing the default
	///                       `~/.postgresql/postgresql.crt`.
	public mutating func setSSLCertificate(_ filePath: String) {
		self.parameters["sslcert"] = filePath
	}
	
	/// - Parameter filePath: This parameter specifies the location for the
	///                       secret key used for the client certificate.
	public mutating func setSSLKey(_ filePath: String) {
		self.parameters["sslkey"] = filePath
	}
	
	/// - Parameter filePath: This parameter specifies the name of a file
	///                       containing SSL certificate authority (CA)
	///                       certificate(s).
	public mutating func setSSLRootCertificate(_ filePath: String) {
		self.parameters["sslrootcert"] = filePath
	}
	
	/// - Parameter filePath: This parameter specifies the file name of the SSL
	///                       certificate revocation list (CRL).
	public mutating func setSSLRevocationList(_ filePath: String) {
		self.parameters["sslcrl"] = filePath
	}
	
	/// - Parameter peer: This parameter specifies the operating-system user
	///                   name of the server.
	public mutating func setServerUserName(_ peer: String) {
		self.parameters["requirepeer"] = peer
	}
	
	/// - Parameter name: Kerberos service name to use when authenticating with
	///                   GSSAPI.
	public mutating func setKerberosServiceName(_ name: String) {
		self.parameters["krbsrvname"] = name
	}
	
	/// - Parameter name: GSS library to use for GSSAPI authentication.
	public mutating func setGSSName(_ name: String) {
		self.parameters["gsslib"] = name
	}
	
	/// - Parameter name: Service name to use for additional parameters.
	public mutating func setServiceName(_ name: String) {
		self.parameters["service"] = name
	}
}

extension Database {
	/// - Parameter host: Name of host to connect to.
	public func withHost(_ host: String) -> Database {
		var parameters = self.parameters
		parameters["host"] = host
		return Database(parameters: parameters)
	}
	
	/// - Parameter address: Numeric IP address of host to connect to.
	public func withHostAddress(_ address: String) -> Database {
		var parameters = self.parameters
		parameters["hostaddr"] = address
		return Database(parameters: parameters)
	}
	
	/// - Parameter port: Port number to connect to at the server host.
	public func withPort(_ port: Int) -> Database {
		var parameters = self.parameters
		parameters["port"] = "\(port)"
		return Database(parameters: parameters)
	}
	
	/// - Parameter name: The database name.
	public func withDatabaseName(_ name: String) -> Database {
		var parameters = self.parameters
		parameters["dbname"] = name
		return Database(parameters: parameters)
	}
	
	/// - Parameter user: PostgreSQL user name to connect as.
	public func withUser(_ user: String) -> Database {
		var parameters = self.parameters
		parameters["user"] = user
		return Database(parameters: parameters)
	}
	
	/// - Parameter password: Password to be used if the server demands password
	///                       authentication.
	public func withPassword(_ password: String) -> Database {
		var parameters = self.parameters
		parameters["password"] = password
		return Database(parameters: parameters)
	}
	
	/// - Parameter seconds: Maximum wait for connection, in seconds.
	public func withConnectTimeout(_ seconds: Int) -> Database {
		var parameters = self.parameters
		parameters["connect_timeout"] = "\(seconds)"
		return Database(parameters: parameters)
	}
	
	/// - Parameter options: Specifies command-line options to send to the
	///                      server at connection start.
	public func withOptions(_ options: String) -> Database {
		var parameters = self.parameters
		parameters["options"] = options
		return Database(parameters: parameters)
	}
	
	/// - Parameter name: Specifies a value for the application_name
	///                   configuration parameter.
	public func withApplicationName(_ name: String) -> Database {
		var parameters = self.parameters
		parameters["application_name"] = name
		return Database(parameters: parameters)
	}
	
	/// - Parameter use: Controls whether client-side TCP keepalives are used.
	public func withUseKeepalives(_ use: Bool) -> Database {
		var parameters = self.parameters
		parameters["keepalives"] = use ? "1" : "0"
		return Database(parameters: parameters)
	}
	
	/// - Parameter seconds: Controls the number of seconds of inactivity after
	///                      which TCP should send a keepalive message to the
	///                      server.
	public func withKeepalivesIdle(_ seconds: Int) -> Database {
		var parameters = self.parameters
		parameters["keepalives_idle"] = "\(seconds)"
		return Database(parameters: parameters)
	}
	
	/// - Parameter seconds: Controls the number of seconds after which a TCP
	///                      keepalive message that is not acknowledged by the
	///                      server should be retransmitted.
	public func withKeepalivesInterval(_ seconds: Int) -> Database {
		var parameters = self.parameters
		parameters["keepalives_interval"] = "\(seconds)"
		return Database(parameters: parameters)
	}
	
	/// - Parameter count: Controls the number of TCP keepalives that can be
	///                    lost before the client's connection to the server is
	///                    considered dead.
	public func withKeepalivesMaxLossCount(_ count: Int) -> Database {
		var parameters = self.parameters
		parameters["keepalives_count"] = "\(count)"
		return Database(parameters: parameters)
	}
	
	/// - Parameter mode: This option determines whether or with what priority a
	///                   secure SSL TCP/IP connection will be negotiated with
	///                   the server.
	public func withSSLMode(_ mode: SSLMode) -> Database {
		var parameters = self.parameters
		parameters["sslmode"] = mode.description
		return Database(parameters: parameters)
	}
	
	/// - Parameter compress: Will data sent over SSL connections be compressed.
	public func withSSLCompression(_ compress: Bool) -> Database {
		var parameters = self.parameters
		parameters["sslcompression"] = compress ? "1" : "0"
		return Database(parameters: parameters)
	}
	
	/// - Parameter filePath: This parameter specifies the file name of the
	///                       client SSL certificate, replacing the default
	///                       `~/.postgresql/postgresql.crt`.
	public func withSSLCertificate(_ filePath: String) -> Database {
		var parameters = self.parameters
		parameters["sslcert"] = filePath
		return Database(parameters: parameters)
	}
	
	/// - Parameter filePath: This parameter specifies the location for the
	///                       secret key used for the client certificate.
	public func withSSLKey(_ filePath: String) -> Database {
		var parameters = self.parameters
		parameters["sslkey"] = filePath
		return Database(parameters: parameters)
	}
	
	/// - Parameter filePath: This parameter specifies the name of a file
	///                       containing SSL certificate authority (CA)
	///                       certificate(s).
	public func withSSLRootCertificate(_ filePath: String) -> Database {
		var parameters = self.parameters
		parameters["sslrootcert"] = filePath
		return Database(parameters: parameters)
	}
	
	/// - Parameter filePath: This parameter specifies the file name of the SSL
	///                       certificate revocation list (CRL).
	public func withSSLRevocationList(_ filePath: String) -> Database {
		var parameters = self.parameters
		parameters["sslcrl"] = filePath
		return Database(parameters: parameters)
	}
	
	/// - Parameter peer: This parameter specifies the operating-system user
	///                   name of the server.
	public func withServerUserName(_ peer: String) -> Database {
		var parameters = self.parameters
		parameters["requirepeer"] = peer
		return Database(parameters: parameters)
	}
	
	/// - Parameter name: Kerberos service name to use when authenticating with
	///                   GSSAPI.
	public func withKerberosServiceName(_ name: String) -> Database {
		var parameters = self.parameters
		parameters["krbsrvname"] = name
		return Database(parameters: parameters)
	}
	
	/// - Parameter name: GSS library to use for GSSAPI authentication.
	public func withGSSName(_ name: String) -> Database {
		var parameters = self.parameters
		parameters["gsslib"] = name
		return Database(parameters: parameters)
	}
	
	/// - Parameter name: Service name to use for additional parameters.
	public func withServiceName(_ name: String) -> Database {
		var parameters = self.parameters
		parameters["service"] = name
		return Database(parameters: parameters)
	}
}

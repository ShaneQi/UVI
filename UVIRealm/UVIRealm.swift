//
//  UVIRealm.swift
//  UVI
//
//  Created by Shane Qi on 4/16/17.
//  Copyright © 2017 Transformers. All rights reserved.
//

import RealmSwift

public class UVIRealm {

	private init() {}

	public static let `default` = UVIRealm()

	var realm: Realm!

	public func launch(completion: @escaping ((Result<Any?>) -> Void)) {
		SyncUser.logIn(with: .usernamePassword(username: UVIRealmUsername,
		                                       password: UVIRealmPassword),
		               server: UVIRealmServerUrl,
		               timeout: 20) { [unowned self] user, error in
			guard let user = user else {
				completion(.failure(error!))
				return
			}
			DispatchQueue.main.async {
				let config = Realm
					.Configuration(syncConfiguration: SyncConfiguration(user: user,
					                                                    realmURL: UVIRealmUrl))
				do {
					self.realm = try Realm(configuration: config)
					completion(.success(nil))
				} catch (let error) {
					completion(.failure(error))
				}
			}
		}
	}

}

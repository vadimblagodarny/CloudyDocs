//
//  AccountModel.swift
//  ydisk_client
//
//  Created by Vadim Blagodarny on 22.03.2023.
//

struct DiskInfo: Codable {
    let trash_size: Int
    let total_space: Int
    let used_space: Int
}

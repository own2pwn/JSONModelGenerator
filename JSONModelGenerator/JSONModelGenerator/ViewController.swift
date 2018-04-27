//
//  ViewController.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        testWorker()
    }

    private func testWorker() {
        let path = "file://" + FileManager.default.currentDirectoryPath + "/Model.json"
        guard let url = URL(string: path),
            let content = try? Data(contentsOf: url),
            let object = try? JSONSerialization.jsonObject(with: content, options: []),
            let json = object as? JSONObject else { return }

        let worker = Worker()
        _ = worker.generate(for: json)
    }
}

struct SearchModel {
    let status: String
    struct ResultsModel {
        struct GeometryModel {
            struct ViewportModel {
                struct NortheastModel {
                    let lat: Double
                    let lng: Double
                }

                struct SouthwestModel {
                    let lat: Double
                    let lng: Double
                }
            }

            struct LocationModel {
                let lat: Double
                let lng: Double
            }
        }

        let reference: String
        let icon: String
        let name: String
        let id: String
        let place_id: String
        struct PhotosModel {
            let photo_reference: String
            let height: Int
            let html_attributions: [String]
            let width: Int
        }

        /*
         for type in element.types {
            if type.isObject {
                /
            }
         }
        */

        let scope: String
        let vicinity: String
        let types: [String]
    }

    let html_attributions: [Any]
    let next_page_token: String
}

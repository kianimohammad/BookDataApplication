//
//  Book.swift
//  Book Data Application
//
//  Created by Mohammad Kiani on 2020-06-13.
//  Copyright © 2020 mohammadkiani. All rights reserved.
//

import Foundation

class Book {
    var title: String
    var author: String
    var pages: Int
    var year: Int
    
    init(title: String, author: String, pages: Int, year: Int) {
        self.title = title
        self.author = author
        self.pages = pages
        self.year = year
    }
}

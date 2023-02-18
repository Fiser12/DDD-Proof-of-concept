//
//  Profesor.swift
//  DDD Prof of concept
//
//  Created by Rubén on 18/2/23.
//

import Foundation

final class ProfesorRepository: Repository {
    typealias AggregateType = Profesor
    
    static subscript(key: Profesor.ID) -> Profesor? {
        profesores.first {$0.id == key }
    }
}

struct Profesor: Aggregate {
    typealias RepositoryType = ProfesorRepository
    
    let id: ID = ID()
    var nombre: String
    var edad: Int
}

extension Profesor {
    struct ID: AggregateId {
        typealias AggregateType = Profesor
        let id: UUID = UUID()
    }
}

extension Profesor: CustomStringConvertible {
    var description: String {
        "\(self.nombre)"
    }
}




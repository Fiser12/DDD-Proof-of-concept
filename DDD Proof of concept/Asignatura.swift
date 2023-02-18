//
//  Asignatura.swift
//  DDD Prof of concept
//
//  Created by Rubén on 18/2/23.
//

import Foundation

final class AsignaturaRepository: Repository {
    typealias AggregateType = Asignatura
    static var cursos: [Curso] {
        CursoRepository.cursos
    }
    static subscript(key: Asignatura.ID) -> Asignatura? {
        asignaturas.first {$0.id == key }
    }
}

struct Asignatura: Aggregate {
    typealias RepositoryType = AsignaturaRepository
    
    let id: ID = ID()
    var nombre: String
    var cursos: AggregateDictionary<Curso>
    
    init(nombre: String, cursos: Set<Curso.ID>) {
        self.nombre = nombre
        self.cursos = AggregateDictionary(cursos)
    }
}

extension Asignatura {
    struct ID: AggregateId {
        typealias AggregateType = Asignatura
        let id: UUID = UUID()
    }
}

extension Asignatura: CustomStringConvertible {
    var description: String {
        "\(self.nombre)"
    }
}

//
//  Curso.swift
//  DDD Prof of concept
//
//  Created by Rubén on 18/2/23.
//

import Foundation

final class CursoRepository: Repository {
    typealias AggregateType = Curso
    
    static subscript(key: Curso.ID) -> Curso? {
        cursos.first {$0.id == key }
    }
}

struct Curso: Aggregate {
    typealias RepositoryType = CursoRepository
    
    let id: ID = ID()
    var nombre: String
    var alumnos: AggregateDictionary<Alumno>
    //No se porque no me infiere el ID del agregado tengo que revisarlo
    @AggregateWrapper<Profesor.ID> var profesor: Profesor?
    var profesorId: Profesor.ID {
        //Si quieres solo el Id no tienes porque triggear la carga de todo accediendo al propertywrapper
        self._profesor.id
    }
    init(nombre: String, alumnos: Set<Alumno.ID>, profesorId: Profesor.ID) {
        self.nombre = nombre
        self.alumnos = AggregateDictionary(alumnos)
        self._profesor = AggregateWrapper(profesorId)
    }
}

extension Curso {
    struct ID: AggregateId {
        typealias AggregateType = Curso
        let id: UUID = UUID()
    }
}

extension Curso: CustomStringConvertible {
    var description: String {
        "\(self.nombre)"
    }
}


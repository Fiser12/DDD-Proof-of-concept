//
//  Alumno.swift
//  DDD Prof of concept
//
//  Created by Rubén on 18/2/23.
//

import Foundation

final class AlumnoRepository: Repository {
    typealias AggregateType = Alumno
    static var cursos: [Curso] {
        CursoRepository.cursos
    }
    static subscript(key: Alumno.ID) -> Alumno? {
        alumnos.first {$0.id == key }
    }
}

struct Alumno: Aggregate {
    typealias RepositoryType = AlumnoRepository
    
    let id: ID = ID()
    var edad: Int
    var nombre: String
    @AggregateWrapper<Curso.ID> var curso: Curso?
    
    init(nombre: String, edad: Int, curso: Curso.ID) {
        self.nombre = nombre
        self.edad = edad
        self._curso = AggregateWrapper(curso)
    }
}

extension Alumno {
    struct ID: AggregateId {
        typealias AggregateType = Alumno
        let id: UUID = UUID()
    }
}

extension Alumno: CustomStringConvertible {
    var description: String {
        "\(self.nombre)"
    }
}


//Ejercicio 2.4
/*
 Vamos a crear un colegio donde crearemos la estructura de datos necesarios usando structs en vez de clases.
 - Struct para los Profesores, con nombre y edad.
 - Struct para las Asignaturas, con nombre de asignatura y cursos donde se imparte.
 - Struct para los Alumnos, con nombre, edad y curso.
 - Struct para los Cursos con el tutor (profesor) y los alumnos.
 - Struct del Colegio con los distintos cursos del mismo.
 Queremos poder extraer listados y/o conteo de las asignaturas que imparte cada profesor, cuántos alumnos tiene cada uno y cuántos alumnos distintos hay en el colegio que al menos estén en una asignatura.
 Para probar que funciona crea una serie de datos de prueba.
 */
import Foundation

//Voy a implementar aquí el concepto de Domain Driven Design sobre Swift para que puedas usar Id y carga lazy sobre colecciones de los mismos sin tener que preocuparte de ello. Esto en un overengineering de puta madre 😂, pero tenía algunas ideas desde hace tiempo que quería ver si podía poner en práctica.
//Esto no es buena idea en SwiftUI por como es pero para arquitecturas complejas de backend con Vapor puede ser útil si se perfecciona.
//Aquí está como sería el acceso desde el modelo a todos los elementos del dominio desde el propio objeto del dominio.


//MockData
extension AlumnoRepository {
    static let alumnos = (0..<100).map { Alumno(nombre: "Alumno \($0)", edad: Int.random(in: 5...20), curso: cursos.randomElement()!.id) }
}

extension AsignaturaRepository {
    static let asignaturas = [
        Asignatura(nombre: "Asignatura 1", cursos: [cursos[0].id, cursos[1].id, cursos[2].id]),
        Asignatura(nombre: "Asignatura 2", cursos: [cursos[3].id, cursos[4].id, cursos[5].id]),
        Asignatura(nombre: "Asignatura 3", cursos: [cursos[6].id, cursos[7].id, cursos[8].id]),
        Asignatura(nombre: "Asignatura 4", cursos: [cursos[9].id, cursos[0].id, cursos[1].id]),
        Asignatura(nombre: "Asignatura 5", cursos: [cursos[2].id, cursos[3].id, cursos[4].id]),
        Asignatura(nombre: "Asignatura 6", cursos: [cursos[5].id, cursos[6].id, cursos[7].id]),
        Asignatura(nombre: "Asignatura 7", cursos: [cursos[8].id, cursos[9].id, cursos[0].id]),
        Asignatura(nombre: "Asignatura 8", cursos: [cursos[1].id, cursos[2].id, cursos[3].id]),
        Asignatura(nombre: "Asignatura 9", cursos: [cursos[4].id, cursos[5].id, cursos[6].id]),
        Asignatura(nombre: "Asignatura 10", cursos: [cursos[7].id, cursos[8].id, cursos[9].id]),
    ]
}

extension CursoRepository {
    static var cursos = [
        Curso(nombre: "Curso 1", alumnos: [], profesorId: ProfesorRepository.profesores[0].id),
        Curso(nombre: "Curso 2", alumnos: [], profesorId: ProfesorRepository.profesores[1].id),
        Curso(nombre: "Curso 3", alumnos: [], profesorId: ProfesorRepository.profesores[2].id),
        Curso(nombre: "Curso 4", alumnos: [], profesorId: ProfesorRepository.profesores[3].id),
        Curso(nombre: "Curso 5", alumnos: [], profesorId: ProfesorRepository.profesores[4].id),
        Curso(nombre: "Curso 6", alumnos: [], profesorId: ProfesorRepository.profesores[5].id),
        Curso(nombre: "Curso 7", alumnos: [], profesorId: ProfesorRepository.profesores[6].id),
        Curso(nombre: "Curso 8", alumnos: [], profesorId: ProfesorRepository.profesores[7].id),
        Curso(nombre: "Curso 9", alumnos: [], profesorId: ProfesorRepository.profesores[8].id),
        Curso(nombre: "Curso 10", alumnos: [], profesorId: ProfesorRepository.profesores[9].id),
    ]
}

extension ProfesorRepository {
    static let profesores = [
        Profesor(nombre: "Profesor 1", edad: 30),
        Profesor(nombre: "Profesor 2", edad: 40),
        Profesor(nombre: "Profesor 3", edad: 50),
        Profesor(nombre: "Profesor 4", edad: 50),
        Profesor(nombre: "Profesor 5", edad: 50),
        Profesor(nombre: "Profesor 6", edad: 30),
        Profesor(nombre: "Profesor 7", edad: 40),
        Profesor(nombre: "Profesor 8", edad: 50),
        Profesor(nombre: "Profesor 9", edad: 50),
        Profesor(nombre: "Profesor 10", edad: 50)
    ]
}
//Hay que cargar los alumnos por problema de dependenias cruzadas
CursoRepository.cursos = CursoRepository.cursos.map {
    var curso = $0
    curso.alumnos = AggregateDictionary(Set(AlumnoRepository.alumnos.filter {
        $0.curso?.id == curso.id
    }
    .map(\.id)))
    return curso
}

ProfesorRepository.profesores.forEach { profesor in
    let cursosDelProfesor = CursoRepository.cursos.filter {
        $0.profesorId == profesor.id
    }

    let alumnosDelProfesor = cursosDelProfesor.map {
        $0.alumnos.loaded.values
    }.flatMap{$0}
    let asignaturasQueImparte = AsignaturaRepository.asignaturas.filter {
        $0.cursos.keys.contains { curso in
            cursosDelProfesor.map{ $0.id }.contains(curso)
        }
    }
    print(profesor)
    print(cursosDelProfesor)
    print(alumnosDelProfesor)
    print(asignaturasQueImparte)
    print("___________________________")
}

//Se me ocurren ideas para hacer que las busquedas fuesen optimas entre los IDs asociados, pero tendría que pensarlo con más calma. De modo que un clousure de filtrado sobre un campo asociado se transmitiese al repositorio y este lo aplicase para no tener que cargar todos los elementos y filtrarlos tu. Tampoco se si es posible quizá requiera de una arquitectura tan compleja que no sea factible y habría que adoptar otro enfoque.

//Esto no es optimo, hay ciertas capacidades de filtrado que requieren de la carga de los elementos y eso es ineficiente, pero creo que realmente esto es algo que se puede optimizar mucho si se le dedicase más tiempo. Con este ejemplo

//
//  DDDLibraries.swift
//  DDD Prof of concept
//
//  Created by Rubén on 18/2/23.
//

import Foundation

protocol Repository {
    associatedtype AggregateType: Aggregate where Self == AggregateType.RepositoryType
    
    //Esto debería de ser de otra forma y con async await, pero por simplificarlo voy a mockear el acceso a los datos de todos los repositorios, pero lo lógico sería que se accediese a esos datos de algún almacen. 
    static subscript(key: AggregateType.ID) -> AggregateType? { get }
}

protocol AggregateId: Hashable {
    associatedtype AggregateType: Aggregate where Self == AggregateType.ID
}

protocol Aggregate: Identifiable {
    associatedtype RepositoryType: Repository where Self == RepositoryType.AggregateType
    associatedtype AggregateIdType: AggregateId where Self == AggregateIdType.AggregateType
    
    var id: AggregateIdType { get }
}

struct LazyAggregate<T: AggregateId> {
    let id: T
    
    var content: T.AggregateType? {
        T.AggregateType.RepositoryType[id]
    }
}

//Cuando estén los genericos variadicos creo que un AggregateNode podría tener definidos aquellos agregados con los que se relaciona de 1 a N o de N a M, Esto daría muchisimas más posibilidades a este tipo de arquitectura.
enum AggregateNode<T: AggregateId> {
    case stored(T.AggregateType)
    case lazy(LazyAggregate<T>)
    
    var content: T.AggregateType? {
        switch self {
        case .stored(let content): return content
        case .lazy(let aggregate): return aggregate.content
        }
    }
    
    var id: T {
        switch self {
        case .stored(let content): return content.id
        case .lazy(let lazyAggregate):  return lazyAggregate.id
        }
    }
}

//Me hubise gustado haber hecho esto más trasparente, creo que esta parte se podría mejorar con un property wrapper o algo, pero tampoco quiero pelearme más con esto.
struct AggregateDictionary<Element: Aggregate> {
    typealias Id = Element.AggregateIdType
    //Todos los agregados deberían de guardar una fecha de última modificación para poder decidir cual conservar de los 2 en caso de desincronización, pero no me voy a meter en eso ahora, pero habría que pensar una forma de gestionar este sistema para hacerlo multithread friendly, aun así me falta mucha info para saber gestionar esto bien.
    //var syncToRepository: Bool = true
    
    private var dictionary: Dictionary<Id, AggregateNode<Id>>
    
    init(_ ids: Set<Id>) {
        let ids = ids.map{($0, AggregateNode.lazy(LazyAggregate(id: $0)))}
        self.dictionary = Dictionary(uniqueKeysWithValues: ids)
    }
    
    init(_ elements: Dictionary<Id, Element>) {
        self.dictionary = elements.mapValues{AggregateNode.stored($0)}
    }
    
    init(_ dictionary: Dictionary<Id, AggregateNode<Id>>) {
        self.dictionary = dictionary
    }
    
    //Para acotar las cosas no voy a implementar el set ya que tiene más implicaciones y habría pensarlo en detalle.
    subscript(key: Id) -> Element? {
        dictionary[key]?.content
    }
        
    var loaded: Dictionary<Id, Element> {
        dictionary.compactMapValues{
            $0.content
        }
    }
    
    var keys: Set<Id> {
        Set(dictionary.map {
            $0.key
        })
    }
}

@propertyWrapper
struct AggregateWrapper<Wrapped: AggregateId> {
    var id: Wrapped
    //Lo mismo que en el diccionario, si quisiere cambiar los datos de un agregado desde aquí se podría hacer actualizando el repositorio desde aquí pero no lo voy a implementar por no sobrecomplicarlo, esto solo es un demostrador tecnológico.
    var wrappedValue: Wrapped.AggregateType? {
        type(of: id).AggregateType.RepositoryType[id]
    }

    init(_ wrappedValue: Wrapped) {
        self.id = wrappedValue
    }
}


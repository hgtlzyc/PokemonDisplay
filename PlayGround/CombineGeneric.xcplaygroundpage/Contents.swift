import Foundation
import Combine

/*
 Created by lijia xu
    
*/

//Make tasks trackable, nonblocking and individually cancelable with generics and protocols
typealias CancelableIntTaskType = CancelableTask<AnyPublisher<Int, Never>>
var cancelableIntTasks = CancelableIntTaskType()
var taskIdArray = [UUID?]()

taskIdArray = [
    startFizzBuzzTask(50, -80, &cancelableIntTasks),
    startFizzBuzzTask(100, 200, &cancelableIntTasks),
    startFizzBuzzTask(600, 1000, &cancelableIntTasks),
    startFizzBuzzTask(2000, 2600, &cancelableIntTasks)
]

checkAllTasksStarted(taskIdArray)

DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
    if let id = taskIdArray.compactMap({$0}).first {
        cancelableIntTasks.cancelTaskWithID(id)
    }
}

DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
    cancelableIntTasks.cancelAll()
}



//outputs
//*id C00 started
//*id A8A started
//id A8A fizzbuzz at 600 progress 0.0%
//id C00 buzz at 100 progress 0.0%
//*id 744 started
//id 744 buzz at 2000 progress 0.0%
//id 744 fizz at 2001 progress 1.0%
//id C00 fizz at 102 progress 2.0%
//id 744 fizz at 2004 progress 1.0%
//id A8A fizz at 603 progress 1.0%
//id 744 buzz at 2005 progress 1.0%
//id C00 fizzbuzz at 105 progress 5.0%
//....
//id 744 fizz at 2019 progress 4.0%
//4 tasks initiated 3 started
//task at index 0 failed
//id 744 buzz at 2020 progress 4.0%
//id A8A fizz at 618 progress 5.0%
//id C00 fizzbuzz at 120 progress 20.0%
//....
//id C00 fizz at 132 progress 32.0%
//**C00 canceled at 133 progress: 33.0%
//id A8A fizz at 636 progress 9.0%
//id 744 fizzbuzz at 2040 progress 7.0%
//id A8A fizz at 639 progress 10.0%
//id 744 fizz at 2043 progress 8.0%
//...
//id A8A fizz at 654 progress 14.0%
//id 744 fizz at 2058 progress 10.0%
//id A8A buzz at 655 progress 14.0%
//**744 canceled at 2058 progress: 10.0%
//**A8A canceled at 656 progress: 15.0%

//Fizzbuzz Task related
func startFizzBuzzTask(_ fromIndex: Int,_ toIndex: Int,_ tasksContainer: inout CancelableIntTaskType) -> UUID?{
    guard toIndex > fromIndex else { return nil}
    let id = UUID()
    let tracker = FizzBuzzProgressTracker(fromIndex, toIndex, uuid: id)
    
    tasksContainer.startTask(
        taskPublisher: generateIntInRangePublisher(fromIndex, toIndex),
        tracker: tracker,
        displayHelper: fizzBuzzDisplayHelper()
    ) { result in
        switch result {
        case .failure(let printerError):
            print(printerError.description)
        case .success(let finishedIndex):
            print("finished at \(finishedIndex)")
        }
    }
    
    return id
}

func generateIntInRangePublisher(_ fromIndex: Int,_ toIndex: Int) -> AnyPublisher<Int, Never> {
    Array<Int>(fromIndex ..< toIndex).publisher
        .eraseToAnyPublisher()
}

struct FizzBuzzProgressTracker: ProgressIndicable {
    var uuid: UUID
    let startValue: Int
    let toValue: Int
    var currentValue: Int
    
    init(_ startValue: Int,_ toValue: Int, uuid: UUID ) {
        self.startValue = startValue
        self.currentValue = startValue
        self.toValue = toValue <= startValue ? startValue + 1 : toValue
        self.uuid = uuid
    }
    
    var currentProgress: Double {
        Double(currentValue - startValue) / Double(toValue - startValue)
            * 100.0
    }
}

//Generic CancelableTask Container related
struct CancelableTask<P: Publisher>{
    private var subscriptions = [UUID : AnyCancellable]()
    //tracker’s associated type restricted to match publisher’s output type
    mutating func startTask<T: ProgressIndicable> (
        taskPublisher: P,
        tracker: T,
        displayHelper: CancelableTaskDisplayHelper? = nil,
        handler: @escaping (_ result: Result<P.Output,CancelableTaskError>) -> Void
    ) -> Void where P.Output == T.ValueType {
        var tracker = tracker
        let id = tracker.uuid.uuidString.prefix(3)
        let cancelableToken = taskPublisher
            .subscribe(on: DispatchQueue.global(qos: .background))
            .handleEvents(
                receiveSubscription: { _ in
                    if let str = displayHelper?
                        .stringBasedOnTrackerEvent(tracker, .started, 3) {
                            print(str)
                        }
                },
                receiveOutput: { value in
                    tracker.currentValue = value
                    if let str = displayHelper?
                        .stringBasedOnTrackerEvent(tracker, .updateCurrent, 3){
                            print(str)
                        }
                },
                receiveCancel: {
                    handler(
                        .failure(
                            .subscriptionError(
                                displayHelper?.stringBasedOnTrackerEvent(tracker, .canceled, 3) ?? "\(id) cancelled"
                            )
                        )
                    )
                }
            )
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    handler(.success(tracker.currentValue))
                case .failure(let error):
                    handler(.failure(.publisherError(error)))
                }
            } receiveValue: { _ in }
        
        subscriptions[tracker.uuid] = cancelableToken
    }
    
    @discardableResult
    mutating func cancelTaskWithID(_ id: UUID) -> Bool{
        if let task = subscriptions[id] {
            task.cancel()
            subscriptions.removeValue(forKey: id) != nil
            return true
        }
        return false
    }
    
    mutating func cancelAll() {
        subscriptions.forEach{ $0.value.cancel()}
    }
}

enum CancelableTaskError: Error {
    case subscriptionError(String)
    case publisherError(Error)
    
    var description: String {
        switch self {
        case .subscriptionError(let description):
            return description
        case .publisherError(let description):
            return description.localizedDescription
        }
    }
}

protocol ProgressIndicable {
    associatedtype ValueType
    var uuid: UUID { get }
    var currentValue: ValueType {get set}
    var startValue: ValueType { get }
    var toValue: ValueType { get }
    var currentProgress: Double {get}
    
}

//helper functions
enum TasksFailureError: Error {
    case noIdAtIndexs([Int])
}

@discardableResult
func checkAllTasksStarted(_ tasksIdArray: [UUID?], displayLog: Bool = true) -> Result<Int,TasksFailureError> {
    let successedArray = taskIdArray.compactMap{$0}
    let isAllSuccess = taskIdArray.count == successedArray.count ? true : false
    var result: Result<Int,TasksFailureError>
    
    switch isAllSuccess {
    case true:
        result = .success(tasksIdArray.count)
    case false:
        let failedIndexes = tasksIdArray.enumerated().filter{$0.1 == nil}.map{$0.0}
        result = .failure(.noIdAtIndexs(failedIndexes))
    }
    
    guard displayLog else { return result }

    switch result {
    case .success(let total):
        print("All \(total) tasks started")
    case .failure(let error):
        switch error {
        case .noIdAtIndexs(let indexes):
            print("\(taskIdArray.count) tasks initiated \(successedArray.count) started")
            indexes.forEach{ print("task at index \($0) failed") }
        }
    }
    
    return result
}

enum TrackerEvent {
    case started
    case canceled
    case updateCurrent
}

protocol CancelableTaskDisplayHelper {
   func stringBasedOnTrackerEvent<T: ProgressIndicable> (_ tracker: T, _ eventType: TrackerEvent, _ prefix: Int) -> String?
}

struct fizzBuzzDisplayHelper: CancelableTaskDisplayHelper {
    
    func stringBasedOnTrackerEvent<T: ProgressIndicable> (_ tracker: T, _ eventType: TrackerEvent, _ prefix: Int ) -> String? {
        guard prefix > 0 else { return "id displayPrefix error"}
        
        let displayID = tracker.uuid.uuidString.prefix(prefix)
        
        switch eventType {
        case .started:
            return "*id " + displayID + " started"
        case .updateCurrent:
            guard let number = tracker.currentValue as? Int else {
                return "id:" + displayID + " val: \(tracker.currentValue)"
                    + " progress \(tracker.currentProgress.rounded(.up))%"
            }
            var str = ""
            switch (number.isMultiple(of: 3), number.isMultiple(of: 5) ) {
            case (true, true):
                str = "id \(displayID) fizzbuzz at \(number)"
            case (true, false):
                str = "id \(displayID) fizz at \(number)"
            case (false, true):
                str = "id \(displayID) buzz at \(number)"
            case (false, false):
                return nil
            }
            return str + " progress \(tracker.currentProgress.rounded(.up))%"
        case .canceled:
            return "**\(displayID) canceled at \(tracker.currentValue)"
                + " progress: \(tracker.currentProgress.rounded(.up))%"
        }
        
    }
}

























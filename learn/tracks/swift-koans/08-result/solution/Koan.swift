enum MathError: Error, Equatable { case divisionByZero }

func divide(_ a: Int, _ b: Int) -> Result<Int, MathError> {
    b == 0 ? .failure(.divisionByZero) : .success(a / b)
}

func divideTwice(_ a: Int, by b: Int, then c: Int) -> Result<Int, MathError> {
    divide(a, b).flatMap { divide($0, c) }
}

func describe(_ result: Result<Int, MathError>) -> String {
    switch result {
    case .success(let value): "ok \(value)"
    case .failure(.divisionByZero): "error: division by zero"
    }
}

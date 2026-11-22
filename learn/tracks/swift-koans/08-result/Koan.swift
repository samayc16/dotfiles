enum MathError: Error, Equatable { case divisionByZero }

func divide(_ a: Int, _ b: Int) -> Result<Int, MathError> {
    return .success(0)
}

func divideTwice(_ a: Int, by b: Int, then c: Int) -> Result<Int, MathError> {
    return divide(a, b)
}

func describe(_ result: Result<Int, MathError>) -> String {
    return ""
}

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable{

  const Failure() : super();

  @override
  List<Object> get props => [];
}

//General Failures
class ServerFailure extends Failure{}

class CacheFailure extends Failure{}
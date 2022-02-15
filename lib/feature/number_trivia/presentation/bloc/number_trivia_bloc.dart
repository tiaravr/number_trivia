import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:learn/core/error/failures.dart';
import 'package:learn/core/usecases/usecase.dart';
import 'package:learn/core/util/input_converter.dart';
import 'package:learn/feature/number_trivia/domain/entities/number_trivia.dart';
import 'package:learn/feature/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:learn/feature/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';

part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {required this.getConcreteNumberTrivia,
      required this.getRandomNumberTrivia,
      required this.inputConverter})
      : super(Empty()) {
    on<NumberTriviaEvent>((event, emit) {});
    on<GetTriviaForConcreteNumber>(
        (event, emit) => onGetTriviaForConcreteNumber(event, emit));
    on<GetTriviaForRandomNumber>(
        (event, emit) => onGetTriviaForRandomNumber(event, emit));
  }

  Future<void> onGetTriviaForConcreteNumber(
      GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emitter) async{
    emitter(Empty());
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);

    inputEither.fold((failure) {
      emitter(const Error(message: INVALID_INPUT_FAILURE_MESSAGE));
    }, (integer) async {
      emitter(Loading());
      final failureOrTrivia = await getConcreteNumberTrivia(Params(number: integer));
      _eitherLoadedOrErrorState(emitter, failureOrTrivia);
    });
  }

  Future<void> onGetTriviaForRandomNumber(
      GetTriviaForRandomNumber event, Emitter<NumberTriviaState> emitter) async{
    emitter(Empty());
    emitter(Loading());
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    _eitherLoadedOrErrorState(emitter, failureOrTrivia);

  }

  _eitherLoadedOrErrorState(Emitter<NumberTriviaState> emitter, Either<Failure, NumberTrivia> failureOrTrivia) async {
    emitter(failureOrTrivia.fold((l) => Error(message: mapFailureToMessage(l)), (r) => Loaded(trivia: r)));
  }

  String mapFailureToMessage(Failure failure){
    switch(failure.runtimeType ){
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:learn/core/error/failures.dart';
import 'package:learn/core/usecases/usecase.dart';
import 'package:learn/core/util/input_converter.dart';
import 'package:learn/feature/number_trivia/domain/entities/number_trivia.dart';
import 'package:learn/feature/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:learn/feature/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:learn/feature/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main(){
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);

  });
  
  test('initialState should be empty', () {
    //assert
    expect(bloc.state, equals(Empty()));
  });
  
  group('getTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    void setMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(tNumberString))
            .thenReturn(const Right(tNumberParsed));

    test('should call the InputConverter to validate and convert the string to an unsigned integer ', () async {
      //arrange
      setMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((realInvocation) async => const Right(tNumberTrivia));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(tNumberString));
      //assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test('should emit [Error] when the input is invalid', () async {
      //arrange
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));

      //assertLater
      final expected = [
        Empty(),
        const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));

      },
    );

    test('should get data from the concrete use case', () async {
      //arrange
      setMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
      .thenAnswer((_) async => const Right(tNumberTrivia));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      //assert
      verify(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
      },
    );

    test('should emit [loading, loaded] when data is gotten successfully ', () async {
      //arrange
      setMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test('should emit [loading, Error] when getting data fails ', () async {
      //arrange
      setMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test('should emit [loading, Error] with a proper message for the error when getting data fails ', () async {
      //arrange
      setMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });

  group('getTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test('should get data from the random use case', () async {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));
      //assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    },
    );

    test('should emit [loading, loaded] when data is gotten successfully ', () async {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForRandomNumber());
    },
    );

    test('should emit [loading, Error] when getting data fails ', () async {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForRandomNumber());
    },
    );

    test('should emit [loading, Error] with a proper message for the error when getting data fails ', () async {
      //arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForRandomNumber());
    },
    );
  });

}
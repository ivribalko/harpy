import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:harpy/components/authentication/bloc/authentication/authentication_event.dart';
import 'package:harpy/components/authentication/bloc/authentication/authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  /// The [twitterLogin] is used to log in and out with the native twitter sdk.
  TwitterLogin twitterLogin;

  /// The [twitterSession] contains information about the authenticated user.
  ///
  /// If the user is not authenticated, [twitterSession] will be `null`.
  TwitterSession twitterSession;

  /// Completes with either `true` or `false` whether the user has an active
  /// twitter session after initialization.
  Completer<bool> sessionInitialization = Completer<bool>();

  @override
  AuthenticationState get initialState => const UnauthenticatedState();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    yield* event.applyAsync(currentState: state, bloc: this);
  }
}

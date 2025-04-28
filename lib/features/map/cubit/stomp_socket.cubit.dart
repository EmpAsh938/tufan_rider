import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:tufan_rider/core/constants/api_constants.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket_state.dart';

class StompSocketCubit extends Cubit<StompSocketState> {
  StompSocketCubit() : super(StompSocketInitial()) {
    // connectSocket('', '48');
  }

  StompClient? _stompClient;

  void connectSocket(String token, String userId) {
    emit(StompSocketConnecting());

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${ApiConstants.socketUrl}/ride-websocket',
        onConnect: _onConnect,
        beforeConnect: () async {
          print('Connecting to STOMP...');
          await Future.delayed(Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) {
          print('WebSocket error: $error');
          emit(StompSocketError("WebSocket Error: $error"));
        },
        // stompConnectHeaders: {
        //   'Authorization': 'Sandip $token',
        // },
        // webSocketConnectHeaders: {
        //   'Authorization': 'Sandip $token',
        // },
        onDisconnect: (frame) {
          print("Disconnected");
          emit(StompSocketDisconnected());
        },
        onStompError: (frame) {
          print("STOMP error: ${frame.body}");
          emit(StompSocketError(frame.body ?? 'Unknown STOMP error'));
        },
        onDebugMessage: (msg) => print('🟡 DEBUG: $msg'),
        heartbeatIncoming: Duration(seconds: 0),
        heartbeatOutgoing: Duration(seconds: 0),
      ),
    );

    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('✅ Connected to STOMP');
    emit(StompSocketConnected());

    _stompClient?.subscribe(
      destination: '/topic/rides',
      callback: (frame) {
        final message = frame.body;
        print('📩 Received: $message');
        emit(StompSocketMessageReceived(message!));
      },
    );
  }

  void sendMessage(String destination, String body) {
    if (_stompClient?.connected ?? false) {
      _stompClient?.send(destination: destination, body: body);
    } else {
      print("Client not connected");
    }
  }

  void disconnect() {
    print('Stomp Disconnected');
    _stompClient?.deactivate();
    emit(StompSocketDisconnected());
  }
}

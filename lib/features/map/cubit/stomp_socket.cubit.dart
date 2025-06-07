import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:tufan_rider/core/constants/api_constants.dart';
import 'package:tufan_rider/core/model/ride_message_model.dart';
import 'package:tufan_rider/features/map/cubit/stomp_socket_state.dart';
import 'package:tufan_rider/features/map/models/bid_model.dart';
import 'package:tufan_rider/features/map/models/ride_request_model.dart';
import 'package:tufan_rider/features/map/models/rider_bargain_model.dart';
import 'package:tufan_rider/features/rider/map/models/ride_request_passenger_model.dart';

class StompSocketCubit extends Cubit<StompSocketState> {
  StompSocketCubit() : super(StompSocketInitial());

  StompClient? _stompClient;

  StompClient? get stompClient => _stompClient;

  void connectSocket() {
    emit(StompSocketConnecting());
    if (_stompClient != null) {
      _stompClient?.deactivate();
    }
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${ApiConstants.socketUrl}/ride-websocket',
        onConnect: (StompFrame frame) => _onConnect(frame),
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
        heartbeatIncoming: Duration(seconds: 10),
        heartbeatOutgoing: Duration(seconds: 10),
      ),
    );

    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('✅ Connected to STOMP');
    emit(StompSocketConnected());
    listenToMessage();
  }

  void listenToMessage() {
    if (_stompClient == null || !_stompClient!.connected) return;

    _stompClient!.subscribe(
      destination: '/topic/messages',
      callback: (StompFrame frame) {
        final message = frame.body;
        print('📩 Received Message Live: $message');
        if (message != null) {
          try {
            final decoded = jsonDecode(message);
            final rideRequest = RideMessageModel.fromJson(decoded);
            emit(RideMessageReceived(rideRequest));
          } catch (e) {
            print("❌ Failed to parse ride message: $e");
          }
        }
      },
    );
  }

  void sendMessage(RideMessageModel message) {
    if (_stompClient == null || !_stompClient!.connected) return;

    final body = jsonEncode(message.toJson());

    _stompClient!.send(
      destination: '/app/send/message',
      body: body,
    );

    print("MESSAGE SENT: $body");
  }

  void subscribeToRideBroadcasts() {
    if (_stompClient == null) return;
    _stompClient?.subscribe(
      destination: '/topic/eligible-riders',
      callback: (frame) {
        final message = frame.body;
        print('📩 Received: $message');
        if (message != null) {
          try {
            final decoded = jsonDecode(message);
            final rideRequest = RideRequestPassengerModel.fromJson(decoded);
            emit(RiderRequestMessageReceived(rideRequest));
            print("✅ EMITTED RiderRequestMessageReceived");
          } catch (e) {
            print("❌ Failed to parse ride message: $e");
          }
        }
      },
    );
  }

  void subscribeToRideReject(String rideRequestId) {
    if (_stompClient == null) return;
    _stompClient?.subscribe(
      destination: '/topic/ride-rejected/$rideRequestId',
      callback: (frame) {
        final message = frame.body;
        print('📩 Received RIde Rejected: $message');
        if (message != null) {
          try {
            final decoded = jsonDecode(message);
            final rideRequest = RideRequestModel.fromJson(decoded);
            emit(RideRejectedReceived(rideRequest));
          } catch (e) {
            print("❌ Failed to parse ride message: $e");
          }
        }
      },
    );
  }

  void subscribeToRequestDecline(String riderAppId) {
    if (_stompClient == null) return;
    _stompClient?.subscribe(
      destination: '/topic/passenger-rejected-rider/$riderAppId',
      callback: (frame) {
        final message = frame.body;
        print('📩 Received RIde Decline: $message');
        if (message != null) {
          try {
            final decoded = jsonDecode(message);
            final rideRequest = BidModel.fromJson(decoded);
            emit(RideDeclineReceived(rideRequest));
          } catch (e) {
            print("❌ Failed to parse ride message: $e");
          }
        }
      },
    );
  }

  void subscribeToRiderApprove(String rideRequestId) {
    if (_stompClient == null) return;
    _stompClient?.subscribe(
      destination: '/topic/passenger-approved/$rideRequestId',
      callback: (frame) {
        final message = frame.body;
        print('📩 Received Approve final: $message');
        if (message != null) {
          try {
            final decoded = jsonDecode(message);
            final rideRequest = RideRequestModel.fromJson(decoded);
            emit(RideApproveReceived(rideRequest));
          } catch (e) {
            print("❌ Failed to parse ride message: $e");
          }
        }
      },
    );
  }

  void subscribeToRideCompletion(String rideRequestId) {
    if (_stompClient == null) return;
    _stompClient?.subscribe(
      destination: '/topic/ride-completed/$rideRequestId',
      callback: (frame) {
        final message = frame.body;
        print('📩 Received Ride completion: $message');
        if (message != null) {
          try {
            final decoded = jsonDecode(message);
            final rideRequest = RideRequestModel.fromJson(decoded);
            emit(RideCompletionReceive(rideRequest));
          } catch (e) {
            print("❌ Failed to parse ride message: $e");
          }
        }
      },
    );
  }

  void subscribeToRideRiders(String rideRequestId) {
    if (_stompClient?.connected ?? false) {
      final destination = '/topic/rider-approvals/$rideRequestId';
      _stompClient?.subscribe(
        destination: destination,
        callback: (frame) {
          final message = frame.body;
          if (message != null) {
            final decoded = jsonDecode(message) as List<dynamic>;
            final rideProposals =
                decoded.map((e) => RiderBargainModel.fromJson(e)).toList();
            emit(PassengerMessageReceived(rideProposals));
            print('📩 Received for ride-riders/$rideRequestId: $message');
          }
          // Optionally emit another state here
        },
      );
    } else {
      print(
          "Client not connected. Cannot subscribe to ride-riders/$rideRequestId");
    }
  }

  void subscribeToPassengerPickup(String rideRequestId) {
    if (_stompClient?.connected ?? false) {
      final destination = '/topic/ride-pickup/$rideRequestId';
      _stompClient?.subscribe(
        destination: destination,
        callback: (frame) {
          final message = frame.body;
          if (message != null) {
            final decoded = jsonDecode(message);
            final rideRequest = RideRequestModel.fromJson(decoded);
            emit(PassengerPickupReceived(rideRequest));
          }
          // Optionally emit another state here
        },
      );
    } else {
      print(
          "Client not connected. Cannot subscribe to ride-riders/$rideRequestId");
    }
  }

  void clearRide(RideRequestModel rideRequest) {
    emit(RideRejectedReceived(rideRequest));
  }

  void disconnect() {
    print('Stomp Disconnected');
    _stompClient?.deactivate();
    emit(StompSocketDisconnected());
  }
}

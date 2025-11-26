import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'auth_service.dart';

/// Service for managing SignalR connection for real-time notifications
class SignalRService {
  final AuthService _authService;
  final String _baseUrl;
  
  HubConnection? _hubConnection;
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnecting = false;
  
  SignalRService(this._authService, this._baseUrl);
  
  /// Stream of incoming notifications
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  
  /// Whether the connection is active
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
  
  /// Start the SignalR connection
  Future<void> connect() async {
    if (_isConnecting || isConnected) return;
    
    final token = _authService.authState.token;
    if (token == null || token.isEmpty) {
      return; // Not authenticated
    }
    
    _isConnecting = true;
    
    try {
      final hubUrl = '$_baseUrl/hubs/notifications';
      
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              skipNegotiation: true,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();
      
      // Listen for new notifications
      _hubConnection!.on('NewNotification', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final notification = arguments[0];
          if (notification is Map<String, dynamic>) {
            _notificationController.add(notification);
          } else if (notification is Map) {
            _notificationController.add(Map<String, dynamic>.from(notification));
          }
        }
      });
      
      // Handle connection state changes
      _hubConnection!.onclose(({error}) {
        print('SignalR connection closed: $error');
      });
      
      _hubConnection!.onreconnecting(({error}) {
        print('SignalR reconnecting: $error');
      });
      
      _hubConnection!.onreconnected(({connectionId}) {
        print('SignalR reconnected: $connectionId');
      });
      
      await _hubConnection!.start();
      print('SignalR connected successfully');
    } catch (e) {
      print('SignalR connection error: $e');
    } finally {
      _isConnecting = false;
    }
  }
  
  /// Disconnect from SignalR
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
    }
  }
  
  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationController.close();
  }
}


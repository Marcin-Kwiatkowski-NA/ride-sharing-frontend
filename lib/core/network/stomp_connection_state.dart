/// Connection state of the STOMP WebSocket client.
enum StompConnectionState {
  /// Not connected. Initial state and state after deactivate/reset.
  disconnected,

  /// Connection attempt in progress.
  connecting,

  /// Connected and ready to send/receive.
  connected,

  /// Connection error (STOMP or WebSocket level).
  error,
}

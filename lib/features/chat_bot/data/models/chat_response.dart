class ChatResponse {
  final String status;
  final String message;
  final ChatResponseData data;

  ChatResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      status: json['status'],
      message: json['message'],
      data: ChatResponseData.fromJson(json['data']),
    );
  }
}

class ChatResponseData {
  final String response;
  final int facilitiesFound;

  ChatResponseData({
    required this.response,
    required this.facilitiesFound,
  });

  factory ChatResponseData.fromJson(Map<String, dynamic> json) {
    return ChatResponseData(
      response: json['response'],
      facilitiesFound: json['facilities_found'],
    );
  }
}

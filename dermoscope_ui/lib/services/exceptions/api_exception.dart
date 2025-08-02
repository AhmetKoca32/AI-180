class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status Code: $statusCode)' : ''}';

  factory ApiException.fromJson(Map<String, dynamic> json) {
    return ApiException(
      json['message'] ?? 'An unknown error occurred',
      statusCode: json['statusCode'],
      data: json,
    );
  }
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized access'}) : super(message, statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = 'Requested resource not found'}) : super(message, statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({String message = 'Internal server error'}) : super(message, statusCode: 500);
}

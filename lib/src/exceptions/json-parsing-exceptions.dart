class MalformedJsonException implements Exception {

  late String message;

  MalformedJsonException({String? json}){
    message = 'Ops! The JSON received from the outer world seems to be corrupted.'; 
    if (json != null){
      message += ' Here is a copy of it:  $json';
    }

  }

  @override
  String toString() {
    return message;
  }

}
class Request {
  final String id;
  final String vehicle;
  final String driver;
  final String source = '';
  final String destination = '';
  final String fare = '120';
  final String time = '1:20';
  final String distance = 'nice';

  Request({required this.id, required this.vehicle, required this.driver});
}
